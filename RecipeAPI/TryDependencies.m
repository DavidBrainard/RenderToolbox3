
clear
clc

%% Build a recipe for the coordinates test scene.
configScript = 'RenderToolbox3ConfigurationTemplate';
executive = @RenderRecipe;
parentScene = 'Dragon.dae';
conditionsFile = 'DragonColorCheckerConditions.txt';
mappingsFile = 'DragonColorCheckerMappings.txt';
hints.renderer = 'Mitsuba';
hints.outputSubfolder = 'dependenciesTest';

recipe = NewRecipe(configScript, executive, parentScene, ...
    conditionsFile, mappingsFile, hints);

recipe = AppendRecipeLog(recipe, 'Testing a new recipe');

%% Locate recipe dependencies.
extraFiles = {which(configScript), which(parentScene), ...
    which(conditionsFile), which(mappingsFile)};
dependencies = FindDependentFiles( ...
    recipe.input.parentSceneFile, ...
    recipe.input.conditionsFile, ...
    recipe.input.mappingsFile, ...
    extraFiles, ...
    hints);

%% Copy recipe and dependencies to a resources subfolder.
resourcesFolder = GetOutputPath('resourcesFolder', hints);
if ~exist(resourcesFolder, 'dir')
    mkdir(resourcesFolder);
end

for ii = 1:numel(dependencies)
    copyfile(dependencies(ii).fullLocalPath, resourcesFolder);
end

% RecipeAPI function should automatically include configScript,
% parentScene, conditionsFile, and mappingsFile as extra dependency files.
% It should resolve their full local paths with which?
%
% It should also check each element of executive, and include it if it is
% not the name of a RenderToolbox3 build-in function (i.e.
% RenderToolboxRoot() is not a prefix of its path).
%
% It should also store a mapping of local file names (i.e. names in the zip
% archive or resources folder) and the paths where they might want to be
% copied (i.e. "unportabled" path, if any).
%
% Actually, we night never want to unportable the files.  It might be best
% to leave them in the resources folder.  Simpler that way.