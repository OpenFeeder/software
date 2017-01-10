function Key = ini_getkey(Section, Index, Filename)
% ini_getkey Enumerate keys.
%   ini_getkey reads the name of an indexed key inside a given section.
%
%   Input arguments:
%       Section:  the name of the section.
%       Index:    the one-based index of the key to return.
%       Filename: the name of the INI file.
%
%   Output argument:
%       Key: key name (char class).
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni 
%
%   See also: ini_getsection.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%

narginchk(3, 3);

if ~isa(Index,'int32')
    Index = int32(Index);
end

if Index==0
    error('First index must be 1 (one-based value)');    
end

if exist(Filename, 'file')~=2
    error('File not found');
end

Key = ini_getkeyc(Section, Index-1, Filename);