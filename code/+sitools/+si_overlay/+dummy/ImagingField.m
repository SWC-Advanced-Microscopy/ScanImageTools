classdef ImagingField < handle
    % Stand-in for scanimage.mroi.scanfield.ImagingField
    %
    % pixelToRefTransform uses the same formula as ScanImage. With the default
    % affine (identity) the FOV covers 0..1 in reference space.

    properties
        pixelResolutionXY = [512 512]
        affine = eye(3)  % Scanfield unit square -> reference space
    end

    methods
        function obj = ImagingField(pixelResolutionXY)
            if nargin > 0
                obj.pixelResolutionXY = pixelResolutionXY;
            end
        end

        function T = pixelToRefTransform(obj)
            % Same as scanimage.mroi.scanfield.ImagingField: pixel centres, 1-based
            pixelWidthXY = 1 ./ obj.pixelResolutionXY;
            T = [pixelWidthXY(1)        0        -pixelWidthXY(1)/2; ...
                        0        pixelWidthXY(2) -pixelWidthXY(2)/2; ...
                        0               0                 1        ];
            T = obj.affine * T;
        end
    end
end
