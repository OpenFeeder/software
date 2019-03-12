function OF_events_to_txt(binFile, eventsFile, textFile, separator)
% Convert binary events file to text file.
%
%   OF_events_to_txt(BINFILE, EVENTSFILE, TEXTFILE) reads the events from
%   the files BINFILE and EVENTSFILE, converts them to readable strings and 
%   store them in the file TEXTFILE.
%
%   OF_events_to_txt(___, ___, ___, SEPARATOR) uses SEPARATOR as a string 
%   separator for the time data and the string that contains the event.
%
%   See also OF_events_read, OF_events_to_sub, OF_events_to_srt, OF_events_to_usf
%
%   More information on the Openfeeder project at:
%   https://openfeeder.github.io/
%

% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 04, 2018 - First release
%

% Check number of input arguments
narginchk(0,4)

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
    separator = ',';
end

if exist(binFile, 'file')~=2
    error('File "%s" not found', binFile)
end
if exist(eventsFile, 'file')~=2
    error('File "%s" not found', eventsFile)
end

[ev, X] = OF_events_readable_read(binFile, eventsFile);

if nargin<3
    
    [filename, pathname] = uiputfile('*.txt', 'Get txt file');

    if ~filename
        return
    end

    textFile = fullfile(pathname, filename);
    
end

corrupted_lines = zeros(1,size(ev,1));
fid = fopen(textFile, 'wt');
for n = 1:size(ev,1)
    
    if ev(n,1)>=0 && ev(n,1)<=23
        fprintf(fid, '%02d:', ev(n,1));
    else
        fprintf(fid, '~~:');
        corrupted_lines(n) = 1;
    end
    
    if ev(n,2)>=0 && ev(n,2)<=59
        fprintf(fid, '%02d:', ev(n,2));
    else
        fprintf(fid, '~~:');
        corrupted_lines(n) = 1;
    end
    
    if ev(n,3)>=0 && ev(n,3)<=59
        fprintf(fid, '%02d', ev(n,3));
    else
        fprintf(fid, '~~');
        corrupted_lines(n) = 1;
    end
    
    if ev(n,4)>0 && ev(n,4)<=numel(X)
        fprintf(fid, '%s%s\n', separator, X{ev(n,4)});
    else
        fprintf(fid, '%s~~~~~~~~~~~~~~~~~~~\n', separator);
        corrupted_lines(n) = 1;
    end
end
fclose(fid);

if any(corrupted_lines)
    warning('Corrupted data found')
end