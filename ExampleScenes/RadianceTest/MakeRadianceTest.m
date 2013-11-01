%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render a perfect reflector and check physical principles.
%   @param renderer name of the renderer to render with
%
% @details
% Using the given @a renderer, renders several variations on a calibrated
% test scene with known radiometric properties.  This is a useful
% diagnostic for any renderer, so this "executive script" accepts a
% renderer name as a function argument.
%
% @details
% Usage:
%   MakeRadianceTest(renderer)
function MakeRadianceTest(renderer)

hints = GetDefaultHints();
if nargin > 0
    hints.renderer = renderer;
end

%% Choose example files, make sure they're on the Matlab path.
examplePath = fileparts(mfilename('fullpath'));
AddWorkingPath(examplePath);
parentSceneFile = 'RadianceTest.dae';
conditionsFile = 'RadianceTestConditions.txt';
mappingsFile = 'RadianceTestMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 100;
hints.imageHeight = 100;
hints.outputSubfolder = mfilename();

%% Move to temp folder before creating new files.
originalFolder = pwd();
tempFolder = GetOutputPath('tempFolder', hints);
AddWorkingPath(tempFolder);
cd(tempFolder);

%% Choose illuminant spectra.
% uniform white spectrum sampled every 5mn
wls = 300:5:800;
magnitudes = ones(size(wls));
WriteSpectrumFile(wls, magnitudes, 'uniformSpectrum5nm.spd');

% uniform white spectrum sampled every 10mn
wls = 300:10:800;
magnitudes = ones(size(wls));
WriteSpectrumFile(wls, magnitudes, 'uniformSpectrum10nm.spd');

%% Render with Mitsuba and PBRT.
% make an sRGB montage for the default renderer
toneMapFactor = 10;
isScaleGamma = true;

% turn off radiometric unit scaling
oldRadiometricScale = getpref(hints.renderer, 'radiometricScaleFactor');
setpref(hints.renderer, 'radiometricScaleFactor', 1);

% make multi-spectral renderings, saved in .mat files
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);

% restore radiometric unit scaling
setpref(hints.renderer, 'radiometricScaleFactor', oldRadiometricScale);

% condense multi-spectral renderings into one sRGB montage
montageName = sprintf('RadianceTest (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScaleGamma, hints);

% display the sRGB montage
ShowXYZAndSRGB([], SRGBMontage, montageName);

cd(originalFolder);