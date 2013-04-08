%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get wavelengths and magnitudes from a multispectral image pixel.
%   @param image multispectral image matrix of size [height width n]
%   @param spectrum description of the n spectrum bands of @a image
%   @param x x-coordinate of the pixel to probe
%   @param y y-coordinate of the pixel to probe
%
% @details
% Gets the spectral magnitude distribution of one pixel in the given
% multi-spectral @a image.
%
% @details
% @a image must be a multi-spectral image matrix, with size [height width
% n], where height and width are the image pixel dimensions, and n is the
% number of spectrum bands in the image.
%
% @details
% @a spectrum must be a description of the n spectrum bands in @a image.
% @a spectrum may be a 1 x n list of wavelengths, or it may be an "S"
% description of the form [start delta n], where start is the wavelength of
% the lowest spectrum band, and delta is the width of each band.
%
% @details
% @a x and @a y must be the x-coordinage and y-coordinate of the pixel of
% interest.
%
% @details
% Returns a 1 x n matrix of n wavelengths, and a corresponding 1 x n matrix
% of magnitudes, for the pixel of interest.  Also returns an sRGB
% approximation of the spectrum of the pixel of interest.
%
% @details
% Usage:
%   [wavelengths, magnitudes, sRGB] = GetPixelSpectrum(image, spectrum, x, y)
%
% @ingroup Utilities
function [wavelengths, magnitudes, sRGB] = GetPixelSpectrum(image, spectrum, x, y)

% determine the wavelength of each spectrum band
wavelengths = MakeItWls(spectrum);

% probe the pixel of interest
magnitudes = squeeze(image(y, x, :));

% make an sRGB approximation
sRGB = squeeze(MultispectralToSRGB( ...
    reshape(magnitudes, 1, 1, []), wavelengths, 0, false));