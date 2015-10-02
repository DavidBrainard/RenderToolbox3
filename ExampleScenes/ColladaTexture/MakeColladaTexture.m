%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the ColladaTexture scene.

clear;

%% Choose example files.
parentSceneFile = 'ColladaTexture.dae';

mfilePath = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'ColladaTexture');
stoneWallImage = fullfile(mfilePath, 'stone-wall.exr');
earthImage = fullfile(mfilePath, 'earthbump1k-stretch-rgb.exr');

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

%% Copy images to working folder where renders can find them
copyfile(stoneWallImage, GetWorkingFolder('', false, hints));
copyfile(earthImage, GetWorkingFolder('', false, hints));

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', '', hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('ColladaTexture (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
