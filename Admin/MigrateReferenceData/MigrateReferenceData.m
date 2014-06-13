%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Move RenderToolbox3 data folders from the "v1" style to the "v2" style.
%
% In RenderToolbox3 v1, input and output files used a folder structure like
%   user-root-folder/data/recipeName/rendererName/fileName.extension
% Where "data" might also be "images" or "temp".
%
% RenderToolbox3 v2 uses a different folder structure, which is easier for
% recipes to configure and makes recipes easier to share across machines:
%   user-root-folder/recipeName/renderings/rendererName/fileName.extension
% Where "renderings" might also be "images", "scenes", "resources", or
% "temp".
%
% This script moves folders from the v1 format to a new root folder in the
% v2 format.  It's intended to be used one time only, to update the folder
% structure of the RenderToolbox3-ReferenceData repository on GitHub.  It
% only copies some kinds of "temp" files.
%
% Perhaps one day someone will want to consult this script or reuse it.
%

%% Most users should ignore this script.

function MigrateReferenceData()

referenceRoot = '/Users/ben/RenderToolbox3-ReferenceData';
rearrangedRoot = '/Users/ben/Rearranged';

%% Move "data" files to "renderings" folder.
referenceFolder = fullfile(referenceRoot, 'data');
referenceFiles = FindFiles(referenceFolder, '\.mat$');
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'renderings', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Move "temp" exr files to "renderings" folder.
referenceFolder = fullfile(referenceRoot, 'temp');
referenceFiles = FindFiles(referenceFolder, '\.exr$');
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'renderings', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Move "temp" dat files to "renderings" folder.
referenceFolder = fullfile(referenceRoot, 'temp');
referenceFiles = FindFiles(referenceFolder, '\.dat$');
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'renderings', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Move "images" files to "images" folder.
referenceFolder = fullfile(referenceRoot, 'images');
referenceFiles = FindFiles(referenceFolder);
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'images', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Move "temp" pbrt files to "scenes" folder.
referenceFolder = fullfile(referenceRoot, 'temp');
referenceFiles = FindFiles(referenceFolder, '\.pbrt$');
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'scenes', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Move "temp" xml files to "scenes" folder.
referenceFolder = fullfile(referenceRoot, 'temp');
referenceFiles = FindFiles(referenceFolder, '\.xml$');
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'scenes', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Move "temp" serialized files to "scenes" folder.
referenceFolder = fullfile(referenceRoot, 'temp');
referenceFiles = FindFiles(referenceFolder, '\.serialized$');
for ii = 1:numel(referenceFiles)
    info = v1PathParts(referenceFiles{ii});
    v2Path = v2FullPath(rearrangedRoot, ...
        info.recipeName, 'scenes', ...
        info.rendererName, info.fileName);
    copyV1PathToV2Path(info.original, v2Path);
end

%% Break "v1" file path into meaningul parts.
function info = v1PathParts(v1Path)

% break off the file name
[v1ParentPath, v1Base, v1Ext] = fileparts(v1Path);
fileName = [v1Base v1Ext];

% break out subfolder names
scanResult = textscan(v1ParentPath, '%s', 'Delimiter', filesep());
tokens = scanResult{1};

% is there a renderer folder?
if any(strcmp(tokens{end}, {'PBRT', 'Mitsuba'}))
    rendererName = tokens{end};
    recipeNameIndex = numel(tokens) - 1;
else
    rendererName = '';
    recipeNameIndex = numel(tokens);
end

% get the recipe name
recipeName = tokens{recipeNameIndex};

% get the named subfolder name
subfolderName = tokens{recipeNameIndex-1};

% get the root path
rootPath = fullfile(tokens{1:recipeNameIndex-2});

info = struct( ...
    'original', v1Path, ...
    'fileName', fileName, ...
    'rendererName', rendererName, ...
    'recipeName', recipeName, ...
    'subfolderName', subfolderName, ...
    'rootPath', rootPath);

%% Assemble path parts into a "v2" path.
function v2path = v2FullPath(rootPath, recipeName, subfolderName, rendererName, fileName)
v2path = fullfile(rootPath, recipeName, subfolderName, rendererName, fileName);

%% Copy a "v1" path to a "v2" path, create "v2" path as needed.
function copyV1PathToV2Path(v1Path, v2Path)
% disp(v1Path)
% disp(v2Path)
% disp(' ');

v2ParentPath = fileparts(v2Path);
if ~exist(v2ParentPath, 'dir')
    mkdir(v2ParentPath);
end
copyfile(v1Path, v2Path);
