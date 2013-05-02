%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the MaterialSphere scene with 3 materials.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'MaterialSphere.dae';
conditionsFile = 'MaterialSphereConditions.txt';
mappingsFile = 'MaterialSphereMappings.txt';

%% Choose batch renderer options.
% which materials to use, [] means all
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 200;
hints.imageHeight = 160;

%% Choose some color matching functions to make sensor images.
% choose several Pyschtoolbox matching functions
%   these are the names of Pyschtoolbox colorimetric .mat files
matchFuncs = {'T_xyz1931.mat', 'T_cones_smj', 'T_rods'};

% invent a new matching function that extracts a narrow wavelength band
bandName = 'narrow-band-matching';
nBands = 81;
bandSampling = [380 5 nBands];
bandFunction = zeros(1, nBands);
bandFunction(round(nBands/2)) = 1;

% choose the invented matching function, along with descriptive metadata
matchFuncs{4} = bandFunction;
matchSampling{4} = bandSampling;
matchNames{4} = bandName;

%% Render with Mitsuba and PBRT.

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;

% make a montage and sensor images with each renderer
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 3 multi-spectral renderings, saved in .mat files
    sceneFiles = MakeSceneFiles(sceneFile, conditionsFile, mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('MaterialSphere (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
    
    % make some sensor images, in addition to the sRGB montage
    sensorImages = MakeSensorImages( ...
        outFiles, matchFuncs, matchSampling, matchNames, hints);
end
