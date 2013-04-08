%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Plot XYZ and sRGB image representations.
%   @param XYZImage image matrix with XYZ color data
%   @param SRGBImage image matrix with sRGB color data
%   @param name a name to give the images (optional)
%
% @details
% Quick plotter for XYZ and sRGB image representations.  The given @a
% XYZImage and @a SRGB image will be plotted in new figures.  If @a name is
% provided, it will appear as the image title.  This might help distinguish
% similar plots.
%
% @details
% Usage:
%   ShowXYZAndSRGB(XYZImage, SRGBImage, name)
%
% @ingroup Utilities
function ShowXYZAndSRGB(XYZImage, SRGBImage, name)

if nargin < 3
    name = '';
end

if nargin > 0 && ~isempty(XYZImage)
    figure; clf;
    % assume XYZ image is full range floating point
    imshow(XYZImage);
    ylabel('XYZ')
    title(name)
    drawnow();
end

if nargin > 1 && ~isempty(SRGBImage)
    figure; clf;
    % assume SRGB is gamma corrected unsigned bytes
    imshow(uint8(SRGBImage));
    ylabel('SRGB')
    title(name)
    drawnow();
end