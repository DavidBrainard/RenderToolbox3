%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke PBRT.
%   @param scene struct description of the scene to be rendererd
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% This function is the RenderToolbox3 "Render" function for PBRT.
%
% @details
% See RTB_Render_SampleRenderer() for more about Render functions.
%
% Usage:
%   [status, result, multispectralImage, S] = RTB_Render_PBRT(scene, hints)
function [status, result, multispectralImage, S] = RTB_Render_PBRT(scene, hints)

if hints.isAbsoluteResourcePaths
    sceneFile = scene.pbrtFile;
else
    [scenePath, sceneBase, sceneExt] = fileparts(scene.pbrtFile);
    sceneFile = [sceneBase, sceneExt];
end


% invoke PBRT!
[status, result, output] = RunPBRT(sceneFile, hints);
if status ~= 0
    error('PBRT rendering failed\n  %s\n  %s\n', sceneFile, result);
end

% read output into memory
multispectralImage = ReadDAT(output);

% interpret output according to PBRT's spectral sampling
S = getpref('PBRT', 'S');