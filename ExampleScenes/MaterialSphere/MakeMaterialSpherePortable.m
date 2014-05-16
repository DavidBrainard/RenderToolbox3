%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render MaterialSphere in a portable fashion using the Recipe API.c
clear

%% Choose inputs for a new recipe.
% replace this config script with your own config script
configScript = 'RenderToolbox3ConfigurationTemplate';

% choose the 3D model and parameteric variations
parentSceneFile = 'MaterialSphere.dae';
conditionsFile = 'MaterialSphereConditions.txt';
mappingsFile = 'MaterialSphereBumpsMappings.txt';

% choose the order of operations for rendering the recipe
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @MakeRecipeMontage, ...
    };

%% Choose RenderToolbox3 options.
% which materials to use, [] means all
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 200;
hints.imageHeight = 160;

% put output files in a subfolder named like this script
hints.outputSubfolder = mfilename();

% resources like textures files should be located in the working folder
hints.workingFolder = GetOutputPath('tempFolder', hints);

% choose the renderer
hints.renderer = 'PBRT';

%% Make a new recipe that contains all of the above choices.
recipe = NewRecipe(configScript, executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

% add a log message to the recipe
recipe = AppendRecipeLog(recipe, 'Portable recipe for Material Sphere');

%% Generate sceen files and pack up the recipe.
% generate all the scene files for the recipe
recipe = ExecuteRecipe(recipe, 1);

% pack up the recipe with its pre-generated scene files
fullZipFileName = fullfile(GetUserFolder(), 'MaterialSpherePortable.zip');
[recipe, fullZipFileName] = PackUpRecipe(recipe, fullZipFileName);

% boldly delete generated scene files from the temp folder
% since they're already packed up with the recipe
sceneFileFolder = ...
    fullfile(GetOutputPath('tempFolder', hints), hints.renderer);
rmdir(sceneFileFolder, 's');

%% Note: above, scene files were generated but no rendering was done.

%% Note: below, only pre-generated scene files are rendererd.

%% Un-pack and render in a new location -- could be on another computer.
% locate the packed-up recipe
% change this fullZipFileName if you moved to another computer
fullZipFileName = fullfile(GetUserFolder(), 'MaterialSpherePortable.zip');

% choose a folder to un-pack the recipe into
% this could also be on another computer
newFolder = fullfile(GetUserFolder(), 'AnotherComputer');
hints.workingFolder = fullfile(newFolder, 'unpack-recipe');

% choose new RenderToolbox3 output folders
% this might be unnecessary if you moved to another computer
hints.tempFolder = fullfile(newFolder, 'temp');
hints.outputDataFolder = fullfile(newFolder, 'data');
hints.outputImageFolder = fullfile(newFolder, 'images');
hints.resourcesFolder = fullfile(newFolder, 'resources');

% un-pack the recipe into the new folder
recipe = UnpackRecipe(fullZipFileName, true, hints);

% choose a configuration script for this machine
% change this configureScript if you moved to a new machine.
configureScript = 'RenderToolbox3ConfigurationTemplate';
recipe.input.configureScript = configureScript;

% render the pre-generated scene files
recipe = ExecuteRecipe(recipe);
