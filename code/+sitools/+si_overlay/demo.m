function hOverlay = demo(useDummy)
    % Show a 3×3 grid of test targets on the ScanImage channel windows
    %
    % hOverlay = sitools.si_overlay.demo        % real ScanImage if running, otherwise dummy
    % hOverlay = sitools.si_overlay.demo(true)  % always use the dummy window
    %
    % Purpose
    % Check the overlay with or without a rig.
    %
    % Real ScanImage: start it and Focus or Grab once so the channel windows
    % exist, then run this.
    %
    % Dummy mode: opens a blank 512×512 channel window (sitools.si_overlay.dummy.SI)
    % and puts it in the base workspace as hSI, so everything below works the
    % same as on the rig. Hover over the window to see pixel coordinates in its
    % title. Close the window to end dummy mode.
    %
    % Then try:
    %   hOverlay.setTargetsPixels([1 1; 512 512])   % corners
    %   hOverlay.marker = 'x'; hOverlay.color = [1 0 0];
    %   hOverlay.hide; hOverlay.show; hOverlay.clear
    %   hSI.focus                                   % dummy only: rebuild the window, markers come back
    %   delete(hOverlay)

    hSI = sitools.si_overlay.TargetOverlay.getSIFromBase();
    if nargin < 1 || isempty(useDummy)
        useDummy = ~isa(hSI, 'scanimage.SI');
    end

    if useDummy && isa(hSI, 'sitools.si_overlay.dummy.SI') && isvalid(hSI)
        fprintf('Reusing the open dummy channel window\n');
    elseif useDummy
        hSI = sitools.si_overlay.dummy.SI([512 512]);
        if isempty(sitools.si_overlay.TargetOverlay.getSIFromBase())
            assignin('base', 'hSI', hSI); % Never overwrite a real ScanImage
        else
            fprintf('hSI already exists in the base workspace and was left alone\n');
        end
    end

    hOverlay = sitools.si_overlay.TargetOverlay(hSI);

    sf = hSI.hRoiManager.currentRoiGroup.rois(1).scanfields(1);
    res = sf.pixelResolutionXY;

    [x, y] = meshgrid(linspace(0.25, 0.75, 3) * res(1), linspace(0.25, 0.75, 3) * res(2));
    hOverlay.setTargetsPixels([x(:), y(:)]);

    fprintf('si_overlay demo: 9 targets on a %d×%d pixel FOV\n', res(1), res(2));
    fprintf('  hOverlay.setTargetsPixels([1 1; %d %d])\n', res(1), res(2));
    fprintf('  hOverlay.marker = ''x''; hOverlay.hide; hOverlay.show; delete(hOverlay)\n');
    if useDummy
        fprintf('  hSI.focus   %% rebuild the dummy window; markers should come back\n');
    end
end
