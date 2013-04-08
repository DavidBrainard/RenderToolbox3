%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render the CubanSphere scene and make a montage.
%

%%
clear;
clc;
working = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'CubanSphere');
batchOutputs = fullfile(working, 'outputs');
cd(working);

%% Choose files to work with.
sceneFile = 'CubanSphere.dae';
conditionsFile = 'CubanSphereConditions.txt';
mappingsFile = 'CubanSphereMappings.txt';

[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 200;
hints.imageHeight = 160;
hints.isDeleteIntermediates = true;
hints.outputFolder = batchOutputs;

%% Render with Mitsuba and PBRT
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints);
    montageName = sprintf('%s (%s)', sceneBase, hints.renderer);
    montageFile = [montageName '.tiff'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

%% Clean up the batch render outputs.
if hints.isDeleteIntermediates
    rmdir(batchOutputs, 's')
end

