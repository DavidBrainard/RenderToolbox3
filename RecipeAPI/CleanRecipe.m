%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Clear out recipe derived data fileds.
%   @param recipe a recipe struct to be cleaned
%
% @details
% Clear recipe derived data fields.
%
% @details
% Returns the given @a recipe, cleared out and reset to a like-new state.
%
% @details
% Usage:
%   recipe = CleanRecipe(recipe)
%
% @ingroup RecipeAPI
function recipe = CleanRecipe(recipe)

% Clear all derived data fields
recipe.rendering = [];
recipe.processing = [];
recipe.log = [];