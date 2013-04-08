%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Merge a PBRT-XML scene document with an adjustments document.
%   @param sceneIDMap
%   @param adjustmentsIDMap
%
% @details
% Merge scene node values from the document represented by @a
% adjustmentsIDMap into the document represented by @a sceneIDMap.  Nodes
% that exist in both documents will have their values set to the values in
% the adjustments document.  Nodes that don't exist in the scene document
% will be created as needed.
%
% @details
% Nodes in the adjustment file are matched with nodes in the scene file
% using the id attribute.  A node in the adjustments file with the node
% name "merge" will merge values and attributes with the matching nodes in
% the scene file, with the adjustments nodes taking precidence.  Other
% nodes will replace the matching node in the scene file.
%
% @details
% Used internally by ColladaToPBRT().
%
% @details
% Usage:
%   MergeAdjustments(sceneIDMap, adjustmentsIDMap)
%
% @ingroup ColladaToPBRT
function MergeAdjustments(sceneIDMap, adjustmentsIDMap)

% create or delete scene file id nodes
%   as specified in the adjustments file
adjustIDs = adjustmentsIDMap.keys();
for ii = 1:numel(adjustIDs)
    % get an adjustment node, id, and name
    id = adjustIDs{ii};
    adjustNode = adjustmentsIDMap(id);
    name = char(adjustNode.getNodeName());
    
    % ignore the top-level document
    if strcmp('document', id)
        continue;
    end
    
    % delete an existing scene node?
    if ~strcmp('merge', name) && isKey(sceneIDMap, id)
        RemoveSceneNode(sceneIDMap, {id});
    end
    
    % create a new scene node like the adjustment node
    if ~isKey(sceneIDMap, id)
        sceneDoc = sceneIDMap('document');
        sceneRoot = sceneDoc.getDocumentElement();
        idNode = CreateElementChild(sceneRoot, name, id);
        sceneIDMap(id) = idNode;
    end
end

% get paths to all nodes in the adjustments document
%   disambiguate similar nodes using the 'name' attribute
adjustDoc = adjustmentsIDMap('document');
adjustRoot = adjustDoc.getDocumentElement();
adjustPathMap = GenerateScenePathMap(adjustRoot, 'name');

% copy the value from each adjustment path into the scene document
%   create scene document nodes as needed
adjustPaths = adjustPathMap.keys();
for ii = 1:numel(adjustPaths)
    % get the scene path for the next adjustment
    pathCell = PathStringToCell(adjustPaths{ii});
    id = pathCell{1};
    
    % ignore paths that refer to the top-level document
    if strcmp('document', id)
        continue;
    end
    
    % set the adjustment node value to the scene node
    adjustValue = GetSceneValue(adjustmentsIDMap, pathCell);
    if ~isempty(adjustValue)
        SetSceneValue(sceneIDMap, pathCell, adjustValue, true);
    end
end