function ini_structtofile(ini, pathname, Filename)
% ini_filetostruct Write data from a structure into a INI file.
%
%   Code is based on the minIni library by CompuPhase
%       http://www.compuphase.com/minini.htm
%       https://github.com/compuphase/minIni
%
%   See also ini_filetostruct.
%

narginchk(3, 3);

if exist(fullfile(pathname, Filename), 'file')==2
    delete(fullfile(pathname, Filename));
end

[~, fname, ext] = fileparts(Filename);

currentPath = pwd;

cd(tempdir)

for n = 1:numel(ini.sections)
    
    if isempty(ini.sections{n})
        continue
    end
    
    filename = strrep(Filename, ext, sprintf('-%02d%s', n, ext));
    
    for m = 1:numel(ini.keys{n})
        
        switch class(ini.values{n}{m})
            
            case {'double' 'single'}
                ini_putf(ini.sections{n}, ini.keys{n}{m}, ini.values{n}{m}, filename);
                
            case {'int8' 'uint8' 'int16' 'uint16' 'int32' 'uint32' 'int64' 'uint64'}
                ini_putl(ini.sections{n}, ini.keys{n}{m}, ini.values{n}{m}, filename);
                
            case 'char'
                ini_puts(ini.sections{n}, ini.keys{n}{m}, ini.values{n}{m}, filename);
                
            case 'logical'
                ini_putl(ini.sections{n}, ini.keys{n}{m}, ini.values{n}{m}, filename);
                
            otherwise
                warning('%s class not supported (ini.sections: %s, ini.keys: %s)', class(ini.values{n}{m}), ini.sections{n}, ini.keys{n}{m})
                
        end
        
    end
    
end

cd(currentPath)

archstr = computer('arch');

if strcmp(archstr(1:3), 'win')
    cmd = sprintf('copy /b %s-*%s %s%s', fullfile(tempdir,fname), ext, fullfile(pathname,fname), ext);
    
else
    cmd = sprintf('cat %s-*%s > %s%s', fullfile(tempdir,fname), ext, fullfile(pathname,fname), ext);
end

[~, ~] = system(cmd);

delete(sprintf('%s-*%s', fullfile(tempdir,fname), ext))