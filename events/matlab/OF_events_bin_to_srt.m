function OF_events_bin_to_srt(binFile, eventFile, srtFile, videoBeginTime, separator)

narginchk(0,5)

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
    
    videoBeginTime = [];
    separator = ',';
    
end

if exist(binFile, 'file')~=2
    error('File "%s" not found', binFile)
end

[ev, X] = OF_events_read_bin(binFile, eventFile);

if nargin<3
    
    [filename, pathname] = uiputfile('*.srt', 'Get srt file');
    
    if ~filename
        return
    end
    
    srtFile = fullfile(pathname, filename);
    
end

if isempty(videoBeginTime)
    videoBeginTime = ev(1,1:3);    
end

dn_videoBeginTime = datenum([2000 1 1 videoBeginTime]);

fid = fopen(srtFile, 'wt');

sectionNumber = 1;

dn_beginSubtitle = datenum([2000 1 1 ev(1,1:3)])-dn_videoBeginTime;

beginSubtitle = datevec(dn_beginSubtitle);

subtitle = strrep(X{ev(1,4)}, 'OF_', '');


for n = 2:size(ev,1)-1
    
    if all(ev(n,1:3)==ev(n-1,1:3))
        
        subtitle = [subtitle separator ' ' strrep(X{ev(n,4)}, 'OF_', '')];
        
    else
        
        dn_endSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        endSubtitle = datevec(dn_endSubtitle);
        
        fprintf(fid, '%d\n%02d:%02d:%02d,000 --> %02d:%02d:%02d,000\n%s\n\n', sectionNumber, beginSubtitle(4:end), endSubtitle(4:end), subtitle);
        
        dn_beginSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        
        beginSubtitle = datevec(dn_beginSubtitle);
        
        sectionNumber = sectionNumber+1;
        subtitle = strrep(X{ev(n,4)}, 'OF_', '');
    end
end

fclose(fid);