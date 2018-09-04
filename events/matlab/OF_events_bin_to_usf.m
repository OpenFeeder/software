function OF_events_bin_to_usf(binFile, eventFile, usfFile, videoBeginTime, separator)

stop_or_duration = 1;

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
    
    usfFile = fullfile(pathname, filename);
    
end

if isempty(videoBeginTime)
    videoBeginTime = ev(1,1:3);
end

dn_videoBeginTime = datenum([2000 1 1 videoBeginTime]);

fid = fopen(usfFile, 'wt');
fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid, '<USFSubtitles version="1.0">\n');
fprintf(fid, '  <metadata>\n');
fprintf(fid, '    <title>OF subtitles</title>\n');
fprintf(fid, '    <author>\n');
fprintf(fid, '      <name>Jerome Briot</name>\n');
fprintf(fid, '      <email>jbtechlab@gmail.com</email>\n');
fprintf(fid, '    </author>\n');
fprintf(fid, '    <language code="eng">English</language>\n');
fprintf(fid, '    <date>%s</date>\n', datestr(now, 'yyyy-mm-dd'));
fprintf(fid, '    <comment></comment>\n');
fprintf(fid, '  </metadata>\n');

fprintf(fid, '  <subtitles>\n');
fprintf(fid, '    <language code="eng">English</language>\n');

dn_beginSubtitle = datenum([2000 1 1 ev(1,1:3)])-dn_videoBeginTime;

beginSubtitle = datevec(dn_beginSubtitle);

subtitle = strrep(X{ev(1,4)}, 'OF_', '');

for n = 2:size(ev,1)-1
    
    if all(ev(n,1:3)==ev(n-1,1:3))
        
        subtitle = [subtitle separator ' ' strrep(X{ev(n,4)}, 'OF_', '')];
        
    else
        
        dn_endSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        endSubtitle = datevec(dn_endSubtitle);
        
        dn_duration = dn_endSubtitle-dn_beginSubtitle;
        duration = datevec(dn_duration);
        
        if stop_or_duration
            fprintf(fid, '    <subtitle start="%02d:%02d:%02d.000" duration="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n',beginSubtitle(4:end), duration(4:end), subtitle);
        else
            fprintf(fid, '    <subtitle start="%02d:%02d:%02d.000" stop="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n',beginSubtitle(4:end), endSubtitle(4:end), subtitle);
        end
          
        dn_beginSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        
        beginSubtitle = datevec(dn_beginSubtitle);
        subtitle = strrep(X{ev(n,4)}, 'OF_', '');
    end
end

fprintf(fid, '  </subtitles>\n');
fprintf(fid, '</USFSubtitles>\n');
fclose(fid);