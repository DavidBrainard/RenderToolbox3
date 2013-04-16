%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert an image in XYZ colors to sRGB colors.
%   @param XYZImage matrix of XYZ image data
%   @param toneMapFactor relative luminance truncation (optional)
%   @param toneMapMax absolute luminance truncation (optional)
%   @param isScale whether or not to scale in gamma correction (optional)
%
% @details
% Converts an image in XYZ colors to sRGB colors, using a few Psychtoolbox
% functions.  The given @a XYZ image should be a matrix of size [height
% width n] with XYZ color data.
%
% If @A toneMapFactor is greater than 0, truncates luminance above this
% factor times the mean luminance.
%
% If @a toneMapMax is greater than 0, truncates luminance above this fixed
% value.
%
% If @a isScale is true, the gamma-corrected image will be scaled to use
% the gamma-corrected maximum.
%
% Returns a matrix of size [height width n] with gamma corrected sRGB color
% data.  Also returns a matrix of the same size with uncorrected sRGB color
% data.
%
% @details
% Usage:
%   [gammaImage, rawImage] = XYZToSRGB(XYZImage, toneMapFactor, toneMapMax, isScale)
%
% @ingroup Utilities
function [gammaImage, rawImage] = XYZToSRGB(XYZImage, toneMapFactor, toneMapMax, isScale)

%% parameters
if nargin < 2
    toneMapFactor = 0;
end

if nargin < 3
    toneMapMax = 0;
end

if nargin < 4
    isScale = false;
end

%% Convert XYZ to sRGB
%
% This is a standard color conversion given that one started in XYZ.
% All of the PTB color correction machinary wants 3 by nPixels matrices
% as input. This format is what I call calibration format.  It's convenient
% because it allows certain operations to be done as one big matrix
% multiply. Thus the conversion from image plane to calibration format at
% the start of the sequence, and the back converstion at the end.

% Convert to calibration format.
[XYZCalFormat,m,n] = ImageToCalFormat(XYZImage);

% Tone map.  This is a very simple algorithm that truncates
% luminance above a factor times the mean luminance.
if (toneMapFactor > 0)
    meanLuminance = mean(XYZCalFormat(2,:));
    maxLum = toneMapFactor * meanLuminance;
    XYZCalFormat = BasicToneMapCalFormat(XYZCalFormat, maxLum);
end

% Tone map again.  This is an even simpler algorithm
% that truncates luminance above a fixed value.
if (toneMapMax > 0)
    XYZCalFormat = BasicToneMapCalFormat(XYZCalFormat, toneMapMax);
end

% Convert to sRGB
%   may allow code to scale input max to output max.
SRGBPrimaryCalFormat = XYZToSRGBPrimary(XYZCalFormat);
SRGBCalFormat = SRGBGammaCorrect(SRGBPrimaryCalFormat, isScale);

% Back to image plane format
rawImage = CalFormatToImage(SRGBPrimaryCalFormat, m, n);
gammaImage = CalFormatToImage(SRGBCalFormat, m, n);
