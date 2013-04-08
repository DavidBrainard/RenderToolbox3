%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Create a new document element.
%   @param element document element to be the parent of the new element
%   @param name string node name for the new element
%   @param id string unique identifier for the new element (optional)
%
% @details
% Create a new document element that is a child of the given @a element.
% @a element must be an element node from an scene document, as returned 
% from SearchScene().  @a name must be the string node name for the new
% element.
%
% @details
% If @a id is provided, the new element will have an 'id' attribute with
% the value of @a id.
%
% @details
% Returns the new document element.
%
% @details
% Usage:
%   newElement = CreateElementChild(element, name, id)
%
% @ingroup SceneDOM
function newElement = CreateElementChild(element, name, id)

if nargin < 3
    id = '';
end

% make a new node with the given name
doc = element.getOwnerDocument();
newElement = doc.createElement(name);
element.appendChild(newElement);

% add id attribute to the new node
if ~isempty(id)
    idAttribute = doc.createAttribute('id');
    idAttribute.setValue(id);
    newElement.setAttributeNode(idAttribute);
end