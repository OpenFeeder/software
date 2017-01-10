function ini = ini_filetostruct(Filename, Format, DefValue)
% ini_filetostruct Read a INI file and store data into a structure.
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni
%
%   See also ini_structtofile.
%

narginchk(1, 3);

if exist(Filename, 'file')~=2
    error('File %s not found', Filename);
end

if nargin==2 && ~iscell(Format)
    error('Template argument must be a cell array');
end

if nargin<3
    DefValue = {false 'X' int32(-1) single(-1)};
else
    if ~iscell(DefValue) || numel(DefValue)~=4
        error('...');
    end
    if ~isa(DefValue{1}, 'logical') && DefValue{1}~=0 && DefValue{1}~=1
        error('...');
    end
    if ~isa(DefValue{2}, 'char')
        error('...');
    end
    if ~isa(DefValue{3}, 'numeric')
        error('...');
    else
        DefValue{3} = int32(DefValue{3});
    end
    if ~isa(DefValue{4}, 'float')
        error('...');
    else
        DefValue{3} = single(DefValue{3});
    end
end

[ini.sections, ini.keys] = ini_getallsectionsandkeys(Filename);

if nargin == 1
    
    for m = 1:numel(ini.sections)
        for n = 1:numel(ini.keys{m})
            ini.values{m}{n} = ini_gets(ini.sections{m}, ini.keys{m}{n}, DefValue{2}, Filename);
            ini.formats{m}{n} = 's';
        end
    end
    
else
    
    if size(ini.keys,1)~=size(Format,1) || size(ini.keys,2)~=size(Format,2)
        error('...');
    end
    
    for m = 1:numel(ini.sections)
        for n = 1:numel(ini.keys{m})
 
            switch Format{m}{n}
                
                case 'b'
                    ini.values{m}{n} = ini_getbool(ini.sections{m}, ini.keys{m}{n}, DefValue{1}, Filename);
                case 's'
                    ini.values{m}{n} = ini_gets(ini.sections{m}, ini.keys{m}{n}, DefValue{2}, Filename);
                case 'l'
                    ini.values{m}{n} = ini_getl(ini.sections{m}, ini.keys{m}{n}, DefValue{3}, Filename);
                case 'f'
                    ini.values{m}{n} = ini_getf(ini.sections{m}, ini.keys{m}{n},DefValue{4}, Filename);
                    
                otherwise
                    error('...');
                    
            end
            
            ini.formats{m}{n} = Format{m}{n};
            
        end
        
    end
end