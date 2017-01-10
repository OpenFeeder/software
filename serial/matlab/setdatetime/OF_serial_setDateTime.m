function [status, dateSet] = OF_serial_setDateTime(comPort)

% Author: Jerome Briot - https://github.com/JeromeBriot

if ~ispc
    error('Works only on Windows system')
end

if nargin==0
    comPort = 'COM31';
end

delay = 0.03;

s = instrfind('Port', comPort);

if isempty(s)
    alreadyExistCOM = false;
    s = serial(comPort, ...
        'Terminator', {'CR/LF', '' }, ...
        'Timeout', 1);
    pause(delay)
    fopen(s);
    alreadyOpenCOM = false;
else
    if ~strcmp(s.Status, 'open')
        alreadyOpenCOM = false;
        fopen(s);
    else
        alreadyOpenCOM = true;
    end
    alreadyExistCOM = true;
end

t = 0;
while strcmp(s.Status, 'open')~=1 && t<=0.5
    pause(delay)
    t = t+delay;
end

if t>0.5
    if alreadyExistCOM==false
        delete(s)
    end
    error('Unable to open communication with port %s', comPort);
end

empty_uart_buffer(s)
fprintf(s, 's');
pause(delay);
while(s.BytesAvailable>0)
    fscanf(s);
    pause(delay);
end

V = datevec(now);
V(1) = V(1)-2000;

% mS = mod(V(end),1);
V(end) = round(V(end));

fprintf(s, '%d\r', V([3 2 1]));
pause(delay);
while(s.BytesAvailable>0)
    fscanf(s);
    pause(delay);
end
fprintf(s, '%d\r', V([4 5 6]));
pause(delay);
while(s.BytesAvailable>0)
    fscanf(s);
    pause(delay);
end

fprintf(s, 't');
pause(delay)
while(s.BytesAvailable>0)
    dateSet = fscanf(s);
    pause(delay);
end

if exist('dateSet', 'var')~=1
    if alreadyOpenCOM==false
        fclose(s);
    end
    if alreadyExistCOM==false
        delete(s)
    end
    error('Unable to set date and time. Try again !');
end

dateSet(dateSet==13 | dateSet==10) = [];

V(1) = V(1)+2000;

status = strcmp(dateSet,datestr(V, 'dd/mm/yy HH:MM:SS'));

if status==0
    while(s.BytesAvailable>0)
        dateSet = fscanf(s);
        pause(delay);
    end
end

if alreadyOpenCOM==false
    fclose(s);
end

if alreadyExistCOM==false
    delete(s)
end

function empty_uart_buffer(s)

while(s.BytesAvailable>0)
    fscanf(s);
    pause(delay)
end