%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Calculate scale factors to bring renderer outputs into radiance units.
%   @param renderer the name of the renderer to use
%
% @details
% Calculates a radiometric unit scale factor for the given @renderer and
% stores the scale factor using Matlab's setpref().  Radiometric unit scale
% factors are used by RenderToolbox3 DataToRadiance functions to bring
% "raw" renderer output into physical rasiance units.  Computation is based
% on the ExampleScenes/RadiaceTest recipe which has known radiometric
% properties.
%
% @details
% See the RenderToolbox3 wiki for details about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/RadianceTest'>Radiometric
% Unit</a> calculation.
%
% @details
% Stores the calculated scale factors for each renderer, using the built-in
% setpref() function.  To see the results for a @a renderer such as
% "SampleRenderer", try
% @code
%   scaleFactor = getpref('SampleRenderer', 'radiometricScale');
% @endcode
%
% @details
% Returns the computed radiometric unit scale factor for the given
% @a renderer.
%
% @details
% Usage:
%   radiometricScaleFactor = ComputeRadiometricScaleFactor(renderer)
%
% @ingroup BatchRenderer
function radiometricScaleFactor = ComputeRadiometricScaleFactor(renderer)

% temporarily disable radometric scaling
setpref(renderer, 'radiometricScaleFactor', 1);

%% Produce renderingings with known radiometric properties.
% render the RadianceTest scene
%   assume outputs go to the deafult outputDataFolder
setpref('RenderToolbox3', 'renderer', renderer);
MakeRadianceTest;

%% Read known parameters from the RadianceTest "reference" condition.
% distance from point light to reflector
[names, values] = ParseConditions('RadianceTestConditions.txt');
isName = strcmp('imageName', names);
isReference = strcmp('reference', values(:, isName));
isDistance = strcmp('lightDistance', names);
distanceToPointSource = StringToVector(values{isReference, isDistance});

% power of point source per unit wavelength
%   arbitrarily, choose a spectrum sample near 500nm
isSpectrum = strcmp('lightSpectrum', names);
spectrumFile = values{isReference, isSpectrum};
[wavelengths, magnitudes] = ReadSpectrum(spectrumFile);
spectrumIndex = find(wavelengths >= 500, 1, 'first');
pointSource_PowerPerUnitWavelength = magnitudes(spectrumIndex);

%% Compute expected radiance from first principles.

% illuminance arriving at a unit area on the diffuser.
irradiance_PowerPerUnitAreaUnitWl = ...
    pointSource_PowerPerUnitWavelength/(4*pi*(distanceToPointSource^2));

% light coming off the diffuser scatters over a hemisphere.
%   because of the cos(phi) factor in the lambertion equation,
%   the total light over the hemisphere is equal to pi times
%   the luminance.  See Wyszecki and Stiles, 2cd edition, pp.
%   273-274, equaiton 29(4.3.6).
radiance_PowerPerAreaSrUnitWl = irradiance_PowerPerUnitAreaUnitWl/(pi);

%% Compute a radiometric unit scale factor the given render.
dataFolder = GetOutputPath('outputDataFolder');

% locate RadianceTest "reference" data file
dataFile = FindFiles(dataFolder, [renderer '.+reference']);
data = load(dataFile{1});

% get a pixel spectrum from the center of the multispectral rendering
%   arbitrarily, choose a spectrum sample near 500nm
center = round(size(data.multispectralImage)/2);
wavelengths = MakeItWls(data.S);
spectrumIndex = find(wavelengths >= 500, 1, 'first');
renderedIrradiance_PixelValue = ...
    data.multispectralImage(center(1), center(2), spectrumIndex);

% scale renderer output to match expected radiance
rendererRadiometricUnitFactor = ...
    radiance_PowerPerAreaSrUnitWl/renderedIrradiance_PixelValue;

% store the scale factor
setpref(renderer, 'radiometricScaleFactor', rendererRadiometricUnitFactor);

% explain the scale factor
fprintf('%s irradiance: %0.4g (arbitrary units)\n', ...
    renderer, renderedIrradiance_PixelValue);
fprintf('Corresponding radiance: %0.4g (power/[area-sr-wl])\n', ...
    radiance_PowerPerAreaSrUnitWl);
fprintf('%s scale factor: %0.4g to bring rendered image into physical radiance units\n\n', ...
    renderer, rendererRadiometricUnitFactor);

% report the new scale factor
radiometricScaleFactor = getpref(renderer, 'radiometricScaleFactor');