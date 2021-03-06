function [ev, X] = OF_events_raw_read(binFile, eventsFile)
% Read events file generated by the Openfeeder device in a raw form.
%
%   [EV, X] = OF_events_raw_read(BINFILE, EVENTSFILE) reads the events 
%   binary file BINFILE generated by the Openfeeder device. It translates 
%   binary events to strings using the raw text file EVENTSFILE. EV is a Nx3
%   numercial array that contains dates in the form [HH MM SS]. X is a cell
%   array that contains strings.
%
%   OF_events_raw_read(___, ___) displays output data in the command window
%   of MATLAB.
%
%   See also OF_events_readable_read.
%
%   More information on the Openfeeder project at:
%   https://openfeeder.github.io/
%

% Author:  Jerome Briot
% Contact: jbtechlab@gmail.com
% Version: 1.0.0 - Sept. 04, 2018 - First release
%

% Check number of input arguments
narginchk(0,2)

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

% Test if files exist
if exist(binFile, 'file')~=2
    error('File "%s" not found', binFile)
end
if exist(eventsFile, 'file')~=2
    error('File "%s" not found', eventsFile)
end

% Read numercial data stored in binary file
fid = fopen(binFile, 'r');
ev = fread(fid, [4,inf]).';
fclose(fid);

% Read string stored in the text file
fid = fopen(eventsFile, 'r');
X = textscan(fid, '%s', 'delimiter', '%s');
fclose(fid);

% Simplify the cell array X
X = X{1};

% Display result if no outpout argument required
if nargout==0
    for n = 1:size(ev,1)
        fprintf('%02d:%02d:%02d %s\n', ev(n,1), ev(n,2), ev(n,3), X{ev(n,4)})
    end
end
