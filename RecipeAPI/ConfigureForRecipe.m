%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Configure RenderToolbox3 to run the given recipe.
%   @param recipe a recipe struct
%
% @details
% Attempts to configure RenderToolbox3 for rendering the given @a recipe
% using @a recipe.input.configureScript.
%
% @details
% Sets the "current recipe" so that @a recipe.input.configureScript may
% access and modify the given @a recipe using CurrentRecipe();
%
% @details
% Returns the given @a recipe, possibly updated by @a
% recipe.input.configureScript, possibly with a new error appended.
%
% @details
% Usage:
%   recipe = ConfigureForRecipe(recipe)
%
% @ingroup RecipeAPI
function recipe = ConfigureForRecipe(recipe)

recipe = ChangeToRecipeFolder(recipe);

errorData = [];
try
    % set the current recipe so that configureScript can access it
    CurrentRecipe(recipe);
    run(recipe.input.configureScript);
    
catch errorData
    % fills in placeholder above, log it below
end

% get the current recipe in case configureScript modified it
recipe = CurrentRecipe();

% put this execution in the log with any error data
recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    recipe.input.configureScript, errorData, 0);
