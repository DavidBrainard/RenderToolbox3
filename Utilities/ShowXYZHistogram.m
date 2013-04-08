%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Plot histograms for XYZ image components.
%   @param XYZImage matrix of XYZ image data
%   @param nEdges how many bin edges to use in histograms
%
% @details
% Plots histograms of X, Y, and Z components of the given @a XYZimage, in a
% new figure.  @a XYZimage should be in Psychtoolbox "Image" format (as
% opposed to "Calibration" format), with size [nY, nX, 3].
%
% @details
% By default, plots histograms with 100 bin edges.  If @a nEdges is
% provided, uses the given number of bin edges.  All  
% components will share the same bin edges, ranging from a common
% minimum to a commpn maximum.  0-values are ignored.
%
% @details
% Returns the bin frequency counts for each component, X, Y, and Z.  Also
% returns the array of bin edges.
%
% @details
% Usage:
%   [nX, nY, nZ, edges] = ShowXYZHistogram(XYZImage, nEdges)
%
% @ingroup Utilities
function [nX, nY, nZ, edges] = ShowXYZHistogram(XYZImage, nEdges)

if nargin < 2 || isempty(nEdges)
    nEdges = 100;
end

%% compute bin edges
grandMax = max(XYZImage(:));
grandMin = min(XYZImage(XYZImage(:)~=0));
edges = linspace(grandMin, grandMax, nEdges);

%% "calibration" format is more natural for histograms
[XYZCalFormat,m,n] = ImageToCalFormat(XYZImage);
N = histc(XYZCalFormat, edges, 2);
nX = N(1,:);
meanX = mean(XYZCalFormat(1,:));
nY = N(2,:);
meanY = mean(XYZCalFormat(2,:));
nZ = N(3,:);
meanZ = mean(XYZCalFormat(3,:));

%% plot the three histograms
%   with markers at the mean
figure;
clf;

subplot(3,1,1)
bar(edges, nX)
line(meanX*[1 1], [0, max(nX)], 'Marker', '+', 'LineStyle', '-')
xlim([0, grandMax])
ylabel('X')

subplot(3,1,2);
bar(edges, nY)
line(meanY*[1 1], [0, max(nY)], 'Marker', '+', 'LineStyle', '-')
xlim([0, grandMax])
ylabel('Y')

subplot(3,1,3);
bar(edges, nZ)
line(meanZ*[1 1], [0, max(nZ)], 'Marker', '+', 'LineStyle', '-')
xlim([0, grandMax])
ylabel('Z')