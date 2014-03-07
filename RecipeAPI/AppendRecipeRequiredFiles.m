%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Add files to the list of dependencies for a recipe.
%   @param recipe a recipe struct
%   @param requiredFiles cell array of files that @a recipe depends on
%
% @details
% Appends the given @a requiredFiles, to the given @a recipe's list of
% dependencies.  Dependencies include files like texture images and
% spectrum descriptions.  These are often referenced indirectly from input
% files like the conditions and mappings files.
%
% @details
% Returns the given @a recipe, with files appended to @a
% recipe.requiredFiles.all.
%
% @details
% Usage:
%   recipe = AppendRecipeRequiredFiles(recipe, requiredFiles)
%
% @ingroup RecipeAPI
function recipe = AppendRecipeRequiredFiles(recipe, requiredFiles)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    requiredFiles = {};
end

%% Append entry to the recipe log.
if IsStructFieldPresent(recipe, 'requiredFiles')
    recipe.requiredFiles.all = cat(recipe.requiredFiles, requiredFiles);
else
    recipe.requiredFiles.all = requiredFiles;
end
