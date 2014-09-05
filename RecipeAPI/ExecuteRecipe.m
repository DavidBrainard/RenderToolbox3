%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Execute the given recipe and make long entries.
%   @param recipe a recipe struct to be cleaned
%   @param whichExecutives indices to select specific scripts or functions
%   @param throwException whether to re-throw a Matlab MException
%
% @details
% First calls ConfigureForRecipe(), then executes each of the scripts or
% functions in the given recipe.input.executive, and makes a log entry for
% each.  If a corresponding log entry already exists, skips that script or
% funciton and moves on to the next.
%
% @details
% To make sure that no executive scripts or functions are skipped, first
% call CleanRecipe().
%
% @details
% By default, tries to execute all of the scripts and functions in
% recipe.input.executive.  If @a whichExecutives is provided, it must be an
% array of indices used to select specific scripts or functions.  All and
% onlythese elements of recipe.input.executive will be executed, regardless
% of whether corresponding log entries exist.
%
% @details
% If any executive script or recipe throws an error, logs the error and
% stops executing.  If @a throwException is true (the default), and the
% error is a Matlab MException, rethrows the exception to produce a stack
% trace in the command window.
%
% @details
% Returns the given @a recipe, with @a recipe.log filled in.
%
% @details
% Usage:
%   recipe = ExecuteRecipe(recipe, whichExecutives, throwException)
%
% @ingroup RecipeAPI
function recipe = ExecuteRecipe(recipe, whichExecutives, throwException)

if nargin < 2 || isempty(whichExecutives)
    skipAlreadyLogged = true;
    whichExecutives = 1:numel(recipe.input.executive);
else
    skipAlreadyLogged = false;
end

if nargin < 3 || isempty(throwException)
    throwException = true;
end

recipe = ConfigureForRecipe(recipe);

for ii = whichExecutives
    errorData = [];
    
    try
        executive = recipe.input.executive{ii};
        
        if skipAlreadyLogged
            alreadyExecuted = [recipe.log.executiveIndex];
            if any(ii == alreadyExecuted)
                continue;
            end
        end
        
        if isa(executive, 'function_handle')
            recipe = feval(executive, recipe);
        elseif ischar(executive)
            CurrentRecipe(recipe);
            run(executive);
            recipe = CurrentRecipe();
        end
        
    catch errorData
        % fills in placeholder above, log it below
    end
    
    % put this execution in the log with any error data
    recipe = AppendRecipeLog(recipe, ...
        ['run automatically by ' mfilename()], ...
        executive, errorData, ii);
    
    errorData = GetFirstRecipeError(recipe, throwException);
    if ~isempty(errorData)
        break;
    end
end
