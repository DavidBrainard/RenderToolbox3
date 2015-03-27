%%% RenderToolbox3 Copyright (c) 2012-2015 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read scan multi-spectral image slice names for wavelength info
%   @param sliceNames cell array of image slice names
%   @param namePattern sscanf() pattern to use on slice names
%
% @details
% Scans each multi-spectral image slice in the given @a sliceNames for
% numeric wavelength data.
%
% @details
% By default, scans each slice name using the sscanf() pattern '%f-%f'.  If
% @a namePattern is provided, it must be a different pattern to use
% instead.
%
% @details
% For each image slice, if sscanf() returns a single number, this is
% treated as a spectral band center.  If sscanf() returns two numbers, they
% are treated as band edges and averaged to obtain a band center.  If
% sscanf() returns zero or more than two numbers, that band is ignored.
%
% @details
% Returns an array of n spectral band centers, one for each image slice.
% The array will be sorted from low to high.  Also returns a summary of the
% list of wavelengths in "S" format.  This is an array with elements [start
% delta n].  Finally, returns an array of indices that may be used to sort
% the given @a sliceNames or other data from low to high wavelength.
%
% @details
% Usage:
%   [wls, S, order] = GetWlsFromSliceNames(sliceNames, namePattern)
%
% @ingroup Readers
function [wls, S, order] = GetWlsFromSliceNames(sliceNames, namePattern)

if nargin < 2 || isempty(namePattern)
    namePattern = '%f-%f';
end

% look for channels that contain wavelengths
nSlices = numel(sliceNames);
wls = zeros(1, nSlices);
isSpectralBand = false(1, nSlices);
for ii = 1:nSlices
    band = sscanf(sliceNames{ii}, namePattern);
    switch numel(band)
        case 1
            wls(ii) = band;
            isSpectralBand(ii) = true;
        case 2
            wls(ii) = mean(band);
            isSpectralBand(ii) = true;
    end
end

% sort slices by wavelength
[wls, order] = sort(wls);
isSpectralBand = isSpectralBand(order);

% summarize the slice wavelengths
wls = wls(isSpectralBand);
S = MakeItS(wls(:));
