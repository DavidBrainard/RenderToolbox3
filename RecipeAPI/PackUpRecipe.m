%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Save a recipe and its file dependencies to a zip file.
%   @param recipe a recipe struct
%   @param archiveName name of the archive file to create
%
% @details
% Creates a new zip archive named @a archiveName which contains the given
% @a recipe (in a mat-file) along with its file dependencies from the
% current working folder.  See GetWorkingFolder().
%
% @details
% Returns the name of the zip archive that was created, which may be the
% same as the given @a archiveName.
%
% @details
% Usage:
%   archiveName = PackUpRecipe(recipe, archiveName)
%
% @ingroup RecipeAPI
function archiveName = PackUpRecipe(recipe, archiveName)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    archiveName = 'recipe.zip';
end
[archivePath, archiveBase] = fileparts(archiveName);


%% Set up a clean, temporary folder.
hints.recipeName = archiveBase;
tempFolder = GetWorkingFolder('', false, hints);
if exist(tempFolder, 'dir')
    rmdir(tempFolder, 's');
end
mkdir(tempFolder);

%% Save the recipe itself to the working folder.
recipeFileName = fullfile(tempFolder, 'recipe.mat');
save(recipeFileName, 'recipe');

%% Copy dependencies from the working folder to the temp folder.

% TODO: optionally specify working folder names to ignore

workingFolder = GetWorkingFolder('', false, recipe.input.hints);
dependencies = FindFiles(workingFolder);
for ii = 1:numel(dependencies)
    localPath = dependencies{ii};
    relativePath = GetWorkingRelativePath(localPath, recipe.input.hints);
    tempPath = fullfile(tempFolder, relativePath);
    
    if exist(tempPath, 'file')
        continue;
    end
    
    tempPrefix = fileparts(tempPath);
    if ~exist(tempPrefix, 'dir')
        mkdir(tempPrefix);
    end
    
    [isSuccess, message] = copyfile(localPath, tempPath);
    if ~isSuccess
        warning('RenderToolbox3:PackUpRecipeCopyError', ...
            ['Error packing up recipe file: ' message]);
    end
end

%% Zip up the whole temp folder with recipe and dependencies.
if ~exist(archivePath, 'dir')
    mkdir(archivePath);
end
zip(archiveName, tempFolder);

%% Clean up.
rmdir(tempFolder, 's');
