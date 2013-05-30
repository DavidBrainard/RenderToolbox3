%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a furnished interior scene from Nextwave Multimedia, plus dragon!

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
scenePath = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'Interior');
sceneFile = fullfile(scenePath, 'interior/source/interio-dragon.dae');
mappingsFile = 'InteriorDragonMappings.txt';

% generate a fresh mappings file
%WriteDefaultMappingsFile(sceneFile, mappingsFile)

%% Write some spectra to use.
load B_cieday

% make orange-yellow for a few lights
temp = 4000;
scale = 3;
spd = scale * GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, sprintf('YellowLight.spd', temp));

% make strong yellow for the hanging spot light
temp = 5000;
scale = 30;
spd = scale * GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, sprintf('HangingLight.spd', temp));

% make daylight for the windows behind the camera
[wavelengths, magnitudes] = ReadSpectrum('D65.spd');
scale = 1;
magnitudes = scale * magnitudes;
WriteSpectrumFile(wavelengths, magnitudes, 'WindowLight.spd');

%% Choose batch renderer options.
hints.imageHeight = 480;
hints.imageWidth = 640;

%% Render with Mitsuba and PBRT
toneMapFactor = 4;
isScale = true;
for renderer = {'Mitsuba'}
    hints.renderer = renderer{1};
    sceneFiles = MakeSceneFiles(sceneFile, '', mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    montageName = sprintf('Interior Dragon (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
