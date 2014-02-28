clear
clc

% make a new recipe!
configScript = 'BadConfigScript';
executive = 'MakeDragonColorChecker.m';
parentScene = 'Dragon.dae';
conditionsFile = 'DragonColorCheckerConditions.txt';
mappingsFile = 'DragonColorCheckerMappings.txt';
hints.renderer = 'Mitsuba';
recipe = NewRecipe(configScript, executive, parentScene, ...
    conditionsFile, mappingsFile, hints);

recipe = AppendRecipeLog(recipe, [], [], 'I made a new recipe.');

% configure for the recipe
recipe = ConfigureForRecipe(recipe);
recipe
recipe.hints

PrintRecipeLog(recipe, false);
WriteRecipeLog(recipe, 'recipe.log')