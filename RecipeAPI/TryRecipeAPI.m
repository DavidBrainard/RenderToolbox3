
clear
clc

% Build a recipe for the coordinates test scene.
configScript = 'RenderToolbox3ConfigurationTemplate';
executive = @RenderRecipe;
parentScene = 'CoordinatesTest.dae';
conditionsFile = '';
mappingsFile = '';
hints.renderer = 'Mitsuba';

recipe = NewRecipe(configScript, executive, parentScene, ...
    conditionsFile, mappingsFile, hints);

recipe = AppendRecipeLog(recipe, 'Testing a new recipe');

%% configure for the recipe
recipe = ConfigureForRecipe(recipe);
recipe = MakeRecipeSceneFiles(recipe);
recipe = MakeRecipeRenderings(recipe);
recipe = MakeRecipeMontage(recipe);

PrintRecipeLog(recipe, true);
WriteRecipeLog(recipe, 'recipe.log');
