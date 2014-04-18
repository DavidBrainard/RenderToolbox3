%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Start a new recipe from scratch.
%   @param configureScript name of a system configuration script
%   @param executive script/function names/handles to execute
%   @param parentSceneFile name of a Collada scene file
%   @param conditionsFile name of a RenderToolbox3 conditions file
%   @param mappingsFile name of a RenderToolbox3 mappings file
%   @param hints struct of hints as from GetDefaultHints()
%
% @details
% Create a brand new RenderToolbox3 recipe struct with the given fields
% filled in and some derived fields filed in, like conditions and mappings.
% All arguments are optional.
%
% @details
% @a configureScript should be the name of a RenderToolbox3 system
% configuration script, such as a locally modified copy of
% RenderToolbox3ConfigurationTemplate.
%
% @details
% @a executive should be a cell array of function_handles or string script
% names to be executed in order to carry out the recipe.  All
% function_handles must refer to functions that expect a recipe as the
% first argument return the recipe as the first output.  All strings must
% refer to m-files that use CurrentRecipe() to access and modify the
% current recipe.
%
% @details
% @a parentSceneFile should be the name name of a Collada parent scene
% file, for example Dragon.dae.
%
% @details
% @a conditionsFile should be the name of a RenderToolbox3 conditions
% file, for example DragonColorCheckerConditions.txt.
%
% @details
% @a mappingsFile should be the name of a RenderToolbox3 mappings file, for
% example DragonColorCheckerMappings.txt.
%
% @details
% @a hints should be a struct of hints as from GetDefaultHints(), or a
% partial struct with some fields filed in, to be merged with a full hints
% struct.
%
% @details
% Returns a new recipe struct which should be ready for rendering.
%
% @details
% Usage:
%   recipe = NewRecipe(configureScript, executive, ...
%    parentSceneFile, conditionsFile, mappingsFile, hints)
%
% @ingroup RecipeAPI
function recipe = NewRecipe(configureScript, executive, ...
    parentSceneFile, conditionsFile, mappingsFile, hints)

%% Default arguments.
if nargin < 1
    configureScript = '';
end

if nargin < 2
    executive = {};
end
if ~iscell(executive)
    executive = {executive};
end

if nargin < 3
    parentSceneFile = '';
end

if nargin < 4
    conditionsFile = '';
end

if nargin < 5
    mappingsFile = '';
end

if nargin < 6
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Brand new recipe struct with basic fields filled in.
% note: struct() needs executive cell array to be wrapped in another cell
basic = struct( ...
    'configureScript', configureScript, ...
    'executive', {executive}, ...
    'parentSceneFile', parentSceneFile, ...
    'conditionsFile', conditionsFile, ...
    'mappingsFile', mappingsFile, ...
    'hints', hints);
recipe.input = basic;

%% Derive conditions and mappings from respective files.
recipe = ReadRecipeConditions(recipe);
recipe = ReadRecipeMappings(recipe);

%% "CleanRecipe" is the origin of all other derived field names.
recipe = CleanRecipe(recipe);
