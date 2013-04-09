%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a perfect reflector and check physics of radiance units.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
examplePath = fileparts(mfilename('fullpath'));
AddWorkingPath(examplePath);
sceneFile = 'RadianceTest.dae';
conditionsFile = 'RadianceTestConditions.txt';
mappingsFile = 'RadianceTestMappings.txt';

%% Choose illuminant spectra.
% uniform white spectrum sampled every 5mn
wls = 300:5:800;
magnitudes = ones(size(wls));
name = fullfile(examplePath, 'uniformSpectrum5nm.spd');
WriteSpectrumFile(wls, magnitudes, name);

% uniform white spectrum sampled every 10mn
wls = 300:10:800;
magnitudes = ones(size(wls));
name = fullfile(examplePath, 'uniformSpectrum10nm.spd');
WriteSpectrumFile(wls, magnitudes, name);

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageWidth = 100;
hints.imageHeight = 100;

%% Render with Mitsuba and PBRT.
% make an sRGB montage with each renderer
toneMapFactor = 10;
isScaleGamma = true;
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 3 multi-spectral renderings, saved in .mat files
    outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('%s (%s)', 'RadianceTest', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end