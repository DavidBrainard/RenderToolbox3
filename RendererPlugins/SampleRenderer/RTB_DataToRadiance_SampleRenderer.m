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
