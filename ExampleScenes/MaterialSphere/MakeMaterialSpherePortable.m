%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render MaterialSphere in a portable fashion using the Recipe API
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
hints.recipeName = 'MakeMaterialSpherePortable';
ChangeToWorkingFolder(hints);

% choose the renderer
hints.renderer = 'PBRT';

%% Make a new recipe that contains all of the above choices.
recipe = NewRecipe(configScript, executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

% add a log message about creating this new recipe
recipe = AppendRecipeLog(recipe, 'Portable recipe for Material Sphere');

%% Generate scene files and pack up the recipe.
% generate all the scene files for the recipe
recipe = ExecuteRecipe(recipe, 1);

% pack up the recipe with its pre-generated scene files
%   don't pack up boring temp files
archiveName = fullfile(GetUserFolder(), 'MaterialSpherePortable.zip');
PackUpRecipe(recipe, archiveName, {'temp'});

% boldly delete the recipe working folder now that it's packed up
scenesFolder = GetWorkingFolder('', false, hints);
rmdir(scenesFolder, 's');


%% Un-pack and render in a new location -- could be on another computer.
% locate the packed-up recipe
% change this archiveName if you moved to another computer
archiveName = fullfile(GetUserFolder(), 'MaterialSpherePortable.zip');

% choose a folder to un-pack the recipe into
% this could also be on another computer
newFolder = fullfile(GetUserFolder(), 'AnotherComputer');
hints.workingFolder = newFolder;

% un-pack the recipe into the new folder
recipe = UnpackRecipe(archiveName, hints);

% change the recipe's configureScript if you moved to a new machine.
configureScript = 'RenderToolbox3ConfigurationTemplate';
recipe.input.configureScript = configureScript;

% render the recipe from pre-generated scene files
recipe = ExecuteRecipe(recipe);
