classdef Display < handle
    % Stand-in for hSI.hDisplay: one figure holding one channel window

    properties (SetObservable, SetAccess = private)
        hAxes = {}      % {channel}{tile} of RoiDisplay, as in ScanImage. Replaced on every rebuild
    end

    properties (SetAccess = private)
        hMergeAxes = [] % No merge window in the dummy
        hFig
    end

    properties (Hidden)
        scanfield
    end

    methods
        function obj = Display(scanfield, closeFcn)
            obj.scanfield = scanfield;
            res = scanfield.pixelResolutionXY;

            obj.hFig = figure('Name', sprintf('Dummy Channel 1 (%d×%d)', res(1), res(2)), ...
                'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                'Color', [0.94 0.94 0.94], ...
                'Position', [100 100 560 560], ...
                'CloseRequestFcn', closeFcn);
            obj.resetDisplayFigs();
        end

        function delete(obj)
            obj.deleteRoiDisplays();
            if isgraphics(obj.hFig)
                delete(obj.hFig);
            end
        end

        function resetDisplayFigs(obj)
            % Delete the old window contents and build new ones, like ScanImage does
            obj.deleteRoiDisplays();
            rd = sitools.si_overlay.dummy.RoiDisplay(obj.hFig, obj.scanfield);
            obj.hAxes = {{rd}}; % Fires PostSet, which the overlay listens to
        end
    end

    methods (Access = private)
        function deleteRoiDisplays(obj)
            for ii = 1:numel(obj.hAxes)
                cellfun(@delete, obj.hAxes{ii});
            end
        end
    end
end
