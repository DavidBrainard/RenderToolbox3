%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Load a recipe and its file dependencies from a zip file.
%   @param zipFileName name of the zip file to create
%   @param isCopyDependencies whether or not to copy dependencies locally
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Creates a new recipe struct based on the zip archive called @a
% zipFileName, as produced by PackUpRecipe().  Also unpacks recipe file
% dependencies that were saved in the archive along with the recipe struct.
%
% @details
% If @a isCopyDependencies is provided and true, file dependencies that
% were saved in the zip archive will be copied to locally configured
% folders like the RenderToolbox3 outputDataFolder.  See GetOutputPath()
% for more about RenderToolbox3 configured folders.  @a hints may be
% provided to customize the behavior of GetOutputPath().
%
% @details
% Returns a new recipe struct that was contained in the zip archive named
% @a zipFileName.
%
% @details
% Usage:
%   recipe = UnpackRecipe(zipFileName, isCopyDependencies, hints)
%
% @ingroup RecipeAPI
function recipe = UnpackRecipe(zipFileName, isCopyDependencies, hints)

if nargin < 1 || ~exist(zipFileName, 'file')
    error('You must suplpy the name of a zip archive');
end
[zipPath, zipBase] = fileparts(zipFileName);

if nargin < 2
    isCopyDependencies = false;
end

if nargin < 3
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Set up a clean, temporary working folder.
workingHints = hints;
workingHints.outputSubfolder = zipBase;
workingFolder = GetOutputPath('tempFolder', workingHints);
workingHints.tempFolder = fullfile(workingFolder, 'temp');
workingHints.outputDataFolder = fullfile(workingFolder, 'data');
workingHints.outputImageFolder = fullfile(workingFolder, 'images');
workingHints.resourcesFolder = fullfile(workingFolder, 'resources');
if exist(workingFolder, 'dir')
    rmdir(workingFolder, 's');
end
mkdir(workingFolder);


%% Unpack the zip archive to the working folder.
unzip(zipFileName, workingFolder);

% extract the recipe struct
recipeFiles = FindFiles(workingFolder, 'recipe\.mat');
if 1 == numel(recipeFiles)
    recipeFileName = recipeFiles{1};
else
    error('Could not fing recipe.m in the given zip archive');
end
matData = load(recipeFileName);
recipe = matData.recipe;


%% Copy dependencies from working folder to locally configured folders?
if isCopyDependencies
    hints.outputSubfolder = recipe.input.hints.outputSubfolder;
    hints.renderer = recipe.input.hints.renderer;
    dependencyFiles = FindFiles(workingFolder);
    for ii = 1:numel(dependencyFiles)
        tempPath = dependencyFiles{ii};
        if strcmp(tempPath, recipeFileName)
            continue;
        end
        
        portablePath = LocalPathToPortablePath(tempPath, workingHints);
        localPath = PortablePathToLocalPath(portablePath, hints);
        localDir = fileparts(localPath);
        if ~exist(localDir, 'dir')
            mkdir(localDir);
        end
        copyfile(tempPath, localDir);
    end
    
    % don't keep redundant copies of dependencies.
    rmdir(workingFolder, 's');
end


%% Re-detect dependencies locally for the unpacked recipe.
dependencies = FindRecipeDependentFiles(recipe);
recipe.dependencies = dependencies;

recipe = AppendRecipeLog(recipe, ...
    ['run automatically by ' mfilename()], ...
    @FindRecipeDependentFiles, [], 0);