%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Modify a scene document with a mapping.
%   @param idMap
%   @param mapping
%
% @details
% Modify the document represented by the given @a idMap, with the given
% @a mapping.  @a mapping must be a mappings struct as returned from
% ParseMappings(), with a Scene DOM path as the left-hand value and a
% string as the right-hand value.
%
% @details
% Creates document nodes as needed, to satisfy the left-hand scene path.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   ApplyScenePathMapping(idMap, mapping)
%
% @ingroup BatchRender
function ApplyScenePathMapping(idMap, mapping)

% make sure there's an id node for the mapping scene path
nodePath = PathStringToCell(mapping.left.value);
id = nodePath{1};

% make sure the path id node exists
if ~idMap.isKey(id)
    % create a new node for this id
    %   the default node name may be overwritten
    docNode = idMap('document');
    docRoot = docNode.getDocumentElement();
    idNode = CreateElementChild(docRoot, 'node', id);
    idMap(id) = idNode;
end

% apply the mapping right-hand value to the left-hand path
SetSceneValue(idMap, nodePath, mapping.right.value, true, mapping.operator);
