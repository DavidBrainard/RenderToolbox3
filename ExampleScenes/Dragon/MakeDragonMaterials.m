%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render the Dragon Materials scene.
%

%%
clear;
clc;
working = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'Dragon');
batchOutputs = fullfile(working, 'outputMaterials');
cd(working);

%% Choose files to work with.
sceneFile = 'Dragon.dae';
conditionsFile = 'DragonMaterialsConditions.txt';
mappingsFile = 'DragonMaterialsMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 200;
hints.imageHeight = 160;
hints.isDeleteIntermediates = true;
hints.outputFolder = batchOutputs;

%% Render with Mitsuba and PBRT.
toneMapFactor = 2.5;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints);
    montageName = sprintf('%s (%s)', 'DragonMaterials', hints.renderer);
    montageFile = [montageName '.tiff'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

%% Clean up the batch render outputs.
if hints.isDeleteIntermediates
    rmdir(batchOutputs, 's')
end
