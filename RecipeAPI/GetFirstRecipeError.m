%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get the first logged recipe error, if any.
%   @param recipe a recipe struct to be cleaned
%   @param throwException whether to re-throw a Matlab MException
%
% @details
% Searches the given @a recipe.log for errors and returns the first one
% found, if any.  If @a throwException is true (the default), and the first
% error is a Matlab MException, rethrows the exception (which gives a handy
% stack trace in the command window).
%
% @details
% Returns the first error found in the given @a recipe.log, if any.
%
% @details
% Usage:
%   errorData = GetFirstRecipeError(recipe)
%
% @ingroup RecipeAPI
function errorData = GetFirstRecipeError(recipe, throwException)

if nargin < 2 || isempty(throwException)
    throwException = true;
end

errorData = [];

if IsStructFieldPresent(recipe, 'log')
    for ii = 1:numel(recipe.log)
        errorData = recipe.log(ii).errorData;
        if ~isempty(errorData)
            break;
        end 
    end
end

if throwException && isa(errorData, 'MException')
    rethrow(errorData)
end
