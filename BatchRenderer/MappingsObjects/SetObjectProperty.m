%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Set a mappings object property value.
%   @param obj
%   @param name
%   @param value
%
% @details
% Set a property value for a mappings object.  Returns the updated object.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   obj = SetObjectProperty(obj, name, value)
%
% @ingroup MappingsObjects
function obj = SetObjectProperty(obj, name, value)
if ~isempty(obj.properties)
    isProp = strcmp(name, {obj.properties.name});
    if any(isProp)
        index = find(isProp, 1, 'first');
        obj.properties(index).value = value;
    end
end
