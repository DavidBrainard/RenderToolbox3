clear
clc

% make a new recipe!
configScript = 'BadConfigScript';
executiveScript = 'MakeDragonColorChecker.m';
parentScene = 'Dragon.dae';
conditionsFile = 'DragonColorCheckerConditions.txt';
mappingsFile = 'DragonColorCheckerMappings.txt';
hints.renderer = 'Mitsuba';
recipe = NewRecipe(configScript, executiveScript, parentScene, ...
    conditionsFile, mappingsFile, hints);

% configure for the recipe
recipe = ConfigureForRecipe(recipe);
recipe
recipe.hints
rethrow(recipe.errorData{1})