%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the Dice scene with various spatial transformations.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'Dice.dae';
mappingsFile = 'DiceTransformationsMappings.txt';
conditionsFile = 'DiceTransformationsConditions.txt';

%% Choose batch renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.outputSubfolder = mfilename();
hints.workingPath = fileparts(mfilename('fullpath'));

%% Render with Mitsuba and PBRT.
toneMapFactor = 10;
isScale = true;
for renderer = {'Mitsuba','PBRT'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    
    for ii = 1:numel(radianceDataFiles)
        [dataPath, imageName] = fileparts(radianceDataFiles{ii});
        montageName = sprintf('Dice - %s (%s)', imageName, hints.renderer);
        montageFile = [montageName '.png'];
        [SRGBMontage, XYZMontage] = MakeMontage( ...
            radianceDataFiles(ii), montageFile, toneMapFactor, isScale, hints);
        ShowXYZAndSRGB([], SRGBMontage, montageName);
    end
end
