%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Add an instance reference to a PBRT-XML document.
%   @param idMap
%   @param id
%   @param name
%   @param type
%   @param value
%
% @details
% Adds an instance reference to the PBRT-XML document represented by @a
% idMap, using a standard format for node @a id and reference @a name and
% @a type.  Strips '#' symbols from @a value automatically.
%
% @details
% Used internally by ColladaToPBRT().
%
% @details
% Usage:
%   AddReference(idMap, id, name, type, value)
%
% @ingroup ColladaToPBRT
function AddReference(idMap, id, name, type, value)

% create new XML DOM objects as needed
isCreate = true;

% strip '#' from the node id and reference value
value = value(value ~= '#');
id = id(id ~= '#');

% create new XML DOM nodes as needed
isCreate = true;

% declare the reference
refPath = {id, [':reference|name=' name]};
SetSceneValue(idMap, refPath, value, isCreate);

% set the parameter type
refPath = {id, [':reference|name=' name], '.type'};
SetSceneValue(idMap, refPath, type, isCreate);
