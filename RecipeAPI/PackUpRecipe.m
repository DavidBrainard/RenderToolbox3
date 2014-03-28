%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Save a recipe and its file dependencies to a zip file.
%   @param recipe a recipe struct
%   @param zipFileName name of the zip file to create
%   @param extras cell array of extra files to include
%
% @details
% Creates a new zip archive named @a zipFileName which contains the given
% @a recipe (in a mat-file) along with its file dependencies, including
% input files and recource files that are referenced from the input files.
% @a extras may include a cell array of extra files to include in the zip
% archive.
%
% @details
% Returns the given @a recipe, with @a recipe.dependencies filled in.  Also
% returns the name of the zip archive that was created, which may be the
% same as the given @a zipFileName.
%
% @details
% Usage:
%   [recipe, zipFileName] = PackUpRecipe(recipe, zipFileName, extras)
%
% @ingroup RecipeAPI
function [recipe, zipFileName] = PackUpRecipe(recipe, zipFileName, extras)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    zipFileName = 'recipe.zip';
end
[zipPath, zipBase] = fileparts(zipFileName);

if nargin < 3
    extras = {};
end

%% Set up a clean, temporary working folder.
hints = recipe.input.hints;
hints.outputSubfolder = zipBase;
workingFolder = GetOutputPath('tempFolder', hints);
hints.tempFolder = fullfile(workingFolder, 'temp');
hints.outputDataFolder = fullfile(workingFolder, 'data');
hints.outputImageFolder = fullfile(workingFolder, 'images');
hints.resourcesFolder = fullfile(workingFolder, 'resources');
if exist(workingFolder, 'dir')
    rmdir(workingFolder, 's');
end
mkdir(workingFolder);

%% Before saving, detect dependencies for this recipe.
dependencies = FindRecipeDependentFiles(recipe, extras);
recipe.dependencies = dependencies;

recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @FindRecipeDependentFiles, [], 0);

%% Save the recipe itself to the working folder.
recipeFileName = fullfile(workingFolder, 'recipe.mat');
save(recipeFileName, 'recipe');

%% Copy dependencies to subfolders of the working folder.
hints.workingFolder = workingFolder;
for ii = 1:numel(recipe.dependencies)
    originalPath = recipe.dependencies(ii).fullLocalPath;
    portablePath = recipe.dependencies(ii).portablePath;
    tempPath = PortablePathToLocalPath(portablePath, hints);
    tempDir = fileparts(tempPath);
    if ~exist(tempDir, 'dir')
        mkdir(tempDir);
    end
    copyfile(originalPath, tempPath);
end

%% Zip up the whole working folder and clean it up.
if ~exist(zipPath, 'dir')
    mkdir(zipPath);
end
zip(zipFileName, workingFolder);
rmdir(workingFolder, 's');
