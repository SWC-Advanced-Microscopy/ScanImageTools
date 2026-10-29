classdef TargetOverlay < handle
    % Draw target markers on top of the ScanImage channel windows
    %
    % hOverlay = sitools.si_overlay.TargetOverlay
    % hOverlay = sitools.si_overlay.TargetOverlay(hSI)
    %
    % Purpose
    % Show a set of points (e.g. hologram spots) as markers on every ScanImage
    % channel window (and the merge window). The markers are drawn in the same
    % coordinates as the image (ScanImage reference space), so they stay on the
    % right place when you pan or zoom. ScanImage rebuilds its channel windows
    % when you Focus/Grab or change channels; the markers are redrawn
    % automatically when that happens.
    %
    % Currently supports a single FOV and a single plane.
    %
    % Example
    % hOverlay = sitools.si_overlay.TargetOverlay;
    % hOverlay.setTargetsPixels([100 100; 256 256; 400 150]) % imaging pixels
    % hOverlay.marker = 'x';
    % hOverlay.hide
    % delete(hOverlay) % removes the markers and the listener

    properties
        marker char = '*'         % '*', 'x' or '+'
        markerSize = 12           % [points]
        color = [0 1 0]           % RGB
        lineWidth = 1.5
        visible logical = true
    end

    properties (SetAccess = private)
        hSI                       % ScanImage object
        xyRef = zeros(0,2)        % N×2 targets in ScanImage reference space
    end

    properties (Hidden)
        hLines = gobjects(1,0)    % One line object per channel window
        hDisplayListener          % Redraws after ScanImage rebuilds its channel windows
    end

    properties (Constant, Hidden)
        TAG = 'si_overlay_TargetOverlay'
        ALLOWED_MARKERS = {'*', 'x', '+'}
    end

    methods
        function obj = TargetOverlay(hSI)
            if nargin < 1 || isempty(hSI)
                hSI = sitools.si_overlay.TargetOverlay.getSIFromBase();
            end
            if ~(isa(hSI, 'scanimage.SI') || isa(hSI, 'sitools.si_overlay.dummy.SI'))
                error('TargetOverlay needs a running ScanImage (hSI) object, or sitools.si_overlay.dummy.SI');
            end
            obj.hSI = hSI;

            % hSI.hDisplay.hAxes is SetObservable and is replaced every time
            % ScanImage rebuilds the channel windows (which deletes our markers)
            obj.hDisplayListener = addlistener(hSI.hDisplay, 'hAxes', 'PostSet', @(~,~)obj.redraw());
            obj.redraw();
        end

        function delete(obj)
            delete(obj.hDisplayListener);
            obj.deleteLines();
        end

        function setTargets(obj, xyRef)
            % Set the targets in ScanImage reference space (N×2, [x y])
            if isempty(xyRef)
                xyRef = zeros(0,2);
            end
            assert(size(xyRef,2) == 2, 'Targets must be N×2 ([x y])');
            obj.xyRef = double(xyRef);
            obj.updateLines();
        end

        function setTargetsPixels(obj, xyPixel)
            % Set the targets in imaging pixels (N×2, [x y], 1-based, (1,1) = top-left pixel centre)
            obj.setTargets(obj.pixelToRef(xyPixel));
        end

        function xyRef = pixelToRef(obj, xyPixel)
            % Convert imaging pixels of the current (single) FOV to reference space
            if isempty(xyPixel)
                xyRef = zeros(0,2);
                return
            end
            sf = obj.getImagingScanfield();
            xyRef = sitools.si_overlay.TargetOverlay.applyAffine(xyPixel, sf.pixelToRefTransform);
        end

        function xyPixel = refToPixel(obj, xyRef)
            % Convert reference space to imaging pixels of the current (single) FOV
            if isempty(xyRef)
                xyPixel = zeros(0,2);
                return
            end
            sf = obj.getImagingScanfield();
            xyPixel = sitools.si_overlay.TargetOverlay.applyAffine(xyRef, inv(sf.pixelToRefTransform));
        end

        function clear(obj)
            obj.setTargets(zeros(0,2));
        end

        function show(obj)
            obj.visible = true;
        end

        function hide(obj)
            obj.visible = false;
        end

        function redraw(obj)
            % Recreate the markers on every channel window. Called automatically
            % after ScanImage rebuilds its windows; call it yourself if the
            % markers have gone missing.
            obj.deleteLines();

            rds = obj.getRoiDisplays();
            for ii = 1:numel(rds)
                obj.hLines(end+1) = line('Parent', rds{ii}.hOnTopGroup, ...
                    'Tag', obj.TAG, ...
                    'LineStyle', 'none', ...
                    'HitTest', 'off', ...
                    'PickableParts', 'none');
            end
            obj.updateLines();
        end
    end

    methods % Setters
        function set.marker(obj, val)
            assert(ismember(val, obj.ALLOWED_MARKERS), ...
                'marker must be one of: %s', strjoin(obj.ALLOWED_MARKERS, ' '));
            obj.marker = val;
            obj.updateLines();
        end

        function set.markerSize(obj, val)
            obj.markerSize = val;
            obj.updateLines();
        end

        function set.color(obj, val)
            obj.color = val;
            obj.updateLines();
        end

        function set.lineWidth(obj, val)
            obj.lineWidth = val;
            obj.updateLines();
        end

        function set.visible(obj, val)
            obj.visible = val;
            obj.updateLines();
        end
    end

    methods (Access = private)
        function updateLines(obj)
            obj.hLines = obj.hLines(isgraphics(obj.hLines)); % Some may have gone with a deleted window
            if isempty(obj.hLines)
                return
            end

            if obj.visible
                vis = 'on';
            else
                vis = 'off';
            end

            % ZData is left empty: hOnTopGroup already places the markers just above the image plane
            set(obj.hLines, ...
                'XData', obj.xyRef(:,1), ...
                'YData', obj.xyRef(:,2), ...
                'Marker', obj.marker, ...
                'MarkerSize', obj.markerSize, ...
                'MarkerEdgeColor', obj.color, ...
                'LineWidth', obj.lineWidth, ...
                'Visible', vis);
        end

        function deleteLines(obj)
            delete(obj.hLines(isgraphics(obj.hLines)));
            obj.hLines = gobjects(1,0);
        end

        function rds = getRoiDisplays(obj)
            % All image windows: one per channel (several if tiled) plus the merge window
            hDisplay = obj.hSI.hDisplay;
            allAxes = [hDisplay.hAxes(:)', {hDisplay.hMergeAxes}];

            rds = {};
            for ii = 1:numel(allAxes)
                chanAxes = allAxes{ii};
                if ~iscell(chanAxes)
                    continue
                end
                for jj = 1:numel(chanAxes)
                    rd = chanAxes{jj};
                    % Line scan windows have no hOnTopGroup and are skipped
                    if isobject(rd) && isvalid(rd) && isprop(rd, 'hOnTopGroup')
                        rds{end+1} = rd; %#ok<AGROW>
                    end
                end
            end
        end

        function sf = getImagingScanfield(obj)
            roiGroup = obj.hSI.hRoiManager.currentRoiGroup;
            assert(~isempty(roiGroup.rois) && ~isempty(roiGroup.rois(1).scanfields), ...
                'ScanImage has no imaging scanfield');
            if numel(roiGroup.rois) > 1
                warning('TargetOverlay:multiFOV', ...
                    'Several FOVs are active; pixels are taken from the first one');
            end
            sf = roiGroup.rois(1).scanfields(1);
        end
    end

    methods (Static, Hidden)
        function xyOut = applyAffine(xy, T)
            % Apply a 3×3 affine T to N×2 points
            xyh = [double(xy), ones(size(xy,1),1)] * T';
            xyOut = xyh(:,1:2);
        end

        function hSI = getSIFromBase()
            hSI = [];
            W = evalin('base', 'whos');
            if ismember('hSI', {W.name})
                hSI = evalin('base', 'hSI');
            end
        end
    end
end
