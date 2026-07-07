function blankMonitorStart(src,~,varargin) 
    % This is ScanImage function. See the ScanImage doc for details.
    % https://docs.scanimage.org/Advanced+Features/User+Functions.html
    % ScanImage Arguments:
    %   on_duration: int. The duration of when monitor is ON in usec.
    %   offset:      int. The waveform offset in usec (can be negative).
    
    global MonitorBlanker
    MonitorBlanker = sitools.blankMonitor(src);
    if nargin>2 && ~isempty(varargin{1}) % on_duration provided
        MonitorBlanker.on_duration = varargin{1};
    end
    if nargin>3 && ~isempty(varargin{2}) % offset provided
        MonitorBlanker.offset = varargin{2};
    end
    MonitorBlanker.start(true);
    
 end