classdef RoiDisplay < handle
    % Stand-in for scanimage.mroi.RoiDisplay: a blank image in reference space
    %
    % The image is drawn the way ScanImage shows it: pixel (1,1) at the top-left,
    % x to the right, y downwards. Moving the mouse over it shows the pixel
    % under the cursor in the window title.

    properties (SetAccess = private)
        hAxes
        hOnTopGroup     % Layer drawn above the image; TargetOverlay draws into this
        hImage
    end

    properties (Hidden)
        scanfield
        baseName
    end

    methods
        function obj = RoiDisplay(hFig, scanfield)
            obj.scanfield = scanfield;
            res = scanfield.pixelResolutionXY;
            obj.baseName = regexprep(hFig.Name, '\s+pixel \[x y\].*$', ''); % Name may still show the old mouse position

            % Image corners in reference space (pixel edges at 0.5 and res+0.5)
            corners = sitools.si_overlay.TargetOverlay.applyAffine( ...
                [0.5 0.5; res(1)+0.5 res(2)+0.5], scanfield.pixelToRefTransform);

            obj.hAxes = axes('Parent', hFig, ...
                'Units', 'normalized', 'Position', [0 0 1 1], ...
                'Color', [0 0 0], 'XColor', 'none', 'YColor', 'none', ...
                'XTick', [], 'YTick', [], ...
                'XLim', corners(:,1)', 'YLim', corners(:,2)', ...
                'YDir', 'reverse', ...
                'DataAspectRatio', [1 1 1], ...
                'SortMethod', 'childorder', ...
                'NextPlot', 'add');

            % Blank image; XData/YData are the centres of the first and last pixel
            centres = sitools.si_overlay.TargetOverlay.applyAffine([1 1; res(1) res(2)], scanfield.pixelToRefTransform);
            obj.hImage = image('Parent', obj.hAxes, ...
                'XData', centres(:,1)', 'YData', centres(:,2)', ...
                'CData', zeros(res(2), res(1), 3), ...
                'HitTest', 'off');

            % Created after the image, so it is drawn on top
            obj.hOnTopGroup = hgtransform('Parent', obj.hAxes, 'HitTest', 'off', 'PickableParts', 'none');

            hFig.WindowButtonMotionFcn = @(~,~)obj.showPixelUnderMouse();
        end

        function delete(obj)
            if isgraphics(obj.hAxes)
                delete(obj.hAxes); % Also deletes anything drawn in hOnTopGroup
            end
        end
    end

    methods (Access = private)
        function showPixelUnderMouse(obj)
            if ~isgraphics(obj.hAxes)
                return
            end
            pt = obj.hAxes.CurrentPoint(1,1:2);
            xyPixel = sitools.si_overlay.TargetOverlay.applyAffine(pt, inv(obj.scanfield.pixelToRefTransform));
            res = obj.scanfield.pixelResolutionXY;

            hFig = ancestor(obj.hAxes, 'figure');
            if all(xyPixel >= 0.5) && all(xyPixel <= res + 0.5)
                hFig.Name = sprintf('%s   pixel [x y] = [%.0f %.0f]', obj.baseName, xyPixel(1), xyPixel(2));
            else
                hFig.Name = obj.baseName;
            end
        end
    end
end
