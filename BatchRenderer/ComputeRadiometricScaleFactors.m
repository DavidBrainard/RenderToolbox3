%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Calculate scale factors to bring renderer outputs into radiance units.
%
% @details
% Calculates a radiometric unit scale factor to bring the "raw" output from
% each renderer into physical radiance units.  Uses the
% ExampleScenes/RadiaceTest scene to generate renderings with known
% radiometric properties.
%
% @details
% See the RenderToolbox3 wiki for details about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/RadianceTest'>Radiometric
% Unit</a> calculation.
%
% @details
% Stores the calculated scale factors for each renderer, using the built-in
% setpref() function:
% @code
%   setpref('RenderToolbox3', 'PBRTRadiometricScale', pbrtScale);
%   setpref('RenderToolbox3', 'MitsubaRadiometricScale', mitsubaScale);
% @endcode
% These persistent values may be modified with setpref().  They may be
% accessed with getpref() or GetDefaultHints().
%
% @details
% PBRTDataToRadiance() and MitsubaDataToRadiance() use the stored scale
% factors to convert renderer-specific ouput data into common radiance
% units.  BatchRender() applies these conversions automatically.
%
% @details
% Custom scale factors can be used instead of stored scale factors, if they
% are supplied in a hints struct.  For example:
% @code
%   hints.PBRTRadiometricScale = myPBRTScale;
%   hints.MitsubaRadiometricScale = myMitsubaScale;
%   BatchRender(..., hints);
% @endcode
%
%
% @details
% Returns the computed PBRT and Mitsuba radiometric unit scale factors.
%
% @details
% Usage:
%   [pbrtScale, mitsubaScale] = ComputeRadiometricScaleFactors()
%
% @ingroup BatchRender
function [pbrtScale, mitsubaScale] = ComputeRadiometricScaleFactors()

%% Get renderingings with known radiometric properties.
% render the RadianceTest scene
%   disable renderer ouput scaling
%   assume outputs go to the deafult outputDataFolder
setpref('RenderToolbox3', 'PBRTRadiometricScale', 1);
setpref('RenderToolbox3', 'MitsubaRadiometricScale', 1);
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

%% Compute a radiometric unit scale factor for each render.
dataFolder = getpref('RenderToolbox3', 'outputDataFolder');
renderers = {'PBRT', 'Mitsuba'};
for ii = 1:numel(renderers)
    % locate RadianceTest "reference" data file
    rendererName = renderers{ii};
    dataFile = FindFiles(dataFolder, [rendererName '.+reference']);
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
    prefName = [rendererName 'RadiometricScale'];
    setpref('RenderToolbox3', prefName, rendererRadiometricUnitFactor);
    
    % explain the scale factor
    fprintf('%s irradiance: %0.4g (arbitrary units)\n', ...
        rendererName, renderedIrradiance_PixelValue);
    fprintf('Corresponding radiance: %0.4g (power/[area-sr-wl])\n', ...
        radiance_PowerPerAreaSrUnitWl);
    fprintf('%s scale factor: %0.4g to bring rendered image into physical radiance units\n\n', ...
        rendererName, rendererRadiometricUnitFactor);
end

% report the scale factors
pbrtScale = getpref('RenderToolbox3', 'PBRTRadiometricScale');
mitsubaScale = getpref('RenderToolbox3', 'MitsubaRadiometricScale');