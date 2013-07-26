%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert multi-spectral image data to XYZ and sRGB.
%   @param multispectralImage multispectral image matrix [height width n]
%   @param S image spectral sampling description [start delta n]
%   @param toneMapFactor optional threshold for clipping luminance
%   @param isScale whether to normalize sRGB image by max luminance
%
% @details
% Convert the given @a multispectralImage of size [height width n] to an
% sRGB image of size [height width 3], for viewing on a standard monitor,
% using the CIE 1931 standard weighting functions.
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
% Returns a gamma-corrected sRGB image of size [height width 3].  Also
% returns the intermediate XYZ image and the uncorrected RGB image, which
% have the same size.
%
% @details
% Usage:
%   [sRGBImage, XYZImage, rawRGBImage] = MultispectralToSRGB(multispectralImage, S, toneMapFactor, isScale)
%
% @ingroup Utilities
function [sRGBImage, XYZImage, rawRGBImage] = MultispectralToSRGB(multispectralImage, S, toneMapFactor, isScale)

%% parameters
if nargin < 3
    toneMapFactor = 0;
end

if nargin < 4
    isScale = false;
end

% convert to CIE XYZ image using CIE 1931 standard weighting functions
%   683 converts watt-valued spectra to lumen-valued luminances (Y-values)
wattsToLumens = 683;
matchingData = load('T_xyz1931');
matchingFunction = wattsToLumens*matchingData.T_xyz1931;
matchingS = matchingData.S_xyz1931;
XYZImage = MultispectralToSensorImage(multispectralImage, S, ...
    matchingFunction, matchingS);

% convert to sRGB with a very simple tone mapping algorithm that truncates
% luminance above a factor times the mean luminance
[sRGBImage, rawRGBImage] = XYZToSRGB(XYZImage, toneMapFactor, 0, isScale);