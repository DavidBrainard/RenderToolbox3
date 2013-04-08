%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Write conditions data to a text file.
%   @param conditionsFile name of new text file to write.
%   @param names 1 x n cell array of string variable names
%   @param values m x n cell array of variable values
%
% @details
% Writes batch renderer condition variables with the given @a names and @a
% values to a new text file with the given @a conditionsFile name.  See the
% RenderToolbox3 wiki for more about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Conditions-File-Format">Conditions
% Files</a>.
%
% @details
% @a names will appear in the first line of the new file, separated by
% tabs.  Each of the m rows of @a values will appear in a separate line,
% with elements separated by tabs.  So, the values for each variable will
% appear in a tab-separated column.
%
% @details
% Attempts to convert numeric values to string, as needed.
%
% @details
% Usage:
%   conditionsFile = WriteConditionsFile(conditionsFile, names, values)
%
% @ingroup BatchRender
function conditionsFile = WriteConditionsFile(conditionsFile, names, values)

if nargin < 1 || isempty(conditionsFile)
    conditionsFile = 'conditionsFile.txt';
end

if nargin < 2 || isempty(names)
    names = {};
end

if nargin < 3 || isempty(values)
    values = {};
end

if isempty(names)
    warning('No variable names given!');
    return;
end

%% Create a new file.
fid = fopen(conditionsFile, 'w');
if -1 == fid
    warning('Cannot create conditions file "%s".', conditionsFile);
    return;
end

%% Write variable names.
nNames = numel(names);
for ii = 1:nNames
    fprintf(fid, '%s\t', names{ii});
end
fprintf(fid, '\n');

%% Write variable values.
nCols = size(values, 2);
if nCols ~= nNames;
    warning('Number of variable names %d must match number of variable columns %d', ...
        nNames, nCols);
end

nConditions = size(values, 1);
for jj = 1:nConditions
    for ii = 1:nCols
        fprintf(fid, '%s\t', VectorToString(values{jj,ii}));
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n');

fclose(fid);