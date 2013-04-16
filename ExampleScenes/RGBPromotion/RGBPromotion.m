%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Probe the RGB spectral promotion algortigms of renderers.
clear;
clc;

%% Choose some illuminants and RGB colors to render
% yellow daylight
load B_cieday
temp = 4000;
spd = GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
yellowDay = WriteSpectrumFile(wls, spd, sprintf('CIE-daylight-%d.spd', temp));

% blue daylight
temp = 10000;
spd = GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
blueDay = WriteSpectrumFile(wls, spd, sprintf('CIE-daylight-%d.spd', temp));

illuminants = {'300:1 800:1', 'D65.spd', yellowDay, blueDay};
RGBs = {[.9 0 0], [0 .9 0], [0 0 .9], [.5 .5 .5]};

%% Get RGB promotions from PBRT and Mitsuba
renderers = {'Mitsuba', 'PBRT'};
nRenderers = numel(renderers);
nIlluminants = numel(illuminants);
nRGBs = numel(RGBs);
promotions = cell(nRenderers, nIlluminants, nRGBs);
Ss = cell(nRenderers, nIlluminants, nRGBs);
RGBOuts = cell(nRenderers, nIlluminants, nRGBs);
dataFiles = cell(nRenderers, nIlluminants, nRGBs);
for rend = 1:nRenderers
    for ilum = 1:nIlluminants
        for rgb = 1:nRGBs
            hints.renderer = renderers{rend};
            [promoted, S, RGB, dataFile] = ...
                PromoteRGBReflectance(RGBs{rgb}, illuminants{ilum}, hints);
            promotions{rend, ilum, rgb} = promoted;
            Ss{rend, ilum, rgb} = S;
            RGBOuts{rend, ilum, rgb} = RGB;
            dataFiles{rend, ilum, rgb} = dataFile;
        end
    end
end