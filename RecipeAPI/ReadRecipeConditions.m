%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Parse conditions from file and save in recipe struct
%   @param recipe a recipe struct
%
% @details
% Reads RenderToolbox3 conditions from @a recipe.conditionsFile and saves
% the results in @a recipe.conditions.
%
% @details
% Returns the given @a recipe, with parsed conditions.
%
% @details
% Usage:
%   recipe = ReadRecipeConditions(recipe)
%
% @ingroup RecipeAPI
function recipe = ReadRecipeConditions(recipe)

recipe.conditions = [];
if IsStructFieldPresent(recipe, 'conditionsFile')
    [recipe.conditions.names, recipe.conditions.values] = ...
        ParseConditions(recipe.conditionsFile);
end
