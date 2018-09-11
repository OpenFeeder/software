function v = ini_getbool(Section, Key, DefValue, Filename)
% ini_getbool Read a "truth" flag.
%   ini_getbool returns the true/false flag as interpreted from the value 
%   read at the given key, or DefValue if the key is not present in the given 
%   section (or if it cannot be interpreted to either a "true" or a "false" 
%   flag).
%
%   Input arguments:
%       Section:  the name of the section.
%       Key:      the name of the key.
%       DefValue: the default value, which will be returned if the key is not 
%                 present in the INI file.
%       Filename: the name of the INI file.
%
%   Output argument:
%       v: 0 or 1 (int32 class).
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni 
%
%   See also: ini_getf, ini_getl, ini_gets.
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

if DefValue~=0 && DefValue~=1
   error('Default value muste be true/false or 1/0') ;
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

v = ini_getboolc(Section, Key, DefValue, Filename);