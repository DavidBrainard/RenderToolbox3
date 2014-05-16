%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render MaterialSphere in a portable fashion using the Recipe API.

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
hints.renderer = 'Mitsuba';

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

% note that above, only scene files were generated
% but no rendering was done

%% Un-pack and render in a new location -- could be on another computer.

% note that below, no scene files are generated
% but the pre-generated scene files are rendered

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

% render the pre-generated scene files
recipe = ExecuteRecipe(recipe);
