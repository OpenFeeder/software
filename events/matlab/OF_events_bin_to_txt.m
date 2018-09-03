function OF_events_bin_to_txt(binFile, eventFile, textFile)

narginchk(0,3)

if nargin==0
    
    [filename, pathname] = uigetfile('*.BIN', 'Get BIN file');
    
    if ~filename
        return
    end
    
    binFile = fullfile(pathname, filename);
    
    [filename, pathname] = uigetfile('OF_events.txt', 'Get events file');
    
    if ~filename
        return
    end
    
    eventFile = fullfile(pathname, filename);
    
end

if exist(binFile, 'file')~=2
    error('File "%s" not found', binFile)
end

[ev, X] = OF_events_read_bin(binFile, eventFile);

if nargin<3
    
    [filename, pathname] = uiputfile('*.txt', 'Get txt file');

    if ~filename
        return
    end

    textFile = fullfile(pathname, filename);
    
end

fid = fopen(textFile, 'wt');
for n = 1:size(ev,1)
    fprintf(fid, '%02d:%02d:%02d %s\n', ev(n,1), ev(n,2), ev(n,3), X{ev(n,4)});
end
fclose(fid);