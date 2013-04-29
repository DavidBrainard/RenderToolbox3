%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Promote an RGB reflectance to a full spectrum, using a renderer.
%   @param reflectance RGB reflectance to promote to spectrum
%   @param illuminant illuminant spectrum to use in rendering
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Converts the given RGB @a reflectance to a spectral value, by rendering a
% simple scene that contains a matte reflector with the given surface @a
% reflectance, illuminated by a directional "sun" light with the given @a
% illuminant spectrum.
%
% @details
% @a reflectance should have RGB components in the range [0 1].
%
% @details
% The renderer will "promote" the given RGB @a reflectance to its own
% internal spectral representation, perform rendering, and output some
% pixels that have spectral values that depend a few factors:
%   - the given RGB @a reflectance
%   - the given @a illuminant spectrum
%   - the geometry of the test scene
%   - the renderer's spectral promotion algorithm
%   .
%
% @details
% This function estimates the "promoted" reflectance spectrum that the
% renderer used internally:
%   - reads the spectrum from one of the rendered output pixels
%   - "divides out" the spectrum of the given @a illuminant
%   - normalizes the obtained spectrum to have the same max value as the
%   given @a reflectance.
%   .
% The obtained "promoted" spectrum will expose the "shape" of the
% renderer's sprctral promotion algorithm, but not scaling effects.
%
% @details
% This function also converts the "promoted" spectrum to down to an RGB
% RGB representation, for comparison with the given @a reflectance.  The
% down-conversion uses the CIE XYZ 1931 color matching functions.  The
% donw-converted RGB reflectance will have its max value scaled to match
% the given @a reflectance.
%
% @details
% By default, uses a "white" illuminant spectrum with unit untensity at all
% wavelengths.  If @a illuminant is provided, it must be a formatted
% string or name of a formatted text file that contains spectrum data. See
% ReadSpectrum() for string and text file formats.
%
% @details
% @a hints may be a struct with options that affect the rendering process,
% as returned from GetDefaultHints().  If @a hints is omitted, default
% options are used.  @a hints.renderer specifies which renderer to use.
%
% @details
% Returns the estimated, "promoted" reflectance spectrum that the renderer
% used internally.  Also returns the "S" description of the renderer's
% wavelength sampling.  Also returns the RGB representation of the promoted
% spectrum.  Finally, returns the name of the .mat file that contains the
% renderer ouput data and metadata from the simple scene rendering.
%
% @details
% Usage:
%   [promoted, S, RGB, dataFile] = PromoteRGBReflectance(reflectance, illuminant, hints)
%
% @ingroup Readers
function [promoted, S, RGB, dataFile] = PromoteRGBReflectance(reflectance, illuminant, hints)

if nargin < 2 || isempty(illuminant)
    illuminant = '300:1 800:1';
end

if nargin < 3
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

% choose scene files.
scenePath = fullfile(RenderToolboxRoot(), 'Utilities', 'SpectralPromotion');
sceneFile = fullfile(scenePath, 'SpectralPromotion.dae');
mappingsFile = fullfile(scenePath, 'SpectralPromotionMappings.txt');
calibrationFile = fullfile(scenePath, 'SpectralPromotionCalibration.mat');
conditionsFile = 'SpectralPromotionConditions.txt';

% create a conditions file with given reflectance and illuminant
varNames = {'reflectanceRGB', 'illuminant'};
varValues = {reflectance, illuminant};
conditionsFile = WriteConditionsFile(conditionsFile, varNames, varValues);

% choose batch renderer options
hints.whichConditions = [];
nPixels = 50;
hints.imageWidth = nPixels;
hints.imageHeight = nPixels;

% render and read an output pixel from the middle
sceneFiles = MakeSceneFiles(sceneFile, conditionsFile, mappingsFile, hints);
outFiles = BatchRender(sceneFiles, hints);
dataFile = outFiles{1};
outData = load(dataFile);
S = outData.S;
outPixel = outData.multispectralImage(nPixels/2, nPixels/2, :);
outPixel = squeeze(outPixel);

% divide out scene specific scale factors related to geometry
%   this should be independent of the renderer
calibrationData = load(calibrationFile);
outPixel = outPixel ./ calibrationData.geometryScale;

% divide out the illuminant
%   SplineRaw(), not SplineSpd(): renderers already assume power/wavelength
[illumWls, illumPower] = ReadSpectrum(illuminant);
illumResampled = SplineRaw(illumWls, illumPower, outData.S);
promoted = outPixel ./ illumResampled;

% convert to sRGB
tinyImage = reshape(promoted, 1, 1, []);
[sRGB, XYZ, rawRGB] = MultispectralToSRGB(tinyImage, outData.S, 0, false);
RGB = squeeze(rawRGB);

% scale so unit-valued reflectance comes out with unit-valued RGB
RGB = RGB ./ calibrationData.rgbScale;