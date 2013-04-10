%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the CubanSphere scene, with a texture.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'CubanSphere.dae';
conditionsFile = 'CubanSphereConditions.txt';
mappingsFile = 'CubanSphereTexturedMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = 1:4:36;
hints.imageWidth = 200;
hints.imageHeight = 160;

%% Render with Mitsuba and PBRT
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    sceneFiles = MakeSceneFiles(sceneFile, conditionsFile, mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    montageName = sprintf('%s (%s)', 'CubanSphere-Textured', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
