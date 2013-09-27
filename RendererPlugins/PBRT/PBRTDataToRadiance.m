%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert PBRT multi-spectral data to radiance units.
%   @param pbrtData "raw" data from a PBRT multi-spectral rendering
%   @param pbrtDoc XML DOM document node representing the PBRT-XML scene
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Scales the given "raw" @a pbrtData into physical radiance units.  The
% scaling depends on a PBRT-specific scale factor computed previously with
% ComputeRadiometricScaleFactors().  The scaling might also depend on some
% non-radiometric scene parameters.  If these parameters use non-default
% values, prints a warning that additional scaling might be required.
%
% @details
% @a pbrtData should be a matrix of multi-spectral data obtained from
% the PBRT renderer, and read into Matlab with a function like
% ReadDAT().  Each element of @a pbrtData will be scaled into radiance
% units.
%
% @details
% @a pbrtDoc should be the "document" node of the PBRT-XML document that
% represents the rendered scene, as returned from ColladaToPBRT().
% Parameters stored in the PBRT-XML document might indicate that the scene
% should be scaled in order to compensate fot non-radiometric factors, like
% the number of ray samples used per pixel.
%
% @details
% @a hints should be a struct with additional parameters used during
% rendering.  In particular, @a hints.PBRTRadiometricScale may contain the
% PBRT-specific scale factor for converting multi-spectral data to
% radiance units.  If @a hints does not contain this field, the default
% value will be taken from GetDefaultHints().
%
% @details
% Returns the given "raw" @a pbrtData, scaled into physical radiance
% units.  Also returns the radiance scale factor that was used, which in
% some cases might differ from @a hints.PBRTRadiometricScale.
%
% @details
% Usage:
%   [radianceData, scaleFactor] = PBRTDataToRadiance(pbrtData, pbrtDoc, hints)
%
% @ingroup BatchRenderer
function [radianceData, scaleFactor] = PBRTDataToRadiance(pbrtData, pbrtDoc, hints)

if nargin < 2
    pbrtDoc = [];
end

% merge custom hints with defaults
if nargin < 3 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if IsStructFieldPresent(hints, 'PBRTRadiometricScale')
    % get custom or stored scale factor
    scaleFactor = hints.PBRTRadiometricScale;
else
    % scale factor has not been computed yet
    scaleFactor = 1;
end

%% PBRT requires scene-specific adjustments to the scaling factor.
if isempty(pbrtDoc)
    warning('RenderToolbox3:PBRTXMLIncorrectlyScaled','PBRT-XML document was not provided.\nRadiance data might be incorrectly scaled.');
    
else
    % compare scene pixel reconstruction filter to default
    sceneIdMap = GenerateSceneIDMap(pbrtDoc);
    defaultAdjustments = 'PBRTDefaultAdjustments.xml';
    [defaultDoc, defaultIdMap] = ReadSceneDOM(defaultAdjustments);
    
    nodePath = 'filter.type';
    sceneFilterType = GetSceneValue(sceneIdMap, nodePath);
    if ~isempty(sceneFilterType)
        defaultFilterType = GetSceneValue(defaultIdMap, nodePath);
        checkSceneParameter('Pixel Filter type', ...
            sceneFilterType, defaultFilterType);
    end
    
    nodePath = 'filter:parameter|name=alpha';
    sceneAlpha = GetSceneValue(sceneIdMap, nodePath);
    if ~isempty(sceneAlpha)
        defaultAlpha = GetSceneValue(defaultIdMap, nodePath);
        checkSceneParameter('Pixel Filter alpha', sceneAlpha, defaultAlpha);
    end
    
    nodePath = 'filter:parameter|name=xwidth';
    sceneXWidth = GetSceneValue(sceneIdMap, nodePath);
    if ~isempty(sceneXWidth)
        defaultXWidth = GetSceneValue(defaultIdMap, nodePath);
        factor = StringToVector(defaultXWidth) / StringToVector(sceneXWidth);
        checkSceneParameter('Pixel Filter xwidth', ...
            sceneXWidth, defaultXWidth, factor);
    end
    
    nodePath = 'filter:parameter|name=ywidth';
    sceneYWidth = GetSceneValue(sceneIdMap, nodePath);
    if ~isempty(sceneYWidth)
        defaultYWidth = GetSceneValue(defaultIdMap, nodePath);
        factor = StringToVector(defaultYWidth) / StringToVector(sceneYWidth);
        checkSceneParameter('Pixel Filter ywidth', ...
            sceneYWidth, defaultYWidth, factor);
    end
    
    % TODO: apply non-radiometric scale corrections for filter
    
    % compare scene ray sampler to default
    nodePath = 'sampler.type';
    sceneSamplerType = GetSceneValue(sceneIdMap, nodePath);
    if ~isempty(sceneSamplerType)
        defaultSamplerType = GetSceneValue(defaultIdMap, nodePath);
        checkSceneParameter('Sampler type', sceneSamplerType, defaultSamplerType);
    end
    
    nodePath = 'sampler:parameter|name=pixelsamples';
    sceneSamplesPerPixel = GetSceneValue(sceneIdMap, nodePath);
    if ~isempty(sceneSamplesPerPixel)
        defaultSamplesPerPixel = GetSceneValue(defaultIdMap, nodePath);
        factor = StringToVector(defaultSamplesPerPixel) / StringToVector(sceneSamplesPerPixel);
        checkSceneParameter('Sampler samples per pixel', ...
            sceneSamplesPerPixel, defaultSamplesPerPixel, factor);
    end
    
    % TODO: apply non-radiometric scale corrections for sampler
end

radianceData = scaleFactor .* pbrtData;


% Warn if scene and default properties don't match.
function checkSceneParameter(paramName, sceneValue, defaultValue, scale)

if ~strcmp(sceneValue, defaultValue)
    warningMessage = sprintf('%s (%s) does not match default (%s).', ...
        paramName, sceneValue, defaultValue);
    if nargin >= 4 && ~isempty(scale)
        warningMessage = sprintf('%s\n Radiance data might need to be scaled by a factor of %f.', ...
            warningMessage, scale);
    else
        warningMessage = sprintf('%s\n Radiance data might be incorrectly scaled.', ...
            warningMessage);
    end
    warning('RenderToolbox3:DefaultParamsIncorrectlyScaled',warningMessage);
end