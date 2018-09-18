function OF_export_files_from_OF

% Author: Jerome Briot - https://github.com/JeromeBriot

comPort = 'COM41';

% Special characters for communication
stx = hex2dec('02');
etx = hex2dec('03');
enq = hex2dec('05');
ack = hex2dec('06');
dc4 = hex2dec('14');
nack = hex2dec('15');

autoscroll = 1;

echoCommands = true;
delay = 0.03;
s = [];

buffer = [];
files = [];

text_color.state = [0 128 0];
text_color.command = [255 24 230];

fig = figure(2);
clf

figSize = [800 600];

set(fig, ...
    'units', 'pixels', ...
    'position', [0 0 figSize], ...
    'resize', 'off', ...
    'menubar', 'none', ...
    'numbertitle', 'off', ...
    'name', 'OpenFeeder - File I/O - Not connected', ...
    'visible', 'off', ...
    'CloseRequestFcn', @closeCOMWindow, ...
    'Pointer', 'arrow');

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
uiButtonListFiles = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 75 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'List files', ...
    'tag', 'uiButtonListFiles', ...
    'enable', 'off', ...
    'callback', @listFiles);
uiButtonDisplayIni = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 75 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display INI', ...
    'tag', 'uiButtonDisplayIni', ...
    'enable', 'off', ...
    'callback', {@displayFiles, 'INI'});
uiButtonDisplayCsv = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 60 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display CSV', ...
    'tag', 'uiButtonDisplayCsv', ...
    'enable', 'off', ...
    'callback', {@displayFiles, 'CSV'});
uiButtonDisplayErr = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [30 60 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Display Errors', ...
    'tag', 'uiButtonDisplayErr', ...
    'enable', 'off', ...
    'callback', {@displayFiles, 'ERR'});

uiButtonExportFiles = uicontrol(fig, ...
    'units', 'pixels', ...
    'position', [5 45 20 10]*uiSketchfactor, ...
    'fontweight', 'bold', ...
    'string', 'Export files', ...
    'tag', 'uiButtonExportFiles', ...
    'enable', 'off', ...
    'callback', @exportAllFiles);

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
        
        s = instrfind('Port', comPort);
        
        if isempty(s)
            s = serial(comPort, ...
                'Terminator', {'CR/LF', '' }, ...
                'Timeout', 2, ...
                'BytesAvailableFcnMode', 'terminator', ...
                'BytesAvailableFcn', @readDataFromOF);
            pause(delay)
            fopen(s);
        else
            if ~strcmp(s.Status, 'open')
                fopen(s);
            end
            
            set(s, 'Terminator', {'CR/LF', '' }, ...
                'Timeout', 2, ...
                'BytesAvailableFcnMode', 'terminator', ...
                'BytesAvailableFcn', @readDataFromOF);
        end
        
        % Purge input buffer
        while(s.BytesAvailable>0)
            fscanf(s);
            pause(delay);
        end
        
        set(uiButtonConnect, 'enable', 'off')
        set(uiButtonDisconnect, 'enable', 'on')
        set(uiButtonListFiles, 'enable', 'on')
        set(uiButtonDisplayIni, 'enable', 'on')
        set(uiButtonDisplayCsv, 'enable', 'on')
        set(uiButtonDisplayErr, 'enable', 'on')
        set(uiButtonExportFiles, 'enable', 'on')        
        set(uiButtonEmptyBuffer, 'enable', 'on')
        
        set(fig, 'name', sprintf('OpenFeeder - File I/O - Connected to port %s', comPort))
        
    end

    function disconnectCOM(~, ~)
        
        if strcmp(s.Status, 'open')
            fclose(s);
        end
        
        delete(s)
        
        set(uiButtonConnect, 'enable', 'on')
        set(uiButtonDisconnect, 'enable', 'off')
        set(uiButtonListFiles, 'enable', 'off')
        set(uiButtonDisplayIni, 'enable', 'off')
        set(uiButtonDisplayCsv, 'enable', 'off')
        set(uiButtonDisplayErr, 'enable', 'off')
        set(uiButtonExportFiles, 'enable', 'off')
        set(uiButtonEmptyBuffer, 'enable', 'off')
        
         set(fig, 'name', 'OpenFeeder - File I/O - Not connected')
         
    end

    function listFiles(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'J');
            populateCommunicationWindow(str)
        end

        fwrite(s, uint8('J'))
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'L');
            populateCommunicationWindow(str)
        end

        fwrite(s, uint8('L'))

    end

    function displayFiles(~, ~, ext)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'J');
            populateCommunicationWindow(str)
        end

        fwrite(s, uint8('J'))
        
        switch ext
            
            case 'INI'
                arg = 'I';                
            case 'CSV'
                arg = 'C'; 
            case 'ERR'
                arg = 'E';
        end
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', arg);
            populateCommunicationWindow(str)
        end

        fwrite(s, uint8(arg))

    end

    function exportAllFiles(~, ~)
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'J');
            populateCommunicationWindow(str)
        end

        fwrite(s, uint8('J'))
        
        pause(1)
        
        set(s, 'BytesAvailableFcn', @readDataFromOFToBuffer, ...
            'BytesAvailableFcnMode', 'terminator', ...
            'Terminator', {dc4, '' });
        
        if echoCommands
            str = sprintf('<html><font color="#FF18E6"><b> => %s</b></font></html>', 'X');
            populateCommunicationWindow(str)
        end
        
        set(gcf, 'pointer', 'watch')

        fwrite(s, uint8('X'))
        
    end

    function readDataFromOFToBuffer(~, ~)
        
        if s.BytesAvailable==0
            return
        end
        
        tmp = fread(s, [1, s.BytesAvailable]);
        
        if isempty(tmp)
            return
        end

        if any(tmp==stx)
            idx_stx = strfind(tmp, stx);
            if idx_stx>1
                tmp(1:idx_stx-1) = [];
            end
            buffer = [];            
        end
        
        if any(tmp==etx)
            
            idx_etx = strfind(tmp, etx);
            if idx_etx > numel(tmp)
                tmp(idx_etx+1:end) = [];
            end
            
            set(s,'BytesAvailableFcn', @readDataFromOF, ...
                'BytesAvailableFcnMode', 'terminator', ...
                'Terminator', {'CR/LF', '' });
            
            buffer = [buffer tmp];
            
            parseBuffer();
            
        end
        
        buffer = [buffer tmp];
        
    end

    function parseBuffer()
        
        if buffer(1)==stx
            buffer(1) = [];
        end
        
        if buffer(end)==etx
            buffer(end) = [];
        end
        
        if buffer(1)==ack
            buffer(1) = [];
        elseif buffer(1)==nack
            buffer(1) = [];
            parseError()
        end
        
        buffer(buffer==dc4) = [];
        
        idx = strfind(buffer, enq);
        
        k = 1;
        for n = 1:3:numel(idx)-1
           
            files.name{k} = char(buffer(idx(n)+1:idx(n+1)-1));
            files.size(k) = str2double(char(buffer(idx(n+1)+1:idx(n+2)-1)));
            files.content{k} = buffer(idx(n+2)+1:idx(n+3)-1);
            
            k = k+1;
            
        end
        
        set(gcf, 'pointer', 'arrow')
        
        saveDataToFiles()
        
    end

    function saveDataToFiles()
        
        folder_name = uigetdir();
        
        if ~folder_name
            return
        end
        
        for n = 1:numel(files.name)
           
            fid = fopen(fullfile(folder_name, files.name{n}), 'w');
            fwrite(fid, files.content{n});            
            fclose(fid);
            
            populateCommunicationWindow([files.name{n} ' saved.'])
            
        end
        
    end

    function parseError()
        
       populateCommunicationWindow(['Error: ' char(buffer)])
        
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
        
        if s.BytesAvailable==0
            return
        end
        
        tmp = fscanf(s);
        
        if ~isempty(tmp) && (strncmp(tmp, 'Files I/O:', numel('Files I/O:')) || tmp(1)==9)
            return
        end
        
        
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

    function keyPressComWindow(~, ~)

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
        fprintf(s, arg, 'async');
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
        
        while(s.BytesAvailable>0)
            fscanf(s);
            pause(delay)
        end
        
    end

    function closeCOMWindow(~, ~)
        
        s = instrfind('Port', comPort);
        
        if ~isempty(s)
            
            disconnectCOM([],[])
            
        end
        
        closereq;
    end

end