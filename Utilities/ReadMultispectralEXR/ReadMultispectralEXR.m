%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read an OpenEXR image with multiple spectral slices.
%   @param exrFile file name or path of an OpenEXR file
%
% @details
% Reads an OpenEXR image with an arbitrary number of spectral slices.
%
% @details
% The given @a exrFile should be an OpenEXR multi-spectral data file, with
% color data stored as evenly spaced slices through the spectrum, not as
% RGB or RGBA.  Each slice must have a name that identifies the wavelengths
% of that particular slice.  The name should be formatted like this:
% @code
%   12.34-56.78nm
% @endcode
% where "12.34" represents any decimal value for the low bound of the
% slice's spectrum band, and "56.78" represents any decimal value for the
% high bound.  Both values should be in units of nanometers.  The "nm"
% suffix is optional.  Image slices with names that don't match this
% pattern will be ignored.
%
% @details
% Returns an array of image data with size [height width n], where height
% and width are image sizes in pixels, and n is the number of spectral
% slices.  The n slices will be sorted from low to high wavelength.
%
% @details
% Also returns the list of n wavelengths, one for each spectral slice.  The
% wavelength for each slice is taken as the mean of the low and high bounds
% The list of wavelengths will be sorted from low to high.  See the
% RenderToolbox3 wiki for more about <a 
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands">Spectrum
% Bands</a>
%
% @details
% Also returns a summary of the list of wavelengths in "S" format.  This is
% an array with elements [start delta n].
%
% @details
% Usage:
%   [imageData, wls, S] = ReadMultispectralEXR(exrFile)
%
% @ingroup Readers
function [imageData, wls, S] = ReadMultispectralEXR(exrFile)

% read all channels from the OpenEXR image
[sliceInfo, imageData] = ReadMultichannelEXR(exrFile);

% look for channels that contain wavelengths
nSlices = numel(sliceInfo);
wls = zeros(1, nSlices);
isSpectralBand = false(1, nSlices);
for ii = 1:nSlices
    band = sscanf(sliceInfo(ii).name, '%f-%f');
    if 2 == numel(band)
        wls(ii) = mean(band);
        isSpectralBand(ii) = true;
    end
end

% sort slices by wavelength
[wls, order] = sort(wls);
imageData(:,:,:) = imageData(:,:,order);
isSpectralBand = isSpectralBand(order);

% summarize the slice wavelengths
wls = wls(isSpectralBand);
S = MakeItS(wls(:));