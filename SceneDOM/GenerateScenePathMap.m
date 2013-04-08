%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get many XML document nodes and Scene DOM paths.
%   @param docNode XML document node object 
%   @param checkName name of attribute to include in the path
%   @param filterPattern regular expression to filter document nodes
%
% @details
% Traverses the XML document represented by @a docNode, finding elements
% and attributes, and recording Scene DOM paths to each element or
% attribute.
%
% @details
% Returns a "path map" that represents the same document as @a docNode.  A
% path map is a containers.Map of all document elements and attributtes,
% with Scene DOM path strings as map keys.
%
% @details
% By default, the Scene DOM paths refer only to element node names.
% Therefore, the paths may not be unique and some nodes will be ignored.
% If @a checkName is provided, it should be the name of an attribute that
% can disambiguate elements by its value.  The attribute name and value
% will be included in the paths, for all objects that have the attribute.
%
% @details
% A useful value for @a checkName might be 'id', 'sid', 'name', or
% 'semantic'.  These attributes often distinguish similar nodes in Collada
% scene files and renderer adjustments files.
%
% @details
% Also by default, all elements and attributes are included in the path
% map.  If @a filterPattern is provided, it must be a regular expression to
% compare to each Scene DOM path string.  Only nodes whose path strings
% match the @a filterPattern will be included in the path map.
%
% @details
% Usage:
%   GenerateScenePathMap(docNode, checkName, filterPattern)
%
% @ingroup SceneDOM
function pathMap = GenerateScenePathMap(docNode, checkName, filterPattern)

if nargin < 2
    checkName = '';
end

if nargin < 3
    filterPattern = '';
end

% create the container for path strings and nodes
pathMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

% traverse the DOM!
traverseElements(docNode, pathMap, checkName, filterPattern);


%% Iterate attributes and child elements
function traverseElements(element, pathMap, checkName, filterPattern)
% get a path for the element itself
%   add this element to the path map
elementPath = GetNodePath(element, checkName);
if ~isempty(elementPath)
    pathString = PathCellToString(elementPath);
    if isempty(filterPattern) || ~isempty(regexp(pathString, filterPattern))
        pathMap(pathString) = element;
    end
end

% get a path for each attribute
%   add each attribute to the path map
[attributes, names, values] = GetElementAttributes(element);
nAttributes = numel(attributes);
for ii = 1:nAttributes
    attribPath = GetNodePath(attributes{ii}, checkName);
    pathString = PathCellToString(attribPath);
    if isempty(filterPattern) || ~isempty(regexp(pathString, filterPattern))
        pathMap(pathString) = attributes{ii};
    end
end

% recur: get paths for each child
children = GetElementChildren(element);
for ii = 1:numel(children)
    traverseElements(children{ii}, pathMap, checkName, filterPattern);
end