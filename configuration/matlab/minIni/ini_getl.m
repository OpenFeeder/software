function v = ini_getl(Section, Key, DefValue, Filename)
% ini_getl Read a numeric value.
%   ini_getl returns the integer value that is found in the given section 
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
%       v: integer (int32 class).
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni 
%
%   See also: ini_getf, ini_getbool, ini_gets.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%

narginchk(4, 4);

if ~isa(DefValue,'int32')
    DefValue = int32(DefValue);
end

if ~ischar(Section)
   error('Section name must be a string'); 
end

if ~ischar(Key)
   error('Key name must be a string'); 
end

if exist(Filename, 'file')~=2
    error('File not found');
end

v = ini_getlc(Section, Key, DefValue, Filename);