%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert spectral power-per-wavelength-band to power-per-nanometer.
%   @param spdPerWlBand matrix of data with power-per-wavelength-band
%   @param S description of wavelength sampling, [start delta n]
%
% @details
% Converts the given @a spdPerWlBand matrix, which should contain a
% spectral power distribution with samples in units of
% power-per-wavelength-band, to the equivalent distribution with in units
% of power-per-nanometer.  The given @a S must describe the spectral
% sampling used in @a spdPerWlBand, and determines the correct conversion
% factor.
%
% @details
% Returns the given @a spdPerWlBand, divided by the spectral sampling band
% width in the given @a S.
%
% @details
% Usage:
%   spdPerNm = SpdPowerPerWlBandToPowerPerNm(spdPerWlBand, S)
%
% @ingroup Utilities
function spdPerNm = SpdPowerPerWlBandToPowerPerNm(spdPerWlBand, S)

% get the sampling bandwidth
S = MakeItS(S);
bandwidth = S(2);

% divide band power by bandwidth to get power per nanometer
spdPerNm = spdPerWlBand ./ bandwidth;
