%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render MaterialSphere in a portable fashion using the Recipe API.

%% Top Half.
clear;

%% Choose inputs for a new recipe.

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

% use a temporary working folder, which will be deleted below
workingPortable = fullfile(GetWorkingFolder(), 'portable');
hints.workingFolder = workingPortable;

% put output files in a subfolder named like this script
hints.recipeName = 'MakeMaterialSpherePortable';

% choose the renderer
hints.renderer = 'PBRT';


%% Make a new recipe that contains all of the above choices.
recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

% add a log message about creating this new recipe
recipe = AppendRecipeLog(recipe, 'Portable recipe for Material Sphere');

%% Move resource files inside the workingFolder, so they can be detected.
resourceFiles = { ...
    fullfile(RenderToolboxRoot(), 'RenderData/Macbeth-ColorChecker/mccBabel-11.spd'), ...
    fullfile(RenderToolboxRoot(), 'RenderData/Macbeth-ColorChecker/mccBabel-7.spd'), ...
    fullfile(RenderToolboxRoot(), 'RenderData/PBRTMetals/Au.eta.spd'), ...
    fullfile(RenderToolboxRoot(), 'RenderData/PBRTMetals/Au.k.spd'), ...
    fullfile(RenderToolboxRoot(), 'ExampleScenes/CubanSphere/earthbump1k-stretch-rgb.exr')};

resources = GetWorkingFolder('resources', false, hints);
for ii = 1:numel(resourceFiles)
    copyfile(resourceFiles{ii}, resources);
end

%% Generate scene files and pack up the recipe.
% generate all the scene files for the recipe
recipe = ExecuteRecipe(recipe, 1);

% pack up the recipe with resources and pre-generated scene files
%   don't pack up boring temp files
archiveName = fullfile(GetWorkingFolder(), 'MaterialSpherePortable.zip');
PackUpRecipe(recipe, archiveName, {'temp'});

% boldly delete the working folder, now that the recie is packed up
rmdir(workingPortable, 's');

%% Bottom Half.
clear;

%% Un-pack and render in a new location -- could be on another computer.
% locate the packed-up recipe
% change this archiveName if you moved to another computer
archiveName = fullfile(GetWorkingFolder(), 'MaterialSpherePortable.zip');

% un-pack the recipe into the new folder
hints = GetDefaultHints();
recipe = UnpackRecipe(archiveName, hints);

% render the recipe from pre-generated scene files
recipe = ExecuteRecipe(recipe);
