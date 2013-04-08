%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert multi-spectral image data to XYZ and sRGB.
%   @param multispectralImage
%   @param S
%   @param toneMapFactor
%   @param isScale
%
% @details
% Convert the given @a multispectralImage of size [height width n] to an
% sRGB image of size [height width 3], for viewing on a standard monitor.
%
% @details
% The given @a S must describe the n spectral planes of the @a
% multispectralImage.  It should have the form [start delta n], where start
% and delta are wavelengths in nanometers, and n is the number of spectral
% planes.
%
% @details
% If @a S toneMapFactor is provided and greater than 0, truncates
% luminances above this factor times the mean luminance.
%
% @details
% If @a isScale is true, the gamma-corrected image will be scaled to use
% they gamma-corrected maximum.
%
% @details
% Returns an sRGB image of size [height width 3].  Also returns the
% intermediate XYZ image of size [height width 3].
%
% @details
% Usage:
%   [SRGBImage, XYZImage] = MultispectralToSRGB(multispectralImage, S, toneMapFactor, isScale)
%
% @ingroup Utilities
function [SRGBImage, XYZImage] = MultispectralToSRGB(multispectralImage, S, toneMapFactor, isScale)

%% parameters
if nargin < 3
    toneMapFactor = 0;
end

if nargin < 4
    isScale = false;
end

%% Convert to CIE XYZ image by weighting
% the hyperspectral planes by the CIE color
% matching functions.
%
% This code is a template for converting down
% from hyperspectral to any linear color space.
wls = SToWls(S);
imSiz = size(multispectralImage);
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
XYZImage = zeros(imSiz(1),imSiz(2),size(T_xyz,1));
for w = 1:length(wls)
    for j = 1:size(T_xyz,1)
        XYZImage(:,:,j) = XYZImage(:,:,j) + T_xyz(j,w)*multispectralImage(:,:,w);
    end
end

%% Convert XYZ to sRGB

% convert to sRGB
% A very simple tone mapping algorithm will truncate
% luminance above a factor times the mean luminance.
SRGBImage = XYZToSRGB(XYZImage, toneMapFactor, 0, isScale);