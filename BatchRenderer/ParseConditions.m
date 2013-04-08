%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read conditions data from a text file.
%   @param conditionsFile
%
% @details
% Reads batch renderer condition variables from the given @a
% conditionsFile.  See the RenderToolbox3 wiki for more about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Conditions-File-Format">Conditions
% Files</a>.
%
% @details
% Returns a 1 x n cell array of string variable names from the first line
% of @a conditionsFile.  Also returns an m x n cell array
% of varible values, with m values per variable.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   [names, values] = ParseConditions(conditionsFile)
%
% @ingroup BatchRender
function [names, values] = ParseConditions(conditionsFile)

%% Prepare to read conditions file.
if ~exist(conditionsFile, 'file')
    names = {};
    values = {};
    return;
end

fid = fopen(conditionsFile, 'r');
if -1 == fid
    names = {};
    values = {};
    warning('Cannot open conditions file "%s".', conditionsFile);
    return;
end

columnPattern = '([\S ]+)[\t,]*';
commentPattern = '^\s*\%';

%% Read variable names from the first line.
nextLine = fgetl(fid);
nameTokens = regexp(nextLine, columnPattern, 'tokens');
nNames = numel(nameTokens);
names = cell(1, nNames);
% dig out individual names
for ii = 1:nNames
    names(ii) = nameTokens{ii}(1);
end

%% Read values from subsequent lines.
nValues = 0;
values = cell(nValues,nNames);
nextLine = fgetl(fid);
while ischar(nextLine)
    % skip comment lines
    if isempty(regexp(nextLine, commentPattern, 'once'))
        valueTokens = regexp(nextLine, columnPattern, 'tokens');
        if numel(valueTokens) == nNames
            nValues = nValues + 1;
            % dig out individual names
            for ii = 1:nNames
                values(nValues,ii) = valueTokens{ii}(1);
            end
        end
    end
    nextLine = fgetl(fid);
end

%% Done with file
fclose(fid);