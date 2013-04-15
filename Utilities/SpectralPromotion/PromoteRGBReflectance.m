%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Promote an RGB reflectance to a spectrum, using a renderer.
%   @param reflectance RGB reflectance to promote to spectrum
%   @param illuminant illuminant spectrum to use in rendering
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Converts the given RGB @a reflectance to a spectral value, by rendering a
% simple scene.  The scene contains a matte reflector with the given @a
% reflectance, illuminated by a directional "sun" light with the given @a
% illuminant spectrum.
%
% @details
% The renderer will "promote" the given RGB @a reflectance to its own
% internal spectral representation, perform rendering, and output some
% pixels that have spectral values that depend on the given RGB
% reflectance and the given @a illuminant spectrum, and also on the
% algorithm that the renderer used to promote the @a reflectance to
% spectral representation.
%
% @details
% Estimates the "promoted" reflectance that the renderer used internally
% by reading the spectrum from one of the rendered output pixels, and
% "dividing out" the known spectrum of the given @a illuminant.
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
% options are used.  hints.renderer specifies which renderer to use.
%
% @details
% Returns the estimated "promoted" reflectance spectrum that the renderer
% used internally.  Also returns the "S" description of the renderer's
% wavelength sampling.  Also returns the "promoted" reflectance spectrum,
% converted down to sRGB.  Also returns the name of the .mat file that
% contains the renderer ouput data and metadata.
%
% @details
% Usage:
%   [promoted, S, sRGB, dataFile] = PromoteRGBReflectance(reflectance, illuminant, hints)
%
% @ingroup Readers
function [promoted, S, sRGB, dataFile] = PromoteRGBReflectance(reflectance, illuminant, hints)

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
conditionsFile = fullfile(scenePath, 'SpectralPromotionConditions.txt');

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

% divide out the illuminant
[illumWls, illumPower] = ReadSpectrum(illuminant);
illumResampled = SplineSpd(illumWls, illumPower, outData.S);
promoted = outPixel ./ illumResampled;

% convert to sRGB
tinyImage = reshape(promoted, 1, 1, []);
sRGB = squeeze(MultispectralToSRGB(tinyImage, outData.S, false));
