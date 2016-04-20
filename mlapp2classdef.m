function mlapp2classdef(pathToMLapp)
% MLAPP2CLASSDEF converts an App Designer GUI's class definition, packaged 
% as a *.mlapp file, from XML to a standalone *.m class definition.
%
% MLAPP2CLASSDEF() prompts the user to select a single *.mlapp file for
% processing
%
% MLAPP2CLASSDEF(pathToMLapp) processes the files specified by the user.
% pathToMLapp can be a string for a single file or a cell array of strings
% for multiple files. Filepaths should be absolute.
%
% The class definition for an App Designer GUI is embedded in an XML file
% located in a subfolder of the packaged *.mlapp file, which can be
% accessed like a *.zip file. MLAPP2CLASSDEF strips the XML header & footer
% and saves the class definition to a *.m file located in the same path as
% the *.mlapp file.
%
% MLAPP2CLASSDEF assumes that the targeted *.mlapp file is a GUI created by
% MATLAB's App Designer. Other packaged apps are not explicitly supported.

if verLessThan('matlab', '7.9')
    error('mlapp2classdef:UnsupportedMATLABver', ...
          'MATLAB releases prior to R2009b are not supported' ...
          );
end

% Choose appropriate behavior based on number of inputs
if nargin == 0
    % No input selected, prompt user to select a MATLAB app to process
    % Currently limited to single file selection
    [filename, pathname] = uigetfile('*.mlapp', 'Select MATLAB App');
    if ~filename
        error('mlapp2classdef:NoFileSelected', 'No file selected, exiting...');
    else
        [~, appname, ext] = fileparts(filename);
    end
else
    % Wrap validateattributes for more verbose error handling
    % validateattributes won't catch if the cell array contains
    % non-strings, but the subsequent fileparts call will error if these
    % are encountered
    pathToMLapp = validateattributes_wrapped(pathToMLapp, {'char', 'cell'}, {'vector'});
    if iscell(pathToMLapp)
        [pathname, appname, ext] = cellfun(@fileparts, pathToMLapp, 'UniformOutput', false);
    else
        [pathname, appname, ext] = fileparts(pathToMLapp);
    end
    filename = strcat(appname, ext);
end

if iscell(pathToMLapp)
    for indF = 1:numel(pathToMLapp)
        checkfile(pathname{indF}, filename{indF}, ext{indF});
        processMlapp(pathname{indF}, filename{indF}, appname{indF});
        % TODO: Add a counter of successfully converted files.
    end
else
    checkfile(pathname, filename, ext);
    processMlapp(pathname, filename, appname);
end

end

function processMlapp(pathname, filename, appname)
% Unzip user selected MATLAB App, which are packaged in a renamed zip file
tmpdir = fullfile(pathname, sprintf('%s_tmp', appname));
unzip(fullfile(pathname, filename), tmpdir);

% Read in XML file
% Since there isn't really much XML-ness to this XML file, no need to
% utilize a full-fledged parser. MATLAB's won't open it anyway...
xmlfile = fullfile(tmpdir, 'matlab', 'document.xml');

% Get a count of lines in the xml file to preallocate the cell array in
% memory. If no count can be made, revert to growing the array in memory
nlines = countlines(xmlfile);
if ~isempty(nlines)
    A = cell(nlines, 1);
else
    A = {};
end

% Read XML file line-by-line into a cell array to make later export simpler
fID = fopen(xmlfile, 'r');
ii = 1;
while ~feof(fID)
    A{ii} = fgetl(fID);
    ii = ii + 1;
end
fclose(fID);

% Strip out header & footer, then save to a *.m file
% Limit search to first & last lines of file, currently all that is
% modified by MATLAB to wrap the class definition in XML
A([1,end]) = regexprep(A([1,end]), '(^.*)\[(?=classdef)|(?<=end)(\].*$)', '');

fID = fopen(fullfile(pathname, sprintf('%s.m', appname)), 'w');
for ii = 1:length(A)
    fprintf(fID, '%s\n', A{ii});
end
fclose(fID);

rmdir(tmpdir, 's');

disp(['Successfully unpacked ' filename '!']);
end


function A = validateattributes_wrapped(A, classes, attributes)
% Wrap validateattributes with try-catch block for more verbose error
% handling
try 
    validateattributes(A, classes, attributes)
catch err
    switch err.identifier
        case 'MATLAB:invalidType'
            newerr.identifier = 'mlapp2classdef:InvalidInputType';
            newerr.message = sprintf('Invalid input type: %s\nExpected: char, cell', class(A));
            newerr.cause = err.cause;
            newerr.stack = err.stack;
            error(newerr);
        case 'MATLAB:expectedVector'
            % Warn and reshape
            sizestr = sprintf('%u,', size(A));
            sizestr = sizestr(1:end-1);  % Strip trailing comma
            warning('mlapp2classdef:InvalidInputShape', ...
                    'Input cell array must be a vector of cells. Size of input array is: [%s]. Reshaping...', ...
                    sizestr ...
                    );
            A = reshape(A, 1, []);
        otherwise
            rethrow err
    end
end
end


function checkfile(pathname, filename, ext)
% Check for existence of file
if exist(fullfile(pathname, filename), 'file')
    % Check for correct file type
    if ~strcmp(ext, '.mlapp')
        error('mlapp2classdef:InvalidFileType', ...
            '''%s'' is not a *.mlapp file', fullfile(pathname, filename) ...
            );
    end
else
    error('mlapp2classdef:FileNotFound', ...
        '''%s'' does not exist', fullfile(pathname, filename) ...
        );
end
end


function nlines = countlines(filepath)
% Count the number of lines present in the specified file.
% filepath should be an absolute path
fID = fopen(filepath, 'rt');

nlines = 0;
while ~feof(fID)
    nlines = nlines + sum(fread(fID, 16384, 'char') == char(10));
end

fclose(fID);
end