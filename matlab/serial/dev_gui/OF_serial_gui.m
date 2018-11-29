function OF_serial_gui

% URL: https://github.com/OpenFeeder/softwares/tree/master/serial/matlab/gui01
% Author: Jerome Briot - https://github.com/JeromeBriot

version.major = 1;
version.minor = 0;
version.patch = 0;
about.author = 'Jerome Briot';
about.contact = 'jbtechlab@gmail.com';

if ispc
    defaultPath = fullfile(getenv('USERPROFILE'), 'Desktop');
else
    defaultPath = '~/Desktop';
end

% Default serial port
comPort = 'COM17';

% Serial communication parameters
baudRate = 115200;
parity = 'none';
stopBits = 1;
dataBits = 8;

% Special characters for communication
% stx = hex2dec('02');
% etx = hex2dec('03');
% enq = hex2dec('05');
% ack = hex2dec('06');
% dc4 = hex2dec('14');
% nack = hex2dec('15');

stx = hex2dec('FA');
etx = hex2dec('FB');
enq = hex2dec('FC');
ack = hex2dec('FD');
dc4 = hex2dec('FE');
nack = hex2dec('FF');

t_transfert = 0;
transfert_time = 0;

servoMinPosition = 600;
servoMaxPosition = 2400;

autoscroll = 1;
linebreak = false;

echoCommands = true;
delay = 0.03;
serialObj = [];

buffer = [];
files = [];

buffer_size = 50;

udid = '';
zone = '';

timeCalib.PC_time = 0;
timeCalib.deltaPic = 0;
timeCalib.deltaExt = 0;

text_color.state = [0 128 0];
text_color.command = [255 24 230];

fig = figure(1);
clf

figSize = [800 600];

set(fig, ...
    'units', 'pixels', ...
    'position', [0 0 figSize], ...
    'resize', 'off', ...
    'menubar', 'none', ...
    'numbertitle', 'off', ...
    'name', sprintf('OpenFeeder - Serial interface - v%d.%d.%d - Not connected', version.major, version.minor, version.patch), ...
    'visible', 'off', ...
    'CloseRequestFcn', @closeCOMWindow);

movegui(fig, 'center')

button_size = [20 5];
button_size_2 = [15 5];
uiSketchfactor = figSize(1)/140; % 140/105 mm => 800x600 px

frame_color = [.5 .5 .5];
frame_width = 0.3;

%% Button Zone
uiButtonConnect = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 98 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Connect', ...
    'tag', 'uiButtonConnect', ...
    'callback', @connectCOM);
uiButtonDisconnect = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 98 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Disconnect', ...
    'tag', 'uiButtonDisconnect', ...
    'enable', 'off', ...
    'callback', @disconnectCOM);
uiButtonSelectPort = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 98 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Select port', ...
    'tag', 'uiButtonSelectPort', ...
    'enable', 'on', ...
    'callback', @select_port);

uiButtonListCommand = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [52 99.5 5 5]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', '?', ...
    'tag', 'uiButtonListCommand', ...
    'enable', 'off', ...
    'callback', {@sendCommand, '?'});
uiButtonEmptyBuffer = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [52 94.5 5 5]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'X', ...
    'tag', 'uiButtonEmptyBuffer', ...
    'enable', 'off', ...
    'callback', @empty_uart_buffer);

uiUartRxFrame = uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [53 90.5 3 3]*uiSketchfactor, ...
    'tag', 'uiUartRxFrame', ...
    'backgroundcolor', frame_color);

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 96 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

% uiButtonSetCurrentDate = uicontrol(fig, ...
%     'units', 'pixels', ...
%     'position', [5 90 button_size]*uiSketchfactor, ...
%     'fontweight', 'bold', ...
%     'string', 'Set current date', ...
%     'tag', 'uiButtonSetCurrentDate', ...
%     'enable', 'off', ...
%     'callback', @setCurrentDate);

uiSynchroTime = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 90 button_size]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Synchro PC <=> OF', ...
    'tag', 'uiSynchroDoor', ...
    'enable', 'off', ...
    'callback', @synchroTime);
uiButtonGetCurrentDate = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 90 button_size]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Get current date', ...
    'tag', 'uiButtonGetCurrentDate', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 't'});
%     'callback', {@getCurrentDate);
uiButtonSetDate = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 82 button_size]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Set date', ...
    'tag', 'uiButtonSetDate', ...
    'enable', 'off', ...
    'callback', @setDate);
uiPopDay = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [28 84 8 5]*uiSketchfactor, ...
    'tag', 'TimDay', ...
    'string',  cellstr(num2str((1:31).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', str2double(datestr(now, 'dd')));
uiPopMonth = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [37 84 8 5]*uiSketchfactor, ...
    'tag', 'TimeMonth', ...
    'string',  cellstr(num2str((1:12).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', str2double(datestr(now, 'mm')));
uiPopYear = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [46 84 8 5]*uiSketchfactor, ...
    'tag', 'TimeYear', ...
    'string',  cellstr(num2str((1:20).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', str2double(datestr(now, 'yy')));
uiPopHour = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [28 79.5 8 5]*uiSketchfactor, ...
    'tag', 'TimeHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 1+str2double(datestr(now, 'HH')));
uiPopMinute = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [37 79.5 8 5]*uiSketchfactor, ...
    'tag', 'TimeMinute', ...
    'string',  cellstr(num2str((0:59).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 1+str2double(datestr(now, 'MM')));
uiPopSecond = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [46 79.5 8 5]*uiSketchfactor, ...
    'tag', 'TimeSecond', ...
    'string',  cellstr(num2str((0:59).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 1+str2double(datestr(now, 'SS')));

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 79 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiFileIOList = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 73 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'List files', ...
    'tag', 'uiFileIOList', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'jl'});

uiFileIOImport = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 73 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Import files', ...
    'tag', 'uiFileIOImport', ...
    'enable', 'off', ...
    'callback', {@fileio, 'imp'});

uiFileIOExport = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 73 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Export files', ...
    'tag', 'uiFileIOExport', ...
    'enable', 'off', ...
    'callback', {@fileio, 'exp'});

uiFileIOAllDelete = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 66 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Delete all files', ...
    'tag', 'uiFileIOAllDelete', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'jz'});

uiFileIOConfigDelete = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 66 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Delete config', ...
    'tag', 'uiFileIOConfigDelete', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'jv'});

uiFileIOEventsDelete = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 59 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Delete BIN', ...
    'tag', 'uiFileIOEventsDelete', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'jw'});

uiFileIOCsvDelete = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 59 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Delete CSV', ...
    'tag', 'uiFileIOCsvDelete', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'ju'});

uiFileIOLogDelete = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 59 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Delete LOG', ...
    'tag', 'uiFileIOLogDelete', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'jt'});

uiFlushData = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 66 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Flush data', ...
    'tag', 'uiFlushData', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'f'});

uiFileIOCsv = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 52.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display CSV', ...
    'tag', 'uiFileIOCsv', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'jc'});

uiFileIOIni = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 52.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display INI', ...
    'tag', 'uiFileIOIni', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'ji'});

uiFileIOErr = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 52.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display Errors', ...
    'tag', 'uiFileIOErr', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'je'});


uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 51 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiDataBuffers = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 45 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Data buffers', ...
    'tag', 'uiDataBuffers', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'b'});

uiConfigIni = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 45 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display Config.', ...
    'tag', 'uiConfigIni', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'cd'});

uiConfigRe = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 45 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Reconfigure', ...
    'tag', 'uiConfigRe', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'cr'});

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 43.5 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiMeasureBattery = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 37.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Battery', ...
    'tag', 'uiMeasureBattery', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'mb'});

uiMeasureVBat = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 37.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Vbat', ...
    'tag', 'uiMeasureVBat', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'mv'});

uiMeasureDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 37.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Door pos.', ...
    'tag', 'uiMeasureDoor', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'md'});

uiMeasureRfid = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 31 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'RFID freq.', ...
    'tag', 'uiMeasureRfid', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'mr'});

uiMeasureTemperature = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 31 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Temperature', ...
    'tag', 'uiMeasureTemperature', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'mt'});

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 30 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiButtonCloseDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 24.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Close door', ...
    'tag', 'uiButtonCloseDoor', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'dc'});
uiButtonOpenDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 24.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Open door', ...
    'tag', 'uiButtonOpenDoor', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'do'});
uiButtonSetDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 24.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Set position', ...
    'tag', 'uiButtonSetDoor', ...
    'enable', 'off', ...
    'callback', @setDoorPosition);

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 23.5 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiI2c = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 17.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'I2C scanner', ...
    'tag', 'uiI2c', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'l'});

uiStatusLeds = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 17.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Status LEDs', ...
    'tag', 'uiStatusLeds', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'q'});

uiTestRfid = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 17.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Test RFID', ...
    'tag', 'uiTestRfid', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'z'});

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 16 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiIRPower = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 10 button_size]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'IR power', ...
    'tag', 'uiIRPower', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'ip'});

uiIRStatus = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 10 button_size]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'IR status', ...
    'tag', 'uiIRStatus', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'is'});

uicontrol('style', 'frame', ...
    'units', 'pixels', ...
    'position', [5 8 45 frame_width]*uiSketchfactor, ...
    'backgroundcolor', frame_color);

uiInformation = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 1.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Information', ...
    'tag', 'uiInformation', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'h'});

uiUSBdevice = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [20 1.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'USB device', ...
    'tag', 'uiUSBdevice', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'k'});

uiUDID = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [35 1.5 button_size_2]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'UDID', ...
    'tag', 'uiUDID', ...
    'enable', 'off', ...
    'callback', {@sendCommand, 'u'});

%% Preview zone
uiCommunicationWindow = uicontrol(fig, ...
    'style', 'listbox', ...
    'units', 'pixels', ...
    'position', [60 0 80 105]*uiSketchfactor, ...
    'horizontalalignment', 'left', ...
    'fontweight', 'bold', ...
    'fontname', 'monospaced', ...
    'fontsize', 10, ...
    'tag', 'uiCommunicationWindow', ...
    'min', 0, ...
    'max', 2, ...
    'keypressfcn', @keyPressComWindow);

hcmenu = uicontextmenu;
uimenu(hcmenu, 'Label', 'Clear all', 'Callback', {@clearComWindow 'all'});
uimenu(hcmenu, 'Label', 'Clear selection', 'Callback', {@clearComWindow 'select'});
uimenu(hcmenu, 'Label', 'Copy all', 'Callback', {@copyComWindow 'all'}, 'separator', 'on');
uimenu(hcmenu, 'Label', 'Copy selection', 'Callback', {@copyComWindow 'select'});
autoscrollmenu = uimenu(hcmenu, 'Label', 'Auto scroll', 'Callback', @toggleAutoScroll, 'separator', 'on', ...
    'checked', 'on');
set(uiCommunicationWindow, 'uicontextmenu' ,hcmenu)

set(fig, 'visible', 'on', 'pointer', 'arrow');

% Timer to periodically read data sent by the Openfeeder
t = timerfind('tag', 'OF_serial_timer');
if ~isempty(t)
    stop(t)
    delete(t)
end
timerReadData = timer('ExecutionMode', 'fixedDelay', 'Period', 0.01, 'TimerFcn', @readDataFromOF, 'tag', 'OF_serial_timer');

    function connectCOM(~, ~)
        
        serialObj = instrfind('Port', comPort);
        
        if isempty(serialObj)
            serialObj = serial(comPort, ...
                'BaudRate', baudRate, ...
                'DataBits', dataBits, ...
                'Parity', parity, ...
                'StopBits', stopBits, ...
                'Timeout', 2, ...
                'InputBufferSize', 1024);
            
            try
                fopen(serialObj);
            catch ME
                errordlg(ME.message);
                return
            end
            
        else
            
            if ~strcmp(serialObj.Status, 'open')
                try
                    fopen(serialObj);
                catch ME
                    errordlg(ME.message);
                    return
                end
            end
            
            set(serialObj, ...
                'BaudRate', baudRate, ...
                'DataBits', dataBits, ...
                'Parity', parity, ...
                'StopBits', stopBits, ...
                'Timeout', 2, ...
                'InputBufferSize', 1024)
            
        end
        
        % Purge input buffer
        while(serialObj.BytesAvailable>0)
            fread(serialObj, serialObj.BytesAvailable);
        end
        
        if strcmpi(timerReadData.Running, 'off')
            start(timerReadData)
        end
        
        set(uiButtonConnect, 'enable', 'off')
        set(uiButtonDisconnect, 'enable', 'on')
        set(uiButtonSelectPort, 'enable', 'off')
        set(uiButtonEmptyBuffer, 'enable', 'on')
        set(uiButtonListCommand, 'enable', 'on')
        
        set(uiButtonGetCurrentDate, 'enable', 'on')
        set(uiButtonSetDate, 'enable', 'on')
        set(uiSynchroTime, 'enable', 'on')
        
        set(uiFileIOList, 'enable', 'on')
        set(uiFileIOImport, 'enable', 'on')
        set(uiFileIOExport, 'enable', 'on')
        set(uiFileIOAllDelete, 'enable', 'on')
        set(uiFileIOConfigDelete, 'enable', 'on')
        set(uiFileIOEventsDelete, 'enable', 'on')
        set(uiFileIOCsvDelete, 'enable', 'on')
        set(uiFileIOLogDelete, 'enable', 'on')

        set(uiFileIOCsv, 'enable', 'on')
        set(uiFileIOIni, 'enable', 'on')
        set(uiFileIOErr, 'enable', 'on')
        
        
        set(uiDataBuffers, 'enable', 'on')
        set(uiFlushData, 'enable', 'on')

        set(uiButtonOpenDoor, 'enable', 'on')
        set(uiButtonCloseDoor, 'enable', 'on')
        set(uiButtonSetDoor, 'enable', 'on')
        
        set(uiConfigIni, 'enable', 'on')
        set(uiConfigRe, 'enable', 'on')
        
        set(uiMeasureBattery, 'enable', 'on')
        set(uiMeasureVBat, 'enable', 'on')
        set(uiMeasureDoor, 'enable', 'on')
        set(uiMeasureRfid, 'enable', 'on')
        set(uiMeasureTemperature, 'enable', 'on')
        
        set(uiI2c, 'enable', 'on')
        set(uiStatusLeds, 'enable', 'on')
        set(uiTestRfid, 'enable', 'on')
        
        set(uiIRPower, 'enable', 'on')
        set(uiIRStatus, 'enable', 'on')
        
        set(uiInformation, 'enable', 'on')
        set(uiUSBdevice, 'enable', 'on')
        set(uiUDID, 'enable', 'on')
 
        set(fig, 'name', sprintf('OpenFeeder - Serial interface - v%d.%d.%d - Connected to port %s ', version.major, version.minor, version.patch, comPort))
    end

    function disconnectCOM(~, ~)
        
        if strcmp(serialObj.Status, 'open')
            if strcmpi(timerReadData.Running, 'on')
                stop(timerReadData)
            end
            fclose(serialObj);
        end
        
        set(uiButtonConnect, 'enable', 'on')
        set(uiButtonDisconnect, 'enable', 'off')
        set(uiButtonSelectPort, 'enable', 'on')
        set(uiButtonEmptyBuffer, 'enable', 'off')
        set(uiButtonListCommand, 'enable', 'off')
        
        set(uiButtonGetCurrentDate, 'enable', 'off')
        set(uiButtonSetDate, 'enable', 'off')
        set(uiSynchroTime, 'enable', 'off')
        
        set(uiFileIOList, 'enable', 'off')
        set(uiFileIOImport, 'enable', 'off')
        set(uiFileIOExport, 'enable', 'off')
        set(uiFileIOAllDelete, 'enable', 'off')
        set(uiFileIOConfigDelete, 'enable', 'off')
        set(uiFileIOEventsDelete, 'enable', 'off')
        set(uiFileIOCsvDelete, 'enable', 'off')
        set(uiFileIOLogDelete, 'enable', 'off')
        
        set(uiFileIOCsv, 'enable', 'off')
        set(uiFileIOIni, 'enable', 'off')
        set(uiFileIOErr, 'enable', 'off')
        
        set(uiDataBuffers, 'enable', 'off')
        set(uiFlushData, 'enable', 'off')
        
        set(uiButtonOpenDoor, 'enable', 'off')
        set(uiButtonCloseDoor, 'enable', 'off')
        set(uiButtonSetDoor, 'enable', 'off')
        
        set(uiConfigIni, 'enable', 'off')
        set(uiConfigRe, 'enable', 'off')
        
        set(uiMeasureBattery, 'enable', 'off')
        set(uiMeasureVBat, 'enable', 'off')
        set(uiMeasureDoor, 'enable', 'off')
        set(uiMeasureRfid, 'enable', 'off')
        set(uiMeasureTemperature, 'enable', 'off')
        
        set(uiI2c, 'enable', 'off')
        set(uiStatusLeds, 'enable', 'off')
        set(uiTestRfid, 'enable', 'off')
        
        set(uiIRPower, 'enable', 'off')
        set(uiIRStatus, 'enable', 'off')
        
        set(uiInformation, 'enable', 'off')
        set(uiUSBdevice, 'enable', 'off')
        set(uiUDID, 'enable', 'off')
        
        set(uiUartRxFrame, 'backgroundcolor', frame_color);
        
        set(fig, 'name', sprintf('OpenFeeder - Serial interface - v%d.%d.%d - Not connected', version.major, version.minor, version.patch))
        
    end

    function select_port(~, ~)
        
        prompt = {'Enter serial port:'};
        dlg_title = 'Port selection';
        num_lines = 1;
        defaultans = {comPort};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if isempty(answer)
            return
        end
        
        if ispc
            if ~strncmpi(answer{1}, 'COM', 3)
                errordlg('Port name must start with COM');
            end
        end
        
        comPort = answer{1};
        
    end

    function populateCommunicationWindow(substr)
        
        try
            C = {};
            
            str = get(uiCommunicationWindow, 'string');
            str = cellstr(str);
            n = numel(str);
            
            substr = char(substr);
            substr = strrep(substr, char(9), '   ');
            
            if isempty(substr)
                return
            end
            
            if any(substr==13)
                
                idx = substr==10;
                if any(idx)
                    substr(idx) = [];
                end
                
                C = strsplit(substr, char(13)).';
                if isempty(C{end})
                    C(end) = [];
                end
                
            elseif any(substr==10)
                
                C = strsplit(substr, char(10)).';
                if isempty(C{end})
                    C(end) = [];
                end
                
            else
                
                C = {substr};
                
            end
            
            if isempty(C)
                return
            end
            
            for k = 1:numel(C)
                if ~isempty(C{k}) && C{k}(1)=='>'
                    C{k} = sprintf('<html><font color="#%02X%02X%02X"><b>%s</b></font></html>', ...
                        text_color.state(1), ...
                        text_color.state(2), ...
                        text_color.state(3), ...
                        C{k});
                end
            end
            
            if isempty(str)
                str = C;
            else
                if linebreak
                    str = [str ; C];
                else
                    str{n} = [str{n} C{1}];
                    if numel(C)>1
                        str = [str ; C(2:end)];
                    end
                end
            end
            
            if substr(end)==13
                linebreak = true;
            else
                linebreak = false;
            end
            
            if autoscroll
                set(uiCommunicationWindow, 'string', str, 'value', numel(str));
            else
                set(uiCommunicationWindow, 'string', str);
            end
            
            drawnow
            
        catch ME
            
            disp(ME.identifier)
            disp(ME.message)
            disp(ME.cause)
            for u = 1 :numel(ME.stack)
                disp(ME.stack(u).file)
                disp(ME.stack(u).name)
                disp(ME.stack(u).line)
            end
            
        end
        
    end

    function readDataFromOF(~, ~)
        
        bytesAvailable = serialObj.BytesAvailable;
        
        if bytesAvailable==0
            set(uiUartRxFrame, 'backgroundcolor', frame_color);
            return
        end
        
        set(uiUartRxFrame, 'backgroundcolor', 'g');
        
        drawnow
        
        buf = fread(serialObj, [1,bytesAvailable], 'char');
        
        populateCommunicationWindow(buf)
        
    end

    function clearComWindow(~, ~, flag)
        
        if strcmpi(flag, 'all')
            set(uiCommunicationWindow, 'string', {}, 'value', 0)
        else
            idx = get(uiCommunicationWindow, 'value');
            str = get(uiCommunicationWindow, 'string');
            if isempty(str)
                return
            end
            str(idx) = [];
            
            set(uiCommunicationWindow, 'string', str, 'value', idx(1)-1)
        end
    end

    function copyComWindow(~, ~, flag)
        
        if strcmpi(flag, 'all')
            str = get(uiCommunicationWindow, 'string');
        else
            idx = get(uiCommunicationWindow, 'value');
            str = get(uiCommunicationWindow, 'string');
            str = str(idx);
        end
        
        str = removeTextDecoration(str);
        str = sprintf('%s\n', str{:});
        clipboard('copy', str)
        
    end

    function str = removeTextDecoration(str)
        
        fn = fieldnames(text_color);
        
        for n = 1:numel(fn)
            html = sprintf('<html><font color="#%02X%02X%02X"><b>', text_color.(fn{n})(1), text_color.(fn{n})(2), text_color.(fn{n})(3));
            str = strrep(str, html, '');
        end
        str = strrep(str, '</b></font></html>', '');
        
    end

    function keyPressComWindow(~, event)
        
        if strcmp(event.Key, 'shift') || strcmp(event.Key, 'alt') || strcmp(event.Key, 'control')
            return
        end
        
        sendCommand([], [], event.Character)
        
    end

    function sendCommand(~, ~, arg)
        
        if echoCommands
            
            str = sprintf('<html><font color="#%02X%02X%02X"><b>=> %s</b></font></html>', ...
                text_color.command(1), ...
                text_color.command(2), ...
                text_color.command(3), ...
                arg);
            
            populateCommunicationWindow(str)
            
            linebreak = true;
            
        end
        
        fwrite(serialObj, uint8(arg));
        
    end

    function setDate(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'S');
            populateCommunicationWindow(str)
        end
        
        val = get(uiPopYear, 'value');
        str = get(uiPopYear, 'string');
        V(1) = str2double(str{val});
        val = get(uiPopMonth, 'value');
        str = get(uiPopMonth, 'string');
        V(2) = str2double(str{val});
        val = get(uiPopDay, 'value');
        str = get(uiPopDay, 'string');
        V(3) = str2double(str{val});
        val = get(uiPopHour, 'value');
        str = get(uiPopHour, 'string');
        V(4) = str2double(str{val});
        val = get(uiPopMinute, 'value');
        str = get(uiPopMinute, 'string');
        V(5) = str2double(str{val});
        val = get(uiPopSecond, 'value');
        str = get(uiPopSecond, 'string');
        V(6) = str2double(str{val});
        
        fwrite(serialObj, uint8(['S' V]))
        
    end

    function synchroTime(~, ~)
        
        pause(.2);
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'T');
            populateCommunicationWindow(str)
        end
        
        if strcmpi(timerReadData.Running, 'on')
            stop(timerReadData)
        end
        
        num = 12;
        maxTime = 7;
        
        for n = 1:2
            
            empty_uart_buffer;
            
            % Dont synchronize OF date and time during the first iteration to allow offsets computation
            if n > 1
                % Query PC date and time
                tmp = now;
                PC_time = now;
                while (PC_time-tmp)<0.000011574074074 % 1/86400 => 1s
                    PC_time = now;
                end
                fwrite(serialObj, uint8(['S' datevec(PC_time)-[2000 0 0 0 0 0]]))
                pause(2);
            end
            
            % Query PC date and time
            tmp = now;
            PC_time = now;
            while (PC_time-tmp)<0.000011574074074 % 1/86400 => 1s
                PC_time = now;
            end
            
            T1 = tic;
            % Query OF date and time
            fwrite(serialObj, uint8('T'))
            
            T2 = tic;
            while(serialObj.BytesAvailable<num)
                t = toc(T2);
                if t>maxTime
                    if serialObj.BytesAvailable==0
                        error('No reply from the OF after %ds (iteration %d).\nNo data received', maxTime, n);
                    else
                        c = fread(serialObj, [1 serialObj.BytesAvailable], '*char');
                        error('No reply from the OF after %ds (iteration %d).\n%d characters received: %s', maxTime, n, c);
                    end
                end
            end
            
            OF_time = fread(serialObj, [1 num]);
            if numel(OF_time)~=num
                error('Wrong number of bytes read.')
            end
            
            if ~any(OF_time(7:end))
                ext_rtc_available = false;
            else
                ext_rtc_available = true;
            end
            
            t = toc(T1);
            
            PC_time = PC_time + t*0.000011574074074;
            
            if n==1
                timeCalib.PC_time = PC_time;
            end
            
            if n==1
                str = sprintf('\r\nBefore calibration:');
            else
                str = sprintf('\r\nAfter calibration:');
            end
            populateCommunicationWindow(str)
            
            % Print dates and times in the console
            str = sprintf('\r\nPC : %s\r\n', datestr(PC_time, 'dd/mm/yyyy HH:MM:SS'));
            populateCommunicationWindow(str)
            str = sprintf('PIC: %02d/%02d/20%02d %02d:%02d:%02d\r\n', OF_time(3), OF_time(2), OF_time(1) , OF_time(4), OF_time(5), OF_time(6));
            populateCommunicationWindow(str)
            if ext_rtc_available
                str = sprintf('EXT: %02d/%02d/20%02d %02d:%02d:%02d\r\n', OF_time(9), OF_time(8), OF_time(7), OF_time(10), OF_time(11), OF_time(12));
            else
                str = sprintf('EXT: --/--/---- --:--:--\r\n');
            end
            populateCommunicationWindow(str)
            
            % Compute offset between PC and PIC date and time
            PIC_time = datenum(OF_time(1:6)+[2000 0 0 0 0 0]);
            
            if PC_time > PIC_time
                deltaPic = PC_time-PIC_time;
                s = '+';
            else
                deltaPic = PIC_time-PC_time;
                s = '-';
            end
            
            if n==1
                timeCalib.deltaPic = deltaPic;
            end
            
            deltaPic = datevec(deltaPic);
            
            if deltaPic(3) < 1
                str = sprintf('\r\nDiff PC-PIC: %c%02d:%02d:%02d (%e)\r\n', s, floor(deltaPic(4:6)) , datenum(deltaPic));
            else
                str = sprintf('\r\nDiff PC-PIC: greater than one day (%e)\r\n', datenum(deltaPic));
            end
            populateCommunicationWindow(str)
            
            % Compute offset between PC and external module date and time (if available)
            if ext_rtc_available
                
                EXT_time = datenum(OF_time(7:end)+[2000 0 0 0 0 0]);
                
                if PC_time > EXT_time
                    deltaExt = PC_time-EXT_time;
                    s = '+';
                else
                    deltaExt = EXT_time-PC_time;
                    s = '-';
                end
                
                if n==1
                    timeCalib.deltaExt = deltaExt;
                end
                
                deltaExt = datevec(deltaExt);
                
                if deltaExt(3) < 1
                    str = sprintf('Diff PC-EXT: %c%02d:%02d:%02d (%e)\r\n', s, floor(deltaExt(4:6)) , datenum(deltaExt));
                else
                    str = sprintf('Diff PC-EXT: greater than one day (%e)\r\n', datenum(deltaExt));
                end
                populateCommunicationWindow(str)
                
            else
                timeCalib.deltaExt = NaN;
                str = sprintf('Diff PC-EXT:  --:--:-- (0)\r\n');
                populateCommunicationWindow(str)
            end
            
        end
        
        saveCalibInfos();
        
        if strcmpi(timerReadData.Running, 'off')
            start(timerReadData)
        end
        
    end

    function saveCalibInfos(~, ~)
        
        getUdid;
        
        if strcmp(udid, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
            str = sprintf('\r\nWarning UDID incorrect\r\n');
            populateCommunicationWindow(str)
        end
        
        getZone;
        
        if strcmp(zone, 'XXXX')
            str = sprintf('\r\nWarning zone incorrect\r\n');
            populateCommunicationWindow(str)
        end
        
        filename = fullfile(defaultPath, 'OF_calibrations.csv');
        
        fid = fopen(filename, 'at');
        
        fprintf(fid, '%s,%s,%s,%.3f,%.3f\n', datestr(timeCalib.PC_time, 'dd/mm/yyyy,HH:MM:SS'), zone, udid([23 24 29 30]), timeCalib.deltaPic/0.000011574074074, timeCalib.deltaExt/0.000011574074074);
        
        fclose(fid);
        
        str = sprintf('\r\nCalibration data appended to file:\r\n%s\r\n', filename);
        populateCommunicationWindow(str)
        
    end

    function getUdid(~, ~)
        
        empty_uart_buffer;
        
        fwrite(serialObj, uint8('u'))
        pause(1)
        tmp = fread(serialObj, [1, serialObj.BytesAvailable], 'char');
        
        tmp = strrep(tmp, 'UDID:', '');
        idx = isstrprop(tmp, 'wspace');
        udid = char(tmp(~idx));
        
        if numel(udid)~=30
            udid = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
        end
        
    end

    function getZone(~, ~)
        
        empty_uart_buffer;
        
        fwrite(serialObj, uint8('ji'))
        pause(1)
        tmp = fread(serialObj, [1, serialObj.BytesAvailable], 'char');
        
        tmp = strsplit(char(tmp), char([13 10]));
        idx = strncmp(tmp, 'zone=', 5);
        if any(idx)
            zone = strrep(tmp{idx}, 'zone=', '');
        else
            zone = 'XXXX';
        end
        
    end

    function fileio(~, ~, action)
        
        switch action
            
            case 'imp'
                
                try
                    
                    choice = questdlg('Do you really want to import files from the OF?', ...
                        'Files import', 'Yes', 'No', 'No');
                    
                    if strcmpi(choice, 'No')        
                        return
                    end

                    choice = questdlg('Don''t forget to flush data before import?', ...
                        'Flush before import', 'Continue', 'Abort', 'Abort');
                    
                    if strcmpi(choice, 'Abort')        
                        return
                    end
                    
                    if strcmpi(timerReadData.Running, 'on')
                        stop(timerReadData)
                    end
                    set(timerReadData, 'TimerFcn', @readDataFromOFToBuffer)
                    if strcmpi(timerReadData.Running, 'off')
                        start(timerReadData)
                    end
                    
                    fwrite(serialObj, uint8('jx'))
                    
                    if echoCommands
                        str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>\r\n', 'X');
                        populateCommunicationWindow(str)
                    end
                    
                    populateCommunicationWindow(sprintf('   Import in progress. Please wait...\r\n'))
                    
                    set(gcf, 'pointer', 'watch')
                    
                    t_transfert = tic();
                    
                catch ME
                    
                    disp(ME.identifier)
                    disp(ME.message)
                    disp(ME.cause)
                    for u = 1 :numel(ME.stack)
                        disp(ME.stack(u).file)
                        disp(ME.stack(u).name)
                        disp(ME.stack(u).line)
                    end
                    
                end
                
            case 'exp'
                
                choice = questdlg('Do you really want to export files to the OF?', ...
                    'Files export', 'Yes', 'No', 'No');
                
                if strcmpi(choice, 'No')
                    return
                end
                
                p = uigetdir();

                if ~p
                    return
                end
                
                fwrite(serialObj, uint8('ja'))
                if echoCommands
                    str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>\r\n', 'ja');
                    populateCommunicationWindow(str)
                end
                
                if strcmpi(timerReadData.Running, 'on')
                    stop(timerReadData)
                end

                d = dir(fullfile(p, '*.*'));
                
                d([d.isdir]) = [];
                
                fwrite(serialObj, uint8(numel(d)))
                
                for n = 1:numel(d)

                    fwrite(serialObj, uint8([numel(d(n).name) d(n).name]))
                    
                    num = numel(d(n).name)+5;
                    while(serialObj.BytesAvailable<num)
%                         t = toc(T2);
%                         if t>maxTime
%                             if serialObj.BytesAvailable==0
%                                 error('No reply from the OF after %ds (iteration %d).\nNo data received', maxTime, n);
%                             else
%                                 c = fread(serialObj, [1 serialObj.BytesAvailable], '*char');
%                                 error('No reply from the OF after %ds (iteration %d).\n%d characters received: %s', maxTime, n, c);
%                             end
%                         end
                    end
            
                    X = fread(serialObj, [1 num]);
                    
                    file_name_size = X(2);
                    file_name = char(X(4:end-2));
                    
                    if file_name_size==numel(d(n).name) && strcmp(file_name,d(n).name)
                        
                        fwrite(serialObj, uint8(1))
                        
                        fid = fopen(fullfile(p, d(n).name), 'r');
                        
                        for q = 1:floor(d(n).bytes/buffer_size)
                            
                            X = fread(fid, [1,buffer_size]);
                            fwrite(serialObj, uint8([buffer_size X]))
                            
                            num = 1;
                        
                            while(serialObj.BytesAvailable<num)

                            end

                            X = fread(serialObj, [1 num]);
                        
                        end
                        
                        m = mod(d(n).bytes, buffer_size);
                        if m==0
                            fwrite(serialObj, uint8(0))
                        else                            
                            X = fread(fid, [1,m]);
                            fwrite(serialObj, uint8([m X 0]))
                        end
                        
                        fclose(fid);
                        
                        num = 1;
                        
                        while(serialObj.BytesAvailable<num)
                            
                        end
                        
                        X = fread(serialObj, [1 num]);
                        
                        num = 1;
                        
                        while(serialObj.BytesAvailable<num)
                            
                        end
                        
                        X = fread(serialObj, [1 num]);
                        
                        str = sprintf('\t%s exported.\r\n', file_name);
                        populateCommunicationWindow(str)
                        
                    else
                        
                        fwrite(serialObj, uint8(0))
                        
                        str = sprintf('\t%s failed to export.\r\n', file_name);
                        populateCommunicationWindow(str)
                        break;
                        
                    end

                    
                end
                
                str = sprintf('\r\n\t/!\\ Reconfigure OF is needed.\r\n');
                populateCommunicationWindow(str)
                
                if strcmpi(timerReadData.Running, 'off')
                    start(timerReadData)
                end
                
        end
        
    end

    function readDataFromOFToBuffer(~, ~)
        
        try
            if serialObj.BytesAvailable==0
                set(uiUartRxFrame, 'backgroundcolor', frame_color);
                return
            end
            
            set(uiUartRxFrame, 'backgroundcolor', 'g');
            
            tmp = fread(serialObj, [1, serialObj.BytesAvailable], 'char');
            
            % Detect start of transmitted frame [STX]
            if any(tmp==stx)
                idx_stx = strfind(tmp, stx);
                if idx_stx>1
                    tmp(1:idx_stx-1) = [];
                end
                buffer = [];
            end
            
            % Detect end of transmitted frame [ETX]
            if any(tmp==etx)
                
                if strcmpi(timerReadData.Running, 'on')
                    stop(timerReadData)
                end
                
                idx_etx = strfind(tmp, etx);
                if idx_etx > numel(tmp)
                    tmp(idx_etx+1:end) = [];
                end
                
                buffer = [buffer tmp];
                
                transfert_time = toc(t_transfert);
                
                assignin('base', 'buffer', buffer);
                
                parseBuffer();
                
            end
            
            buffer = [buffer tmp];
            
        catch ME
            
            disp(ME.identifier)
            disp(ME.message)
            disp(ME.cause)
            for u = 1 :numel(ME.stack)
                disp(ME.stack(u).file)
                disp(ME.stack(u).name)
                disp(ME.stack(u).line)
            end
            
        end
        
    end

    function parseBuffer()
        
        populateCommunicationWindow(sprintf('   Transfert total: %d bytes\r\n', numel(buffer)));
        populateCommunicationWindow(sprintf('   Transfert time: %d s\r\n', round(transfert_time)));
        populateCommunicationWindow(sprintf('   Transfert rate: %d bytes/s\r\n', round(numel(buffer)/transfert_time)));
        
        idx_ck = buffer==stx | buffer==etx;
        
        if ~isempty(idx_ck)
            buffer(idx_ck) = [];
        end
        
        idx_ck = find(buffer==ack | buffer==nack);
        idx_enq = find(buffer==enq);
        idx_dc4 = find(buffer==dc4);
        
        if numel(idx_enq)~=numel(idx_ck)-1
            %TODO
        end
        
        if numel(idx_enq)~=numel(idx_dc4)
            %TODO
        end
        
        idx_data = 1;
        
        k_file = 0;
        k_error = 0;
        
        for n = 1:numel(idx_enq)
            
            buf = buffer(idx_enq(n)+1:idx_dc4(n)-1);
            
            if buffer(idx_enq(n)-1)==ack
                
                if idx_data==1
                    k_file = k_file+1;
                    files.name{k_file} = char(buf);
                    idx_data = idx_data+1;
                elseif idx_data==2
                    files.type(k_file) = char(buf);
                    idx_data = idx_data+1;
                elseif idx_data==3
                    files.size(k_file) = str2double(char(buf));
                    idx_data = idx_data+1;
                else
                    files.content{k_file} = buf;
                    idx_data = 1;
                end
                
            else
                
                k_error = k_error+1;
                errors{k_error} = char(buf);
                
            end
            
        end
        
        buffer = [];
        
        set(gcf, 'pointer', 'arrow')
        
        saveDataToFiles()
        
        set(timerReadData, 'TimerFcn', @readDataFromOF)
        if strcmpi(timerReadData.Running, 'off')
            start(timerReadData)
        end
        
    end

    function saveDataToFiles()
        
        folder_name = uigetdir(defaultPath);
        
        if ~folder_name
            populateCommunicationWindow(sprintf('\tImport aborted.\r\n'))
            return
        end
        
        success = true;
        
        for n = 1:numel(files.name)
            
            fid = fopen(fullfile(folder_name, files.name{n}), 'w');
            fwrite(fid, files.content{n});
            fclose(fid);
            
            if files.size(n)==numel(files.content{n})
                populateCommunicationWindow(sprintf('\t%s saved. File size OK.\r\n', files.name{n}))
            else
                populateCommunicationWindow(sprintf('\t%s saved. File size PB.\r\n\t\tSize should be %d but %s read.\r\n', files.name{n}, files.size(n), numel(files.content{n}))) 
                success = false;
            end
            
        end
        
        if success == false
           populateCommunicationWindow(sprintf('\n\t/!\\ Problem during importation. See above.\r\n')) 
        end
        
        files = [];
        
    end

%     function parseError()
%
%         populateCommunicationWindow(sprintf('\tError: %s\r\n', char(buffer)))
%
%     end

    function setDoorPosition(~, ~)
        
        answer = inputdlg({'Set door position'}, 'OF', 1, {'900'});
        
        val = str2double(answer{1});
        
        if val < servoMinPosition || val > servoMaxPosition
            errordlg(sprintf('Servo position must be in the range [%d %d]', servoMinPosition, servoMaxPosition));
            return
        end
        
        val = uint16(round(val));
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>\r\n', 'p');
            populateCommunicationWindow(str)
        end
        
        strv = num2str(val, '%04d');
        
        if echoCommands
            for n = 1:numel(strv)
                str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>\r\n', strv(n));
                populateCommunicationWindow(str)
            end
        end
        
        fwrite(serialObj, uint8(['dp' strv]));
        
    end

    function toggleAutoScroll(~, ~)
        
        autoscroll = ~autoscroll;
        if autoscroll
            set(autoscrollmenu, 'checked', 'on');
        else
            set(autoscrollmenu, 'checked', 'off');
        end
        
    end

    function empty_uart_buffer(~, ~)
        
        while(serialObj.BytesAvailable>0)
            fread(serialObj, serialObj.BytesAvailable);
            pause(delay)
        end
        
    end

    function closeCOMWindow(~, ~)
        
        serialObj = instrfind('Port', comPort);
        
        if ~isempty(serialObj)
            disconnectCOM([],[])
            delete(serialObj);
            delete(timerReadData)
        end
        
        closereq;
    end

end