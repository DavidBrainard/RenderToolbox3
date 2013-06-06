%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a Ward sphere under point light and orthogonal optics.
% This renders a sphere using Matlab code writted from scratch as part of
% Render Toolbox version 2.  It is a sanity check on the "correct" way to
% render a sphere under a point light and orthogonal projection.
%
% Sets sphere rendering parameters and executes rendering according to
% SphereRenderer rendering algorithm, which is implemented all in Matlab.
%
% This script is based on DoMatlabSphereRender.m from Render Toolbox
% version 2, by Dan Lichtman and David Brainard.

%% Make sure working folder is on the Matlab path.
AddWorkingPath(mfilename('fullpath'));

%% Check whether the Matalb Sphere Renderer is installed.
checkFile = 'SphereRender_BatchRender.m';
if exist(checkFile, 'file')
    sphereRenderPath = fileparts(which(checkFile));
    fprintf('Using Matlab Sphere Renderer found here: \n  %s\n', ...
        sphereRenderPath);
    
else
    wikiLink = 'https://github.com/DavidBrainard/SphereRendererToolbox/wiki';
    fprintf('Matlab Sphere Renderer not found.  Get it here:\n  %s\n', ...
        wikiLink);
end

%% Create new files in a subfolder next to renderer outputs.
dataFolder = fullfile(getpref('RenderToolbox3', 'outputDataFolder'), ...
    getpref('RenderToolbox3', 'outputSubolder'));
working = fullfile(dataFolder, 'SphereRenderer');
if ~exist(working, 'dir')
    mkdir(working)
end

originalPath = pwd();
cd(working);

%% Choose rendering and scene parameters.

% spectral sampling
S = [400 10 31];
params.sampleVec = S;
params.numSamples = S(3);

% tone mapping
params.toneMapName = 'cutOff';
params.cutOff.meanMultiplier = 10;
params.toneMapLock = 0;

% view down the z-axis
params.viewPoint = [0 0 1000];

% sphere size -> image size
params.radius = 100;

% glossy Ward sphere with orange Color Checker color
[sphereWls, sphereMags] = ReadSpectrum('mccBabel-2.spd');
params.diffuseConst = SplineSrf(sphereWls, sphereMags, S)';
params.specularConst = 0.07 * ones(1,S(3));
params.specularBlurConst = 0.05 * ones(S(3),1);

% distant point light with daylight spectrum
[lightWls, lightMags] = ReadSpectrum('D65.spd');
params.lightIntensity = SplineSpd(lightWls, lightMags, S);
params.ambientLightIntensity = zeros(size(params.lightIntensity));
params.lightCoords = 1e3 * [1 1 1];
params.numLights = 1;

%% Render the sphere!

% Matlab sphere renderer creates 3 files:
% - sphereRenderer_imageData.mat
% - sphereRenderer_imageRGBtoneMapped.mat
% - sphereRendererimageRGBtoneMapped.jpg
toneMapProfile = render(params);

% save multi-spectral data in RenderToolbox3 format
outFile = 'MatlabSphere.mat';
sphereData = load('sphereRenderer_imageData.mat');
multispectralImage = sphereData.imageData;
save(outFile, 'multispectralImage', 'S');

cd(originalPath);
