function v = ini_gets(Section, Key, DefValue, Filename)
% ini_gets Read a string
%   ini_gets reads the textual value that is found in the given section 
%   and at the given key, or DefValue if the key is not present 
%   in the given section.
%
%   Input arguments:
%       Section:  the name of the section.
%       Key:      the name of the key.
%       DefValue: the default value, which will be returned if the key is not 
%                 present in the INI file.
%       Filename: the name of the INI file.
%
%   Output argument:
%       v: string (char class).
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni 
%
%   See also: ini_getf, ini_getl, ini_getbool.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%
narginchk(4, 4);

if ~ischar(Section)
   error('Section name must be a string'); 
end

if ~ischar(Key)
   error('Key name must be a string'); 
end

if exist(Filename, 'file')~=2
    error('File not found');
end

v = ini_getsc(Section, Key, DefValue, Filename);