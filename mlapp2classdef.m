function mlapp2classdef(pathToMLapp)
% MLAPP2CLASSDEF an App Designer GUI, packaged as an *.mlapp file, and
% converts the GUI's class definition from an XML file to a standalone *.m 
% file.
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
    [~, appname] = fileparts(filename);
else
    % TODO: Refactor to more verbose error generation
    validateattributes(pathToMLapp, {'char', 'cell'}, {'vector'});
    if iscell(pathToMLapp)
        [pathname, appname, ext] = cellfun(@fileparts, pathToMLapp, 'UniformOutput', false);
    else
        [pathname, appname, ext] = fileparts(pathToMLapp);
    end
    filename = strcat(appname, ext);
end

if iscell(pathToMLapp)
    for indF = 1:numel(pathToMLapp)
        % TODO: Check for existence of file
        processMlapp(pathname{indF}, filename{indF}, appname{indF});
        % TODO: Add a counter of successfully converted files.
    end
else
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