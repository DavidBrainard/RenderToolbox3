%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Plot XYZ and sRGB image representations.
%   @param XYZImage image matrix with XYZ color data
%   @param SRGBImage image matrix with sRGB color data
%   @param name a name to give the images (optional)
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Quick plotter for XYZ and sRGB image representations.  The given @a
% XYZImage and @a SRGB image will be plotted in new figures.  If @a name is
% provided, it will appear as the image title.  This might help distinguish
% similar plots.
%
% @details
% If @a hints is provided, it must be a struct of RenderToolbox3 options,
% as returned from GetDefaultHints().  If hints.isPlot is false, returns
% without plotting anything.
%
% @details
% Usage:
%   ShowXYZAndSRGB(XYZImage, SRGBImage, name, hints)
%
% @ingroup Utilities
function ShowXYZAndSRGB(XYZImage, SRGBImage, name, hints)

if nargin < 3 || isempty(name)
    name = '';
end

if nargin < 4
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if ~hints.isPlot
    return;
end

if nargin > 0 && ~isempty(XYZImage)
    figure();
    % assume XYZ image is full range floating point
    imshow(XYZImage);
    ylabel('XYZ')
    title(name)
    drawnow();
end

if nargin > 1 && ~isempty(SRGBImage)
    figure();
    % assume SRGB is gamma corrected unsigned bytes
    imshow(uint8(SRGBImage));
    ylabel('SRGB')
    title(name)
    drawnow();
end