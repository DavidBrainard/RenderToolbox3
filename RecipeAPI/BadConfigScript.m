% this script should modify the current recipe and throw an error.

run('RenderToolbox3ConfigurationTemplate');

recipe = CurrentRecipe();
recipe.hints.renderer = 'BadRenderer';
CurrentRecipe(recipe);

error('This is a silly error');
