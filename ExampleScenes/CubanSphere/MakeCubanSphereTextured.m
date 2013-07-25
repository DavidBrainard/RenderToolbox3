%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the CubanSphere scene, with a texture.

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
parentSceneFile = 'CubanSphere.dae';
conditionsFile = 'CubanSphereTexturedConditions.txt';
mappingsFile = 'CubanSphereTexturedMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = 1:4:36;
hints.imageWidth = 200;
hints.imageHeight = 160;
hints.outputSubfolder = mfilename();

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('%s (%s)', 'CubanSphere-Textured', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
