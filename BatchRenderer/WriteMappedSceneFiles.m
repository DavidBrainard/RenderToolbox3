%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Apply condition values and mappings to scene and adjustments files.
%   @param workingPath
%   @param name
%   @param originalScene
%   @param originalAdjust
%   @param mappings
%   @param varNames
%   @param varValues
%
% @details
% Apply variable values and mappings to scene and adjustments files.
%
% @details
% @a workingPath must be a folder path name where to put new files.  @a
% name must be a string name to include in the mapped scene file names.
%
% @details
% @a originalScene and @a originalAdjust must be XML scene and adjustments
% files, respectively.  @a originalAdjust is optional.
%
% @details
% mappings must be a struct array of mapping data as returned from
% ParseMappings().
%
% @details
% @a varNames and @a varValues must be cell arrays of variable names and
% corresponding values, as returned from ParseConditions().
%
% @details
% @a hints should be a struct with renderer options.  @a hints.renderer
% should be the name of a renderer, either 'Mitsuba', or 'PBRT'.
%
% @details
% Writes copies of the given @a originalScene file and @a
% originalAdjustments file, and modifies each as specified by the given
% @a mappings, @a varNames, and @a varValues.
%
% @details
% Returns the names of the new, mapped scene file and the new, mapped
% adjustments file.  Also returns a cell array of file names for resources
% specified in mappings, such as image files and spectrum files.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   [mappedScene, mappedAdjust, resources] = WriteMappedSceneFiles( ...
%       workingPath, name, originalScene, originalAdjust, ...
%       mappings, varNames, varValues, hints)
%
% @ingroup BatchRender
function [mappedScene, mappedAdjust, resources] = WriteMappedSceneFiles( ...
    workingPath, name, originalScene, originalAdjust, ...
    mappings, varNames, varValues, hints)

%% Parameters
if nargin < 1 || isempty(name)
    name = 'mapped';
end

[scenePath, sceneBase, sceneExt] = fileparts(originalScene);

if nargin < 3 || isempty(originalAdjust)
    originalAdjust = '';
end
[adjustPath, adjustBase, adjustExt] = fileparts(originalAdjust);

% choose output file names
mappedScene = fullfile(workingPath, [name sceneExt]);
if isempty(originalAdjust)
    mappedAdjust = '';
else
    mappedAdjust = fullfile(workingPath, [name 'Adjustments' adjustExt]);
end

%% Copy and modify the original scene and adjustments XML documents.
% get original documents into memory
[sceneDoc, sceneIDMap] = ReadSceneDOM(originalScene);
if ~isempty(originalAdjust)
    [adjustDoc, adjustIDMap] = ReadSceneDOM(originalAdjust);
end

% if there's a "groupName" variable, it may filter out mappings blocks
isGroupName = strcmp(varNames, 'groupName');
if any(isGroupName)
    groupName = varValues(find(isGroupName, 1, 'first'));
else
    groupName = '';
end

%% Resolve the value part of each mapping:
%   replace (varName) syntax with corresponding varValue values
%   find resource files, possibly substitute full path names
%   filter mappings by group name

% add the current folder and subfolders to the path, temporarily
originalPath = path();
AddWorkingPath(pwd());
isInGroup = true(1, numel(mappings));
resources = {};
for mm = 1:numel(mappings)
    % replace (varName) text with varValue for this condition
    map = mappings(mm);
    for nn = 1:numel(varNames);
        varPattern = ['\(' varNames{nn} '\)'];
        map.left.value = ...
            regexprep(map.left.value, varPattern, varValues{nn});
        map.right.value = ...
            regexprep(map.right.value, varPattern, varValues{nn});
    end
    
    % right-hand value may be a scene path or just a string
    if strcmp('[]', map.right.enclosing)
        % '[]' look up a Collada scene path
        map.right.value = GetSceneValue(sceneIDMap, map.right.value);
        
    elseif strcmp('<>', map.right.enclosing)
        % '<>' look up an adjustments file scne path
        map.right.value = GetSceneValue(adjustIDMap, map.right.value);
        
    else
        % otherwise, just a constant value
        map.right.value = map.right.value;
    end
    
    % locate resource files on the Matlab path
    if ~isempty(strfind(map.right.value, '.')) ...
            && exist(map.right.value, 'file')
        resourcePath = which(map.right.value);
        resources{end+1} = resourcePath;
        
        % write full path name in scene file?
        if hints.isAbsoluteResourcePaths
            map.right.value = resourcePath;
        end
    end
    
    % should this mapping be filtered by group name?
    isInGroup(mm) = isempty(groupName) || isempty(map.group) ...
        || strcmp(groupName, map.group);
    
    % save the mapping with replacements
    mappings(mm) = map;
end

% restore the original path
path(originalPath);

%% Apply mappings separately for each block.
blockNums = [mappings.blockNumber];
rendererName = hints.renderer;
rendererPathName = [rendererName '-path'];
if ~isempty(mappings) && any(isInGroup)
    for bb = unique(blockNums)
        isBlock = isInGroup & bb == blockNums;
        if any(isBlock)
            blockMaps = mappings(isBlock);
            switch blockMaps(1).blockType
                case 'Collada'
                    % scene DOM paths for the Collada document
                    ApplySceneDOMPaths(sceneIDMap, blockMaps);
                    
                case 'Generic'
                    % generic scene targets for the adjustments document
                    objects = MappingsToObjects(blockMaps);
                    objects = SupplementGenericObjects(objects);
                    
                    % convert generic names and values to native and apply
                    switch rendererName
                        case 'PBRT'
                            objects = GenericObjectsToPBRT(objects);
                            ApplyPBRTObjects(adjustIDMap, objects);
                            
                        case 'Mitsuba'
                            objects = GenericObjectsToMitsuba(objects);
                            ApplyMitsubaObjects(adjustIDMap, objects);
                    end
                    
                case rendererName
                    % native scene targets for the adjustments document
                    objects = MappingsToObjects(blockMaps);
                    switch rendererName
                        case 'PBRT'
                            ApplyPBRTObjects(adjustIDMap, objects);
                            
                        case 'Mitsuba'
                            ApplyMitsubaObjects(adjustIDMap, objects);
                    end
                    
                case rendererPathName
                    % scene DOM paths for the adjustments document
                    ApplySceneDOMPaths(adjustIDMap, blockMaps);
            end
        end
    end
end

%% Write new scene and adjustments files, with all the mappings applied.
WriteSceneDOM(mappedScene, sceneDoc);
if ~isempty(originalAdjust)
    WriteSceneDOM(mappedAdjust, adjustDoc);
end