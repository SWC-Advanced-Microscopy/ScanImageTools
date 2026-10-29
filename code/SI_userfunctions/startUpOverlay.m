function startUpOverlay(src, evt, vargin)
    % Create sitools.si_overlay.TargetOverlay as hOverlay in the base workspace.
    % Does nothing if a valid hOverlay already exists, so it is safe to call on every Focus/Grab.
    if evalin('base','exist("hOverlay","var") && isvalid(hOverlay)')
        return
    end

    hOverlay = sitools.si_overlay.TargetOverlay(src);
    assignin('base', 'hOverlay', hOverlay);
end
