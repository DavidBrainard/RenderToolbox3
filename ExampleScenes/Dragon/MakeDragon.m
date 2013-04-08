%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render the Dragon scene.
%

%%
clear;
clc;
working = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'Dragon');
cd(working);

%% Choose files to work with.
sceneFile = 'Dragon.dae';

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.isDeleteIntermediates = true;

%% Render with Mitsuba and PBRT
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, '', '', hints);
    montageName = sprintf('%s (%s)', 'Dragon', hints.renderer);
    montageFile = [montageName '.tiff'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
