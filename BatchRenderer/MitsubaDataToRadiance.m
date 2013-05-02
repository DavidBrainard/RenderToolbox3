%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert Mitsuba multi-spectral data to radiance units.
%   @param mitsubaData "raw" data from a Mitsuba scene rendering
%   @param mitsubaDoc XML DOM document node representing the Mitsuba scene
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Scales the given "raw" @a mitsubaData into physical radiance units.  The
% scaling depends on a Mitsuba-specific scale factor computed previously
% with ComputeRadiometricScaleFactors(), and may also depend on particulars
% of the scene.
%
% @details
% @a mitsubaData should be a matrix of multi-spectral data obtained from
% the Mitsuba renderer, and read into Matlab with a function like
% ReadMultispectralEXR().  Each element of @a mitsubaData will be scaled
% into radiance units.
%
% @details
% @a mitsubaDoc should be the "document" node of the XML document that
% represents the rendered scene.  Particulars of the scene specification
% might affect how @a mitsubaData is scaled.
%
% @details
% @a hints should be a struct with additional parameters used during
% rendering.  In particular, @a hints.MitsubaRadiometricScale may contain
% the mitsuba-specific scale factor for converting multi-spectral data to
% radiance units.  If @a hints does not contain this field, the default
% value will be taken from
% @code
%   scaleFactor = getpref('RenderToolbox3', 'MitsubaRadiometricScale');
% @endcode
%
% @details
% Returns the given "raw" @a mitsubaData, scaled into physical radiance
% units.  Also returns the radiance scale factor that was used, which in
% some cases might differ from @a hints.MitsubaRadiometricScale.
%
% @details
% Usage:
%   [radianceData, scaleFactor] = MitsubaDataToRadiance(mitsubaData, mitsubaDoc, hints)
%
% @ingroup BatchRender
function [radianceData, scaleFactor] = MitsubaDataToRadiance(mitsubaData, mitsubaDoc, hints)

% merge custom hints with defaults
if nargin < 3 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if IsStructFieldPresent(hints, 'MitsubaRadiometricScale')
    % get custom or stored scale factor
    scaleFactor = hints.MitsubaRadiometricScale;
else
    % scale factor has not been computed yet
    scaleFactor = 1;
end

%% As far as we know, Mitsuba does not require scene-specific adjustments
%   to the scaling factor.
radianceData = scaleFactor .* mitsubaData;