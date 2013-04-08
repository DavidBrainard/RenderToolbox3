%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make a Scene DOM path for an XML document element or attribute.
%   @param node XML document element or attribute object
%   @param checkName name of attribute to include in the path
%
% @details
% Create a Scene DOM path for the given XML document element or attribute.
%
% @details
% By default, crates a Scene DOM path that only uses element names.  If
% @a checkName is provided, it must the string name of an attribute to
% "check".  For elements in the path that have an attribute with the given
% @a checkName, the name and value will be included in the path.
%
% @details
% Returns a Scene DOM path cell array for the given node.
%
% @details
% See the RenderToolbox3 wiki for more about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Scene-DOM-Paths">Scene
% DOM paths</a>.
%
% @details
% Usage:
%   nodePath = GetNodePath(node, checkName)
%
% @ingroup SceneDOM
function nodePath = GetNodePath(node, checkName)

if nargin < 2
    checkName = '';
end

% ignore nodes that store raw node text
if strcmp('#text', char(node.getNodeName()))
    nodePath = {};
    return;
end

% starting with the given node, build a path backwards, by working up the
% DOM graph
backwardsPath = {};

% attribute is always last in the path
ATTRIBUTE_NODE = 2;
if ATTRIBUTE_NODE == node.getNodeType()
    % concatenate name and value
    name = char(node.getName());
    backwardsPath{end+1} = PrintPathPart('.', name);
    
    % get the element above this attribute
    node = node.getOwnerElement();
end

% trace node names up the graph
%   until finding an ancestor with an "id"
%   or reaching the top of the document graph
ancestorID = 'document';
while isjava(node) && ~strcmp('#document', char(node.getNodeName()))
    % does this node have a proper id?
    [attribute, name, value] = GetElementAttributes(node, 'id');
    if ~isempty(attribute)
        ancestorID = value;
        break;
    end
    
    % convert the node name from Java to Matlab
    name = char(node.getNodeName());
    
    % append a plain or decorated path part
    if isempty(checkName)
        % plain node name
        backwardsPath{end+1} = PrintPathPart(':', name);
        
    else
        % check the given attribute
        [attrib, attribName, attribValue] = ...
            GetElementAttributes(node, checkName);
        if isempty(attrib)
            % no match, plain node name
            backwardsPath{end+1} = PrintPathPart(':', name);
            
        else
            % match, decorate node name with attribute
            backwardsPath{end+1} = ...
                PrintPathPart(':', name, attribName, attribValue);
        end
    end
    
    % continue up the document graph
    node = node.getParentNode();
end

% make a forwards path, starting with ancestorID
backwardsPath{end+1} = ancestorID;
nodePath = backwardsPath(end:-1:1);