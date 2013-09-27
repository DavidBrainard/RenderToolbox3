%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file the Sample Renderer native format
%   @param colladaFile input Collada parent scene file name or path
%   @param outFile output native scene file name or path
%   @param adjustments native adjustments data, or file name or path
%   @param hints struct of RenderToolbox3 options
%
% @details
% This function is a template for a RenderToolbox3 "ImportCollada"
% function.
%
% @details
% The name of an ImportCollada function must match a specific pattern: it must
% begin with "RTB_ImportCollada_", and it must end with the name of the
% renderer, for example, "SampleRenderer".  This pattern allows
% RenderToolbox3 to automatically locate the ImportCollada function for
% each renderer.  ImportCollada functions should be included in the Matlab
% path.
%
% @details
% An ImportCollada function must convert the given @a colladaFile ('.dae'
% or '.xml') to a native format that the renderer can use for rendering.
% It may write a new native scene file at the specified @a outFile.  It may
% also build up a representation of the native scene to return directly as
% a Matlab variable.
%
% @details
% An ImportCollada function may use the given @a adjustments to modify
% the native scene files following the initial conversion from Collada.  @a
% adjustments may contain scene data or the name of a partial scene file to
% be merged with the scene in a renderer-specific way.  @a adjustments will
% be returned from a RenderToolbox3 ApplyMappings function.
%
% @details
% @a hints will be a struct with RenderToolbox3 options, as returned from
% GetDefaultHints(), which may inform the conversion process.
%
% @details
% An ImportCollada function must return a scene description in
% renderer-native format.  This may be the name of the @a new outFile, or a
% Matlab variable that contains the scene description.  It must also return
% a variable containing meta-data about the scene.  This variable may be
% empty, or it may contain additional data such as an XML representation of
% the scece, or other meta-data.
%
% @details
% Usage:
%   [scene, sceneData] = RTB_ImportCollada_SampleRenderer(colladaFile, outFile, adjustments, hints)
%
% @ingroup RendererPlugins
function [scene, sceneData] = RTB_ImportCollada_SampleRenderer(colladaFile, outFile, adjustments, hints)

disp('SampleRenderer ImportCollada function.');
disp('colladaFile is:');
disp(colladaFile);
disp('outFile is:');
disp(outFile);
disp('adjustments is:');
disp(adjustments);
disp('hints is:');
disp(hints);

scene.height = 5;
scene.width = 5;
scene.value = 1;

sceneData = 'SampleRenderer scene data';