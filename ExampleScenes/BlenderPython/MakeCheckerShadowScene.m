%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render an illusion from parent scene generated procedurally.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'CheckerShadowNoDimples.dae';
mappingsFile    = 'CheckerShadowSceneMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 1000;
hints.imageHeight = 750;
hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

%% Render the scene.
toneMapFactor = 4;
isScale = true;

hints.renderer = 'Mitsuba';
nativeSceneFiles  = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('CheckerShadowScene (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
ShowXYZAndSRGB([], SRGBMontage, montageName);
