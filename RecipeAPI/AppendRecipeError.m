%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Add an error to recipe error data.
%   @param recipe a recipe struct
%   @param errorData a Matlab exception or other error data
%
% @details
% Appends the given @a errorData to the list of errors in the given @a
% recipe.errorData.
%
% @details
% Returns the given @a recipe, with the given @a error appended.
%
% @details
% Usage:
%   recipe = AppendRecipeError(recipe, errorData)
%
% @ingroup RecipeAPI
function recipe = AppendRecipeError(recipe, errorData)

if IsStructFieldPresent(recipe, 'errorData')
    recipe.errorData{end+1} = errorData;
else
    recipe.errorData = {errorData};
end