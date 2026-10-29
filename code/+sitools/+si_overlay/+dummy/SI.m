classdef SI < handle
    % A minimal stand-in for ScanImage's hSI, for trying the overlay without a rig
    %
    % hSI = sitools.si_overlay.dummy.SI
    % hSI = sitools.si_overlay.dummy.SI([512 512])
    %
    % Purpose
    % Opens one blank (black) channel window of the given pixel size and offers
    % only what TargetOverlay uses from ScanImage: hSI.hDisplay.hAxes (observable,
    % replaced on every rebuild), hSI.hDisplay.hMergeAxes and
    % hSI.hRoiManager.currentRoiGroup.rois(1).scanfields(1).
    %
    % hSI.focus rebuilds the channel window the way ScanImage does when you press
    % Focus, which deletes everything drawn on it. Use it to check that the
    % overlay comes back by itself.
    %
    % Closing the window deletes this object.

    properties (SetAccess = private)
        hDisplay        % sitools.si_overlay.dummy.Display
        hRoiManager     % struct mimicking hSI.hRoiManager (currentRoiGroup only)
    end

    methods
        function obj = SI(pixelResolutionXY)
            if nargin < 1 || isempty(pixelResolutionXY)
                pixelResolutionXY = [512 512];
            end

            sf = sitools.si_overlay.dummy.ImagingField(pixelResolutionXY);
            obj.hRoiManager = struct('currentRoiGroup', struct('rois', struct('scanfields', sf)));

            obj.hDisplay = sitools.si_overlay.dummy.Display(sf, @(~,~)delete(obj));
            fprintf('Dummy ScanImage: %d×%d blank channel window\n', pixelResolutionXY(1), pixelResolutionXY(2));
        end

        function delete(obj)
            delete(obj.hDisplay);

            % Do not leave a dead hSI in the base workspace
            try
                if isequal(evalin('base', 'hSI'), obj)
                    evalin('base', 'clear hSI');
                end
            catch
                % No hSI in the base workspace
            end
        end

        function focus(obj)
            % Rebuild the channel window, like ScanImage does on Focus/Grab
            obj.hDisplay.resetDisplayFigs();
            fprintf('Dummy ScanImage: channel window rebuilt\n');
        end
    end
end
