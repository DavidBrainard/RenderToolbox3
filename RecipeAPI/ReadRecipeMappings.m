%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Parse mappings from file and save in recipe struct
%   @param recipe a recipe struct
%
% @details
% Reads RenderToolbox3 mappings from @a recipe.mappingsFile and saves
% the results in @a recipe.mappings.
%
% @details
% Returns the given @a recipe, with parsed mappings.
%
% @details
% Usage:
%   recipe = ReadRecipeMappings(recipe)
%
% @ingroup RecipeAPI
function recipe = ReadRecipeMappings(recipe)

recipe.mappings = [];
if IsStructFieldPresent(recipe, 'mappingsFile')
    recipe.mappings = ParseMappings(recipe.mappingsFile);
end
