%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a shiny sphere sitting on a table.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'TableSphere.dae';
mappingsFile = 'TableSphereMappings.txt';
conditionsFile = 'TableSphereConditions.txt';

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.isDeleteTemp = true;

%% Render with Mitsuba and PBRT
toneMapFactor = 10;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints);
    montageName = sprintf('%s (%s)', 'TableSphere', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
