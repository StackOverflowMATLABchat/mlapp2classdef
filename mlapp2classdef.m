function mlapp2classdef()
% Unzip user selected MATLAB App, which are packaged in a renamed zip file
[filename, pathname] = uigetfile('*.mlapp', 'Select MATLAB App');
[~, appname] = fileparts(filename);
tmpdir = fullfile(pathname, sprintf('%s_tmp', appname));
unzip(fullfile(pathname, filename), tmpdir);

% Read in XML file
% Since there isn't really much XML-ness to this XML file, no need to
% utilize a full-fledged parser. MATLAB's won't open it anyway...
xmlfile = fullfile(tmpdir, 'matlab', 'document.xml');
nlines = countlines(xmlfile);
fID = fopen(xmlfile, 'r');

if ~isempty(nlines)
    A = cell(nlines, 1);
else
    A = {};
end

ii = 1;
while ~feof(fID)
    A{ii} = fgetl(fID);
    ii = ii + 1;
end
fclose(fID);

% Strip out header & footer, then save to a *.m file
A = regexprep(A, '(^.*)(?=classdef)|(?<=end)(.*$)', '');

fID = fopen(fullfile(pathname, sprintf('%s.m', appname)), 'w');
for ii = 1:length(A)
    fprintf(fID, '%s\n', A{ii});
end
fclose(fID);

rmdir(tmpdir, 's');
end

function nlines = countlines(filepath)
% Utilize OS-specific routines to count the number of lines present in the
% specified file.
% filepath should be an absolute path
% Returns an empty array if OS is not supported

myOS = upper(computer);  % Should already be uppercase, force it to be sure

switch myOS
    case {'PCWIN', 'PCWIN64'}
        % Windows systems
        disp('Creating temporary Perl script in current working directory')
        temp_fID = fopen('countlines.pl','w');
        line1 = 'while (<>){};';
        line2 = 'print $.,"\n"';
        fprintf(temp_fID,'%s\n%s',line1,line2);
        fclose(temp_fID);
        nlines = str2double(perl('countlines.pl',filepath));
        delete('countlines.pl');
    case 'GLNXA64'
        % Linux systems
        warning('mlapp2classdef:UnsupportedOS', ...
              'OS currently unsupported: ''%s''', myOS ...
              );
        nlines = [];
    case 'MACI64'
        % Mac OS systems
        warning('mlapp2classdef:UnsupportedOS', ...
              'OS currently unsupported: ''%s''', myOS ...
              );
        nlines = [];
    otherwise
        % Unknown/unsupported OS
        warning('mlapp2classdef:UnsupportedOS', ...
              'OS currently unsupported: ''%s''', myOS ...
              );
        nlines = [];
end
end