function ini = ini_demos

narginchk(0, 0);

Filename = 'ini_demos.ini';

if exist(Filename, 'file')==2
    delete(Filename);
end

ini.sections = {'String' 'Integers' 'Floats' 'Booleans'};

ini.keys{1} = {'A' 'B' 'C'};
ini.keys{2} = {'A' 'B' 'C'};
ini.keys{3} = {'A' 'B' 'C'};
ini.keys{4} = {'A' 'B'};

ini.values{1} = {'Hello' 'Z' ';'};
ini.values{2} = {int32(-10) int32(0) int32(10)};
ini.values{3} = {single(-3.1416) single(0) single(3.1416)};
ini.values{4} = {true false};

ini = ini_setformats(ini);

fprintf('Struture to write:\n')
disp(ini);
fprintf('Write structure to INI file\n\n');
ini_structtofile(ini, Filename)
fprintf('Read structure from INI file\n\n');
ini = ini_filetostruct(Filename, ini.formats);
fprintf('Struture read:\n')
disp(ini)