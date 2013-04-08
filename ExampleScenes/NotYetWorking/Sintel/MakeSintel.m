%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a still image from the Sintel Blender animated movie.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'sintel_lite_cycles_v2.dae';

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.isDeleteTemp = true;

%% Render with Mitsuba and PBRT
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, '', '', hints);
    montageName = sprintf('%s (%s)', 'Sintel', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
