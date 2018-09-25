function [status, OF_time] = OF_serial_setDateTime(comPort)

% Author: Jerome Briot - https://github.com/JeromeBriot

if nargin==0
    comPort = 'COM36';
end

delay = 0.5;

ser = instrfind('Port', comPort);

if isempty(ser)
    alreadyExistCOM = false;
    ser = serial(comPort, ...
        'Terminator', {'CR/LF', '' }, ...
        'Timeout', 2);
    pause(delay)
    fopen(ser);
    alreadyOpenCOM = false;
else
    if ~strcmp(ser.Status, 'open')
        alreadyOpenCOM = false;
        fopen(ser);
    else
        alreadyOpenCOM = true;
    end
    alreadyExistCOM = true;
end

clc

t = 0;
while strcmp(ser.Status, 'open')~=1 && t<=0.5
    pause(delay)
    t = t+delay;
end

if t>0.5
    if alreadyExistCOM==false
        delete(ser)
    end
    error('Unable to open communication with port %s', comPort);
end

num = 12;
maxTime = 5;

for n = 1:2
    
    % Query PC date and time
    PC_time = now;
    
    % Dont synchronize OF date and time during the first iteration to allow offsets computation
    if n > 1
        fwrite(ser, uint8(['S' datevec(PC_time)-[2000 0 0 0 0 0]]))
    end
        
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
    fprintf('\nPC : %s\n', datestr(PC_time, 'dd/mm/yyyy HH:MM:SS'));
    fprintf('PIC: %02d/%02d/20%02d %02d:%02d:%02d\n', OF_time(3), OF_time(2), OF_time(1) , OF_time(4), OF_time(5), OF_time(6))
    if ext_rtc_available
        fprintf('EXT: %02d/%02d/20%02d %02d:%02d:%02d\n', OF_time(9), OF_time(8), OF_time(7), OF_time(10), OF_time(11), OF_time(12))
    else
        fprintf('EXT: --/--/---- --:--:--\n')
    end

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
            fprintf('\nDiff PC-PIC: %c%02d:%02d:%.3f (%e)\n', s, delta(4:6) , datenum(delta))
        else
            fprintf('\nDiff PC-PIC: %c%02d:%02d:0%.3f (%e)\n', s, delta(4:6) , datenum(delta))
        end

    else
        fprintf('\nDiff PC-PIC: greater than one day (%e)\n', datenum(delta))
    end

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
                fprintf('Diff PC-EXT: %c%02d:%02d:%.3f (%e)\n', s, delta(4:6) , datenum(delta))
            else
                fprintf('Diff PC-EXT: %c%02d:%02d:0%.3f (%e)\n', s, delta(4:6) , datenum(delta))
            end

        else
            fprintf('Diff PC-EXT: greater than one day (%e)\n', datenum(delta))
        end

    else
        fprintf('Diff PC-EXT:  --:--:--.--- (0)\n')
    end
        
end

if alreadyOpenCOM==false
    fclose(ser);
end

if alreadyExistCOM==false
    delete(ser)
end

end