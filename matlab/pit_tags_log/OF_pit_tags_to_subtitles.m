function OF_pit_tags_to_subtitles(csvFile, outputFile, videoBeginTime, separator)


% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 11, 2018 - First release
%

% Check number of input arguments
narginchk(0,4)

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

if nargin<3
    videoBeginTime = [];
end

if nargin<4
    separator = ',';
end

if nargin<2
    
    [filename, pathname] = uiputfile({'*.srt','SubRip';'*.sub','SubViewer';'*.usf','Universal Subtitle Format'}, 'Get txt file');

    if ~filename
        return
    end

    outputFile = fullfile(pathname, filename);
    
end

[~, ~, ext] = fileparts(outputFile);

switch lower(ext)
    
    case '.srt'
        OF_subtitles_to_srt(ev, X, outputFile, videoBeginTime, separator)
    case '.sub'
        OF_subtitles_to_sub(ev, X, outputFile, videoBeginTime, separator)
    case '.usf'
        OF_subtitles_to_usf(ev, X, outputFile, videoBeginTime, separator)
    otherwise
        error('Subtitle format %s not supported', ext);
        
end
