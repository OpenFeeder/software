function OF_subtitles_to_usf(ev, X, usfFile, videoBeginTime, separator)
% Convert binary events file to Universal Subtitle Format (USF).
%
%   OF_subtitles_to_usf(EV, X, USFFILE) converts subtitles in EV and X to 
%   the SubRip subtitle format and store them in the file USFFILE.
%
%   OF_subtitles_to_usf(___, ___, ___, VIDEOBEGINTIME) uses VIDEOBEGINTIME
%   to synchronize the begin time of the subtitles. VIDEOBEGINTIME is a Nx3
%   numercial array that contains time in the form [HH MM SS]. It can be
%   passed as an empty array if no synchronization needed.
%
%   OF_subtitles_to_usf(___, ___, ___, ___, SEPARATOR) uses SEPARATOR as a
%   string separator in case of multiple events at the same time.
%
%   See also OF_subtitles_to_sub, OF_subtitles_to_srt
%
%   More information on the Openfeeder project at:
%   https://openfeeder.github.io/
%

% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 04, 2018 - First release
%

stop_or_duration = 1;

% Check number of input arguments
narginchk(2,5)

if nargin<3
    
    [filename, pathname] = uiputfile('*.usf', 'Get usf file');
    
    if ~filename
        return
    end
    
    usfFile = fullfile(pathname, filename);
    
end

if nargin<4
    videoBeginTime = [];
end

if nargin<5
    separator = ',';
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

        if dn_beginSubtitle>=0 && dn_endSubtitle>0
            if stop_or_duration
                fprintf(fid, '    <subtitle start="%02d:%02d:%02d.000" duration="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n',beginSubtitle(4:end), duration(4:end), subtitle);
            else
                fprintf(fid, '    <subtitle start="%02d:%02d:%02d.000" stop="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n',beginSubtitle(4:end), endSubtitle(4:end), subtitle);
            end
        elseif dn_beginSubtitle<0 && dn_endSubtitle>0
            if stop_or_duration
                fprintf(fid, '    <subtitle start="00:00:00.000" duration="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n', duration(4:end), subtitle);
            else
                fprintf(fid, '    <subtitle start="00:00:00.000" stop="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n', endSubtitle(4:end), subtitle);
            end
        end
        
        dn_beginSubtitle = datenum([2000 1 1 ev(n,1:3)])-dn_videoBeginTime;
        
        beginSubtitle = datevec(dn_beginSubtitle);
        subtitle = strrep(X{ev(n,4)}, 'OF_', '');
    end
end

fprintf(fid, '  </subtitles>\n</USFSubtitles>\n');
fclose(fid);