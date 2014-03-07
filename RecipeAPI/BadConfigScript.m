% this script should modify the current recipe and throw an error.

run('RenderToolbox3ConfigurationTemplate');

recipe = CurrentRecipe();
recipe.input.hints.renderer = 'BadRenderer';
CurrentRecipe(recipe);

error('silly:id', 'This is a silly error');
