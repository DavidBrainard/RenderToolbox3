%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the MaterialSphere scene in a portable fashion.

%% TODO: this recipe is broken.
% This recipe uses an "old" way of trying to make a recipe portable across
% machines.  When the RecipeAPI is complete, it will be a better way to
% make recipes portable.  This recipe should be updated to demonstrate the
% RecipeAPI, when the RecipeAPI is complete.
 
return

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'MaterialSphere.dae';
conditionsFile = 'MaterialSphereConditions.txt';
mappingsFile = 'MaterialSphereBumpsMappings.txt';

%% Choose batch renderer options.
% which materials to use, [] means all
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 200;
hints.imageHeight = 160;

% resources like images and spectrum files should use relative paths
hints.workingPath = pwd();

% put output files in a subfolder named like this script
hints.outputSubfolder = mfilename();
hints.workingFolder = GetOutputPath('tempFolder', hints);
ChangeToFolder(hints.workingFolder);

%% Create scene files for Mistuba and PBRT.
%   this could happen on "machine A"
portableFolder = fullfile(GetOutputPath('tempFolder', hints), 'portable-scenes');
for renderer = {'Mitsuba', 'PBRT'}
    % choose one renderer
    hints.renderer = renderer{1};
    
    % save scene required files in a custom outFolder
    outFolder = fullfile(portableFolder, hints.renderer);
    scenes = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints, outFolder);
    
    % pack up scene descriptions in a mat file in the same outFolder
    scenePack = fullfile(outFolder, 'sceneDescriptions.mat');
    save(scenePack, 'scenes');
end

%% Render with Mitsuba and PBRT.
% this could happen on "machine B", after copying over the custom folder

% choose where to look for scenes from machineA
hints = GetDefaultHints();
hints.outputSubfolder = mfilename();
portableFolder = fullfile(GetOutputPath('tempFolder', hints), 'portable-scenes');

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;
for renderer = {'Mitsuba', 'PBRT'}
    % choose one renderer
    hints.renderer = renderer{1};
    
    % unpack scene descriptions from the mat file
    sceneFolder = fullfile(portableFolder, hints.renderer);
    scenePack = fullfile(sceneFolder, 'sceneDescriptions.mat');
    scenePackData = load(scenePack);
    
    % render from the custom scene folder so renderers can find scene files
    cd(sceneFolder);
    radianceDataFiles = BatchRender(scenePackData.scenes, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('MaterialSpherePortable (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
