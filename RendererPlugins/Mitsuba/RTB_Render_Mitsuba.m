%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke Mitsuba.
%   @param scene struct description of the scene to be rendererd
%   @param isShow whether or not to display the output image in a figure
%
% @details
% This function is the RenderToolbox3 "Render" function for Mitsuba.
%
% @details
% See RTB_Render_SampleRenderer() for more about Render functions.
%
% Usage:
%   [status, result, multispectralImage, S] = RTB_Render_Mitsuba(scene, isShow, hints)
function [status, result, multispectralImage, S] = RTB_Render_Mitsuba(scene, isShow, hints)

if hints.isAbsoluteResourcePaths
    sceneFile = scene.mitsubaFile;
else
    [scenePath, sceneBase, sceneExt] = fileparts(scene.mitsubaFile);
    sceneFile = [sceneBase, sceneExt];
end

% invoke Mitsuba!
[status, result, output] = RunMitsuba(sceneFile, isShow);
if status ~= 0
    error('Mitsuba rendering failed\n  %s\n  %s\n', sceneFile, result);
end

% read raw output into memory
%   including explicit spectral sampling, "S"
[multispectralImage, wls, S] = ReadMultispectralEXR(output);
