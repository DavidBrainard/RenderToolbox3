%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Add an entry to the recipe's execution log.
%   @param recipe a recipe struct
%   @param executed a script/function name/handle that was executed
%   @param errorData a Matlab exception or other error data, if any
%   @param comment index optional comment to include with the log
%   @param executiveIndex index of @a executed in @a recipe.executive
%
% @details
% Appends the given @a executed, @a errorData, and @a executiveIndex to the
% execution log of the given @a recipe.  Also appends the current date and
% time, current user name, and current computer's host name.
%
% @details
% @a executed should be the name of a script or function, or a
% function_handle that was executed on the given @a recipe.  This is the
% thing that happened that should be logged.
%
% @details
% @a errorData should be a Matlab exception that was caught, or any other
% error data that resulted from @a executed.  @a errorData should only be
% empty of no error occured.
%
% @details
% Users may supply an optional string @a comment to include with other
% logged data.
%
% @details
% If @a executed is one of the scripts or functions listed in @a
% recipe.executive, then @a executiveIndex should be the index of @a
% executed within @a recipe.executive.  RenderToolbox3 functions will
% always supply @a executiveIndex in order to track the progress of a
% recipe's execution.  Users may omit @a executiveIndex.
%
% @details
% Returns the given @a recipe, with the given logging information appended.
%
% @details
% Usage:
%   recipe = AppendRecipeLog(recipe, executed, errorData, comment, executiveIndex)
%
% @ingroup RecipeAPI
function recipe = AppendRecipeLog(recipe, executed, errorData, comment, executiveIndex)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    executed = [];
end

if nargin < 3
    errorData = [];
end

if nargin < 4
    comment = '';
end

if nargin < 5
    executiveIndex = [];
end


%% Build the new log entry.
logData.executed = executed;
logData.when = datestr(now());
logData.errorData = errorData;
logData.userName = char(java.lang.System.getProperty('user.name'));
logData.hostName = char(java.net.InetAddress.getLocalHost.getHostName);
logData.comment = comment;
logData.executiveIndex = executiveIndex;


%% Append entry to the recipe log.
if IsStructFieldPresent(recipe, 'logData')
    recipe.logData(end+1) = logData;
else
    recipe.logData = logData;
end
