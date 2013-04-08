%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the Dragon scene with 24 ColorChecker colors.

clear;
clc;

%% Create new files in the same folder as these example files.
working = fullfile(RenderToolboxRoot(), 'ExampleScenes', 'Dragon');
cd(working);

%% Choose example files.
sceneFile = 'Dragon.dae';
conditionsFile = 'DragonColorCheckerConditions.txt';
mappingsFile = 'DragonColorCheckerMappings.txt';

%% Choose batch renderer options.

% which colors to use, [] means all 24
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 150;
hints.imageHeight = 120;

% automatically clean up batch renderer intermediate files?
hints.isDeleteIntermediates = true;

% put multi-spectral renderings in a subfolder
batchOutputs = fullfile(working, 'outputColorChecker');
hints.outputFolder = batchOutputs;

%% Render with Mitsuba and PBRT.

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;

% make a montage with each renderer
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 24 multi-spectral renderings, saved in .mat files
    outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints);
    
    % condense multi-spectral renderings into one sRGB montage, 
    %   saved in a .tiff file
    montageName = sprintf('%s (%s)', 'DragonColorChecker', hints.renderer);
    montageFile = [montageName '.tiff'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

% automatically clean up multi-spectral renderings?
if hints.isDeleteIntermediates
    rmdir(batchOutputs, 's')
end
