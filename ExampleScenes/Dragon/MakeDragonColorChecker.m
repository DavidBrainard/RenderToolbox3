%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the Dragon scene with 24 ColorChecker colors.

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'Dragon.dae';
conditionsFile = 'DragonColorCheckerConditions.txt';
mappingsFile = 'DragonColorCheckerMappings.txt';

%% Choose batch renderer options.
% which colors to use, [] means all
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 150;
hints.imageHeight = 120;
hints.outputSubfolder = mfilename();

%% Move to temp folder before creating new files.
originalFolder = pwd();
tempFolder = GetOutputPath('tempFolder', hints);
AddWorkingPath(tempFolder);
cd(tempFolder);

%% Make a fresh conditions file.
% choose spectrum file names and output image names
nSpectra = 24;
imageNames = cell(nSpectra, 1);
fileNames = cell(nSpectra, 1);
for ii = 1:nSpectra
    imageNames{ii} = sprintf('macbethDragon-%d', ii);
    fileNames{ii} = sprintf('mccBabel-%d.spd', ii);
end

% write file names and image names to a conditions file
varNames = {'imageName', 'dragonColor'};
varValues = cat(2, imageNames, fileNames);
WriteConditionsFile(conditionsFile, varNames, varValues);

%% Render with Mitsuba and PBRT.

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;

% make a montage with each renderer
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 24 multi-spectral renderings, saved in .mat files
    sceneFiles = MakeSceneFiles(sceneFile, conditionsFile, mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('%s (%s)', 'DragonColorChecker', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

cd(originalFolder);
