%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Detect input files and other dependencies for a recipe.
%   @param recipe a recipe struct
%   @param extras cell array of extra files to include
%
% @details
% Scans the given @a recipe.input files to determine file dependencies that
% are required for working with the given @a recipe.  These include the @a
% recipe.input files themselves, as well as other resources like spectrum
% description files and texture images that are required for scene file
% generation and rendering.  See FindDependentFiles() for details of how
% these resources are detected.
%
% @details
% if @a extras is included, it must be a cell array of additional
% file names to include along with the detected dependencies.
%
% @details
% Returns a struct array with one element per dependency.  Each element of
% the struct array will have the following fields:
%   - @b verbatimName - the name of the dependent file just as it appeared
%   @a recipe.input or in a specific input file.
%   - @b fullLocalPath - the full local path and name of the dependent file
%   as it appears on the Matlab path.
%   - @b portablePath - a "portable" representation of the @b
%   fullLocalPath, that uses placeholders for RenderToolbox3 output paths
%   as returned from GetOutputPath().
%   .
%
% @details
% Usage:
%   dependencies = FindRecipeDependentFiles(recipe, extras)
%
% @ingroup RecipeAPI
function dependencies = FindRecipeDependentFiles(recipe, extras)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

if nargin < 2
    extras = {};
end

%% Build up a grand list of required files.

% input files are required files
inputs = { ...
    recipe.input.configureScript, ...
    recipe.input.parentSceneFile, ...
    recipe.input.conditionsFile, ...
    recipe.input.mappingsFile};

% executive scripts/functions are required files
executive = recipe.input.executive;

% generated scene files are required (if any)
generated = {};
if IsStructFieldPresent(recipe.rendering, 'requiredFiles')
    generated = recipe.rendering.requiredFiles;
end

% rendered radiance data files are required (if any)
renderings = {};
if IsStructFieldPresent(recipe.rendering, 'radianceDataFiles')
    renderings = recipe.rendering.radianceDataFiles;
end

images = {};
if IsStructFieldPresent(recipe.processing, 'images')
    % processed images and montages are required (if any)
    images = recipe.processing.images;
end

extras = cat(2, extras, inputs, executive, generated, renderings, images);
extras = getWhichFilesIfAny(extras, recipe.input.hints.workingFolder);

%% Scan input files for additional dependencies.
dependencies = FindDependentFiles( ...
    recipe.input.parentSceneFile, ...
    recipe.input.conditionsFile, ...
    recipe.input.mappingsFile, ...
    extras, ...
    recipe.input.hints);

% Get full path to files on Matlab path, excluding RenderToolbox3 files.
function whichFileNames = getWhichFilesIfAny(fileNames, workingFolder)
whichFileNames = cell(size(fileNames));
isIncluded = false(size(fileNames));
for ii = 1:numel(fileNames)
    
    fileName = fileNames{ii};
    if isa(fileName, 'function_handle')
        % convert function handle to file name
        fileName = func2str(fileName);
    end
    
    if ~exist(fileName, 'file')
        % file not found
        isIncluded(ii) = false;
        continue;
    end
    
    [filePath, isRootFolderMatch] = ResolveFilePath(fileName, workingFolder);
    if ~isempty(filePath)
        % convert partial name to unambiguous path
        fileName = filePath;
    end
    
    if ~isRootFolderMatch
        % file not found within working folder
        isIncluded(ii) = false;
        continue;
    end
    
    % take this file
    isIncluded(ii) = true;
    whichFileNames{ii} = fileName;
end
whichFileNames = whichFileNames(isIncluded);