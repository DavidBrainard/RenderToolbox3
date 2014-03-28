%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make renderings from a recipe's native scene files.
%   @param recipe a recipe struct
%
% @details
% Uses the given @a recipe's renderer native scene descriptions to produce
% renderings, using the given @a recipe.input.hints.renderer.
%
% @details
% Returns the given @a recipe, with @a recipe.rendering.radianceDataFiles
% filled in.
%
% @details
% Usage:
%   recipe = MakeRecipeRenderings(recipe)
%
% @ingroup RecipeAPI
function recipe = MakeRecipeRenderings(recipe)

recipe = ChangeToRecipeFolder(recipe);

recipe.rendering.radianceDataFiles = {};
errorData = [];
try
    recipe.rendering.radianceDataFiles = BatchRender( ...
        recipe.rendering.scenes, recipe.input.hints);
    
catch errorData
    % fills in placeholder above, log it below
end

% put this execution in the log with any error data
recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @BatchRender, errorData, 0);
