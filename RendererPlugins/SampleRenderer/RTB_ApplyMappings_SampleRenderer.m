%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Translate generic object names and values to PBRT.
%   @param objects
%
% @details
% Convert generic mappings objectsto PBRT-native mappings objects.  @a
% objects must be a struct array of mappings objects as returned from
% SupplementGenericObjects().
%
% @details
% Used internally by MakeSceneFiles().
%
% @details
% Usage:
%   objects = GenericObjectsToPBRT(objects)
%
% @ingroup Mappings
function objects = GenericObjectsToPBRT(objects)

%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Apply PBRT mappings objects to the adjustments DOM.
%   @param idMap
%   @param objects
%
% @details
% Modify the document represented by the given @a idMap, with the given
% mappings @a objects.  @a objects must be a struct array of mappings
% objects as returned from MappingsToObjects() or GenericObjectsToPBRT().
%
% @details
% Used internally by MakeSceneFiles().
%
% @details
% Usage:
%   ApplyPBRTObjects(idMap, objects)
%
% @ingroup Mappings
function ApplyPBRTObjects(idMap, objects)
