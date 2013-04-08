%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get uniquely identified XML document elements, and Scene DOM paths.
%   @param docNode XML document node object
%
% @details
% Traverses the XML DOM document represented by @a docNode, and builds a
% map to elements that have an "id" attribute.
%
% @details
% Returns an "id map" that represents the same document as @a docNode.  An
% id map is a containers.Map of document elements that have id attributes,
% with the id values as map keys.  Nodes with id attributes often
% correspond to intuitive parts of a scene, like the camera, lights,
% shapes, and materials.
%
% @details
% Usage:
%   idMap = GenerateSceneIDMap(docNode)
%
% @ingroup SceneDOM
function idMap = GenerateSceneIDMap(docNode)

% create the container for ids and elements
idMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% let the top-level element use the id 'document'
idMap('document') = docNode;

% traverse the DOM!
traverseElements(docNode, idMap);


%% Check for "id" and iterate child elements
function traverseElements(element, idMap)
% does this element have an 'id' attribute?
[attribute, name, id] = GetElementAttributes(element, 'id');
if ~isempty(attribute);
    % yes, add element to the idMap
    idMap(id) = element;
end

% recur: get paths for each child
children = GetElementChildren(element);
for ii = 1:numel(children)
    traverseElements(children{ii}, idMap);
end