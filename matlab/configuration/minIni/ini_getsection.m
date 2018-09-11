function Section = ini_getsection(Index, Filename)
% ini_getsection Enumerate sections.
%   ini_getsection reads the name of an indexed section.
%
%   Input arguments:
%       Index:    the one-based index of the section to return.
%       Filename: the name of the INI file.
%
%   Output argument:
%       Section: section name (char class).
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni 
%
%   See also: ini_getkey.
%

% Author  : Jerome Briot
% Contact : dutmatlab at yahoo dot fr
%           http://briot-jerome.developpez.com/
%           fr.mathworks.com/matlabcentral/profile/authors/492531-jerome-briot
% Version : 0.1 - 18 Nov 2016
%

narginchk(2, 2);

if ~isa(Index,'int32')
    Index = int32(Index);
end

if Index==0
    error('First index must be 1 (one-based value)');    
end

if exist(Filename, 'file')~=2
    error('File not found');
end

Section = ini_getsectionc(Index-1, Filename);