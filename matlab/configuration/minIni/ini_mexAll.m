function ini_mexAll

narginchk(0, 0);

mininiURL = 'https://github.com/compuphase/minIni';

srcFiles = dir(fullfile('./src', '*.c'));

if numel(srcFiles)==0
    error('No source file found');
end

minIniPath = './minIni-master';
if exist(minIniPath, 'file')~=7
    error('minIni source file not found.\nDownload zip file from %s\nCopy the "minIni-master" directory in the current directory', mininiURL)
end

BUFFER_SIZE = 250;

tmpOutputDir = tempname;

for n = 1:numel(srcFiles)
    mex(...        
        '-silent', ...
        '-outdir', tmpOutputDir, ...
        fullfile('./src', srcFiles(n).name), ...
        fullfile(minIniPath, 'dev', 'minIni.c'), ...
        ['-I' fullfile(minIniPath, 'dev')], ...
        sprintf('-DBUFFER_SIZE=%d', BUFFER_SIZE))
end

delete(['./*' mexext]);
movefile(fullfile(tmpOutputDir, ['*.' mexext]), '.')

rmdir(tmpOutputDir)