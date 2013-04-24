%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the PBRT renderer.
%   @param sceneFile filename or path of a .pbrt scene file.
%   @param isShow whether or not to display the output image in a figure
%
% @details
% Invoke the PBRT renderer on the given .pbrt @a sceneFile.  This function
% handles some of the boring details of invoking PBRT with Matlab's unix()
% command.
%
% @details
% if @a isShow is provided and true, displays an sRGB representation of the
% output image in a new figure.
%
% @details
% Returns the numeric status code and text output from the unix() command.
% Also returns the name of the expected output file from PBRT.
%
% Usage:
%   [status, result, output] = RunPBRT(sceneFile, isShow)
%
% @ingroup Utilities
function [status, result, output] = RunPBRT(sceneFile, isShow)

if nargin < 2 || isempty(isShow)
    isShow = false;
end

InitializeRenderToolbox();

%% Where to get/put the input/output
[scenePath, sceneBase] = fileparts(sceneFile);
output = fullfile(scenePath, [sceneBase '.dat']);

%% Invoke PBRT.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% find the PBRT executable
pbrt = getpref('PBRT', 'executable');
renderCommand = sprintf('%s --outfile %s %s', pbrt, output, sceneFile);
fprintf('%s\n', renderCommand);

% run PBRT in the destination folder to capture all ouput there
originalFolder = pwd();
if exist(scenePath, 'dir')
    cd(scenePath);
end
[status, result] = unix(renderCommand);
cd(originalFolder)

% restore the library search path
setenv(libPathName, originalLibPath);

%% Show a warning or figure?
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneBase)
    
elseif isShow
    multispectral = ReadDAT(output);
    S = getpref('PBRT', 'S');
    toneMapFactor = 10;
    isScale = true;
    sRGB = MultispectralToSRGB(multispectral, S, toneMapFactor, isScale);
    ShowXYZAndSRGB([], sRGB, sceneBase);
end
