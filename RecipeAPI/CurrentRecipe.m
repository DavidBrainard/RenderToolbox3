%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get or set the RenderToolbox3 "current recipe"
%   @param recipe a recipe struct to become current
%
% @details
% CurrentRecipe() controls acceses to a Matlab persistent variable that
% holds the RenderToolbox3 "current recipe".  There can be only one current
% recipe at a time.  The current recipe is a central point of contact
% allowing various scripts that make up a recipe to interact.
%
% @details
% If @a recipe is provided, replaces the current recipe with the given @a
% recipe.
%
% @details
% Returns the current recipe, which is equal to the given @a recipe, if it
% was privided.
%
% @details
% Usage:
%   recipe = CurrentRecipe(recipe)
%
% @ingroup RecipeAPI
function recipe = CurrentRecipe(recipe)

persistent CURRENT_RECIPE

if nargin > 0
    CURRENT_RECIPE = recipe;
end
recipe = CURRENT_RECIPE;