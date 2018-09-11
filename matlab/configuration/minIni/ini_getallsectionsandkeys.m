function [Sections, Keys] = ini_getallsectionsandkeys(Filename)
% getIniSectionsAndKeys List all sections and keys in a INI file

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

sectionIndexMax = 2000;
keyIndexMax = 2000;

m = 1;
while 1
    
    Sections{m} = ini_getsection(m, Filename);
    if isempty(Sections{m})
        Sections(m) = [];
        break;
    end
    
    n = 1;
    while 1
        
        Keys{m}{n} = ini_getkey(Sections{m}, n, Filename);
        if isempty(Keys{m}{n})
            Keys{m}(n) = [];
            break;
        end
        n = n+1;
        
        if n>keyIndexMax
            warning('Maximum number of key reach.');
            break;
        end
        
    end
    
    m = m+1;
    
    if m>sectionIndexMax
        warning('Maximum number of section reach.');
        break;
    end
    
end