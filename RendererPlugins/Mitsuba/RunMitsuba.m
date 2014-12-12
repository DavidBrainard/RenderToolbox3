%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the Mitsuba renderer.
%   @param sceneFile filename or path of a Mitsuba-native scene file.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%   @param mitsuba struct of mitsuba config., see getpref("Mitsuba")
%
% @details
% Invoke the Mitsuba renderer on the given Mitsuba-native @a sceneFile.
% This function handles some of the boring details of invoking Mitsuba with
% Matlab's unix() command.
%
% @details
% if @a hints.isPlot is provided and true, displays an sRGB representation
% of the output image in a new figure.
%
% @details
% Returns the numeric status code and text output from Mitsuba.
% Also returns the name of the expected output file from Mitsuba.
%
% Usage:
%   [status, result, output] = RunMitsuba(sceneFile, hints)
%
% @ingroup Utilities
function [status, result, output] = RunMitsuba(sceneFile, hints, mitsuba)

if nargin < 2 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if nargin < 3 || isempty(mitsuba)
    mitsuba = getpref('Mitsuba');
end

InitializeRenderToolbox();

%% Where to get/put the input/output
[scenePath, sceneBase] = fileparts(sceneFile);
renderings = GetWorkingFolder('renderings', true, hints);
output = fullfile(renderings, [sceneBase '.exr']);

%% Invoke Mitsuba.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% find the Mitsuba executable
executable = fullfile(mitsuba.app, mitsuba.executable);
renderCommand = sprintf('%s -o %s %s', executable, output, sceneFile);
fprintf('%s\n', renderCommand);
[status, result] = RunCommand(renderCommand, hints);

% restore the library search path
setenv(libPathName, originalLibPath);

%% Show a warning or figure?
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneFile)
elseif hints.isPlot
    [multispectral, wls, S] = ReadMultispectralEXR(output);
    toneMapFactor = 10;
    isScale = true;
    sRGB = MultispectralToSRGB(multispectral, S, toneMapFactor, isScale);
    ShowXYZAndSRGB([], sRGB, sceneBase);
end
