%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the Checkerboard scene with variable dimensions.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'Checkerboard.dae';
mappingsFile = 'CheckerboardMappings.txt';

%% Choose batch renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.outputSubfolder = mfilename();
hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

%% Write scene parameters to a new conditions file.
distance = 76.4;
eyeSep = 6.4;
hFov = 50;
width = 21;
height = 13;
names = { ...
    'distance',    'eyePos',    'fov',  'width',	'height'};
values = {...
    distance,     -eyeSep/2     hFov    width       height; ...
    distance,     +eyeSep/2     hFov    width       height};

conditionsFile = fullfile(GetWorkingFolder('resources', false, hints), ...
    'CheckerboardConditions.txt');
conditionsFile = WriteConditionsFile(conditionsFile, names, values);

%% Render with Mitsuba and PBRT.
toneMapFactor = 10;
isScaleGamma = true;
for renderer = {'Mitsuba', 'PBRT'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    montageName = sprintf('Checkerboard (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
