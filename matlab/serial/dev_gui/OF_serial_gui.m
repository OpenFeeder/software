function OF_serial_gui

% URL: https://github.com/OpenFeeder/softwares/tree/master/serial/matlab/gui01
% Author: Jerome Briot - https://github.com/JeromeBriot

comPort = 'COM36';

ton_min = 600;
ton_max = 2400;
autoscroll = 1;

echoCommands = true;
delay = 0.03;
ser = [];

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
    'name', 'OpenFeeder - Serial interface - Not connected', ...
    'visible', 'off', ...
    'CloseRequestFcn', @closeCOMWindow);

movegui(fig, 'center')

set(fig, 'visible', 'on');

uiSketchfactor = figSize(1)/140; % 140/105 mm => 800x600 px

%% Button Zone
uiButtonConnect = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 90 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Connect', ...
    'tag', 'uiButtonConnect', ...
    'callback', @connectCOM);
uiButtonDisconnect = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 90 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Disconnect', ...
    'tag', 'uiButtonDisconnect', ...
    'enable', 'off', ...
    'callback', @disconnectCOM);
uiButtonSetCurrentDate = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 75 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Set current date', ...
    'tag', 'uiButtonSetCurrentDate', ...
    'enable', 'off', ...
    'callback', @setCurrentDate);
uiButtonGetCurrentDate = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 75 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Get current date', ...
    'tag', 'uiButtonGetCurrentDate', ...
    'enable', 'off', ...
    'callback', @getCurrentDate);
uiButtonSetDate = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 60 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Set date', ...
    'tag', 'uiButtonSetDate', ...
    'enable', 'off', ...
    'callback', @setDate);
uiPopDay = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [30 65 8 5]*uiSketchfactor, ...
    'tag', 'TimDay', ...
    'string',  cellstr(num2str((1:31).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', str2double(datestr(now, 'dd')));
uiPopMonth = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [40 65 8 5]*uiSketchfactor, ...
    'tag', 'TimeMonth', ...
    'string',  cellstr(num2str((1:12).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', str2double(datestr(now, 'mm')));
uiPopYear = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [50 65 8 5]*uiSketchfactor, ...
    'tag', 'TimeYear', ...
    'string',  cellstr(num2str((1:20).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', str2double(datestr(now, 'yy')));
uiPopHour = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [30 60 8 5]*uiSketchfactor, ...
    'tag', 'TimeHour', ...
    'string',  cellstr(num2str((0:23).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 1+str2double(datestr(now, 'HH')));
uiPopMinute = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [40 60 8 5]*uiSketchfactor, ...
    'tag', 'TimeMinute', ...
    'string',  cellstr(num2str((0:59).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 1+str2double(datestr(now, 'MM')));
uiPopSecond = uicontrol(fig, ...
    'style', 'popupmenu', ...
    'units', 'pixels', ...
    'position', [50 60 8 5]*uiSketchfactor, ...
    'tag', 'TimeSecond', ...
    'string',  cellstr(num2str((0:59).', '%02d')), ...
    'fontweight', 'bold', ...
    'value', 1+str2double(datestr(now, 'SS')));

uiSynchroDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 45 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Synchro PC <=> OF', ...
    'tag', 'uiSynchroDoor', ...
    'enable', 'off', ...
    'callback', @synchroTime);

uiButtonCloseDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 30 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Close door', ...
    'tag', 'uiButtonCloseDoor', ...
    'enable', 'off', ...
    'callback', @closeDoor);
uiButtonOpenDoor = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 30 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Open door', ...
    'tag', 'uiButtonOpenDoor', ...
    'enable', 'off', ...
    'callback', @openDoor);
% uiButtonSliderDoor = uicontrol(fig, ...
%     'style', 'slider', ...
%     'units', 'pixels', ...
%     'position', [5 35 45 5]*uiSketchfactor, ...
%     'fontweight', 'bold', ...
%     'string', 'Close door', ...
%     'tag', 'uiButtonCloseDoor', ...
%     'enable', 'on', ...
%     'min', ton_min, ...
%     'max', ton_max, ...
%     'value', ton_min, ...
%     'SliderStep', [0.1 0.1], ...
%     'callback', @setDoorPosition);

uiButtonEmptyBuffer = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 5 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Empty buffer', ...
    'tag', 'uiButtonEmptyBuffer', ...
    'enable', 'off', ...
    'callback', @empty_uart_buffer);

uiButtonQuit = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 5 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Quit', ...
    'tag', 'uiButtonQuit', ...
    'enable', 'on', ...
    'callback', @closeCOMWindow);


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

    function connectCOM(~, ~)
        
        ser = instrfind('Port', comPort);
        
        if isempty(ser)
            ser = serial(comPort, ...
                'Terminator', {'CR/LF', '' }, ...
                'Timeout', 2, ...
                'BytesAvailableFcnMode', 'terminator', ...
                'BytesAvailableFcn', @readDataFromOF);
            pause(delay)
            fopen(ser);
        else
            if ~strcmp(ser.Status, 'open')
                fopen(ser);
            end
            
            set(ser, 'Terminator', {'CR/LF', '' }, ...
                'Timeout', 2, ...
                'BytesAvailableFcnMode', 'terminator', ...
                'BytesAvailableFcn', @readDataFromOF);
        end
        
        % Purge input buffer
        while(ser.BytesAvailable>0)
            fscanf(ser);
            pause(delay);
        end
        
        set(uiButtonConnect, 'enable', 'off')
        set(uiButtonDisconnect, 'enable', 'on')
        set(uiButtonSetCurrentDate, 'enable', 'on')
        set(uiButtonGetCurrentDate, 'enable', 'on')
        set(uiButtonSetDate, 'enable', 'on')
        set(uiSynchroDoor, 'enable', 'on')
        set(uiButtonOpenDoor, 'enable', 'on')
        set(uiButtonCloseDoor, 'enable', 'on')
        set(uiButtonEmptyBuffer, 'enable', 'on')
        
        set(fig, 'name', sprintf('OpenFeeder - Serial interface - Connected to port %s', comPort))
        
    end

    function disconnectCOM(~, ~)
        
        if strcmp(ser.Status, 'open')
            fclose(ser);
        end
        
        delete(ser)
        
        set(uiButtonConnect, 'enable', 'on')
        set(uiButtonDisconnect, 'enable', 'off')
        set(uiButtonSetCurrentDate, 'enable', 'off')
        set(uiButtonGetCurrentDate, 'enable', 'off')
        set(uiButtonSetDate, 'enable', 'off')
        set(uiSynchroDoor, 'enable', 'on')
        set(uiButtonOpenDoor, 'enable', 'off')
        set(uiButtonCloseDoor, 'enable', 'off')
        set(uiButtonEmptyBuffer, 'enable', 'off')
        
        set(fig, 'name', 'OpenFeeder - Serial interface - Not connected')
        
    end

    function populateCommunicationWindow(substr)
        
        
        if ~isempty(substr) && substr(1) == '>'
            
            substr = sprintf('<html><font color="#%02X%02X%02X"><b>%s</b></font></html>', ...
                text_color.state(1), ...
                text_color.state(2), ...
                text_color.state(3), ...
                substr);
            
        end
        
        str = get(uiCommunicationWindow, 'string');
        str = cellstr(str);
        n = numel(str);
        str{n+1} = substr;
        
        if autoscroll
            set(uiCommunicationWindow, 'string', str, 'value', numel(str));
        else
            set(uiCommunicationWindow, 'string', str);
        end
        
    end

    function readDataFromOF(~, ~)
        
        tmp = fscanf(ser);
        tmp = strrep(tmp,[13 10], '');
        str = strrep(tmp, 9, [32 32 32]);
        
        populateCommunicationWindow(str)
        
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
        
        sendCommand(event.Character)
        
    end

    function sendCommand(arg)
        
        if echoCommands
            
            str = sprintf('<html><font color="#%02X%02X%02X"><b>=> %s</b></font></html>', ...
                text_color.command(1), ...
                text_color.command(2), ...
                text_color.command(3), ...
                arg);
            
            populateCommunicationWindow(str)
            
        end
        fprintf(ser, arg, 'async');
        pause(delay)
        
    end

    function setCurrentDate(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'S');
            populateCommunicationWindow(str)
        end
        
        v = datevec (now);
        v(1) = v(1)-2000;
        
        fwrite(ser, uint8(['S' v]), 'async')
        
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
        
        fwrite(ser, uint8(['S' V]), 'async')
        
    end

    function getCurrentDate(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 't');
            populateCommunicationWindow(str)
        end
        
        fprintf(ser, 't', 'async');
        
    end

    function synchroTime(~, ~)
        
        num = 12;
        maxTime = 5;
        
        for n = 1:2
            
            % Query PC date and time
            PC_time = now;
            
            % Dont synchronize OF date and time during the first iteration to allow offsets computation
            if n > 1
                fwrite(ser, uint8(['S' datevec(PC_time)-[2000 0 0 0 0 0]]))
            end
            
            %     pause(delay)
            
            % Query OF date and time
            fwrite(ser, uint8('T'))
            
            tic;
            while(ser.BytesAvailable<num)
                t = toc;
                if t>maxTime
                    if ser.BytesAvailable==0
                        error('No reply from the OF after %ds (iteration %d).\nNo data received', maxTime, n);
                    else
                        c = fread(ser, [1 ser.BytesAvailable], '*char');
                        error('No reply from the OF after %ds (iteration %d).\n%d characters received: %s', maxTime, n, c);
                    end
                end
            end
            
            OF_time = fread(ser, [1 ser.BytesAvailable]);
            
            if ~any(OF_time(7:end))
                ext_rtc_available = false;
            else
                ext_rtc_available = true;
            end
            
            % Print dates and times in the console
            str = sprintf('\nPC : %s', datestr(PC_time, 'dd/mm/yyyy HH:MM:SS'));
            populateCommunicationWindow(str)
            str = sprintf('PIC: %02d/%02d/20%02d %02d:%02d:%02d', OF_time(3), OF_time(2), OF_time(1) , OF_time(4), OF_time(5), OF_time(6));
            populateCommunicationWindow(str)
            if ext_rtc_available
                str = sprintf('EXT: %02d/%02d/20%02d %02d:%02d:%02d', OF_time(9), OF_time(8), OF_time(7), OF_time(10), OF_time(11), OF_time(12));
            else
                str = sprintf('EXT: --/--/---- --:--:--');
            end
            populateCommunicationWindow(str)
            
            % Compute offset between PC and PIC date and time
            PIC_time = datenum(OF_time(1:6)+[2000 0 0 0 0 0]);
            
            if PC_time > PIC_time
                delta = PC_time-PIC_time;
                s = '+';
            else
                delta = PIC_time-PC_time;
                s = '-';
            end
            
            delta = datevec(delta);
            
            if delta(3) < 1                
                if delta(6)>9
                    str = sprintf('\nDiff PC-PIC: %c%02d:%02d:%.3f (%e)', s, delta(4:6) , datenum(delta));
                else
                    str = sprintf('\nDiff PC-PIC: %c%02d:%02d:0%.3f (%e)', s, delta(4:6) , datenum(delta));
                end
            else
                str = sprintf('\nDiff PC-PIC: greater than one day (%e)', datenum(delta));
            end
            populateCommunicationWindow(str)
            
            % Compute offset between PC and external module date and time (if available)
            if ext_rtc_available
                
                EXT_time = datenum(OF_time(7:end)+[2000 0 0 0 0 0]);
                
                if PC_time > EXT_time
                    delta = PC_time-EXT_time;
                    s = '+';
                else
                    delta = EXT_time-PC_time;
                    s = '-';
                end
                
                delta = datevec(delta);
                
                if delta(3) < 1                    
                    if delta(6)>9
                        str = sprintf('Diff PC-EXT: %c%02d:%02d:%.3f (%e)', s, delta(4:6) , datenum(delta));
                    else
                        str = sprintf('Diff PC-EXT: %c%02d:%02d:0%.3f (%e)', s, delta(4:6) , datenum(delta));
                    end                    
                else
                    str = sprintf('Diff PC-EXT: greater than one day (%e)', datenum(delta));
                end
                populateCommunicationWindow(str)
                
            else
                str = sprintf('Diff PC-EXT:  --:--:--.--- (0)');
                populateCommunicationWindow(str)
            end
            
        end
        
    end

    function openDoor(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'o');
            populateCommunicationWindow(str)
        end
        
        fprintf(ser, 'o', 'async');
        pause(delay)
        set(uiButtonSliderDoor, 'value', ton_max)
    end


    function closeDoor(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'c');
            populateCommunicationWindow(str)
        end
        
        fprintf(ser, 'c', 'async');
        pause(delay)
        set(uiButtonSliderDoor, 'value', ton_min)
    end

    function setDoorPosition(obj, ~)
        
        val = get(obj, 'value');
        val = uint16(round(val));
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'p');
            populateCommunicationWindow(str)
        end
        
        fprintf(ser, 'p', 'async');
        pause(delay)
        strv = num2str(val, '%04d');
        if echoCommands
            for n = 1:numel(strv)
                str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', strv(n));
                populateCommunicationWindow(str)
            end
        end
        
        fprintf(ser, strv, 'async');
        pause(delay)
        
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
        
        while(ser.BytesAvailable>0)
            fscanf(ser);
            pause(delay)
        end
        
    end

    function closeCOMWindow(~, ~)
        
        ser = instrfind('Port', comPort);
        
        if ~isempty(ser)
            
            disconnectCOM([],[])
            
        end
        
        closereq;
    end

end