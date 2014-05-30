%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Save a recipe and its file dependencies to a zip file.
%   @param recipe a recipe struct
%   @param archiveName name of the archive file to create
%   @param ignoreFolders optional cell array of folder names to ignore
%
% @details
% Creates a new zip archive named @a archiveName which contains the given
% @a recipe (in a mat-file) along with its file dependencies from the
% current working folder.  See GetWorkingFolder().
%
% @details
% By default, packs up all files in the recipe's working folder.  If @a
% ignoreFolders is provided, it must be a cell array of named subfolders
% not to pack up with the recipe.  For example, {'temp'}.  See
% GetWorkingFolder() for more about named subfolders.
%
% @details
% Returns the name of the zip archive that was created, which may be the
% same as the given @a archiveName.
%
% @details
% Usage:
%   archiveName = PackUpRecipe(recipe, archiveName, ignoreFolders)
%
% @ingroup RecipeAPI
function archiveName = PackUpRecipe(recipe, archiveName, ignoreFolders)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    archiveName = 'recipe.zip';
end
[archivePath, archiveBase] = fileparts(archiveName);

if nargin < 3
    ignoreFolders = {};
end


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

%% Resolve named ignored folders to local file paths.
ignorePaths = cell(size(ignoreFolders));
for ii = 1:numel(ignoreFolders)
    ignorePaths{ii} = ...
        GetWorkingFolder(ignoreFolders{ii}, false, recipe.input.hints);
end

%% Copy dependencies from the working folder to the temp folder.
workingRoot = GetWorkingFolder('', false, recipe.input.hints);
dependencies = FindFiles(workingRoot);
for ii = 1:numel(dependencies)
    localPath = dependencies{ii};
    
    % ignore some files
    if shouldBeIgnored(localPath, ignorePaths);
        continue;
    end
    
    relativePath = GetWorkingRelativePath(localPath, recipe.input.hints);
    tempPath = fullfile(tempFolder, relativePath);
    
    % don't try to copy a file to itself
    if exist(tempPath, 'file')
        continue;
    end
    
    % make sure destination exists
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


%% Is the given file in an ignored folder?
function isIgnore = shouldBeIgnored(filePath, ignorePaths)
isIgnore = false;
for ii = 1:numel(ignorePaths)
    isIgnore = IsPathPrefix(ignorePaths{ii}, filePath);    
    if (isIgnore)
        return;
    end
end
