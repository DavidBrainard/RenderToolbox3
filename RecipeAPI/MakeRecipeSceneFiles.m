%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Generate native scene files for the given recipe.
%   @param recipe a recipe struct
%
% @details
% Uses the given @a recipe's parent scene file, conditions file, and
% mappings file to generate renderer-native scene files for the renderer
% specified in @a recipe.input.hints.renderer.
%
% @details
% Returns the given @a recipe, with @a recipe.rendering.scenes filled in.
%
% @details
% Usage:
%   recipe = MakeRecipeSceneFiles(recipe)
%
% @ingroup RecipeAPI
function recipe = MakeRecipeSceneFiles(recipe)

recipe = ChangeToRecipeFolder(recipe);

recipe.rendering.scenes = {};
errorData = [];
try
    recipe.rendering.scenes = ...
        MakeSceneFiles(...
        recipe.input.parentSceneFile, ...
        recipe.input.conditionsFile, ...
        recipe.input.mappingsFile, ...
        recipe.input.hints);
    
catch errorData
    % fills in placeholder above, log it below
end

% put this execution in the log with any error data
recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @MakeSceneFiles, errorData, 0);
