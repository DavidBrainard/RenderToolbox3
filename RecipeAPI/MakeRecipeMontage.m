%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make an sRGB montage from a recipe's radianceDataFiles.
%   @param recipe a recipe struct
%
% @details
% Uses the given @a recipe's radiance data files to make an sRGB montage.
%
% @details
% Returns the given @a recipe, with @a recipe.processing.xyzMontage and @a
% recipe.processing.srgbMontage and filled in.
%
% @details
% Usage:
%   recipe = MakeRecipeMontage(recipe)
%
% @ingroup RecipeAPI
function recipe = MakeRecipeMontage(recipe)

recipe.processing.xyzMontage = [];
recipe.processing.srgbMontage = [];
errorData = [];
try
    [dataPath, dataBase] = ...
        fileparts(recipe.rendering.radianceDataFiles{1});
    montageName = [dataBase '-montage'];
    montageFile = [montageName '.png'];
    
    [recipe.processing.srgbMontage, recipe.processing.xyzMontage] = ...
        MakeMontage(recipe.rendering.radianceDataFiles, ...
        montageFile, [], [], recipe.input.hints);
    
    if IsStructFieldPresent(recipe.processing, 'images')
        recipe.processing.images{end+1} = montageFile;
    else
        recipe.processing.images = {montageFile};
    end
    
    if recipe.input.hints.isPlot
        ShowXYZAndSRGB( ...
            recipe.processing.xyzMontage, ...
            recipe.processing.srgbMontage, ...
            montageName, recipe.input.hints);
    end
    
catch errorData
    % fills in placeholder above, log it below
end

% put this execution in the log with any error data
recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @MakeMontage, errorData, 0);
