%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file the Sample Renderer native format
%   @param colladaFile input Collada parent scene file name or path
%   @param adjustments native adjustments data, or file name or path
%   @param imageName the name to use for this scene and new files
%   @param hints struct of RenderToolbox3 options
%
% @details
% This function is a template for a RenderToolbox3 "ImportCollada"
% function.
%
% @details
% The name of an ImportCollada function must match a specific pattern: it
% must begin with "RTB_ImportCollada_", and it must end with the name of
% the renderer, for example, "SampleRenderer".  This pattern allows
% RenderToolbox3 to automatically locate the ImportCollada function for
% each renderer.  ImportCollada functions should be included in the Matlab
% path.
%
% @details
% An ImportCollada function must convert the given @a colladaFile ('.dae'
% or '.xml') to a native format that the renderer can use for rendering.
% It must also create a Matlab struct that contains a description of the
% scene, which will be passed to the renderer's Render function.
%
% @details
% An ImportCollada function may use the given @a adjustments to modify
% the native scene, following an initial conversion from Collada.  @a
% adjustments may contain scene data or the name of a partial scene file to
% be merged with the scene in a renderer-specific way.  @a adjustments will
% be returned from a RenderToolbox3 ApplyMappings function.
%
% @details
% @a hints will be a struct with RenderToolbox3 options, as returned from
% GetDefaultHints(), which may inform the conversion process.
%
% @details
% An ImportCollada function must return a struct that describes the
% renderer-native scene.  This struct must contain all of the information
% needed to render the scene, including the names of any new files created.
%
% @details
% An ImportCollada function may write new renderer-native scene files and
% other auxiliary files.  It should put any new files in the current
% working "scenes" folder, obtained as follows:
% @code
%   scenesFolder = GetWorkingFolder('scenes', true, hints);
% @endcode
%
% @details
% The names of all new files should appear in the returned scene
% description struct, or appear within other files whose names appear in
% turn in the scene description struct.  These file names must be converted
% to relative paths using GetWorkingRelativePath(), in order to make scenes 
% portable across machines and users.
%
% @details
% The specific format of the returned struct does not matter, it just has
% to be a struct.  RenderToolbox3 may add or update some struct fields
% automatically, including the authorInfo and imageName fields.
%
% @details
% Usage:
%   scene = RTB_ImportCollada_SampleRenderer(colladaFile, adjustments, imageName, hints)
%
% @ingroup RendererPlugins
function scene = RTB_ImportCollada_SampleRenderer(colladaFile, adjustments, imageName, hints)

disp('SampleRenderer ImportCollada function.');
disp('colladaFile is:');
disp(colladaFile);
disp('adjustments is:');
disp(adjustments);
disp('imageName is:')
disp(imageName);
disp('hints is:');
disp(hints);

scene.description = 'SampleRenderer scene description';
scene.height = 5;
scene.width = 5;
scene.value = 1;

if hints.isReuseSceneFiles
    % may wish to reuse existing scene files instead of creating new ones
    disp('Reusing scene files')
    drawnow();
end
