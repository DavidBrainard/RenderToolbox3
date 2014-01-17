%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the Mitsuba renderer.
%   @param sceneFile filename or path of a Mitsuba-native scene file.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
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
function [status, result, output] = RunMitsuba(sceneFile, hints)

if nargin < 2
    hints = GetDefaultHints();
end

InitializeRenderToolbox();

%% Where to get/put the input/output
[scenePath, sceneBase] = fileparts(sceneFile);
output = fullfile(scenePath, [sceneBase '.exr']);

%% Invoke Mitsuba.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% find the Mitsuba executable
mitsuba = fullfile( ...
    getpref('Mitsuba', 'app'), ...
    getpref('Mitsuba', 'executable'));
renderCommand = sprintf('%s -o %s %s', mitsuba, output, sceneFile);
fprintf('%s\n', renderCommand);

% run Mitsuba in the destination folder to capture all ouput there
originalFolder = pwd();
if exist(scenePath, 'dir')
    cd(scenePath);
end
[status, result] = RunCommand(renderCommand, hints);
cd(originalFolder)

% restore the library search path
setenv(libPathName, originalLibPath);

%% Show a warning or figure?
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneFile)
elseif hints.isPlot
    multispectral = ReadMultispectralEXR(output);
    S = getpref('PBRT', 'S');
    toneMapFactor = 10;
    isScale = true;
    sRGB = MultispectralToSRGB(multispectral, S, toneMapFactor, isScale);
    ShowXYZAndSRGB([], sRGB, sceneBase);
end
