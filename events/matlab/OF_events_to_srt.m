function OF_events_to_srt(binFile, eventsFile, srtFile, videoBeginTime, separator)
% Convert binary events file to SubRip subtitle format.
%
%   OF_events_to_srt(BINFILE, EVENTSFILE, SRTFILE) reads the events from
%   the files BINFILE and EVENTSFILE, converts them to the SubRip subtitle
%   format and store them in the file SRTFILE.
%
%   OF_events_to_srt(___, ___, ___, VIDEOBEGINTIME) uses VIDEOBEGINTIME to
%   synchronize the begin time of the subtitles. VIDEOBEGINTIME is a Nx3
%   numercial array that contains time in the form [HH MM SS]. It can be
%   passed as an empty array if no synchronization needed.
%
%   OF_events_to_srt(___, ___, ___, ___, SEPARATOR) uses SEPARATOR as a
%   string separator in case of multiple events at the same time.
%
%   See also OF_events_read, OF_events_to_sub, OF_events_to_txt, OF_events_to_usf
%
%   More information on the Openfeeder project at:
%   https://openfeeder.github.io/
%

% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 04, 2018 - First release
%

% Check number of input arguments
narginchk(0,5)

% If no input argument, select files via dialog
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
    
    eventsFile = fullfile(pathname, filename);
    
end

if nargin<4
    videoBeginTime = [];
end

if nargin<5
    separator = ',';
end

if exist(binFile, 'file')~=2
    error('File "%s" not found', binFile)
end
if exist(eventsFile, 'file')~=2
    error('File "%s" not found', eventsFile)
end

[ev, X] = OF_events_read(binFile, eventsFile);

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