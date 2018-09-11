function Sections = ini_getallsections(Filename)
% getIniSections List all sections in a INI file
%
%
%
% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%

narginchk(1, 1);

if exist(Filename, 'file')~=2
    error('File not found');
end

sectionIndexMax = 30;

n = 1;
while 1
    Sections{n} = ini_getsection(n, Filename);
    if isempty(Sections{n})
        Sections(n) = [];
        break;
    end
    n = n+1;    
    
    if n>sectionIndexMax
        warning('Maximum number of section reach.');
        break;
    end
end