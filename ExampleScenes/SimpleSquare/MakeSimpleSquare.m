%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a square in many colors.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'SimpleSquare.dae';
mappingsFile = 'SimpleSquareMappings.txt';
conditionsFile = 'SimpleSquareConditions.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 50;
hints.imageHeight = 50;
hints.outputSubfolder = mfilename();
hints.workingFolder = GetOutputPath('tempFolder', hints);
ChangeToFolder(hints.workingFolder);

%% Render with Mitsuba and PBRT
toneMapFactor = 0;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    
    montageName = sprintf('%s (%s)', 'SimpleSquare', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
