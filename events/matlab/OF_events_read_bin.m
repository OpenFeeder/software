function [ev, X] = OF_events_read_bin(binFile, eventFile)

narginchk(0,2)

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

fid = fopen(binFile, 'r');
ev = fread(fid, [4,inf]).';
fclose(fid);

fid = fopen(eventFile, 'r');
X = textscan(fid, '%s', 'delimiter', '%s');
fclose(fid);

X = X{1};

if nargout==0
    
    clc

    for n = 1:size(ev,1)
        fprintf('%02d:%02d:%02d %s\n', ev(n,1), ev(n,2), ev(n,3), X{ev(n,4)})
    end
    
end
