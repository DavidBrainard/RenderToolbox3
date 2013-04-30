%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the MaterialSphere scene in a portable fashion.
clear;
clc;

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'MaterialSphere.dae';
conditionsFile = 'MaterialSphereConditions.txt';
mappingsFile = 'MaterialSphereBumpsMappings.txt';

%% Choose batch renderer options.
% which materials to use, [] means all
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 200;
hints.imageHeight = 160;

% resources like images and spectrum files should use relative paths
hints.isAbsoluteResourcePaths = false;

%% Create scene files for Mistuba and PBRT.
%   this could happen on "machine A"
startFolder = pwd();
for renderer = {'Mitsuba', 'PBRT'}
    % choose one renderer
    hints.renderer = renderer{1};
    
    % save scene files and auxiliary files in a custom folder
    outFolder = fullfile(startFolder, 'portable-scenes', hints.renderer);
    MakeSceneFiles(sceneFile, conditionsFile, mappingsFile, hints, outFolder);
end

%% Render with Mitsuba and PBRT.
% this could happen on "machine B", after copying over the custom folder

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;
for renderer = {'Mitsuba', 'PBRT'}
    % choose one renderer
    hints.renderer = renderer{1};
    
    % locate scene ".xml" files in the custom folder
    sceneFolder = fullfile(startFolder, 'portable-scenes', hints.renderer);
    sceneFiles = FindFiles(sceneFolder, '\.xml');
    
    % render from the custom folder so renderers can find auxiliary files
    cd(sceneFolder);    
    outFiles = BatchRender(sceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('MaterialSpherePortable (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

cd(startFolder);
