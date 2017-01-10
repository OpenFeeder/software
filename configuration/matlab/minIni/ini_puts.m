function s = ini_puts(Section, Key, Value, Filename)
% ini_puts Store a string.
%   ini_puts stores the text parameter that in the given section and at the 
%   given key.
%
%   Input arguments:
%       Section:  the name of the section.
%       Key:      the name of the key.
%       Value:    the value to write at the key and the section.
%       Filename: the name of the INI file.
%
%   Output argument:
%       s: 1/true on success, 0/false on failure (int32 class).
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni 
%
%   See also: ini_putf, ini_putl.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%
narginchk(4, 4);

if ~ischar(Value)
   error('Value must be a string'); 
end

if ~ischar(Section)
   error('Section name must be a string'); 
end

if ~ischar(Key)
   error('Key name must be a string'); 
end

s = ini_putsc(Section, Key, Value, Filename);