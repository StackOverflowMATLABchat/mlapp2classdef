function mlapp2classdef()
% Unzip user selected MATLAB App, which are packaged in a renamed zip file
[filename, pathname] = uigetfile('*.mlapp', 'Select MATLAB App');
[~, appname] = fileparts(filename);
tmpdir = fullfile(pathname, sprintf('%s_tmp', appname));
unzip(fullfile(pathname, filename), tmpdir);

% Read in XML file
% Since there isn't really much XML-ness to this XML file, no need to
% utilize a full-fledged parser. MATLAB's won't open it anyway...
fID = fopen(fullfile(tmpdir, 'matlab', 'document.xml'), 'r');  % TODO: Add recursive file search, make sure no other filenames are possible
A = {};  % TODO: Implement better preallocation
ii = 1;
while ~feof(fID)
    A{ii} = fgetl(fID);
    ii = ii + 1;
end
fclose(fID);

% Strip out header & footer, then save to a *.m file
A = regexprep(A, '(^.*)(?=classdef)', '');
A = regexprep(A, '(?<=end)(.*$)', '');

fID = fopen(fullfile(pathname, sprintf('%s.m', appname)), 'w');
for ii = 1:length(A)
    fprintf(fID, '%s\n', A{ii});
end
fclose(fID);

rmdir(tmpdir, 's');
end