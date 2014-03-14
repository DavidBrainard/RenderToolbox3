
clear
clc

%% Build a recipe for the coordinates test scene.
configScript = 'RenderToolbox3ConfigurationTemplate';
executive = @RenderRecipe;
parentScene = 'CoordinatesTest.dae';
conditionsFile = '';
mappingsFile = '';
hints.renderer = 'Mitsuba';

recipe = NewRecipe(configScript, executive, parentScene, ...
    conditionsFile, mappingsFile, hints);

recipe = AppendRecipeLog(recipe, 'Testing a new recipe');

%% Configure for the recipe and execute it.

% may want one wrapper executable that does all these steps
recipe = ConfigureForRecipe(recipe);
recipe = MakeRecipeSceneFiles(recipe);
recipe = MakeRecipeRenderings(recipe);
recipe = MakeRecipeMontage(recipe);

PrintRecipeLog(recipe, true);
WriteRecipeLog(recipe, 'recipe.log');
