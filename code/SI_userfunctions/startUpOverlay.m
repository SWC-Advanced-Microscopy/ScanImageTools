function startUpOverlay(src,~,varargin)
    % Create sitools.si_overlay.TargetOverlay as hOverlay in the base workspace.
    % Does nothing if a valid hOverlay already exists, so it is safe to call on every Focus/Grab.
    if evalin('base','exist("hOverlay","var") && isvalid(hOverlay)')
        return
    end

    % src is the hSI object when called as a user function, but is missing
    % when run as hSI.startUpScript (TargetOverlay then gets hSI from the base workspace)
    if nargin < 1
        src = [];
    end

    hOverlay = sitools.si_overlay.TargetOverlay(src);
    assignin('base', 'hOverlay', hOverlay);
end
