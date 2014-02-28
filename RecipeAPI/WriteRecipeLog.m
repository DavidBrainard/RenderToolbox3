%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Write a recipe's log as formatted text to a text file.
%   @param recipe a recipe struct
%   @param fileName name of the file to write
%
% @details
% Writes verbose log data from the given @a recipe to a text file at the
% given @a fileName.
%
% @details
% Usage:
%   PrintRecipeLog(recipe, fileName)
%
% @ingroup RecipeAPI
function WriteRecipeLog(recipe, fileName)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2 || isempty(fileName)
    error('You must suplpy a file name to write to');
end

%% Get the verbose log summary.
summary = PrintRecipeLog(recipe, true);

%% Write it out to disk.
fid = fopen(fileName, 'w');
err = [];
try
    fwrite(fid, summary);
    fclose(fid);
catch err
    % replaces placeholder, rethrow below
end

if any(fid == fopen('all'))
    fclose(fid);
end

if ~isempty(err)
    rethrow(err)
end

