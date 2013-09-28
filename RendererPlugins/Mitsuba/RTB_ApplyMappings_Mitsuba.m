%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert mappings objects to native adjustments for the Mitsuba.
%   @param objects mappings objects as returned from MappingsToObjects()
%   @param adjustments native adjustments to be updated, if any
%
% @details
% This is the RenderToolbox3 "ApplyMappings" function for Mitsuba.
%
% @details
% For more about ApplyMappings functions, see
% RTB_ApplyMappings_SampleRenderer().
%
% @details
% Usage:
%   adjustments = RTB_ApplyMappings_Mitsuba(objects, adjustments)
%
% @ingroup RendererPlugins
function adjustments = RTB_ApplyMappings_Mitsuba(objects, adjustments)

% Mitsuba default adjustments is an XML adjustments file name.
if isempty(adjustments)
    adjustments = getpref('Mitsuba', 'adjustments');
end

if isempty(objects)
    return;
end

% convert generic mappings object names and values to mitusba-native
if strcmp('Generic', objects(1).blockType)
    objects = GenericObjectsToMitsuba(objects);
end

% add mappings data to the mitsuba adjustments XML file
[adjustDoc, adjustIDMap] = ReadSceneDOM(adjustments);
ApplyMitsubaObjects(adjustIDMap, objects);
WriteSceneDOM(adjustments, adjustDoc);