function mlapp2classdef()
% MLAPP2CLASSDEF() prompts the user to select an App Designer GUI, packaged
% as an *.mlapp file, and converts the GUI's class definition from an XML 
% file to a standalone *.m file.
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

% Unzip user selected MATLAB App, which are packaged in a renamed zip file
[filename, pathname] = uigetfile('*.mlapp', 'Select MATLAB App');
[~, appname] = fileparts(filename);
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
A = regexprep(A, '(^.*)(?=classdef)|(?<=end)(\].*$)', '');

fID = fopen(fullfile(pathname, sprintf('%s.m', appname)), 'w');
for ii = 1:length(A)
    fprintf(fID, '%s\n', A{ii});
end
fclose(fID);

rmdir(tmpdir, 's');
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