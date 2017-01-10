function s = ini_putl(Section, Key, Value, Filename)
% ini_putl Store a numeric value.
%   ini_putl stores the numeric value that in the given section and at the
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
%   See also: ini_putf, ini_puts.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%

narginchk(4, 4);

if ~isa(Value,'integer') && ~isa(Value, 'logical')
    error('...');
end

if Value>intmax('int32') || Value<intmin('int32')
    warning('%s class value truncated to int32 class', class(Value));
end

Value = int32(Value);

if ~ischar(Section)
    error('Section name must be a string');
end

if ~ischar(Key)
    error('Key name must be a string');
end

s = ini_putlc(Section, Key, Value, Filename);