function OF_config_gui

% Author: Jerome Briot - https://github.com/JeromeBriot

addpath(fullfile(pwd, 'minIni'))

version.major = 1;
version.minor = 0;
version.patch = 0;
about.author = 'Jerome Briot';
about.contact = 'jbtechlab@gmail.com';

%% Default values
default.ServoClosingSpeed = 4;
default.ServoOpeningSpeed = 10;
default.ServoClosePosition = 600;
default.ServoOpenPosition = 1400;
default.ServoMsStep = 20;
default.ServoMaxOffset = 150;

default.WakeUpMinute = 30;
default.WakeUpHour = 6;
default.SleepMinute = 0;
default.SleepHour = 19;

default.RGBColorA = [0 35 0];
default.RGBColorB = [35 0 0];

%% Load sites list
if exist('sites.txt', 'file')==2
    fid = fopen('sites.txt', 'r');
    sites = textscan(fid, '%s%*s%*s', 'delimiter', ',');
    fclose(fid);
else
    sites{1} = '';
end

%% UI
figSize = [800 600]*1.25;

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
if isempty(fig)
    fig = figure(1);
    
    set(fig, ...
        'units', 'pixels', ...
        'position', [0 0 figSize], ...
        'resize', 'off', ...
        'menubar', 'none', ...
        'numbertitle', 'off', ...
        'name', sprintf('OpenFeeder - Configuration tool - v%d.%d.%d', version.major, version.minor, version.patch), ...
        'tag', 'fig_OF_config', ...
        'visible', 'off');
    
else
    clf(fig)
    figure(fig)
end

set(fig, 'visible', 'on');

uiSketchfactor = figSize(1)/240; % 240/180 mm => 800x600 px

uiSiteGroupPos       =   [5 170 50 5 2 5];
uiWakeUpGroupPos     =   [5 159 50 5 2 5];
uiSleepGroupPos      =   [5 148 50 5 2 5];
uiScenarioGroupPos   =   [5 137 35 5 2 5];
uiLogGroupPos        =   [5 126 50 5 2 5];
uiPitTagGroupPos     =   [5 100 90 5 2 95];
uiLedsGroupPos       =   [50 170 50 5 2 5];
uiDoorGroupPos       =   [95 170 50 5 2 5];
uiServoGroupPos      =   [95 132 50 5 2 5];
uiDoorHabitGroupPos  =   [95 92 50 5 2 5];
uiRewardGroupPos     =   [95 81 48 5 2 5];
uiSecurityGroupPos   =   [95 56 48 5 2 5];
uiTimeoutsGroupPos   =   [95 41 48 5 2 5];
uiPunishmentGroupPos =   [95 26 50 5 2 5];
uiCheckGroupPos      =   [95 9 50 5 2 5];
uiPreviewGroupPos    =   [145+5*ismac 170 50 5 2 148];
uiButtonGroupPos     =   [145+5*ismac 15 50 5 2 5];

%% Site ID
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiSiteGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Site ID', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiSiteGroupPos(1)+uiSiteGroupPos(5);
yPos = uiSiteGroupPos(2)-uiSiteGroupPos(6);
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15+5*ismac 5]*uiSketchfactor, ...
    'tag', 'uiSiteName', ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+15+5*ismac;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15+5*ismac 5]*uiSketchfactor, ...
    'tag', 'uiSiteNum', ...
    'string', cellstr(num2str((1:40).', '%02d')),...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

%% Wake up time
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiWakeUpGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Wake up time', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiWakeUpGroupPos(1)+uiWakeUpGroupPos(5);
yPos = uiWakeUpGroupPos(2)-uiWakeUpGroupPos(6);
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiWakeUpHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 7, ...
    'callback', @syncLedDoorTime);
xPos = xPos+12+8*ismac;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiWakeUpMinute', ...
    'string', cellstr(num2str((0:5:55).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @syncLedDoorTime);
xPos = xPos+10;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':', ...
    'visible', 'off');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'edit', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiWakeUpTimeSecond', ...
    'string', '00', ...
    'fontweight', 'bold', ...
    'visible', 'off', ...
    'callback', @syncLedDoorTime);

%% Sleep time
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiSleepGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Sleep time', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiSleepGroupPos(1)+uiSleepGroupPos(5);
yPos = uiSleepGroupPos(2)-uiSleepGroupPos(6);
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiSleepHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 24, ...
    'callback', @syncLedDoorTime);
xPos = xPos+12+8*ismac;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiSleepMinute', ...
    'string', cellstr(num2str((0:5:55).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @syncLedDoorTime);
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':', ...
    'visible', 'off');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiSleepTimeSecond', ...
    'string', '00', ...
    'fontweight', 'bold', ...
    'visible', 'off', ...
    'callback', @syncLedDoorTime);

%% Scenario
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiScenarioGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Scenario', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiScenarioGroupPos(1)+uiScenarioGroupPos(5);
yPos = uiScenarioGroupPos(2)-uiScenarioGroupPos(6);
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos uiScenarioGroupPos(3) 5]*uiSketchfactor, ...
    'tag', 'uiScenario', ...
    'string', {'0 - None' ; '1 - OpenBar' ; '2 - DoorHabituation' ; '3 - Go-NoGo' ; '4 - LongTermSpatialMemory' ; '5 - WorkingSpatialMemory' ; '6 - ColorAssociativeLearning' ; '7 - RiskAversion' ; '8 - PatchProbability'},...    'fontweight', 'bold', ...
    'callback', @setScenario, ...
    'fontweight', 'bold');

%% Log File
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiLogGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Logs', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');

xPos = uiLogGroupPos(1)+uiLogGroupPos(5);
yPos = uiLogGroupPos(2)-uiLogGroupPos(6);

uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiLogFileSeparator', ...
    'string', {',' ; ';'},...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

xPos = uiLogGroupPos(1)+uiLogGroupPos(5)+13;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Temp.', ...
    'value', 0, ...
    'tag', 'uiLogTemperature', ...
    'callback', @previewIniFile);

xPos = xPos+13;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Calibration', ...
    'value', 0, ...
    'tag', 'uiLogCalibration', ...
    'callback', @previewIniFile);

xPos = uiLogGroupPos(1)+uiLogGroupPos(5);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Birds', ...
    'value', 1, ...
    'tag', 'uiLogBirds', ...
    'callback', @previewIniFile);
xPos = xPos+13;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'UDID', ...
    'value', 0, ...
    'tag', 'uiLogUDID', ...
    'callback', @previewIniFile);
xPos = xPos+13;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Events', ...
    'value', 0, ...
    'tag', 'uiLogEvents', ...
    'callback', @previewIniFile);
xPos = uiLogGroupPos(1)+uiLogGroupPos(5);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Errors', ...
    'value', 0, ...
    'tag', 'uiLogErrors', ...
    'callback', @previewIniFile);
xPos = xPos+13;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Battery', ...
    'value', 0, ...
    'tag', 'uiLogBattery', ...
    'callback', @previewIniFile);
xPos = xPos+13;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'RFID', ...
    'value', 0, ...
    'tag', 'uiLogRFID', ...
    'callback', @previewIniFile);

%% Pit Tags
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', (uiPitTagGroupPos(1:4)+[0 3.5 0 0])*uiSketchfactor, ...
    'string', 'PIT tags', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');

xPos = uiPitTagGroupPos(1);
yPos = uiPitTagGroupPos(2);
uicontrol(fig, ...
    'style', 'radio', ...
    'units', 'pixels', ...
    'position', [xPos yPos 40 5]*uiSketchfactor, ...
    'string', '', ...
    'tag', 'uiRadioPitTags1', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold', ...
    'value', 0);
xPos = xPos + 2;
yPos = yPos-uiPitTagGroupPos(6)/2+5;
uicontrol(fig, ...
    'style', 'list', ...
    'units', 'pixels', ...
    'position', [xPos yPos (uiPitTagGroupPos(3)-25)/2 uiPitTagGroupPos(6)/2-5]*uiSketchfactor, ...
    'tag', 'uiPitTags1', ...
    'fontweight', 'bold', ...
    'value', 0, ...
    'max', 2,...
    'fontname', 'monospaced');
xPos = xPos - 2;
yPos = uiPitTagGroupPos(2)-uiPitTagGroupPos(6)/2;
uicontrol(fig, ...
    'style', 'radio', ...
    'units', 'pixels', ...
    'position', [xPos yPos 40 5]*uiSketchfactor, ...
    'string', '', ...
    'tag', 'uiRadioPitTags3', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = xPos + 2;
yPos = uiPitTagGroupPos(2)-uiPitTagGroupPos(6);
uicontrol(fig, ...
    'style', 'list', ...
    'units', 'pixels', ...
    'position', [xPos yPos (uiPitTagGroupPos(3)-25)/2 uiPitTagGroupPos(6)/2]*uiSketchfactor, ...
    'tag', 'uiPitTags3', ...
    'fontweight', 'bold', ...
    'value', 0, ...
    'max', 2,...
    'fontname', 'monospaced');
xPos = xPos+(uiPitTagGroupPos(3)-25)/2+2.5;
yPos = uiPitTagGroupPos(2)-40;
uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 5]*uiSketchfactor, ...
    'tag', 'uiPitTagsButtonLoad', ...
    'string', 'Load', ...
    'enable', 'off', ...
    'callback', @importPITtag, ...
    'fontweight', 'bold');
xPos = uiPitTagGroupPos(1)+(uiPitTagGroupPos(3)-25)/2+5+10+5;
yPos = uiPitTagGroupPos(2);
uicontrol(fig, ...
    'style', 'radio', ...
    'units', 'pixels', ...
    'position', [xPos yPos 40 5]*uiSketchfactor, ...
    'string', '', ...
    'tag', 'uiRadioPitTags2', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold', ...
    'value', 0);
xPos = uiPitTagGroupPos(1)+(uiPitTagGroupPos(3)-25)/2+5+10+5+2;
yPos = yPos-uiPitTagGroupPos(6)/2+5;
uicontrol(fig, ...
    'style', 'list', ...
    'units', 'pixels', ...
    'position', [xPos yPos (uiPitTagGroupPos(3)-25)/2 uiPitTagGroupPos(6)/2-5]*uiSketchfactor, ...
    'tag', 'uiPitTags2', ...
    'fontweight', 'bold', ...
    'value', 0, ...
    'max', 2,...
    'fontname', 'monospaced');
xPos = uiPitTagGroupPos(1)+(uiPitTagGroupPos(3)-25)/2+5+10+5;
yPos = uiPitTagGroupPos(2)-uiPitTagGroupPos(6)/2;
uicontrol(fig, ...
    'style', 'radio', ...
    'units', 'pixels', ...
    'position', [xPos yPos 40 5]*uiSketchfactor, ...
    'string', '', ...
    'tag', 'uiRadioPitTags4', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiPitTagGroupPos(1)+(uiPitTagGroupPos(3)-25)/2+5+10+5+2;
yPos = uiPitTagGroupPos(2)-uiPitTagGroupPos(6);
uicontrol(fig, ...
    'style', 'list', ...
    'units', 'pixels', ...
    'position', [xPos yPos (uiPitTagGroupPos(3)-25)/2 uiPitTagGroupPos(6)/2]*uiSketchfactor, ...
    'tag', 'uiPitTags4', ...
    'fontweight', 'bold', ...
    'value', 0, ...
    'max', 2,...
    'fontname', 'monospaced');

%% Attractive LEDs color
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiLedsGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Attractive LEDs', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
yPos = uiLedsGroupPos(2)-uiLedsGroupPos(6);
uicontrol(fig, ...
    'style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 5]*uiSketchfactor, ...
    'string', 'Set color A', ...
    'callback', @setAttractLEDsColor, ...
    'tag', 'uiAttractLedsButtonA');
yPos = yPos-5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsValueA', ...
    'string', '[0 0 0]');
xPos = xPos+30;
uicontrol(fig, ...
    'style', 'frame', ...
    'units', 'pixels', ...
    'position', [xPos yPos+3 8 8]*uiSketchfactor, ...
    'tag', 'uiAttractLedsFrameA', ...
    'backgroundcolor', [0 0 0]);
xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'pushbutton', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 5]*uiSketchfactor, ...
    'string', 'Set color B', ...
    'callback', @setAttractLEDsColor, ...
    'tag', 'uiAttractLedsButtonB');
yPos = yPos-5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsValueB', ...
    'string', '[0 0 0]');
xPos = xPos+30;
uicontrol(fig, ...
    'style', 'frame', ...
    'units', 'pixels', ...
    'position', [xPos yPos+3 8 8]*uiSketchfactor, ...
    'tag', 'uiAttractLedsFrameB', ...
    'backgroundcolor', [0 0 0]);
xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
yPos = yPos-5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 5]*uiSketchfactor, ...
    'string', 'Pattern', ...
    'hor', 'left');
xPos = xPos+2;
yPos = yPos-4;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'All', ...
    'value', 0, ...
    'tag', 'uiAttractLeds_pattern_all', ...
    'callback', {@attractiveledpattern, 'a'}, ...
    'userdata', 'leds_pattern');
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos-1 15 5]*uiSketchfactor, ...
    'string', '% on', ...
    'hor', 'left');
xPos = xPos+8;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiAttractLeds_pattern_all_percent', ...
    'string', strtrim(cellstr(num2str((0:5:100).'))), ...
    'fontweight', 'bold');

xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
xPos = xPos+2;
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'L/R', ...
    'value', 0, ...
    'tag', 'uiAttractLeds_pattern_lr', ...
    'callback', {@attractiveledpattern, 'lr'}, ...
    'userdata', 'leds_pattern');
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'T/B', ...
    'value', 0, ...
    'tag', 'uiAttractLeds_pattern_tb', ...
    'callback', {@attractiveledpattern, 'tb'}, ...
    'userdata', 'leds_pattern');
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'One', ...
    'value', 0, ...
    'tag', 'uiAttractLeds_pattern_one', ...
    'callback', {@attractiveledpattern, 'o'}, ...
    'userdata', 'leds_pattern');

xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
yPos = yPos-8;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 17 5]*uiSketchfactor, ...
    'string', 'Alt. delay (s)', ...
    'hor', 'left');
xPos = xPos+18;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsAltDelay', ...
    'string', strtrim(cellstr(num2str(([1:10 20:10:30 60]).'))), ... % strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
yPos = yPos-8;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'string', 'On', ...
    'hor', 'left');
xPos = xPos+10;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsOnHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12+8*ismac;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsOnMinute', ...
    'string', cellstr(num2str((0:5:55).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':', ...
    'visible', 'off');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsWakeupTimeSecond', ...
    'string', '00', ...
    'fontweight', 'bold', ...
    'visible', 'off', ...
    'callback', @previewIniFile);
xPos = uiLedsGroupPos(1)+uiLedsGroupPos(5);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'string', 'Off', ...
    'hor', 'left');
xPos = xPos+10;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsOffHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12+8*ismac;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsOffMinute', ...
    'string', cellstr(num2str((0:5:55).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':', ...
    'visible', 'off');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiAttractLedsSleepTimeSecond', ...
    'string', '00', ...
    'fontweight', 'bold', ...
    'visible', 'off');

%% Door
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiDoorGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Door', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiDoorGroupPos(1)+uiDoorGroupPos(5);
yPos = uiDoorGroupPos(2)-uiDoorGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'string', 'Open',...
    'hor', 'left');
xPos = xPos+10;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorOpenHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12+8*ismac;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorOpenMinute', ...
    'string', cellstr(num2str((0:5:55).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':', ...
    'visible', 'off');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiDoorOpenSecond', ...
    'string', '00', ...
    'fontweight', 'bold', ...
    'visible', 'off', ...
    'callback', @previewIniFile);
xPos = uiDoorGroupPos(1)+uiDoorGroupPos(5);
yPos = yPos-8;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'string', 'Close', ...
    'hor', 'left');
xPos = xPos+10;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorCloseHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12+8*ismac;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorCloseMinute', ...
    'string', cellstr(num2str((0:5:55).', '%02d')), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = xPos+12;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 5 5]*uiSketchfactor, ...
    'string', ':', ...
    'visible', 'off');
xPos = xPos+5;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 10 5]*uiSketchfactor, ...
    'tag', 'uiDoorCloseSecond', ...
    'string', '00', ...
    'fontweight', 'bold', ...
    'visible', 'off', ...
    'callback', @previewIniFile);

xPos = uiDoorGroupPos(1)+uiDoorGroupPos(5);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Remain open', ...
    'tag', 'uiDoorremain_open', ...
    'callback', @previewIniFile);

xPos = uiDoorGroupPos(1)+uiDoorGroupPos(5);
yPos = yPos-6;

uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Open delay (s)', ...
    'hor', 'left');
xPos = xPos+30;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorDelaysOpen', ...
    'string', strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = uiDoorGroupPos(1)+uiDoorGroupPos(5);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Close delay (s)', ...
    'hor', 'left');
xPos = xPos+30;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorDelaysClose', ...
    'string', strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

%% Servomotor
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiServoGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Servomotor', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiServoGroupPos(1)+uiServoGroupPos(5);
yPos = uiServoGroupPos(2)-uiServoGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Close position', ...
    'hor', 'left');
xPos = xPos + 25;
uicontrol(fig, ...
    'style', 'edit', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', default.ServoClosePosition, ...
    'tag', 'uiServoMinPos', ...
    'fontweight', 'bold', ...
    'callback', @updateServoMoveTime);
xPos = xPos - 25;
yPos = yPos - uiServoGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Open position', ...
    'hor', 'left');
xPos = xPos + 25;
uicontrol(fig, ...
    'style', 'edit', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', default.ServoOpenPosition, ...
    'tag', 'uiServoMaxPos', ...
    'fontweight', 'bold', ...
    'callback', @updateServoMoveTime);
xPos = xPos - 25;
yPos = yPos - uiServoGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Close speed factor', ...
    'hor', 'left')
xPos = xPos + 25;
uicontrol(fig, ...
    'style', 'edit', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', default.ServoClosingSpeed, ...
    'tag', 'uiServoClosingSpeed', ...
    'fontweight', 'bold', ...
    'callback', @updateServoMoveTime);
xPos = xPos - 25;
yPos = yPos - uiServoGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Open speed factor', ...
    'hor', 'left');
xPos = xPos + 25;
uicontrol(fig, ...
    'style', 'edit', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', default.ServoOpeningSpeed, ...
    'tag', 'uiServoOpeningSpeed', ...
    'fontweight', 'bold', ...
    'callback', @updateServoMoveTime);
xPos = xPos - 25;
yPos = yPos - uiServoGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Max offset position', ...
    'hor', 'left');
xPos = xPos + 25;
uicontrol(fig, ...
    'style', 'edit', ...
    'units', 'pixels', ...
    'position', [xPos yPos 15 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', default.ServoMaxOffset, ...
    'tag', 'uiServoMaxPosOffset', ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
yPos = yPos - uiServoGroupPos(6);
xPos = xPos - 25;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 50 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Closing time (s)', ...
    'hor', 'left');
xPos = xPos + 20;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'fontweight', 'bold', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', sprintf('%.3f', (default.ServoOpenPosition-default.ServoClosePosition)/default.ServoClosingSpeed*default.ServoMsStep/1000), ...
    'tag', 'uiServoClosingTime', ...
    'hor', 'center');
xPos = xPos - 20;
yPos = yPos - uiServoGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 50 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', 'Opening time (s)', ...
    'hor', 'left');
xPos = xPos + 20;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'fontweight', 'bold', ...
    'position', [xPos yPos 25 uiServoGroupPos(6)]*uiSketchfactor, ...
    'string', sprintf('%.3f', (default.ServoOpenPosition-default.ServoClosePosition)/default.ServoOpeningSpeed*default.ServoMsStep/1000), ...
    'tag', 'uiServoOpeningTime', ...
    'hor', 'center');

%% Door habituation
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiDoorHabitGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Door habituation', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiDoorHabitGroupPos(1)+uiDoorHabitGroupPos(5);
yPos = uiDoorHabitGroupPos(2)-uiDoorHabitGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Open (%)', ...
    'hor', 'left');
xPos = xPos+20;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiDoorHabitPercent', ...
    'string', strtrim(cellstr(num2str(([0 25:25:75 90 100]).'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

%% Reward
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiRewardGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Reward', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiRewardGroupPos(1)+uiRewardGroupPos(5);
yPos = uiRewardGroupPos(2)-uiRewardGroupPos(6);
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Enable', ...
    'value', 0, ...
    'tag', 'uiRewardEnable', ...
    'callback', @previewIniFile);
yPos = yPos-6;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Timeout (s)', ...
    'hor', 'left');
xPos = xPos+20;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiRewardTimeout', ...
    'string', strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
    'value', 1, ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

xPos = xPos-20;
yPos = yPos-8;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Probability (%)', ...
    'hor', 'left');
xPos = xPos+20;

prob = [100:-10:0 75 66 33 25];
% prob = [1:-0.1:0 0.75 0.666 0.333 0.25];
prob = sort(prob, 2, 'descend');

uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiRewardProbability', ...
    'string', cellstr(num2str(prob.')), ...%      'string', strtrim(cellstr(num2str(prob.', '%.2f'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

%% Security
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiSecurityGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Security', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiSecurityGroupPos(1)+uiSecurityGroupPos(5);
yPos = uiSecurityGroupPos(2)-uiSecurityGroupPos(6)+1;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Guillotine', ...
    'value', 0, ...
    'tag', 'uiSecurityGuillotine', ...
    'callback', @previewIniFile);
xPos = xPos+20;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiSecurityGuillotineOffset', ...
    'string', strtrim(cellstr(num2str((0.5:0.5:5).', '%.1f'))), ...
    'value', 10, ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

xPos = uiSecurityGroupPos(1)+uiSecurityGroupPos(5);
yPos = uiSecurityGroupPos(2)-uiSecurityGroupPos(6)-5;
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Bird reward reopen', ...
    'tag', 'uiSecurityBirdRewReopen', ...
    'callback', @previewIniFile);

%% Timeouts
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiTimeoutsGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Timeouts', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
% xPos = uiTimeoutsGroupPos(1)+uiTimeoutsGroupPos(5);
% yPos = uiTimeoutsGroupPos(2)-uiTimeoutsGroupPos(6);
% uicontrol(fig, ...
%     'style', 'text', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 20 5]*uiSketchfactor, ...
%     'string', 'Standby (s)', ...
%     'hor', 'left');
% xPos = xPos+20;
% uicontrol(fig, ...
%     'style', 'popup', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
%     'tag', 'uiSleepTimeout', ...
%     'string', strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
%     'fontweight', 'bold', ...
%     'callback', @previewIniFile, ...
%     'enable', 'off');
% xPos = uiTimeoutsGroupPos(1)+uiTimeoutsGroupPos(5);
% yPos = uiTimeoutsGroupPos(2)-2.5*uiTimeoutsGroupPos(6);
% uicontrol(fig, ...
%     'style', 'text', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 20 5]*uiSketchfactor, ...
%     'string', 'PIR (s)', ...
%     'hor', 'left');
% xPos = xPos+20;
% uicontrol(fig, ...
%     'style', 'popup', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
%     'tag', 'uiPIRTimeout', ...
%     'string', strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
%     'fontweight', 'bold', ...
%     'callback', @previewIniFile, ...
%     'enable', 'off');
xPos = uiTimeoutsGroupPos(1)+uiTimeoutsGroupPos(5);
yPos = uiTimeoutsGroupPos(2)-uiTimeoutsGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Guillotine (s)', ...
    'hor', 'left');
xPos = xPos+20;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiGuillotineTimeout', ...
    'string', '0', ...
    'enable', 'off', ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = uiTimeoutsGroupPos(1)+uiTimeoutsGroupPos(5);
yPos = uiTimeoutsGroupPos(2)-2*uiTimeoutsGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Unique visit (s)', ...
    'hor', 'left');
xPos = xPos+20;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiUniqueVisitTimeout', ...
    'string', strtrim(cellstr(num2str(([0:5 10:10:30 60]).'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile, ...
    'enable', 'on');

%% Punishment
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiPunishmentGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Punishment', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiPunishmentGroupPos(1)+uiPunishmentGroupPos(5);
yPos = uiPunishmentGroupPos(2)-uiPunishmentGroupPos(6);
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 20 5]*uiSketchfactor, ...
    'string', 'Delay (s)', ...
    'hor', 'left');
xPos = xPos+24;
uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiPunishmentDelay', ...
    'string', strtrim(cellstr(num2str((0:5:30).'))), ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);
xPos = uiPunishmentGroupPos(1)+uiPunishmentGroupPos(5);
yPos = uiPunishmentGroupPos(2)-uiPunishmentGroupPos(6)-7;
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', [xPos yPos 22 5]*uiSketchfactor, ...
    'string', 'Proba. thresh. (%)', ...
    'hor', 'left');
xPos = xPos+24;

prob = sort(prob, 2, 'ascend');

uicontrol(fig, ...
    'style', 'popup', ...
    'units', 'pixels', ...
    'position', [xPos yPos 12+8*ismac 5]*uiSketchfactor, ...
    'tag', 'uiPunishmentProbaThreshold', ...
    'string', cellstr(num2str(prob.')), ..., ...
    'fontweight', 'bold', ...
    'callback', @previewIniFile);

%% Check
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiCheckGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Check', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiCheckGroupPos(1)+uiCheckGroupPos(5);
yPos = uiCheckGroupPos(2)-uiCheckGroupPos(6);
uicontrol(fig, ...
    'style', 'checkbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 30 5]*uiSketchfactor, ...
    'string', 'Food level', ...
    'value', 0, ...
    'tag', 'uiCheckFoodLevel', ...
    'callback', @previewIniFile);
% xPos = xPos+13;
% uicontrol(fig, ...
%     'style', 'checkbox', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 30 5]*uiSketchfactor, ...
%     'string', 'UDID', ...
%     'value', 0, ...
%     'tag', 'uiLogUDID', ...
%     'callback', @previewIniFile);
% xPos = xPos+13;
% uicontrol(fig, ...
%     'style', 'checkbox', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 30 5]*uiSketchfactor, ...
%     'string', 'Events', ...
%     'value', 0, ...
%     'tag', 'uiLogEvents', ...
%     'callback', @previewIniFile);
% xPos = uiCheckGroupPos(1)+uiCheckGroupPos(5);
% yPos = yPos-6;
% uicontrol(fig, ...
%     'style', 'checkbox', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 30 5]*uiSketchfactor, ...
%     'string', 'Errors', ...
%     'value', 0, ...
%     'tag', 'uiLogErrors', ...
%     'callback', @previewIniFile);
% xPos = xPos+13;
% uicontrol(fig, ...
%     'style', 'checkbox', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 30 5]*uiSketchfactor, ...
%     'string', 'Battery', ...
%     'value', 0, ...
%     'tag', 'uiLogBattery', ...
%     'callback', @previewIniFile);
% xPos = xPos+13;
% uicontrol(fig, ...
%     'style', 'checkbox', ...
%     'units', 'pixels', ...
%     'position', [xPos yPos 30 5]*uiSketchfactor, ...
%     'string', 'RFID', ...
%     'value', 0, ...
%     'tag', 'uiLogRFID', ...
%     'callback', @previewIniFile);

%% Load/Preview/Export buttons
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiButtonGroupPos(1:4)*uiSketchfactor, ...
    'string', 'INI file', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiButtonGroupPos(1)+uiButtonGroupPos(5);
yPos = uiButtonGroupPos(2)-2*uiButtonGroupPos(6);
uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 10]*uiSketchfactor, ...
    'tag', 'uiLoadButton', ...
    'string', 'Load', ...
    'callback', @loadIniFile);
xPos = xPos + 30;
uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 10]*uiSketchfactor, ...
    'tag', 'uiGenerateButton', ...
    'string', 'Preview', ...
    'enable', 'on', ...
    'callback', @previewIniFile);
xPos = xPos + 30;
uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [xPos yPos 25 10]*uiSketchfactor, ...
    'tag', 'uiExportButton', ...
    'string', 'Export', ...
    'enable', 'on', ...
    'callback', @exportIniFile);

%% Preview zone
uicontrol(fig, ...
    'style', 'text', ...
    'units', 'pixels', ...
    'position', uiPreviewGroupPos(1:4)*uiSketchfactor, ...
    'string', 'Preview', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold');
xPos = uiPreviewGroupPos(1)+uiPreviewGroupPos(5)+5;
yPos = uiPreviewGroupPos(2)-uiPreviewGroupPos(6);
uicontrol(fig, ...
    'style', 'listbox', ...
    'units', 'pixels', ...
    'position', [xPos yPos 80 uiPreviewGroupPos(6)]*uiSketchfactor, ...    'string', 'Ini File', ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold', ...
    'tag', 'uiPreview');



%%
handles = guihandles(fig);

handles.default = default;
handles.about = about;
handles.version = version;

guidata(fig, handles);

set(handles.uiSiteName, 'string', sites{1});

syncLedDoorTime();

function setDefaultTime

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

str = get(handles.uiWakeUpMinute, 'String');
[~,idx] = min(abs(cellfun(@str2num, str)-handles.default.WakeUpMinute));
set(handles.uiWakeUpMinute, 'Value', idx);

str = get(handles.uiWakeUpHour, 'String');
[~,idx] = min(abs(cellfun(@str2num, str)-handles.default.WakeUpHour));
set(handles.uiWakeUpHour, 'Value', idx);

str = get(handles.uiSleepMinute, 'String');
[~,idx] = min(abs(cellfun(@str2num, str)-handles.default.SleepMinute));
set(handles.uiSleepMinute, 'Value', idx);

str = get(handles.uiSleepHour, 'String');
[~,idx] = min(abs(cellfun(@str2num, str)-handles.default.SleepHour));
set(handles.uiSleepHour, 'Value', idx);

function setScenario(obj, ~)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

val = get(obj, 'value');

scenarios = {'None' ...
    'Open Bar' ...
    'Door Habituation' ...
    'Go-No go' ...
    'Long Term Spatial Memory' ...
    'Working Spatial Memory' ...
    'Color Associative Learning' ...
    'Risk Aversion', ...
    'Patch Probability'};

switch scenarios{val}
    
    case 'None'
        
        % Set uicontrols to default values
        set(findobj('type', 'uicontrol'), 'enable', 'on');
        set(findobj('type', 'uicontrol', 'style', 'popup', '-and', '-not', 'tag', 'uiScenario'), 'value', 1);
        set(findobj('type', 'uicontrol', 'style', 'checkbox'), 'value', 0)
        set(findobj('type', 'uicontrol', 'style', 'popup', 'tag', 'uiPIRTimeout', '-or', 'tag', 'uiSleepTimeout'), 'enable', 'off')
        set([handles.uiAttractLedsFrameA handles.uiAttractLedsFrameB], 'backgroundcolor', [0 0 0]);
        set([handles.uiAttractLedsValueA handles.uiAttractLedsValueB], 'string', '[0 0 0]');
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration], 'value', 0)
        set(handles.uiLogBirds, 'enable', 'on', 'value', 1);
        
        % PIT tags
        set([handles.uiPitTags1
            handles.uiPitTags2
            handles.uiPitTags3
            handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', []);
        set([handles.uiRadioPitTags1
            handles.uiRadioPitTags2
            handles.uiRadioPitTags3
            handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'off')
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 0, 'enable', 'on')
        set(handles.uiSecurityGuillotine, 'value', 0, 'enable', 'on')
        set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'off')
        set(handles.uiGuillotineTimeout', 'enable', 'off', 'string', '0')
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'on', 'value', 1)
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Open Bar'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1
            handles.uiPitTags2
            handles.uiPitTags3
            handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', []);
        set([handles.uiRadioPitTags1
            handles.uiRadioPitTags2
            handles.uiRadioPitTags3
            handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'off')
        
        % Attractive LEDs
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute
            handles.uiAttractLedsAltDelay], 'enable', 'off')
        set(handles.uiAttractLedsAltDelay, 'value', 1)
        h = findobj('userdata', 'leds_pattern');
        set(h, 'value', 0, 'enable', 'off');
        set([handles.uiAttractLedsValueA handles.uiAttractLedsValueB], 'string', '[0 0 0]');
        set([handles.uiAttractLedsButtonA handles.uiAttractLedsButtonB], 'enable', 'off')
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'off', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        % Door
        set(handles.uiDoorremain_open, 'value', 1, 'enable', 'off');
        set([handles.uiDoorDelaysOpen
            handles.uiDoorDelaysClose], 'value', 1)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour
            handles.uiDoorDelaysOpen
            handles.uiDoorDelaysClose], 'enable', 'off');
        set(handles.uiDoorDelaysClose, 'value', 1);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'enable', 'off', 'value', 1);
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'off')
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 0, 'enable', 'off')
        set(handles.uiSecurityGuillotine, 'value', 0, 'enable', 'off')
        set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'off')
        set(handles.uiGuillotineTimeout', 'enable', 'off', 'string', '0')
        
        % Punishment
        set(handles.uiPunishmentDelay, 'enable', 'off')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Door Habituation'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1
            handles.uiPitTags2
            handles.uiPitTags3
            handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', []);
        set([handles.uiRadioPitTags1
            handles.uiRadioPitTags2
            handles.uiRadioPitTags3
            handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'off')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
        
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'off', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        set(handles.uiAttractLedsAltDelay, 'enable', 'off', 'value', 1)
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');        
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'enable', 'on');
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'off')
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'enable', 'off')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Go-No go'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1
            handles.uiPitTags2
            handles.uiPitTags3
            handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off');
        set([handles.uiRadioPitTags1
            handles.uiRadioPitTags2
            handles.uiRadioPitTags3
            handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'off')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
        
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'on', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'value', 1, 'enable', 'off');
        
        set(handles.uiAttractLedsAltDelay, 'value', 5, 'enable', 'on')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off');
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'on')
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'value', 3, 'enable', 'on')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Long Term Spatial Memory'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1 handles.uiPitTags2], 'string', [], 'value', 1, 'enable', 'on', 'uicontextmenu', [])
        set([handles.uiPitTags3 handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', [])
        
        set([handles.uiRadioPitTags1 handles.uiRadioPitTags2], 'value', 1, 'enable', 'on')
        set(handles.uiRadioPitTags1, 'String', 'Denied');
        set(handles.uiRadioPitTags2, 'String', 'Accepted');
        set([handles.uiRadioPitTags3 handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
        
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'off', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        set(handles.uiAttractLedsAltDelay, 'enable', 'off', 'value', 1)
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off');
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'on')
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'value', 3)
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Working Spatial Memory'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1 handles.uiPitTags2], 'string', [], 'value', 1, 'enable', 'on', 'uicontextmenu', []);
        set([handles.uiPitTags3 handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', []);
        
        set([handles.uiRadioPitTags1 handles.uiRadioPitTags2], 'value', 1, 'enable', 'on')
        set(handles.uiRadioPitTags1, 'String', 'Denied');
        set(handles.uiRadioPitTags2, 'String', 'Accepted');
        set([handles.uiRadioPitTags3 handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
        
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'off', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        set(handles.uiAttractLedsAltDelay, 'enable', 'off', 'value', 1)
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off');
        
        syncLedDoorTime();
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'on')
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'value', 3, 'enable', 'on')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Color Associative Learning'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        for n = 1:2
            hcmenu(n) = uicontextmenu;
            uimenu(hcmenu(n), 'Label', 'All accepted', 'callback', {@pitTagSelect, n, 'inc'});
            uimenu(hcmenu(n), 'Label', 'All denied', 'callback', {@pitTagSelect, n, 'exc'});
            uimenu(hcmenu(n), 'Label', 'Clear', 'separator', 'on', 'callback', {@pitTagSelect, n, 'cl'});
        end
        
        set([handles.uiPitTags1
            handles.uiPitTags2], 'string', [], 'value', 1, 'enable', 'on');
        set(handles.uiPitTags1, 'uicontextmenu', hcmenu(1));
        set(handles.uiPitTags2, 'uicontextmenu', hcmenu(2));
        set(handles.uiRadioPitTags1, 'string', 'Color A', 'value', 1, 'enable', 'on');
        set(handles.uiRadioPitTags2, 'string', 'Color B', 'value', 1, 'enable', 'on');
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = handles.default.RGBColorB;
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'on')
        
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'off', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'value', 1, 'enable', 'off');
        
        set(handles.uiAttractLedsAltDelay, 'value', 5, 'enable', 'on')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off');
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'value', 3, 'enable', 'on')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Risk Aversion'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1 handles.uiPitTags2], 'string', [], 'value', 1, 'enable', 'on', 'uicontextmenu', []);
        set([handles.uiPitTags3 handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', []);
        
        set([handles.uiRadioPitTags1 handles.uiRadioPitTags2], 'value', 1, 'enable', 'on')
        set(handles.uiRadioPitTags1, 'String', 'Denied');
        set(handles.uiRadioPitTags2, 'String', 'Accepted');
        set([handles.uiRadioPitTags3 handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
        
        h = findobj('userdata', 'leds_pattern');
        set(h, 'value', 0, 'enable', 'off');
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        set(handles.uiAttractLedsAltDelay, 'enable', 'off', 'value', 1)
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off');
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'on')
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'off', 'value', 1)
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'value', 3, 'enable', 'on')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'off')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    case 'Patch Probability'
        
        % Time
        setDefaultTime
        
        % Logs
        set([handles.uiLogBirds
            handles.uiLogUDID
            handles.uiLogEvents
            handles.uiLogErrors
            handles.uiLogBattery
            handles.uiLogTemperature
            handles.uiLogCalibration
            handles.uiLogRFID], 'value', 1)
        set(handles.uiLogBirds, 'enable', 'off');
        
        % PIT tags
        set([handles.uiPitTags1 handles.uiPitTags2], 'string', [], 'value', 1, 'enable', 'on', 'uicontextmenu', []);
        set([handles.uiPitTags3 handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', []);
        
        set([handles.uiRadioPitTags1 handles.uiRadioPitTags2], 'value', 1, 'enable', 'on')
        set(handles.uiRadioPitTags1, 'String', 'Denied');
        set(handles.uiRadioPitTags2, 'String', 'Accepted');
        set([handles.uiRadioPitTags3 handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        
        % Attractive LEDs
        rgb = handles.default.RGBColorA;
        set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
        end
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonA, 'enable', 'on')
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
        
        h = findobj('userdata', 'leds_pattern');
        set(h, 'value', 0, 'enable', 'off');
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        set([handles.uiAttractLedsOnHour
            handles.uiAttractLedsOnMinute
            handles.uiAttractLedsOffHour
            handles.uiAttractLedsOffMinute], 'enable', 'off')
        
        set(handles.uiAttractLedsAltDelay, 'enable', 'off', 'value', 1)
        
        % Door
        set(handles.uiDoorremain_open, 'enable', 'off', 'value', 0)
        set([handles.uiDoorOpenMinute
            handles.uiDoorOpenHour
            handles.uiDoorCloseMinute
            handles.uiDoorCloseHour], 'enable', 'off');
        set([handles.uiDoorDelaysOpen handles.uiDoorDelaysClose], 'enable', 'on');
        set(handles.uiDoorDelaysClose, 'value', 2);
        
        syncLedDoorTime();
        
        % Door habituation
        set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off');
        
        % Reward
        set(handles.uiRewardEnable, 'value', 0);
        set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
        set(handles.uiRewardProbability, 'enable', 'off', 'value', 1)
        
        % Timeouts
        set(handles.uiUniqueVisitTimeout, 'enable', 'on', 'value', 6)
        
        % Security
        set(handles.uiSecurityBirdRewReopen, 'value', 1, 'enable', 'on')
        if get(handles.uiSecurityGuillotine, 'value') == 0
            set(handles.uiSecurityGuillotine, 'value', 1, 'enable', 'on')
            set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'on')
            setGuillotineTimeout();
        end
        
        % Punishment
        set(handles.uiPunishmentDelay, 'value', 3, 'enable', 'on')
        set(handles.uiPunishmentProbaThreshold, 'enable', 'on')
        
        % Check
        set(handles.uiCheckFoodLevel, 'value', 0)
        
    otherwise
        
        errordlg(sprintf('Scenario %s not found', scenarios{val}))
        
end

guidata(fig, handles);

previewIniFile

function previewIniFile(~, ~)

getDataFromUi;

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

pathname = tempdir;
filename = 'OF_temp.ini';

OF_writeIni(handles.config, pathname, filename)

fid = fopen(fullfile(pathname, filename), 'r');
X = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);

X{1} = strrep(X{1}, '[', '<html><font color="#8000FF"><b>[');
X{1} = strrep(X{1}, ']', ']</b></font></html>');
X{1} = strrep(X{1}, '=', ' = ');

set(handles.uiPreview, 'string', X{1}, 'value', 1)

delete(fullfile(pathname, filename));

function loadIniFile(~, ~)

[filename, pathname] = uigetfile('*.INI');
if ~filename
    return
end

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);
handles.config = OF_readIni(fullfile(pathname, filename));
guidata(fig, handles);

populateUi
updateServoMoveTime
syncLedDoorTime

if handles.config.scenario.num>2 && ~(handles.config.scenario.num==3 && handles.config.attractiveleds.pattern==0)
    set(handles.uiPitTagsButtonLoad, 'enable', 'on')
else
    set(handles.uiPitTagsButtonLoad, 'enable', 'off')
end

d = dir(fullfile(pathname, 'PT*.TXT'));
for n = 1:numel(d)
    
    fid = fopen(fullfile(pathname, d(n).name), 'r');
    
    k = 1;
    while ~feof(fid)
        
        pt{k} = fread(fid, [1,10], 'uchar=>char*1');
        k = k+1;
        
    end
    
    fclose(fid);
    
    if isempty(pt{end})
        pt(end) = [];
    end
    
    switch d(n).name
        
        case 'PTLEFT.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Left', 'value', 1, 'enable', 'on')
        case 'PTRIGHT.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Right', 'value', 1, 'enable', 'on')
        case 'PTTOP.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Top', 'value', 1, 'enable', 'on')
        case 'PTBOTTOM.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Bottom', 'value', 1, 'enable', 'on')
        case 'PTONE1.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'LED 1', 'value', 1, 'enable', 'on')
        case 'PTONE2.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'LED 2', 'value', 1, 'enable', 'on')
        case 'PTONE3.TXT'
            set(handles.uiPitTags3, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags3, 'string', 'LED 3', 'value', 1, 'enable', 'on')
        case 'PTONE4.TXT'
            set(handles.uiPitTags4, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags4, 'string', 'LED 4', 'value', 1, 'enable', 'on')
        case 'PTDENIED.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Denied', 'value', 1, 'enable', 'on')
        case 'PTACCEPT.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Accepted', 'value', 1, 'enable', 'on')
        case 'PTCOLORA.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Color A', 'value', 1, 'enable', 'on')
        case 'PTCOLORB.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Color B', 'value', 1, 'enable', 'on')
            
    end
    
end

previewIniFile;
% fid = fopen(fullfile(pathname, filename), 'r');
% X = textscan(fid, '%s', 'delimiter', '\n');
% fclose(fid);
%
% X{1} = strrep(X{1}, '[', '<html><font color="#8000FF"><b>[');
% X{1} = strrep(X{1}, ']', ']</b></font></html>');
% X{1} = strrep(X{1}, '=', ' = ');
%
% set(handles.uiPreview, 'string', X{1}, 'value', 1)

set(handles.uiExportButton, 'enable', 'on')

function exportIniFile(~, ~)

[filename, pathname] = uiputfile('*.ini', 'Openfeeder configuration file', 'CONFIG.INI');
if ~filename
    return
end

filename = upper(filename);

getDataFromUi

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

OF_writeIni(handles.config, pathname, filename)

exportPITtag(pathname);

function exportPITtag(pathname)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

pittagdeniedfile = fullfile(pathname, 'PTDENIED.TXT');
if exist(pittagdeniedfile, 'file') == 2
    delete(pittagdeniedfile)
end

pittagacceptedfile = fullfile(pathname, 'PTACCEPT.TXT');
if exist(pittagacceptedfile, 'file') == 2
    delete(pittagacceptedfile)
end

pittagcolorAfile = fullfile(pathname, 'PTCOLORA.TXT');
if exist(pittagcolorAfile, 'file') == 2
    delete(pittagcolorAfile)
end
pittagcolorBfile = fullfile(pathname, 'PTCOLORB.TXT');
if exist(pittagcolorBfile, 'file') == 2
    delete(pittagcolorBfile)
end

pittagleftfile = fullfile(pathname, 'PTLEFT.TXT');
if exist(pittagleftfile, 'file') == 2
    delete(pittagleftfile)
end
pittagrightfile = fullfile(pathname, 'PTRIGHT.TXT');
if exist(pittagrightfile, 'file') == 2
    delete(pittagrightfile)
end

pittagtopfile = fullfile(pathname, 'PTTOP.TXT');
if exist(pittagtopfile, 'file') == 2
    delete(pittagtopfile)
end
pittagbottomfile = fullfile(pathname, 'PTBOTTOM.TXT');
if exist(pittagbottomfile, 'file') == 2
    delete(pittagbottomfile)
end

pittagone1file = fullfile(pathname, 'PTONE1.TXT');
if exist(pittagone1file, 'file') == 2
    delete(pittagone1file)
end
pittagone2file = fullfile(pathname, 'PTONE2.TXT');
if exist(pittagone2file, 'file') == 2
    delete(pittagone2file)
end
pittagone3file = fullfile(pathname, 'PTONE3.TXT');
if exist(pittagone3file, 'file') == 2
    delete(pittagone3file)
end
pittagone4file = fullfile(pathname, 'PTONE4.TXT');
if exist(pittagone4file, 'file') == 2
    delete(pittagone4file)
end

if handles.config.scenario.num<3
    % No PIT tag to export
    return
    
elseif handles.config.scenario.num==3 % Go - No go
    
    if handles.config.attractiveleds.pattern==1
        if handles.config.pittags.num_left==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_left==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags1, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagleftfile, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
        if handles.config.pittags.num_right==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_right==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags2, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagrightfile, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
    elseif handles.config.attractiveleds.pattern==2
        if handles.config.pittags.num_top==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_top==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags1, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagtopfile, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
        if handles.config.pittags.num_bottom==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_bottom==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags2, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagbottomfile, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
    elseif handles.config.attractiveleds.pattern==3
        if handles.config.pittags.num_led_1==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_led_1==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags1, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagone1file, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
        if handles.config.pittags.num_led_2==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_led_2==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags2, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagone2file, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
        if handles.config.pittags.num_led_3==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_led_3==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags3, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagone3file, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
        if handles.config.pittags.num_led_4==-9999
            str = {'XXXXXXXX'};
        elseif handles.config.pittags.num_led_4==9999
            str = {'????????'};
        else
            str = get(handles.uiPitTags4, 'string');
            str = cellstr(str);
        end
        if ~(numel(str)==1 && isempty(str{1}))
            fid = fopen(pittagone4file, 'wt');
            fprintf(fid, '%s', str{:});
            fclose(fid);
        end
        
    end
    
elseif handles.config.scenario.num==6 % Color Associative Learning
    
    if handles.config.pittags.num_color_A==-9999
        str = {'XXXXXXXX'};
    elseif handles.config.pittags.num_color_A==9999
        str = {'????????'};
    else
        str = get(handles.uiPitTags1, 'string');
        str = cellstr(str);
    end
    if ~(numel(str)==1 && isempty(str{1}))
        fid = fopen(pittagcolorAfile, 'wt');
        fprintf(fid, '%s', str{:});
        fclose(fid);
    end
    
    if handles.config.pittags.num_color_B==-9999
        str = {'XXXXXXXX'};
    elseif handles.config.pittags.num_color_B==9999
        str = {'????????'};
    else
        str = get(handles.uiPitTags2, 'string');
        str = cellstr(str);
    end
    if ~(numel(str)==1 && isempty(str{1}))
        fid = fopen(pittagcolorBfile, 'wt');
        fprintf(fid, '%s', str{:});
        fclose(fid);
    end
    
else
    
    if handles.config.pittags.num_denied==-9999
        str = {'XXXXXXXX'};
    elseif handles.config.pittags.num_denied==9999
        str = {'????????'};
    else
        str = get(handles.uiPitTags1, 'string');
        str = cellstr(str);
    end
    if ~(numel(str)==1 && isempty(str{1}))
        fid = fopen(pittagdeniedfile, 'wt');
        fprintf(fid, '%s', str{:});
        fclose(fid);
    end
    
    if handles.config.pittags.num_accepted==-9999
        str = {'XXXXXXXX'};
    elseif handles.config.pittags.num_accepted==9999
        str = {'????????'};
    else
        str = get(handles.uiPitTags2, 'string');
        str = cellstr(str);
    end
    if ~(numel(str)==1 && isempty(str{1}))
        fid = fopen(pittagacceptedfile, 'wt');
        fprintf(fid, '%s', str{:});
        fclose(fid);
    end
    
end

function importPITtag(~, ~)

[filename, pathname] = uigetfile('*.TXT', 'Select PIT tags file', 'Multiselect', 'on');

if isnumeric(filename) && ~filename
    return
end

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

filename = cellstr(filename);

for n = 1:numel(filename)
    
    fid = fopen(fullfile(pathname, filename{n}), 'r');
    
    k = 1;
    while ~feof(fid)
        
        pt{k} = fread(fid, [1,10], 'uchar=>char*1');
        k = k+1;
        
    end
    
    fclose(fid);
    
    if isempty(pt{end})
        pt(end) = [];
    end
    
    switch filename{n}
        
        case 'PTLEFT.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Left', 'value', 1, 'enable', 'on')
        case 'PTRIGHT.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Right', 'value', 1, 'enable', 'on')
        case 'PTTOP.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Top', 'value', 1, 'enable', 'on')
        case 'PTBOTTOM.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Bottom', 'value', 1, 'enable', 'on')
        case 'PTONE1.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'LED 1', 'value', 1, 'enable', 'on')
        case 'PTONE2.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'LED 2', 'value', 1, 'enable', 'on')
        case 'PTONE3.TXT'
            set(handles.uiPitTags3, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags3, 'string', 'LED 3', 'value', 1, 'enable', 'on')
        case 'PTONE4.TXT'
            set(handles.uiPitTags4, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags4, 'string', 'LED 4', 'value', 1, 'enable', 'on')
        case 'PTDENIED.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Denied', 'value', 1, 'enable', 'on')
        case 'PTACCEPT.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Accepted', 'value', 1, 'enable', 'on')
        case 'PTCOLORA.TXT'
            set(handles.uiPitTags1, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags1, 'string', 'Color A', 'value', 1, 'enable', 'on')
        case 'PTCOLORB.TXT'
            set(handles.uiPitTags2, 'string', pt, 'value', 1, 'enable', 'on')
            set(handles.uiRadioPitTags2, 'string', 'Color B', 'value', 1, 'enable', 'on')
            
    end
    
    clear pt
    
end

previewIniFile

function getDataFromUi

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

if isfield(handles, 'config')
    handles = rmfield(handles, 'config');
end

% Scenario
str = cellstr(get(handles.uiScenario, 'string'));
val = get(handles.uiScenario, 'value');
handles.config.scenario.num = uint32(val)-1;
handles.config.scenario.title = char(sscanf(str{val}, '%*d - %s', [1,inf]));

% Site ID
str = get(handles.uiSiteName, 'string');
val = get(handles.uiSiteName, 'value');
handles.config.siteid.zone = str{val};
str = get(handles.uiSiteNum, 'string');
val = get(handles.uiSiteNum, 'value');
handles.config.siteid.zone = [handles.config.siteid.zone str{val}];

% WakeUp
str = get(handles.uiWakeUpHour, 'string');
val = get(handles.uiWakeUpHour, 'value');
handles.config.time.wakeup_hour = int32(str2double(str{val}));
str = get(handles.uiWakeUpMinute, 'string');
val = get(handles.uiWakeUpMinute, 'value');
handles.config.time.wakeup_minute = int32(str2double(str{val}));

% Sleep
str = get(handles.uiSleepHour, 'string');
val = get(handles.uiSleepHour, 'value');
handles.config.time.sleep_hour = int32(str2double(str{val}));
str = get(handles.uiSleepMinute, 'string');
val = get(handles.uiSleepMinute, 'value');
handles.config.time.sleep_minute = int32(str2double(str{val}));

% Log file separator
str = cellstr(get(handles.uiLogFileSeparator, 'string'));
val = get(handles.uiLogFileSeparator, 'value');
handles.config.logs.separator = str{val};

handles.config.logs.birds = int32(get(handles.uiLogBirds, 'value'));
handles.config.logs.udid = int32(get(handles.uiLogUDID, 'value'));
handles.config.logs.events = int32(get(handles.uiLogEvents, 'value'));
handles.config.logs.errors = int32(get(handles.uiLogErrors, 'value'));
handles.config.logs.battery = int32(get(handles.uiLogBattery, 'value'));
handles.config.logs.rfid = int32(get(handles.uiLogRFID, 'value'));
handles.config.logs.temperature = int32(get(handles.uiLogTemperature, 'value'));
handles.config.logs.calibration = int32(get(handles.uiLogCalibration, 'value'));

% Attractive LEDs
if handles.config.scenario.num==0 || handles.config.scenario.num>=2
    
    col = 255*get(handles.uiAttractLedsFrameA,'backgroundcolor');
    handles.config.attractiveleds.red_a = int32(col(1));
    handles.config.attractiveleds.green_a = int32(col(2));
    handles.config.attractiveleds.blue_a = int32(col(3));
    
    if handles.config.scenario.num==6
        col = 255*get(handles.uiAttractLedsFrameB,'backgroundcolor');
        handles.config.attractiveleds.red_b = int32(col(1));
        handles.config.attractiveleds.green_b = int32(col(2));
        handles.config.attractiveleds.blue_b = int32(col(3));
    end
    
    if handles.config.scenario.num==3 || handles.config.scenario.num==6
        str = get(handles.uiAttractLedsAltDelay, 'string');
        val = get(handles.uiAttractLedsAltDelay, 'value');
        handles.config.attractiveleds.alt_delay = int32(str2double(str{val}));
    end
    
    str = get(handles.uiAttractLedsOnHour, 'string');
    val = get(handles.uiAttractLedsOnHour, 'value');
    handles.config.attractiveleds.on_hour = int32(str2double(str{val}));
    str = get(handles.uiAttractLedsOnMinute, 'string');
    val = get(handles.uiAttractLedsOnMinute, 'value');
    handles.config.attractiveleds.on_minute = int32(str2double(str{val}));
    
    if handles.config.attractiveleds.on_hour<handles.config.time.wakeup_hour || (handles.config.attractiveleds.on_hour==0 && handles.config.time.wakeup_hour~=0)
        handles.config.attractiveleds.on_hour = handles.config.time.wakeup_hour;
        handles.config.attractiveleds.on_minute = handles.config.time.wakeup_minute;
    elseif handles.config.attractiveleds.on_hour==handles.config.time.wakeup_hour && handles.config.attractiveleds.on_minute<handles.config.time.wakeup_minute
        handles.config.attractiveleds.on_minute = handles.config.time.wakeup_minute;
    end
    
    str = get(handles.uiAttractLedsOffHour, 'string');
    val = get(handles.uiAttractLedsOffHour, 'value');
    handles.config.attractiveleds.off_hour = int32(str2double(str{val}));
    str = get(handles.uiAttractLedsOffMinute, 'string');
    val = get(handles.uiAttractLedsOffMinute, 'value');
    handles.config.attractiveleds.off_minute = int32(str2double(str{val}));
    
    if handles.config.attractiveleds.off_hour>handles.config.time.sleep_hour || (handles.config.attractiveleds.off_hour==0 && handles.config.time.sleep_hour~=0)
        handles.config.attractiveleds.off_hour = handles.config.time.sleep_hour;
        handles.config.attractiveleds.off_minute = handles.config.time.sleep_minute;
    elseif handles.config.attractiveleds.off_hour==handles.config.time.sleep_hour && handles.config.attractiveleds.off_minute>handles.config.time.sleep_minute
        handles.config.attractiveleds.off_minute = handles.config.time.sleep_minute;
    end
    
    if handles.config.scenario.num==3
        if get(handles.uiAttractLeds_pattern_all, 'value')==1
            handles.config.attractiveleds.pattern = uint32(0);
            
            str = get(handles.uiAttractLeds_pattern_all_percent, 'string');
            val = get(handles.uiAttractLeds_pattern_all_percent, 'value');
            handles.config.attractiveleds.pattern_percent =  uint32(str2double(str{val}));
            
        elseif get(handles.uiAttractLeds_pattern_lr, 'value')==1
            handles.config.attractiveleds.pattern = uint32(1);
        elseif get(handles.uiAttractLeds_pattern_tb, 'value')==1
            handles.config.attractiveleds.pattern = uint32(2);
        elseif get(handles.uiAttractLeds_pattern_one, 'value')==1
            handles.config.attractiveleds.pattern = uint32(3);
        end
    end
    
end

% Pit tags
if handles.config.scenario.num>2
    if handles.config.scenario.num == 3 % Go - No go
        if isfield(handles.config.attractiveleds, 'pattern')
            if handles.config.attractiveleds.pattern==1
                str = get(handles.uiPitTags1, 'string');
                if isempty(str)
                    handles.config.pittags.num_left = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_left = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_left = int32(9999);
                    else
                        handles.config.pittags.num_left = uint32(numel(str));
                    end
                end
                str = get(handles.uiPitTags2, 'string');
                if isempty(str)
                    handles.config.pittags.num_right = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_right = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_right = int32(9999);
                    else
                        handles.config.pittags.num_right = uint32(numel(str));
                    end
                end
            elseif handles.config.attractiveleds.pattern==2
                str = get(handles.uiPitTags1, 'string');
                if isempty(str)
                    handles.config.pittags.num_top = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_top = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_top = int32(9999);
                    else
                        handles.config.pittags.num_top = uint32(numel(str));
                    end
                end
                str = get(handles.uiPitTags2, 'string');
                if isempty(str)
                    handles.config.pittags.num_bottom = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_bottom = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_bottom = int32(9999);
                    else
                        handles.config.pittags.num_bottom = uint32(numel(str));
                    end
                end
                
            elseif handles.config.attractiveleds.pattern==3
                str = get(handles.uiPitTags1, 'string');
                if isempty(str)
                    handles.config.pittags.num_led_1 = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_led_1 = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_led_1 = int32(9999);
                    else
                        handles.config.pittags.num_led_1 = uint32(numel(str));
                    end
                end
                str = get(handles.uiPitTags2, 'string');
                if isempty(str)
                    handles.config.pittags.num_led_2 = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_led_2 = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_led_2 = int32(9999);
                    else
                        handles.config.pittags.num_led_2 = uint32(numel(str));
                    end
                end
                str = get(handles.uiPitTags3, 'string');
                if isempty(str)
                    handles.config.pittags.num_led_3 = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_led_3 = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_led_3 = int32(9999);
                    else
                        handles.config.pittags.num_led_3 = uint32(numel(str));
                    end
                end
                str = get(handles.uiPitTags4, 'string');
                if isempty(str)
                    handles.config.pittags.num_led_4 = uint32(0);
                else
                    str = cellstr(str);
                    if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                        handles.config.pittags.num_led_4 = int32(-9999);
                    elseif numel(str)==1 && strcmp(str{1}, '????????')
                        handles.config.pittags.num_led_4 = int32(9999);
                    else
                        handles.config.pittags.num_led_4 = uint32(numel(str));
                    end
                end
            end
        end
    elseif handles.config.scenario.num == 6 % Color associative learning
        str = get(handles.uiPitTags1, 'string');
        if isempty(str)
            handles.config.pittags.num_color_A = uint32(0);
        else
            str = cellstr(str);
            if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                handles.config.pittags.num_color_A = int32(-9999);
            elseif numel(str)==1 && strcmp(str{1}, '????????')
                handles.config.pittags.num_color_A = int32(9999);
            else
                handles.config.pittags.num_color_A = uint32(numel(str));
            end
        end
        str = get(handles.uiPitTags2, 'string');
        if isempty(str)
            handles.config.pittags.num_color_B = uint32(0);
        else
            str = cellstr(str);
            if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                handles.config.pittags.num_color_B = int32(-9999);
            elseif numel(str)==1 && strcmp(str{1}, '????????')
                handles.config.pittags.num_color_B = int32(9999);
            else
                handles.config.pittags.num_color_B = uint32(numel(str));
            end
        end
    else
        str = get(handles.uiPitTags1, 'string');
        if isempty(str)
            handles.config.pittags.num_denied = uint32(0);
        else
            str = cellstr(str);
            if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                handles.config.pittags.num_denied = int32(-9999);
            elseif numel(str)==1 && strcmp(str{1}, '????????')
                handles.config.pittags.num_denied = int32(9999);
            else
                handles.config.pittags.num_denied = uint32(numel(str));
            end
        end
        str = get(handles.uiPitTags2, 'string');
        if isempty(str)
            handles.config.pittags.num_accepted = uint32(0);
        else
            str = cellstr(str);
            if numel(str)==1 && strcmp(str{1}, 'XXXXXXXX')
                handles.config.pittags.num_accepted = int32(-9999);
            elseif numel(str)==1 && strcmp(str{1}, '????????')
                handles.config.pittags.num_accepted = int32(9999);
            else
                handles.config.pittags.num_accepted = uint32(numel(str));
            end
        end
    end
end

% Door
str = get(handles.uiDoorOpenHour, 'string');
val = get(handles.uiDoorOpenHour, 'value');
handles.config.door.open_hour = int32(str2double(str{val}));
str = get(handles.uiDoorOpenMinute, 'string');
val = get(handles.uiDoorOpenMinute, 'value');
handles.config.door.open_minute = int32(str2double(str{val}));

if handles.config.door.open_hour<handles.config.time.wakeup_hour
    handles.config.door.open_hour = handles.config.time.wakeup_hour;
    handles.config.door.open_minute = handles.config.time.wakeup_minute;
elseif handles.config.door.open_hour==handles.config.time.wakeup_hour && handles.config.door.open_minute<handles.config.time.wakeup_minute
    handles.config.door.open_minute = handles.config.time.wakeup_minute;
end

str = get(handles.uiDoorCloseHour, 'string');
val = get(handles.uiDoorCloseHour, 'value');
handles.config.door.close_hour = int32(str2double(str{val}));
str = get(handles.uiDoorCloseMinute, 'string');
val = get(handles.uiDoorCloseMinute, 'value');
handles.config.door.close_minute = int32(str2double(str{val}));

if handles.config.door.close_hour>handles.config.time.sleep_hour || (handles.config.door.close_hour==0 && handles.config.time.sleep_hour~=0)
    handles.config.door.close_hour = handles.config.time.sleep_hour;
    handles.config.door.close_minute = handles.config.time.sleep_minute;
elseif handles.config.door.close_hour==handles.config.time.sleep_hour && handles.config.door.close_minute>handles.config.time.sleep_minute
    handles.config.door.close_minute = handles.config.time.sleep_minute;
end

val = get(handles.uiDoorremain_open, 'value');
handles.config.door.remain_open = val==1;

str = get(handles.uiDoorDelaysOpen, 'string');
val = get(handles.uiDoorDelaysOpen, 'value');
handles.config.door.open_delay = int32(str2double(str{val}));
str = get(handles.uiDoorDelaysClose, 'string');
val = get(handles.uiDoorDelaysClose, 'value');
handles.config.door.close_delay = int32(str2double(str{val}));

% Servomotor
v = str2double(get(handles.uiServoMinPos, 'string'));
if v<600 || v>2400
    errordlg('Close position must be in the range [600 2400]')
    v = int32(600);
    set(handles.uiServoMinPos, 'string', num2str(v))
    updateServoMoveTime();
end
handles.config.door.close_position = int32(v);

v = str2double(get(handles.uiServoMaxPos, 'string'));
if v<600 || v>2400
    errordlg('Open position must be in the range [600 2400]')
    v = 2400;
    set(handles.uiServoMaxPos, 'string', num2str(v))
    updateServoMoveTime();
end
handles.config.door.open_position = int32(v);

v = str2double(get(handles.uiServoClosingSpeed, 'string'));
if v<1
    v = 1;
    errordlg('Closing speed must greater than 1')
    set(handles.uiServoClosingSpeed, 'string', num2str(v))
    updateServoMoveTime();
end
handles.config.door.closing_speed = int32(v);

v = str2double(get(handles.uiServoOpeningSpeed, 'string'));
if v<1
    v = 1;
    errordlg('Opening speed must greater than 1')
    set(handles.uiServoOpeningSpeed, 'string', num2str(v))
    updateServoMoveTime();
end
handles.config.door.opening_speed = int32(v);

v = str2double(get(handles.uiServoMaxPosOffset, 'string'));
if v<100
    v = 100;
    errordlg('Max offset position must greater than 100')
    set(handles.uiServoMaxPosOffset, 'string', num2str(v))
end
handles.config.door.max_position_offset = int32(v);

% Door habituation
if handles.config.scenario.num==0 || handles.config.scenario.num==2
    str = get(handles.uiDoorHabitPercent, 'string');
    val = get(handles.uiDoorHabitPercent, 'value');
    handles.config.door.habituation = int32(str2double(str{val}));
end

% Reward
val = get(handles.uiRewardEnable, 'value');
handles.config.reward.enable = val==1;
if handles.config.reward.enable
    str = get(handles.uiRewardTimeout, 'string');
    val = get(handles.uiRewardTimeout, 'value');
    handles.config.reward.timeout = int32(str2double(str{val}));
    if handles.config.scenario.num~=1
        set(handles.uiRewardTimeout, 'enable', 'on')
        set(handles.uiSecurityBirdRewReopen, 'enable', 'on', 'value', 1)
    end
else
    set(handles.uiRewardTimeout, 'enable', 'off')
    set(handles.uiSecurityBirdRewReopen, 'enable', 'off', 'value', 0)
end
if handles.config.scenario.num>2 && handles.config.scenario.num<8
    str = get(handles.uiRewardProbability, 'string');
    val = get(handles.uiRewardProbability, 'value');
    handles.config.reward.probability = int32(str2double(str{val}));
end

% Timeouts
if handles.config.scenario.num==8
    str = get(handles.uiUniqueVisitTimeout, 'string');
    val = get(handles.uiUniqueVisitTimeout, 'value');
    handles.config.timeouts.unique_visit = int32(str2double(str{val}));
end
% str = get(handles.uiSleepTimeout, 'string');
% val = get(handles.uiSleepTimeout, 'value');
% handles.config.timeouts.sleep = int32(str2double(str{val}));
% str = get(handles.uiPIRTimeout, 'string');
% val = get(handles.uiPIRTimeout, 'value');
% handles.config.timeouts.pir = int32(str2double(str{val}));

% Security
if handles.config.scenario.num~=1
    val = get(handles.uiSecurityBirdRewReopen, 'value');
    handles.config.security.bird_reward_reopen = val==1;
    val = get(handles.uiSecurityGuillotine, 'value');
    handles.config.security.guillotine = val==1;
    if handles.config.security.guillotine
        set(handles.uiSecurityGuillotineOffset, 'enable', 'on')
        
        str = get(handles.uiSecurityGuillotineOffset, 'string');
        val = get(handles.uiSecurityGuillotineOffset, 'value');
        handles.config.security.guillotine_offset = int32(1000*str2double(str{val}));

        setGuillotineTimeout();

    else
        set(handles.uiSecurityGuillotineOffset, 'enable', 'off')
        set(handles.uiGuillotineTimeout', 'enable', 'off', 'string', '0')
    end
end

% Punishment
if handles.config.scenario.num>2
    str = get(handles.uiPunishmentDelay, 'string');
    val = get(handles.uiPunishmentDelay, 'value');
    handles.config.punishment.delay = int32(str2double(str{val}));
end

if handles.config.scenario.num==8
    str = get(handles.uiPunishmentProbaThreshold, 'string');
    val = get(handles.uiPunishmentProbaThreshold, 'value');
    handles.config.punishment.proba_threshold = int32(str2double(str{val}));
end

%Check
handles.config.check.food_level = int32(get(handles.uiCheckFoodLevel, 'value'));

%Version
handles.config.iniversion.major = int32(handles.version.major);
handles.config.iniversion.minor = int32(handles.version.minor);
handles.config.iniversion.patch = int32(handles.version.patch);

%Date
dv = datevec(now);
handles.config.gendate.year = int32(dv(1));
handles.config.gendate.month = int32(dv(2));
handles.config.gendate.day = int32(dv(3));
handles.config.gendate.hour = int32(dv(4));
handles.config.gendate.minute = int32(dv(5));
handles.config.gendate.second = int32(dv(6));

guidata(fig, handles);

function populateUi

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

assignin('base', 'config', handles.config)

%% Scenario
set(handles.uiScenario, 'value', handles.config.scenario.num+1);

%% Site ID
str = get(handles.uiSiteName, 'string');
idx = find(strcmp(str, handles.config.siteid.zone(1:2)));
set(handles.uiSiteName, 'value', idx)

str = get(handles.uiSiteNum, 'string');
idx = find(strcmp(str, handles.config.siteid.zone(3:4)));
set(handles.uiSiteNum, 'value', idx)

%% Wakeup
str = get(handles.uiWakeUpHour, 'string');
idx = find(strcmp(str, num2str(handles.config.time.wakeup_hour, '%02d')));
set(handles.uiWakeUpHour, 'value', idx)
str = get(handles.uiWakeUpMinute, 'string');
idx = find(strcmp(str, num2str(handles.config.time.wakeup_minute, '%02d')));
set(handles.uiWakeUpMinute, 'value', idx)

%% Sleep
str = get(handles.uiSleepHour, 'string');
idx = find(strcmp(str, num2str(handles.config.time.sleep_hour, '%02d')));
set(handles.uiSleepHour, 'value', idx)
str = get(handles.uiSleepMinute, 'string');
idx = find(strcmp(str, num2str(handles.config.time.sleep_minute, '%02d')));
set(handles.uiSleepMinute, 'value', idx)

%% Log file
set(handles.uiLogFileSeparator, 'string', handles.config.logs.separator);
set(handles.uiLogBirds, 'value', handles.config.logs.birds);
if handles.config.scenario.num>0
    set(handles.uiLogBirds, 'enable', 'off');
end
set(handles.uiLogUDID, 'value', handles.config.logs.udid);
set(handles.uiLogEvents, 'value', handles.config.logs.events);
set(handles.uiLogErrors, 'value', handles.config.logs.errors);
set(handles.uiLogBattery, 'value', handles.config.logs.battery);
set(handles.uiLogRFID, 'value', handles.config.logs.rfid);
set(handles.uiLogTemperature, 'value', handles.config.logs.temperature);
set(handles.uiLogCalibration, 'value', handles.config.logs.calibration);

%% Pit tag
if isfield(handles.config, 'pittags')
    
    set([handles.uiRadioPitTags1
        handles.uiRadioPitTags2
        handles.uiRadioPitTags3
        handles.uiRadioPitTags4], 'String', '', 'value', 0, 'enable', 'off')
    set([handles.uiPitTags1
        handles.uiPitTags2
        handles.uiPitTags3
        handles.uiPitTags4], 'string', '', 'value', 1, 'enable', 'off');
    
    if handles.config.scenario.num == 3
        
        if handles.config.attractiveleds.pattern==1
            set(handles.uiRadioPitTags1, 'String', 'Left')
            set(handles.uiRadioPitTags2, 'String', 'Right')
        elseif handles.config.attractiveleds.pattern==2
            set(handles.uiRadioPitTags1, 'String', 'Top')
            set(handles.uiRadioPitTags2, 'String', 'Bottom')
        elseif handles.config.attractiveleds.pattern==3
            set(handles.uiRadioPitTags1, 'String', 'LED 1')
            set(handles.uiRadioPitTags2, 'String', 'LED 2')
            set(handles.uiRadioPitTags3, 'String', 'LED 3')
            set(handles.uiRadioPitTags4, 'String', 'LED 4')
        end
        
    elseif handles.config.scenario.num == 6
        
        set(handles.uiRadioPitTags1, 'String', 'Color A')
        set(handles.uiRadioPitTags2, 'String', 'Color B')
        
    else
        
        set(handles.uiRadioPitTags1, 'String', 'Denied', 'value', 1, 'enable', 'on')
        set(handles.uiRadioPitTags2, 'String', 'Accepted', 'value', 1, 'enable', 'on')
        
        if numel(handles.config.pittags.denied)>0
            set(handles.uiPitTags1, 'string', handles.config.pittags.denied, 'value', 1, 'enable', 'on');
        end
        if numel(handles.config.pittags.accepted)>0
            set(handles.uiPitTags2, 'string', handles.config.pittags.accepted, 'value', 1, 'enable', 'on');
        end
        
    end
    
else
    
    set([handles.uiPitTags1
        handles.uiPitTags2
        handles.uiPitTags3
        handles.uiPitTags4], 'string', '', 'value', 1, 'enable', 'off');
    set([handles.uiRadioPitTags1
        handles.uiRadioPitTags2
        handles.uiRadioPitTags3
        handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')
    set(handles.uiPitTagsButtonLoad, 'enable', 'off')
    
end

%% Attractive LEDs
if isfield(handles.config, 'attractiveleds')
    
    rgb = [handles.config.attractiveleds.red_a handles.config.attractiveleds.green_a handles.config.attractiveleds.blue_a];
    set(handles.uiAttractLedsValueA, 'string', sprintf('[%d %d %d]', rgb));
    if ~any(rgb==-1)
        set(handles.uiAttractLedsFrameA, 'backgroundcolor', double(rgb)/255)
    end
    set(handles.uiAttractLedsButtonA, 'enable', 'on')
    
    if handles.config.attractiveleds.red_b~=-1 && handles.config.attractiveleds.green_b~=-1 && handles.config.attractiveleds.blue_b~=-1
        rgb = [handles.config.attractiveleds.red_b handles.config.attractiveleds.green_b handles.config.attractiveleds.blue_b];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonB, 'enable', 'on')
    else
        rgb = [0 0 0];
        set(handles.uiAttractLedsValueB, 'string', sprintf('[%d %d %d]', rgb));
        if ~any(rgb==-1)
            set(handles.uiAttractLedsFrameB, 'backgroundcolor', double(rgb)/255)
        end
        
        set(handles.uiAttractLedsButtonB, 'enable', 'off')
    end
    
    if handles.config.attractiveleds.alt_delay~=-1
        str = get(handles.uiAttractLedsAltDelay, 'string');
        idx = find(strcmp(str, num2str(handles.config.attractiveleds.alt_delay)));
        set(handles.uiAttractLedsAltDelay, 'value', idx, 'enable', 'on')
    else
        set(handles.uiAttractLedsAltDelay, 'value', 1, 'enable', 'off')
    end
    
    str = get(handles.uiAttractLedsOnHour, 'string');
    idx = find(strcmp(str, num2str(handles.config.attractiveleds.on_hour, '%02d')));
    set(handles.uiAttractLedsOnHour, 'value', idx, 'enable', 'off')
    str = get(handles.uiAttractLedsOnMinute, 'string');
    idx = find(strcmp(str, num2str(handles.config.attractiveleds.on_minute, '%02d')));
    set(handles.uiAttractLedsOnMinute, 'value', idx, 'enable', 'off')
    
    str = get(handles.uiAttractLedsOffHour, 'string');
    idx = find(strcmp(str, num2str(handles.config.attractiveleds.off_hour, '%02d')));
    set(handles.uiAttractLedsOffHour, 'value', idx, 'enable', 'off')
    str = get(handles.uiAttractLedsOffMinute, 'string');
    idx = find(strcmp(str, num2str(handles.config.attractiveleds.off_minute, '%02d')));
    set(handles.uiAttractLedsOffMinute, 'value', idx, 'enable', 'off')
    
    set([handles.uiAttractLeds_pattern_all
        handles.uiAttractLeds_pattern_lr
        handles.uiAttractLeds_pattern_tb
        handles.uiAttractLeds_pattern_one], 'enable', 'off', 'value', 0)
    set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
    
    if handles.config.scenario.num==3
        
        set([handles.uiAttractLeds_pattern_all
            handles.uiAttractLeds_pattern_lr
            handles.uiAttractLeds_pattern_tb
            handles.uiAttractLeds_pattern_one], 'enable', 'on', 'value', 0)
        set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'off')
        
        switch handles.config.attractiveleds.pattern
            
            case 0
                set(handles.uiAttractLeds_pattern_all, 'value', 1)
                set(handles.uiAttractLeds_pattern_all_percent, 'enable', 'on')
            case 1
                set(handles.uiAttractLeds_pattern_lr, 'value', 1)
            case 2
                set(handles.uiAttractLeds_pattern_tb, 'value', 1)
            case 3
                set(handles.uiAttractLeds_pattern_one, 'value', 1)
                
        end
        
        if handles.config.attractiveleds.pattern_percent~=-1
            [~, idx] = min(abs(cellfun(@str2num, handles.uiAttractLeds_pattern_all_percent.String)-handles.config.attractiveleds.pattern_percent));
            set(handles.uiAttractLeds_pattern_all_percent, 'value', idx, 'enable', 'on')
        else
            set(handles.uiAttractLeds_pattern_all_percent, 'value', 1, 'enable', 'off')
        end
        
    end
    
else
    
    set([handles.uiAttractLedsButtonA handles.uiAttractLedsButtonB], 'enable', 'off')
    set([handles.uiAttractLedsValueA handles.uiAttractLedsValueB], 'string', '[0 0 0]');
    set([handles.uiAttractLedsAltDelay
        handles.uiAttractLedsOnHour
        handles.uiAttractLedsOnMinute
        handles.uiAttractLedsOffHour
        handles.uiAttractLedsOffMinute
        handles.uiAttractLeds_pattern_all_percent], 'value', 1, 'enable', 'off')
    set([handles.uiAttractLeds_pattern_all
        handles.uiAttractLeds_pattern_lr
        handles.uiAttractLeds_pattern_tb
        handles.uiAttractLeds_pattern_one], 'value', 0, 'enable', 'off')
    
end

%% Door
str = get(handles.uiDoorOpenHour, 'string');
str = strtrim(str);
idx = find(strcmp(str, num2str(handles.config.door.open_hour, '%02d')));
set(handles.uiDoorOpenHour, 'value', idx, 'enable', 'off')
str = get(handles.uiDoorOpenMinute, 'string');
str = strtrim(str);
idx = find(strcmp(str, num2str(handles.config.door.open_minute, '%02d')));
set(handles.uiDoorOpenMinute, 'value', idx, 'enable', 'off')

str = get(handles.uiDoorCloseHour, 'string');
str = strtrim(str);
idx = find(strcmp(str, num2str(handles.config.door.close_hour, '%02d')));
set(handles.uiDoorCloseHour, 'value', idx, 'enable', 'off')
str = get(handles.uiDoorCloseMinute, 'string');
str = strtrim(str);
idx = find(strcmp(str, num2str(handles.config.door.close_minute, '%02d')));
set(handles.uiDoorCloseMinute, 'value', idx, 'enable', 'off')

set(handles.uiDoorremain_open, 'value', handles.config.door.remain_open);
% if handles.config.door.remain_open==0
set(handles.uiDoorremain_open, 'enable', 'off');
% end

str = get(handles.uiDoorDelaysOpen, 'string');
str = strtrim(str);
idx = find(strcmp(str, num2str(handles.config.door.open_delay)));
set(handles.uiDoorDelaysOpen, 'value', idx)
str = get(handles.uiDoorDelaysClose, 'string');
str = strtrim(str);
idx = find(strcmp(str, num2str(handles.config.door.close_delay)));
set(handles.uiDoorDelaysClose, 'value', idx)

%% Servomotor
set(handles.uiServoMinPos, 'string', num2str(handles.config.door.close_position));
set(handles.uiServoMaxPos, 'string', num2str(handles.config.door.open_position));
set(handles.uiServoClosingSpeed, 'string', num2str(handles.config.door.closing_speed));
set(handles.uiServoOpeningSpeed, 'string', num2str(handles.config.door.opening_speed));

%% Door habituation
if handles.config.door.habituation~=-1
    str = get(handles.uiDoorHabitPercent, 'string');
    str = strtrim(str);
    idx = find(strcmp(str, num2str(handles.config.door.habituation)));
    set(handles.uiDoorHabitPercent, 'value', idx, 'enable', 'on')
else
    set(handles.uiDoorHabitPercent, 'value', 1, 'enable', 'off')
end

%% Reward
set(handles.uiRewardEnable, 'value', handles.config.reward.enable)
if handles.config.reward.enable
    str = get(handles.uiRewardTimeout, 'string');
    str = strtrim(str);
    idx = find(strcmp(str, num2str(handles.config.reward.timeout)));
    set(handles.uiRewardTimeout, 'value', idx, 'enable', 'on')
else
    set(handles.uiRewardTimeout, 'value', 1, 'enable', 'off')
end

if handles.config.reward.probability~=-1
    str = get(handles.uiRewardProbability, 'string');
    str = strtrim(str);
    idx = find(strcmp(str, num2str(handles.config.reward.probability)));
    set(handles.uiRewardProbability, 'value', idx, 'enable', 'on')
else
    set(handles.uiRewardProbability, 'value', 1, 'enable', 'off')
end

%% Timeouts
if handles.config.timeouts.unique_visit~=-1
    str = get(handles.uiUniqueVisitTimeout, 'string');
    str = strtrim(str);
    idx = find(strcmp(str, num2str(handles.config.timeouts.unique_visit)));
    set(handles.uiUniqueVisitTimeout, 'value', idx, 'enable', 'on')
else
    set(handles.uiUniqueVisitTimeout, 'value', 1, 'enable', 'off')
end
% if handles.config.timeouts.sleep~=-1
%     str = get(handles.uiSleepTimeout, 'string');
%     str = strtrim(str);
%     idx = find(strcmp(str, num2str(handles.config.timeouts.sleep)));
%     set(handles.uiSleepTimeout, 'value', idx)
% else
%     set(handles.uiSleepTimeout, 'value', 1, 'enable', 'off')
% end
% if handles.config.timeouts.pir~=-1
%     str = get(handles.uiPIRTimeout, 'string');
%     str = strtrim(str);
%     idx = find(strcmp(str, num2str(handles.config.timeouts.pir)));
%     set(handles.uiPIRTimeout, 'value', idx)
% else
%     set(handles.uiPIRTimeout, 'value', 1, 'enable', 'off')
% end

%% Security
if isfield(handles.config, 'security')
    
    if handles.config.security.bird_reward_reopen==-1
        set(handles.uiSecurityBirdRewReopen, 'value', 1)
    else
        set(handles.uiSecurityBirdRewReopen, 'value', handles.config.security.bird_reward_reopen)
    end
    
    if handles.config.security.guillotine==-1
        set(handles.uiSecurityGuillotine, 'value', 0, 'enable', 'on')
        set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'off')
        set(handles.uiGuillotineTimeout', 'enable', 'off', 'string', '0');
    else
        set(handles.uiSecurityGuillotine, 'value', handles.config.security.guillotine, 'enable', 'on')
        str = get(handles.uiSecurityGuillotineOffset, 'string');
        idx = find(strcmp(str, num2str(handles.config.security.guillotine_offset/1000)));
        set(handles.uiSecurityGuillotineOffset, 'value', idx, 'enable', 'on')
        setGuillotineTimeout();
    end
    
else
    set(handles.uiSecurityBirdRewReopen, 'value', 0, 'enable', 'on')
    set(handles.uiSecurityGuillotine, 'value', 0, 'enable', 'on')
    set(handles.uiSecurityGuillotineOffset, 'value', 10, 'enable', 'off')
    set(handles.uiGuillotineTimeout', 'enable', 'off', 'string', '0');
    if handles.config.scenario.num == 1
        set(handles.uiSecurityBirdRewReopen, 'enable', 'off')
        set(handles.uiSecurityGuillotine, 'enable', 'off')
    end
end

%% Punishment
if handles.config.punishment.delay~=-1
    str = get(handles.uiPunishmentDelay, 'string');
    str = strtrim(str);
    idx = find(strcmp(str, num2str(handles.config.punishment.delay)));
    set(handles.uiPunishmentDelay, 'value', idx, 'enable', 'on')
else
    set(handles.uiPunishmentDelay, 'value', 1, 'enable', 'off')
end

if handles.config.punishment.proba_threshold~=-1
    str = get(handles.uiPunishmentProbaThreshold, 'string');
    str = strtrim(str);
    idx = find(strcmp(str, num2str(handles.config.punishment.proba_threshold)));
    set(handles.uiPunishmentProbaThreshold, 'value', idx, 'enable', 'on')
else
    set(handles.uiPunishmentProbaThreshold, 'value', 1, 'enable', 'off')
end


%Check
if handles.config.check.food_level==-1
    set(handles.uiCheckFoodLevel, 'value', 0)
else
    set(handles.uiCheckFoodLevel, 'value', handles.config.check.food_level)
end

function updateServoMoveTime(~, ~)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

servoOpenPosition = get(handles.uiServoMaxPos, 'string');
servoOpenPosition = str2double(servoOpenPosition);

servoClosePosition = get(handles.uiServoMinPos, 'string');
servoClosePosition = str2double(servoClosePosition);

servoClosingSpeed = get(handles.uiServoClosingSpeed, 'string');
servoClosingSpeed = str2double(servoClosingSpeed);
servoOpeningSpeed = get(handles.uiServoOpeningSpeed, 'string');
servoOpeningSpeed = str2double(servoOpeningSpeed);

t = (servoOpenPosition-servoClosePosition)/servoClosingSpeed*handles.default.ServoMsStep/1000;
set(handles.uiServoClosingTime, 'string', sprintf('%.3f', t))
if t<0
    set(handles.uiServoClosingTime, 'foregroundcolor', 'r')
else
    set(handles.uiServoClosingTime, 'foregroundcolor', 'k')
end
t = (servoOpenPosition-servoClosePosition)/servoOpeningSpeed*handles.default.ServoMsStep/1000;
set(handles.uiServoOpeningTime, 'string', sprintf('%.3f', t))
if t<0
    set(handles.uiServoOpeningTime, 'foregroundcolor', 'r')
else
    set(handles.uiServoOpeningTime, 'foregroundcolor', 'k')
end

previewIniFile

function syncLedDoorTime(~, ~)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

% WakeUp
val = get(handles.uiWakeUpHour, 'value');
set(handles.uiAttractLedsOnHour, 'value', val);
set(handles.uiDoorOpenHour, 'value', val);

val = get(handles.uiWakeUpMinute, 'value');
set(handles.uiAttractLedsOnMinute, 'value', val);
set(handles.uiDoorOpenMinute, 'value', val);

% Sleep

val = get(handles.uiSleepHour, 'value');
set(handles.uiAttractLedsOffHour, 'value', val);
set(handles.uiDoorCloseHour, 'value', val);

val = get(handles.uiSleepMinute, 'value');
set(handles.uiAttractLedsOffMinute, 'value', val);
set(handles.uiDoorCloseMinute, 'value', val);

previewIniFile;

function setGuillotineTimeout(~, ~)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

close_position = str2double(get(handles.uiServoMinPos, 'string'));

open_position = str2double(get(handles.uiServoMaxPos, 'string'));

closing_speed = str2double(get(handles.uiServoClosingSpeed, 'string'));

str = get(handles.uiSecurityGuillotineOffset, 'string');
val = get(handles.uiSecurityGuillotineOffset, 'value');
guillotine_offset = str2double(str{val});

set(handles.uiGuillotineTimeout', 'enable', 'on', 'string', ...        
            sprintf('%.3f',(open_position-close_position)/closing_speed*handles.default.ServoMsStep/1000+guillotine_offset))
    
function setAttractLEDsColor(obj, ~)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

str = get(obj, 'string');

rgb = get(handles.(['uiAttractLedsFrame' str(end)]), 'backgroundcolor');

rgb = uisetcolor(rgb);

set(handles.(['uiAttractLedsFrame' str(end)]), 'backgroundcolor', rgb);
rgb = round(rgb*255);

set(handles.(['uiAttractLedsValue' str(end)]), 'string', sprintf('[%d %d %d]', rgb));

previewIniFile

function attractiveledpattern(obj, ~, typ)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

h = findobj('userdata', 'leds_pattern');
set(h, 'value', 0);

if get(handles.uiScenario, 'value')~=4
    return
end

set(obj, 'value', 1)
set(handles.uiAttractLeds_pattern_all_percent, 'value', 1, 'enable', 'off');
set(handles.uiPitTagsButtonLoad, 'enable', 'off')

set([handles.uiPitTags1
    handles.uiPitTags2
    handles.uiPitTags3
    handles.uiPitTags4], 'string', [], 'value', 1, 'enable', 'off', 'uicontextmenu', '')
set([handles.uiRadioPitTags1
    handles.uiRadioPitTags2
    handles.uiRadioPitTags3
    handles.uiRadioPitTags4], 'value', 0, 'enable', 'off', 'string', '')

for n = 1:4
    hcmenu(n) = uicontextmenu;
    uimenu(hcmenu(n), 'Label', 'All accepted', 'callback', {@pitTagSelect, n, 'inc'});
    uimenu(hcmenu(n), 'Label', 'All denied', 'callback', {@pitTagSelect, n, 'exc'});
    uimenu(hcmenu(n), 'Label', 'Clear', 'separator', 'on', 'callback', {@pitTagSelect, n, 'cl'});
end

switch typ
    
    case 'a'
        
        set(handles.uiAttractLeds_pattern_all_percent, 'value', 6, 'enable', 'on');
        handles.pattern = uint32(0);
        
    case 'lr'
        
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        handles.pattern = uint32(1);
        set(handles.uiRadioPitTags1, 'string', 'Left', 'value', 1, 'enable', 'on');
        set(handles.uiRadioPitTags2, 'string', 'Right', 'value', 1, 'enable', 'on');
        set(handles.uiPitTags1, 'enable', 'on', 'uicontextmenu', hcmenu(1))
        set(handles.uiPitTags2, 'enable', 'on', 'uicontextmenu', hcmenu(2))
        
    case 'tb'
        
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        handles.pattern = uint32(2);
        set(handles.uiRadioPitTags1, 'string', 'Top', 'value', 1, 'enable', 'on');
        set(handles.uiRadioPitTags2, 'string', 'Bottom', 'value', 1, 'enable', 'on');
        set(handles.uiPitTags1, 'enable', 'on', 'uicontextmenu', hcmenu(1))
        set(handles.uiPitTags2, 'enable', 'on', 'uicontextmenu', hcmenu(2))
        
    case 'o'
        
        set(handles.uiPitTagsButtonLoad, 'enable', 'on')
        handles.pattern = uint32(3);
        set(handles.uiRadioPitTags1, 'string', 'LED 1', 'value', 1, 'enable', 'on');
        set(handles.uiRadioPitTags2, 'string', 'LED 2', 'value', 1, 'enable', 'on');
        set(handles.uiRadioPitTags3, 'string', 'LED 3', 'value', 1, 'enable', 'on');
        set(handles.uiRadioPitTags4, 'string', 'LED 4', 'value', 1, 'enable', 'on');
        
        set([handles.uiPitTags1
            handles.uiPitTags2
            handles.uiPitTags3
            handles.uiPitTags4], 'enable', 'on')
        set(handles.uiPitTags1, 'enable', 'on', 'uicontextmenu', hcmenu(1))
        set(handles.uiPitTags2, 'enable', 'on', 'uicontextmenu', hcmenu(2))
        set(handles.uiPitTags3, 'enable', 'on', 'uicontextmenu', hcmenu(3))
        set(handles.uiPitTags4, 'enable', 'on', 'uicontextmenu', hcmenu(4))
        
end

previewIniFile

function pitTagSelect(~, ~, num, action)

fig = findobj('type', 'figure', 'tag', 'fig_OF_config');
handles = guidata(fig);

switch action
    
    case 'exc'
        set(handles.(['uiPitTags' num2str(num)]), 'string', 'XXXXXXXX')
    case 'inc'
        set(handles.(['uiPitTags' num2str(num)]), 'string', '????????')
    case 'cl'
        set(handles.(['uiPitTags' num2str(num)]), 'string', [])
        
end

previewIniFile

function config = OF_readIni(filename)

if exist(filename, 'file')~=2
    error('INI file not found');
end

sections = ini_getallsections(filename);

config.scenario.num = ini_getl('scenario', 'num', -1, filename);
config.siteid.zone = ini_gets('siteid', 'zone', 'XXXXXXXXXX', filename);

%% Time
config.time.wakeup_hour = ini_getl('time', 'wakeup_hour', -1, filename);
config.time.wakeup_minute = ini_getl('time', 'wakeup_minute', -1, filename);

config.time.sleep_hour = ini_getl('time', 'sleep_hour', -1, filename);
config.time.sleep_minute = ini_getl('time', 'sleep_minute', -1, filename);

%% Loggers
config.logs.separator = ini_gets('logs', 'separator', '', filename);
config.logs.birds = ini_getl('logs', 'birds', 0, filename);
config.logs.udid = ini_getl('logs', 'udid', 0, filename);
config.logs.events = ini_getl('logs', 'events', 0, filename);
config.logs.errors = ini_getl('logs', 'errors', 0, filename);
config.logs.battery = ini_getl('logs', 'battery', 0, filename);
config.logs.rfid = ini_getl('logs', 'rfid', 0, filename);
config.logs.temperature = ini_getl('logs', 'temperature', 0, filename);
config.logs.calibration = ini_getl('logs', 'calibration', 0, filename);

%% Attractive LEDs
if ismember('attractiveleds', sections)
    
    config.attractiveleds.red_a = ini_getl('attractiveleds', 'red_a', -1, filename);
    config.attractiveleds.green_a = ini_getl('attractiveleds', 'green_a', -1, filename);
    config.attractiveleds.blue_a = ini_getl('attractiveleds', 'blue_a', -1, filename);
    
    config.attractiveleds.red_b = ini_getl('attractiveleds', 'red_b', -1, filename);
    config.attractiveleds.green_b = ini_getl('attractiveleds', 'green_b', -1, filename);
    config.attractiveleds.blue_b = ini_getl('attractiveleds', 'blue_b', -1, filename);
    
    config.attractiveleds.alt_delay = ini_getl('attractiveleds', 'alt_delay', -1, filename);
    
    config.attractiveleds.on_hour = ini_getl('attractiveleds', 'on_hour', -1, filename);
    config.attractiveleds.on_minute = ini_getl('attractiveleds', 'on_minute', -1, filename);
    
    config.attractiveleds.off_hour = ini_getl('attractiveleds', 'off_hour', -1, filename);
    config.attractiveleds.off_minute = ini_getl('attractiveleds', 'off_minute', -1, filename);
    
    config.attractiveleds.pattern = ini_getl('attractiveleds', 'pattern', -1, filename);
    config.attractiveleds.pattern_percent = ini_getf('attractiveleds', 'pattern_percent', -1, filename);
    
end

%% Door
config.door.open_hour = ini_getl('door', 'open_hour', -1, filename);
config.door.open_minute = ini_getl('door', 'open_minute', -1, filename);
config.door.close_hour = ini_getl('door', 'close_hour', -1, filename);
config.door.close_minute = ini_getl('door', 'close_minute', -1, filename);
config.door.remain_open = ini_getbool('door', 'remain_open', false, filename);
config.door.open_delay = ini_getl('door', 'open_delay', -1, filename);
config.door.close_delay = ini_getl('door', 'close_delay', -1, filename);
config.door.close_position = ini_getl('door', 'close_position', -1, filename);
config.door.open_position = ini_getl('door', 'open_position', -1, filename);
config.door.closing_speed = ini_getl('door', 'closing_speed', -1, filename);
config.door.opening_speed = ini_getl('door', 'opening_speed', -1, filename);
config.door.habituation = ini_getl('door', 'habituation', -1, filename);

%%Reward
config.reward.enable = ini_getl('reward', 'enable', -1, filename);
config.reward.probability = ini_getl('reward', 'probability', -1, filename);
config.reward.timeout = ini_getl('reward', 'timeout', -1, filename);

%%Timeouts
config.timeouts.sleep = ini_getl('timeouts', 'sleep', -1, filename);
config.timeouts.pir = ini_getl('timeouts', 'pir', -1, filename);
config.timeouts.unique_visit = ini_getl('timeouts', 'unique_visit', -1, filename);

%%Security
if ismember('security', sections)
    config.security.bird_reward_reopen = ini_getl('security', 'bird_reward_reopen', -1, filename);
    config.security.guillotine = ini_getl('security', 'guillotine', -1, filename);
    config.security.guillotine_offset = ini_getl('security', 'guillotine_offset', -1, filename);
end

%%Punishment
config.punishment.delay = ini_getl('punishment', 'delay', -1, filename);
config.punishment.proba_threshold = ini_getl('punishment', 'proba_threshold', -1, filename);

%Check
config.check.food_level = ini_getl('check', 'food_level', -1, filename);

function OF_writeIni(config, pathname, filename)

if exist(fullfile(pathname, filename), 'file')==2
    delete(fullfile(pathname, filename))
end

fn = fieldnames(config);

for n = 1:numel(fn)
    
    ini.sections{n} = fn{n};
    fn2 = fieldnames(config.(fn{n}));
    
    for m = 1:numel(fn2)
        ini.keys{n}{m} = fn2{m};
        ini.values{n}{m} = config.(fn{n}).(fn2{m});
    end
    
end

ini_structtofile(ini, pathname, filename)