function ini = ini_setformats(ini)


%
%   See also ini_filetostruct, ini_structtofile.
%

narginchk(1, 1);

for n = 1:numel(ini.sections)
    
    for m = 1:numel(ini.keys{n})
        
        switch class(ini.values{n}{m})
            
            case {'double' 'single'}
                ini.formats{n}{m} = 'f';
                
            case {'int8' 'uint8' 'int16' 'uint16' 'int32' 'uint32' 'int64' 'uint64'}
                ini.formats{n}{m} = 'l';
                
            case 'char'
                ini.formats{n}{m} = 's';
                
            case 'logical'
                ini.formats{n}{m} = 'b';
                
            otherwise
                warning('%s class not supported (ini.sections: %s, ini.keys: %s)', class(ini.values{n}{m}), ini.sections{n}, ini.keys{n}{m})
                
        end
        
    end
    
end
