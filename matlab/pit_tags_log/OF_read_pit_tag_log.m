function log = OF_read_pit_tag_log(logFile)

% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 11, 2018 - First release
%

if nargin==0
    [filename, pathname] = uigetfile('*.CSV', 'Get CSV file');
    
    if ~filename
        return
    end
    
    logFile = fullfile(pathname, filename);
    
end

% Test if files exist
if exist(logFile, 'file')~=2
    error('File "%s" not found', logFile)
end

% Read data stored in CSV file
fid = fopen(logFile, 'r');
X = textscan(fid, '%s%s%s%s%d%s%d%d%d%d%d%d%d', 'delimiter', ',');
fclose(fid);

log.date = datenum(strcat(X{1}, {' '}, X{2}), 'dd/mm/yy HH:MM:SS');
log.site = X{3};
log.device = X{4};
log.scenario = X{5};
log.pittags = X{6};
log.is_denied = X{7};
log.is_reward_taken = X{8};
log.led_red = X{9};
log.led_green = X{10};
log.led_blue = X{11};
log.door_status = X{12};
log.landing_time = X{13};