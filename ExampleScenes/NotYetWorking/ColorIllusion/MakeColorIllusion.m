%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the ColorIllusion scene, with a texture.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'ColorIllusion.dae';
mappingsFile = 'ColorIllusionMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 320;
hints.imageHeight = 240;

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    sceneFiles = MakeSceneFiles(sceneFile, '', mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    montageName = sprintf('%s (%s)', 'ColorIllusion', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
