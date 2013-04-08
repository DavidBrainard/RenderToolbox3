%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a furnished interior scene from Nextwave Multimedia.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
scenePath = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'Interior');
sceneFile = fullfile(scenePath, 'interior/source/interio.dae');
conditionsFile = 'InteriorConditions.txt';
mappingsFile = 'InteriorMappings.txt';

%% Choose batch renderer options.
hints.isDeleteTemp = false;
hints.whichConditions = [];

%% Render with Mitsuba and PBRT
toneMapFactor = 10;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints);
    
    % write each condition to a separte image file
    for ii = 1:numel(outFiles)
        [outPath, outBase, outExt] = fileparts(outFiles{ii});
        montageName = sprintf('%s (%s)', outBase, hints.renderer);
        montageFile = [montageName '.png'];
        [SRGBMontage, XYZMontage] = MakeMontage( ...
            outFiles(ii), montageFile, toneMapFactor, isScale, hints);
        ShowXYZAndSRGB([], SRGBMontage, montageName);
    end
end
