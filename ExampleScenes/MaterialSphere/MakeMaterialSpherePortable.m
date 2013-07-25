%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the MaterialSphere scene in a portable fashion.

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
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
hints.isAbsoluteResourcePaths = false;

% put output files in a subfolder named like this script
hints.outputSubfolder = mfilename();

%% Create scene files for Mistuba and PBRT.
%   this could happen on "machine A"
portableFolder = fullfile(GetOutputPath('tempFolder'), 'portable-scenes');
for renderer = {'Mitsuba', 'PBRT'}
    % choose one renderer
    hints.renderer = renderer{1};
    
    % save scene files and auxiliary files in a custom folder
    outFolder = fullfile(portableFolder, hints.renderer);
    MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints, outFolder);
end

%% Render with Mitsuba and PBRT.
% this could happen on "machine B", after copying over the custom folder

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;
originalFolder = pwd();
portableFolder = fullfile(GetOutputPath('tempFolder'), 'portable-scenes');
for renderer = {'Mitsuba', 'PBRT'}
    % choose one renderer
    hints.renderer = renderer{1};
    
    % locate scene ".xml" files in the custom folder
    sceneFolder = fullfile(portableFolder, hints.renderer);
    nativeSceneFiles = FindFiles(sceneFolder, '\.xml');
    
    % render from the custom folder so renderers can find auxiliary files
    cd(sceneFolder);    
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('MaterialSpherePortable (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end

cd(originalFolder);
