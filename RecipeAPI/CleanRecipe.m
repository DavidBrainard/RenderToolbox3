%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Clear out recipe derived data fileds.
%   @param recipe a recipe struct to be cleaned
%
% @details
% Clear all recipe derived data fields and reset some fields including
% conditions and mappings.
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
recipe.conditions = [];
recipe.mappings = [];
recipe.nativeScenes = {};
recipe.renderings = {};
recipe.images = {};
recipe.montages = {};
recipe.errorData = {};

% Reset some fields to like-new
if IsStructFieldPresent(recipe, 'conditionsFile')
    [recipe.conditions.names, recipe.conditions.values] = ...
        ParseConditions(recipe.conditionsFile);
end

if IsStructFieldPresent(recipe, 'mappingsFile')
    recipe.mappings = ParseMappings(recipe.mappingsFile);
end