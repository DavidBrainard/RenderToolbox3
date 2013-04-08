%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read numbers from a string, with optional grouping.
%   @param string a string to scan for numbers
%   @param nGrouping how many numbers to include in each group (optional)
%
% @details
% Reads decimal number representations from the given string.  Returns
% numbers as separate elements of a cell array of strings.
%
% By default, each element of the cell array of strings will contain one
% number.  If @a nGrouping is provided, each element will contain @a
% nGrouping numbers.
%
% Also returns the total count of numbers found in in the given @a string.
%
% @details
% Usage:
%   [numbers, nNums] = ReadStringNumbers(string, nGrouping)
%
% @ingroup Utilities
function [numbers, nNums] = ReadStringNumbers(string, nGrouping)

if nargin < 2
    nGrouping = 1;
end

% convert to double array
valueNum = StringToVector(string);
nNums = numel(valueNum);

% convert back to individual or grouped strings
nValues = floor(nNums/nGrouping);
numbers = cell(1, nValues);
for ii = 1:nValues
    numIndices = (1:nGrouping) + (ii-1)*nGrouping;
    numbers{ii} = VectorToString(valueNum(numIndices));
end
