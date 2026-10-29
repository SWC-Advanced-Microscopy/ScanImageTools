function appendDateAndTimeAndModeToFname(src,~,varargin)
    % ScanImage user function to append the current date, time, and acquisition mode to the file string
    %
    % function appendDateAndTimeAndModeToFname(src,evt,fileSavePath)
    %
    % Purpose
    % Appends the current date, time, and mode (mroi/stack) to the file string entered in ScanImage.
    % e.g. If the user enters 'mouse_01' into the "Basename" then this will be
    % replaced by: 'yyyymmdd_hhmmss__mouse_01__mroi' 
    % This string will be updated each time "Grab" or "Loop" is pressed. 
    % You don't need to re-enter "mouse_01"
    % NOTE: Do not use a double underscore ("__") in the file name you enter.
    %
    % How to set it up:
    % a) Add directory containing this function to the path
    % b) In ScanImage go to the User Functions and associate this function with 
    %    the Event Name "acqModeStart". 
    % c) If you wish to always save in a certain directory, supply that as a
    %    string in the "Arguments" box. 
    % d) Enable the user function. 
    % e) You can optionally save the above state as a Configuration file. 
    %
    % Inputs
    % * The third input arg (i.e. what's entered in the ScanImage Arguments box)
    %   should be a path to which all files will be saved. It must exist.
    % * Create a sub-directory within the path defined above that the same
    %   name as the save file string (optional, false by default)
    %

    if nargin < 2
        fprintf('\n\nThis is a ScanImage userfunction. See the help text:\n\n')
        help(mfilename)
        return
    end

    hSI = src.hSI;

    % --- Optionally set the file save path ---
    if nargin > 2
        filePath = varargin{1};
        if ~exist(filePath, 'dir')
            fprintf('Cannot find directory %s. Will not set the save path.\n', filePath)
        else
            hSI.hScan2D.logFilePath = filePath;
        end
    end

    % --- Optionally create a sub-directory ---
    if nargin < 4 || isempty(varargin{2})
        createSubDir = false;
    else
        createSubDir = varargin{2};
    end

    % --- Extract raw sample name from current stem ---
    % The stem may already be formatted as 'yyyymmdd_HHMMSS__sampleName__modeTag'
    % from a previous call. We always parse back to the raw sample name.
    currentStem = hSI.hScan2D.logFileStem;
    tokens = strsplit(currentStem, '__');

    % Strip leading timestamp (yyyymmdd_HHMMSS) if present
    if ~isempty(regexp(tokens{1}, '^\d{8}_\d{6}$', 'once'))
        tokens = tokens(2:end);
    end

    % Strip trailing mode tag if present
    knownTags = {'mroi', 'stack', 'single', 'mroistack'};
    if ~isempty(tokens) && ismember(tokens{end}, knownTags)
        tokens = tokens(1:end-1);
    end

    if isempty(tokens)
        fprintf('Warning: could not parse a sample name from stem "%s". Using "unnamed".\n', currentStem)
        sampleName = 'unnamed';
    else
        sampleName = strjoin(tokens, '__');
    end

    % --- Build mode tag ---
    isMroi  = hSI.hRoiManager.mroiEnable;
    isStack = hSI.hStackManager.enable;

    if isMroi && isStack
        modeTag = '__mroistack';
    elseif isMroi
        modeTag = '__mroi';
    elseif isStack
        modeTag = '__stack';
    else
        modeTag = '__single';
    end

    % --- Assemble new stem ---
    hSI.hScan2D.logFileStem = [datestr(now, 'yyyymmdd_HHMMSS__'), sampleName, modeTag];

    % --- Optionally create sub-directory ---
    if createSubDir
        saveDir = fullfile(hSI.hScan2D.logFilePath, hSI.hScan2D.logFileStem);
        if ~exist(saveDir, 'dir')
            mkdir(saveDir)
        end
        hSI.hScan2D.logFilePath = saveDir;
    end

end