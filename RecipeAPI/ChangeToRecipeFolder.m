%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% cd() to the working folder for a recipe.
%   @param recipe a recipe struct
%
% @details
% Attempts to change directory to the given @a
% recipe.input.hints.workingFolder.  Attemptes to create the folder if it
% doesn't exist yet.
%
% @details
% Returns the given @a recipe, possibly updated with a new error appended.
%
% @details
% Usage:
%   recipe = ChangeToRecipeFolder(recipe)
%
% @ingroup RecipeAPI
function recipe = ChangeToRecipeFolder(recipe)

if IsStructFieldPresent(recipe.input.hints, 'workingFolder')
    workingFolder = recipe.input.hints.workingFolder;
else
    return;
end

errorData = [];
try
    if ~exist(workingFolder, 'dir')
        mkdir(workingFolder)
    end
    cd(workingFolder);
    
catch errorData
    % fills in placeholder above, log it below
end

% put this execution in the log with any error data
recipe = AppendRecipeLog(recipe, ...
    [mfilename() ' cd() to ' workingFolder], ...
    @cd, errorData, 0);
