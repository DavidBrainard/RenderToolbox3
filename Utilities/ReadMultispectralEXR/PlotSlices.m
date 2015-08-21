%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% View each slice from a multi-spectral exr-file.
%   @param sliceInfo struct array of slice data from ReadMultichannelEXR()
%   @param data matrix of image data from ReadMultichannelEXR()
%
% @details
% Plots each slice from the given @a data as a grayscale image, along with
% the slice name and pixelType from the give @a sliceInfo.
%
% @details
% Returns the plot figure.
%
% @details
% Usage:
%   fig = PlotSlices(sliceInfo, data)
%
% @ingroup Utilities
function fig = PlotSlices(sliceInfo, data)

fig = figure();

nSlices = numel(sliceInfo);
rows = round(sqrt(nSlices));
cols = ceil(nSlices/rows);
for ii = 1:nSlices
    subplot(rows, cols, ii)
    imshow(255 * data(:,:,ii))
    title(sliceInfo(ii).name)
    xlabel(sliceInfo(ii).pixelType)
end
