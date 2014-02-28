%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Print a recipe's log as formatted text.
%   @param recipe a recipe struct
%   @param verbose true for full detail, false for simple summary
%
% @details
% Prints the log data for the given @recipe as nicely formatted text.  if
% @a verbose is provided and true, prints lots of details and stack traces
% for logged exceptions.  Otherwise, prints a compact summary.
%
% @details
% Prints the log data to the Command Window and also returns the same
% formatted text as a string.
%
% @details
% Usage:
%   summary = PrintRecipeLog(recipe, verbose)
%
% @ingroup RecipeAPI
function summary = PrintRecipeLog(recipe, verbose)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    verbose = false;
end

%% Print a paragraph for each log entry.
summary = '';
for ii = 1:numel(recipe.logData)
    log = recipe.logData(ii);
    
    % what was executed
    exec = getString(log.executed, 'nothing', 'unknown');
    index = getString(log.executiveIndex, 'none', 'unknown');
    line = ['executed: ' exec ' (index: ' index ')'];
    summary = appendLogLine(summary, line);
    
    % when it was executed
    when = getString(log.when, 'never', 'unknown');
    line = ['at: ' when];
    summary = appendLogLine(summary, line);
    
    if verbose
        % who executed it
        user = getString(log.userName, 'nobody', 'unknown');
        host = getString(log.hostName, 'none', 'unknown');
        line = ['by user: ' user ', on host: ' host];
        summary = appendLogLine(summary, line);
    end
    
    % arbitrary comment
    comment = getString(log.comment, 'none', 'unknown');
    line = ['comment: ' comment];
    summary = appendLogLine(summary, line);
    
    % error info
    err = getString(log.errorData, 'none', 'unknown');
    line = ['with error: ' err];
    summary = appendLogLine(summary, line);
    
    if verbose && isa(log.errorData, 'MException')
        trace = log.errorData.getReport();
        line = 'stack trace:';
        summary = appendLogLine(summary, line);
        summary = appendLogLine(summary, trace);
    end
    
    summary = appendLogLine(summary, '');
end

disp(summary)


function summary = appendLogLine(summary, line)
summary = sprintf('%s\n%s', summary, line);


function string = getString(value, emptyName, unknownName)
if isempty(value)
    string = emptyName;
elseif isnumeric(value)
    string = num2str(value);
elseif isa(value, 'function_handle')
    string = func2str(value);
elseif ischar(value)
    string = value;
elseif isa(value, 'MException')
    string = [value.identifier ', ' value.message];
else
    string = unknownName;
end
