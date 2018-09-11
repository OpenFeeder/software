function OF_subtitles_to_sub(ev, X, subFile, videoBeginTime, separator)
% Convert binary events file to SubViewer subtitle format.
%
%   OF_subtitles_to_sub(EV, X, SRTFILE) converts subtitles in EV and X to 
%   the SubRip subtitle format and store them in the file SRTFILE.
%
%   OF_subtitles_to_sub(___, ___, ___, VIDEOBEGINTIME) uses VIDEOBEGINTIME
%   to synchronize the begin time of the subtitles. VIDEOBEGINTIME is a Nx3
%   numercial array that contains time in the form [HH MM SS]. It can be
%   passed as an empty array if no synchronization needed.
%
%   OF_subtitles_to_sub(___, ___, ___, ___, SEPARATOR) uses SEPARATOR as a
%   string separator in case of multiple events at the same time.
%
%   See also OF_subtitles_to_usf, OF_subtitles_to_srt
%
%   More information on the Openfeeder project at:
%   https://openfeeder.github.io/
%

% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 04, 2018 - First release
%

% Check number of input arguments
narginchk(2,5)

if nargin<3
    
    [filename, pathname] = uiputfile('*.usf', 'Get usf file');
    
    if ~filename
        return
    end
    
    subFile = fullfile(pathname, filename);
    
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