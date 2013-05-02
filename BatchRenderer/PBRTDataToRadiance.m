%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert PBRT multi-spectral data to radiance units.
%   @param pbrtData "raw" data from a PBRT scene rendering
%   @param pbrtDoc XML DOM document node representing the PBRT scene
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Scales the given "raw" @a pbrtData into physical radiance units.  The
% scaling depends on a PBRT-specific scale factor computed previously with
% ComputeRadiometricScaleFactors(), and may also depend on particulars of
% the scene.
%
% @details
% @a pbrtData should be a matrix of multi-spectral data obtained from
% the PBRT renderer, and read into Matlab with a function like
% ReadDAT().  Each element of @a pbrtData will be scaled into radiance
% units.
%
% @details
% @a pbrtDoc should be the "document" node of the XML document that
% represents the rendered scene.  Particulars of the scene specification
% might affect how @a pbrtData is scaled.
%
% @details
% @a hints should be a struct with additional parameters used during
% rendering.  In particular, @a hints.PBRTRadiometricScale may contain the
% PBRT-specific scale factor for converting multi-spectral data to
% radiance units.  If @a hints does not contain this field, the default
% value will be taken from
% @code
%   scaleFactor = getpref('RenderToolbox3', 'PBRTRadiometricScale');
% @endcode
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
% @ingroup BatchRender
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
    disp('PBRT-XML document was not provided.');
    disp('Multi-spectral image might be incorrectly scaled.');
    
else
    idMap = GenerateSceneIDMap(pbrtDoc);
    
    % PBRT scaling depends on the width of the image reconstruction filter
    %   this code assumes the gaussian filter
    nodePath = 'filter:parameter|name=alpha';
    filterAlpha = StringToVector(GetSceneValue(idMap, nodePath));
    
    nodePath = 'filter:parameter|name=xwidth';
    filterXWidth = StringToVector(GetSceneValue(idMap, nodePath));
    
    nodePath = 'filter:parameter|name=ywidth';
    filterYWidth = StringToVector(GetSceneValue(idMap, nodePath));
    
    % TODO: how do we use filter params to modify scaleFactor?
    
    % PBRT scaling depends on the number of samples used per pixel
    %   this code assumes the lowdiscrepancy sampler
    nodePath = 'sampler:parameter|name=pixelsamples';
    samplesPerPixel = StringToVector(GetSceneValue(idMap, nodePath));
    
    % TODO: how do we use number of samples to modify scaleFactor?
end

radianceData = scaleFactor .* pbrtData;