%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a Ward sphere under a point light and orthogonal camera.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'SimpleSphere.dae';
mappingsFile = 'SimpleSphereMappings.txt';

%% Choose batch renderer options.
hints.imageWidth = 201;
hints.imageHeight = 201;
hints.outputSubfolder = mfilename();
hints.workingFolder = GetOutputPath('tempFolder', hints);
ChangeToFolder(hints.workingFolder);

%% Render with Mitsuba and PBRT
toneMapFactor = 10;
isScale = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, '', mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('%s (%s)', 'SimpleSphere', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
