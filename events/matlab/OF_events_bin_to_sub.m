function OF_events_bin_to_sub(binFile, eventFile, subFile, videoBeginTime, separator)

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
    
    [filename, pathname] = uiputfile('*.usf', 'Get usf file');
    
    if ~filename
        return
    end
    
    subFile = fullfile(pathname, filename);
    
end

if isempty(videoBeginTime)
    videoBeginTime = ev(1,1:3);
end

dn_videoBeginTime = datenum([2000 1 1 videoBeginTime]);

fid = fopen(subFile, 'wt');
fprintf(fid, '[INFORMATION]\n');
fprintf(fid, '[TITLE] Title of film.\n');
fprintf(fid, '[AUTHOR] Author of film.\n');
fprintf(fid, '[SOURCE] Arbitrary text\n');
fprintf(fid, '[FILEPATH] Arbitrary text\n');
fprintf(fid, '[DELAY] 0\n');
fprintf(fid, '[COMMENT] Arbitrary text\n');
fprintf(fid, '[END INFORMATION]\n');
fprintf(fid, '[SUBTITLE]\n');
fprintf(fid, '[COLF]&HFFFFFF,[SIZE]12,[FONT]Times New Roman\n');

dn_beginSubtitle = datenum([2000 1 1 ev(1,1:3)])-dn_videoBeginTime;

beginSubtitle = datevec(dn_beginSubtitle);

subtitle = strrep(X{ev(1,4)}, 'OF_', '');

for n = 2:size(ev,1)-1
    
    if all(ev(n,1:3)==ev(n-1,1:3))
        
        subtitle = [subtitle separator ' ' strrep(X{ev(n,4)}, 'OF_', '')];
        
    else
        
        dn_endSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        endSubtitle = datevec(dn_endSubtitle);

        fprintf(fid, '%02d:%02d:%02d.00,%02d:%02d:%02d.00\n%s\n\n',beginSubtitle(4:end), endSubtitle(4:end), subtitle);

        dn_beginSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        
        beginSubtitle = datevec(dn_beginSubtitle);
        subtitle = strrep(X{ev(n,4)}, 'OF_', '');
    end
end


fclose(fid);