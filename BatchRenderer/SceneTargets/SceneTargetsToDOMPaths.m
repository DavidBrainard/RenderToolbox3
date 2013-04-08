%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert mappings from Scene Target syntax to Scene DOM syntax.
%   @param sceneTargetMaps
%   @param hints
%
% @details
% Converts the given scene target mappings, which must contain scene target
% syntax on the left hand side, to renderer-native mappings that contain
% adjustment file scene DOM paths on the left hand side.
%
% @details
% The given @a sceneTargetMaps must be a struct array of mappings as
% returned from ParseMappings().  It should have scene target syntax on the
% left hand side.
%
% @details
% @a hints should be a struct of batch renderer hints, as returned from
% GetDefaultHints().
%
% @details
% Converts scene target syntax to scene DOM paths that can be applied
% to renderer adjustments files, and returns one or more mappings structs
% that contains renderer-native scene paths on the left hand side.
%
% @details
% If the block name in @a sceneTargetMaps.block matches the name of the
% current renderer in @a hints.renderer, then the names, types, and values
% given in the scene target syntax are preserverd in the renderer-native
% scene paths.
%
% @details
% If the block name in @a sceneTargetMaps.block is "Generic", then the
% names and types and values are treated as Generic Scene Elements.  These
% are converted and supplimented with other default mappings, in an attempt
% to make all renderers produce comparable outputs.
%
% @details
% Returns a struct array of one or more mappings, with renderer-native
% scene DOM paths on the left-hand side.  These can be used to modify
% renderer adjustments files.
%
% @details
% See the Rendertoolbox3 wiki for more about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Mappings-Syntax">Scene
% Targets </a>.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   nativeMaps = SceneTargetsToDOMPaths(sceneTargetMaps, hints)
%
% @ingroup SceneTargets
function nativeMaps = SceneTargetsToDOMPaths(sceneTargetMaps, hints)

nativeMaps = [];

if isempty(sceneTargetMaps)
    return;
end

% scan each mapping for scene target
%   each info struct is an intermediate form
%   between scene target and native mappings structs
template = ParseSceneTarget(sceneTargetMaps(1));
sceneTargetInfo = repmat(template, 1, numel(sceneTargetMaps));
for ii = 1:numel(sceneTargetMaps)
    sceneTargetInfo(ii) = ParseSceneTarget(sceneTargetMaps(ii));
end

% convert mappings in groups, by scene object id
ids = unique({sceneTargetInfo.id});
for ii = 1:numel(ids)
    % find all the mappings with this id
    id = ids{ii};
    isID = strcmp(id, {sceneTargetInfo.id});
    objectInfo = sceneTargetInfo(isID);
    
    % always start with an object declaration
    isDeclare = [objectInfo.isDeclaration];
    if any(isDeclare)
        % convert the mapping that declares the object
        declarationInfo = objectInfo(find(isDeclare, 1, 'first'));
        nativeInfo = GetNativeObjectDefaults(declarationInfo, hints);
        
        % convert info about object properties
        for jj = find(~isDeclare)
            % convert the property name and value to native
            configureInfo = GenericSceneTargetToNative( ...
                objectInfo(jj), nativeInfo, hints);
            nativeInfo = cat(2, nativeInfo, configureInfo);
        end
        
        % convert each info struct to native adjustments path mappings
        for jj = 1:numel(nativeInfo)
            newMaps = MakeNativePathMappings(nativeInfo(jj), hints);
            nativeMaps = cat(2, nativeMaps, newMaps);
        end
        
    else
        warning('Object id "%s" must be declared.  Ignoring.', id);
        continue;
    end
end
