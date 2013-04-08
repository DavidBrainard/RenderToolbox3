%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the Mitsuba renderer.
%   @param sceneFile filename or path of a Mitsuba .xml scene file.
%
% @details
% Invoke the Mitsuba renderer on the given .xml @a sceneFile.  This
% function handles some of the boring details of invoking Mitsuba with
% Matlab's unix() command.
%
% @details
% Returns the numeric status code and text output from the unix() command.
% Also returns the name of the expected output file from Mitsuba.
%
% Usage:
%   [status, result, output] = RunMitsuba(sceneFile)
%
% @ingroup Utilities
function [status, result, output] = RunMitsuba(sceneFile)

InitializeRenderToolbox();

%% Where to get/put the input/output
[scenePath, sceneBase] = fileparts(sceneFile);
output = fullfile(scenePath, [sceneBase '.exr']);

%% Change the dynamic library path, which can interfere with Mitsuba.
libPathName = getpref('Mitsuba', 'libPathName');
libPath = getpref('Mitsuba', 'libPath');
MatlabLibPath = getenv(libPathName);
setenv(libPathName, libPath);

%% Invoke the renderer.
mitsuba = fullfile( ...
    getpref('Mitsuba', 'app'), ...
    getpref('Mitsuba', 'executable'));
renderCommand = sprintf('%s -o %s %s', mitsuba, output, sceneFile);
fprintf('%s\n', renderCommand);
[status, result] = unix(renderCommand);

if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneFile)
end

%% Restore the dynamic library path for Matlab.
setenv(libPathName, MatlabLibPath);
