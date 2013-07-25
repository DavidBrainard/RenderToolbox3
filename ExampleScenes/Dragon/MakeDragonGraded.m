%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the Dragon scene with 5 graded colors.

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
parentSceneFile = 'Dragon.dae';
conditionsFile = 'DragonGradedConditions.txt';
mappingsFile = 'DragonGradedMappings.txt';

%% Choose batch renderer options.
nSteps = 6;
hints.whichConditions = 1:nSteps;
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.outputSubfolder = mfilename();

%% Move to temp folder before creating new files.
originalFolder = pwd();
tempFolder = GetOutputPath('tempFolder', hints);
AddWorkingPath(tempFolder);
cd(tempFolder);

%% Write graded spectrum files.
% choose two spectrums to grade between
spectrumA = 'mccBabel-6.spd';
[wlsA, srfA] = ReadSpectrum(spectrumA);
spectrumB = 'mccBabel-9.spd';
[wlsB, srfB] = ReadSpectrum(spectrumB);

% grade linearly from a to b
alpha = linspace(0, 1, nSteps);
imageNames = cell(nSteps, 1);
fileNames = cell(nSteps, 1);
for ii = 1:nSteps
    srf = alpha(ii)*srfA + (1-alpha(ii))*srfB;
    imageNames{ii} = sprintf('GradedDragon-%d', ii);
    fileNames{ii} = sprintf('GradedSpectrum-%d.spd', ii);
    WriteSpectrumFile(wlsA, srf, fileNames{ii});
end

% write a conditions file with image names and spectrum file names.
varNames = {'imageName', 'dragonColor'};
varValues = cat(2, imageNames, fileNames);
WriteConditionsFile(conditionsFile, varNames, varValues);

%% Render with Mitsuba and PBRT.
toneMapFactor = 10;
isScaleGamma = true;
for renderer = {'Mitsuba'}
    hints.renderer = renderer{1};
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    for ii = 1:nSteps
        montageName = sprintf('DragonGraded-%d (%s)', ii, hints.renderer);
        montageFile = [montageName '.png'];
        [SRGBMontage, XYZMontage] = MakeMontage( ...
            radianceDataFiles(ii), montageFile, toneMapFactor, isScaleGamma, hints);
        ShowXYZAndSRGB([], SRGBMontage, montageName);
    end
end

cd(originalFolder);