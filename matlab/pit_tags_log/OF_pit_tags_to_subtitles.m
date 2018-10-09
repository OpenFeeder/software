function OF_pit_tags_to_subtitles(csvFile, outputFile, videoBeginTime, videoEndTime, subtitleMaxDuration, separator)


% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 11, 2018 - First release
%          1.1.0 -  Oct. 09, 2018 - Add videoEndTime parameter
%                                 - Add subtitleMaxDuration parameter
%                                 - Refactor code in one file only
%

% Check number of input arguments
narginchk(0,6)

% If no input argument, select files via dialog
if nargin==0
    
    [filename, pathname] = uigetfile('*.CSV', 'Get CSV file');
    
    if ~filename
        return
    end
    
    csvFile = fullfile(pathname, filename);
    
end

% Test if files exist
if exist(csvFile, 'file')~=2
    error('File "%s" not found', csvFile)
end

log = OF_read_pit_tag_log(csvFile);

ev = zeros(size(log.date,1),4);
[~, ~, ~, ev(:,1), ev(:,2), ev(:,3)] = datevec(log.date);
ev(:,4) = 1:size(log.date,1);

X = log.pittags;

if nargin<3 || isempty(videoBeginTime)
    % If no video begin time => set to the first subtitle time
    videoBeginTime = ev(1,1:3);
end

if nargin<4 || isempty(videoEndTime)
    % If no video end time => set to the last subtitle time
    videoEndTime = ev(end,1:3);
end

if nargin<5
    subtitleMaxDuration = 3;
elseif subtitleMaxDuration<=0
    error('Subtitle max duration must be greater than 0 second');
elseif subtitleMaxDuration>=60
    error('Subtitle max duration must be lesser than 60 seconds');
end

if nargin<6
    separator = ',';
end

if nargin<2
    
    [filename, pathname] = uiputfile({'*.srt','SubRip';'*.sub','SubViewer';'*.usf','Universal Subtitle Format'}, 'Get txt file');

    if ~filename
        return
    end

    outputFile = fullfile(pathname, filename);
    
end

% Get output file extension to select appropriate subtitles format (SRT, USF, SUB…)
[~, ~, ext] = fileparts(outputFile);
ext = lower(ext);

if ~ismember(ext, {'.srt', '.sub', '.usf'})
    error('Subtitle format %s not supported', ext);
end

formatIsSrt = false;
formatIsSub = false;
formatIsUsf = false;
if strcmp(ext, '.srt')
    formatIsSrt = true;
elseif strcmp(ext, '.sub')
    formatIsSub = true;
else
    formatIsUsf = true;
end

% Open subtitle file in write mode
fid = fopen(outputFile, 'wt');
if fid==-1
    msg = ferror(fid);
    error(msg)
end

% Write header if required by the format
if formatIsSub
    writeSubHeader(fid);
elseif formatIsUsf
    writeUsfHeader(fid);
end

% Set variables specific to format
if formatIsSrt
    sectionNumber = 1;
elseif formatIsUsf
    stop_or_duration = 1;
end

% Absolute begin time of video (2000 01 01 HH:MM:SS) in days
absoluteVideoBeginTime = datenum([2000 1 1 videoBeginTime]);
% Absolute end time of video (2000 01 01 HH:MM:SS) in days
absoluteVideoEndTime = datenum([2000 1 1 videoEndTime]);

% Add a dummy row of data at the end of the event array => easier for the next algorithm
ev(end+1,:) = nan(1,4);

if formatIsSrt
    sectionNumber = 1;
elseif formatIsUsf
    stop_or_duration = 1;
end

subtitle = [];

for n = 1:size(ev,1)-1
    
    if isempty(subtitle)
        subtitle = strrep(X{ev(n,4)}, 'OF_', '');
    else
        subtitle = [subtitle separator ' ' strrep(X{ev(n,4)}, 'OF_', '')];
    end
    
    % Next event is a the same thime than the current one
    % => keep concatenating events strings
    if all(ev(n,1:3)==ev(n+1,1:3))
        continue
    end
    
    % Absolute time of the current subtitle (YYYY MM DD HH:MM:SS) in days
    absoluteCurrentEventTime = datenum([2000 1 1 ev(n,1:3)]);
    
    if (absoluteCurrentEventTime - absoluteVideoBeginTime)<0
        % Current subtitle begins before video start => skip current subtitle
        subtitle = [];
        continue
    end
    
    if (absoluteCurrentEventTime - absoluteVideoEndTime)>=0
        % Current subtitle begins after video end => skip remaning subtitles
        break
    end
    
    % Current subtitle time relative to video begin time in days
    relativeCurrentEventTime = absoluteCurrentEventTime - absoluteVideoBeginTime;
    % Current subtitle time relative to video begin time in vector form
    vectorCurrentEventTime = datevec(relativeCurrentEventTime);
    
    % Absolute time of the next subtitle (YYYY MM DD HH:MM:SS) in days
    absoluteNextEventTime = datenum([2000 1 1 ev(n+1,1:3)]);
    % Next subtitle time relative to video begin time in days
    relativNextEventTime = absoluteNextEventTime - absoluteVideoBeginTime;
    % Next subtitle time relative to video begin time in vector form
    vectorNextEventTime = datevec(relativNextEventTime);
    
    % Subtitle begin time in vector form
    subtitleBeginTime = vectorCurrentEventTime;
    
    % Duration of the current subtitle in days
    duration_in_days = absoluteNextEventTime - absoluteCurrentEventTime;
    
    if duration_in_days > (subtitleMaxDuration / 86400);
        duration_in_days = subtitleMaxDuration / 86400;
        subtitleEndTime = datevec(relativeCurrentEventTime+duration_in_days);
    else
        % Subtitle end time in vector form
        subtitleEndTime = vectorNextEventTime;
    end
    
    if formatIsSrt
        fprintf(fid, '%d\n%02d:%02d:%02d,000 --> %02d:%02d:%02d,000\n%s\n\n', sectionNumber, subtitleBeginTime(4:end), subtitleEndTime(4:end), subtitle);
        sectionNumber = sectionNumber+1;
    elseif formatIsSub
        fprintf(fid, '%02d:%02d:%02d.00,%02d:%02d:%02d.00\n%s\n\n',subtitleBeginTime(4:end), subtitleEndTime(4:end), subtitle);
    else % formatIsUsf
        if stop_or_duration
            % Duration of the current subtitle in vector form
            duration_vector = datevec(duration_in_days);
            fprintf(fid, '    <subtitle start="%02d:%02d:%02d.000" duration="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n',subtitleBeginTime(4:end), duration_vector(4:end), subtitle);
        else
            fprintf(fid, '    <subtitle start="%02d:%02d:%02d.000" stop="%02d:%02d:%02d.000">\n      <text>%s</text>\n    </subtitle>\n',subtitleBeginTime(4:end), subtitleEndTime(4:end), subtitle);
        end
    end
    
    subtitle = [];
    
end

fclose(fid);

function writeSubHeader(fid)

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

function writeUsfHeader(fid)

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