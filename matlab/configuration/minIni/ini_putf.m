function s = ini_putf(Section, Key, Value, Filename)
% ini_putf Store a rational number
%   ini_putf stores the numeric value that in the given section and at the
%   given key. The numeric value is written as a rational number, with a
%   "whole part" and a fractional part.
%
%   Input arguments:
%       Section:  the name of the section.
%       Key:      the name of the key.
%       Value:    the value to write at the key and the section.
%       Filename: the name of the INI file.
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni
%
%   Output argument:
%       s: 1/true on success, 0/false on failure (int32 class).
%
%   See also: ini_putl, ini_puts.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%

narginchk(4, 4);

if ~isa(Value,'float')
    error('...');
end

if Value<-realmax('single') || Value>realmax('single')
    warning('Double precision truncated to single precision');
end

Value = single(Value);

if ~ischar(Section)
    error('Section name must be a string');
end

if ~ischar(Key)
    error('Key name must be a string');
end

s = ini_putfc(Section, Key, Value, Filename);