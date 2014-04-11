%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Detect input files and other dependencies for a recipe.
%   @param recipe a recipe struct
%   @param extras cell array of extra files to include with this recipe
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
% Returns a struct array in dependent file info, with one element per
% dependency, as returned from FindDependentFiles().
%
% @details
% Usage:
%   dependenciesInfo = FindRecipeDependentFiles(recipe, extras)
%
% @ingroup RecipeAPI
function dependenciesInfo = FindRecipeDependentFiles(recipe, extras)

if nargin < 1 || ~isstruct(recipe)
    error('You must suplpy a recipe struct');
end

%% Choose required input files.
% get path info about direct input files
% and generated scene files
inputFiles = { ...
    recipe.input.configureScript, ...
    recipe.input.parentSceneFile, ...
    recipe.input.conditionsFile, ...
    recipe.input.mappingsFile};
inputFiles = cat(2, inputFiles, recipe.input.executive);
if IsStructFieldPresent(recipe.rendering, 'requiredFiles')
    inputFiles = cat(2, inputFiles, recipe.rendering.requiredFiles);
end
inputInfo = getFilesInfoIfAny(inputFiles, recipe.input.hints);

% get path info about indirect input files (like spectra, textures)
indirectInfo = FindDependentFiles( ...
    recipe.input.parentSceneFile, ...
    recipe.input.conditionsFile, ...
    recipe.input.mappingsFile, ...
    recipe.input.hints);

% only take input files if they're inside the recipe working folder
inputInfo = cat(2, inputInfo, indirectInfo);
isRootFolderMatch = [inputInfo.isRootFolderMatch];
inputInfo = inputInfo(isRootFolderMatch);


%% Take any rendered or processed output files.
outputFiles = {};
if IsStructFieldPresent(recipe.rendering, 'radianceDataFiles')
    outputFiles = cat(2, outputFiles, recipe.rendering.radianceDataFiles);
end

if IsStructFieldPresent(recipe.processing, 'images')
    outputFiles = cat(2, outputFiles, recipe.processing.images);
end

% get path info about output files
outputInfo = getFilesInfoIfAny(outputFiles, recipe.input.hints);

%% Take any extra files explicitly provided.
extraInfo = getFilesInfoIfAny(extras, recipe.input.hints);

%% Unique list of inputs, outputs, and extras.
dependenciesInfo = cat(2, inputInfo, outputInfo, extraInfo);
[uniques, uniqueIndices] = unique({dependenciesInfo.absolutePath});
dependenciesInfo = dependenciesInfo(uniqueIndices);

% Get full path to files on Matlab path, excluding RenderToolbox3 files.
function filesInfo = getFilesInfoIfAny(fileNames, hints)
infoCell = cell(size(fileNames));
for ii = 1:numel(fileNames)
    
    fileName = fileNames{ii};
    if isa(fileName, 'function_handle')
        % convert function handle to file name
        fileName = func2str(fileName);
    end
    
    if ~exist(fileName, 'file')
        % file not found
        continue;
    end
    
    fileInfo = ResolveFilePath(fileName, hints.workingFolder);
    if ~isempty(fileInfo) && ~isempty(fileInfo.absolutePath)
        fileInfo.portablePath = ...
            LocalPathToPortablePath(fileInfo.absolutePath, hints);
        infoCell{ii} = fileInfo;
    end
end
filesInfo = cat(2, infoCell{:});
