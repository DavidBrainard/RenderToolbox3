%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the PBRT renderer.
%   @param sceneFile filename or path of a PBRT-native text scene file.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%   @param pbrt struct of pbrt config., see getpref("pbrt")
%
% @details
% Invoke the PBRT renderer on the given PBRT-native text @a sceneFile.
% This function handles some of the boring details of invoking PBRT with
% Matlab's unix() command.
%
% @details
% if @a hints.isPlot is provided and true, displays an sRGB representation
% of the output image in a new figure.
%
% @details
% RenderToolbox3 assumes that relative paths in scene files are relative to
% @a hints.workingFolder.  But PBRT assumes that relative paths are
% relative to the folder that contains the scene file.  These are usually
% different folders.  This function copies @a sceneFile into @a
% hints.workingFolder so that relative paths will work using the
% RenderTooblox3 convention.
%
% @details
% Returns the numeric status code and text output from PBRT.
% Also returns the name of the expected output file from PBRT.
%
% Usage:
%   [status, result, output] = RunPBRT(sceneFile, hints)
%
% @ingroup Utilities
function [status, result, output] = RunPBRT(sceneFile, hints, pbrt)

if nargin < 2 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if nargin < 3 || isempty(pbrt)
    pbrt = getpref('PBRT');
end

InitializeRenderToolbox();

%% Where to get/put the input/output
% copy scene file to working folder
% so that PBRT can resolve relative paths from there
if IsStructFieldPresent(hints, 'workingFolder')
    copyDir = GetWorkingFolder('', false, hints);
else
    warning('RenderToolbox3:NoWorkingFolderGiven', ...
        'hints.workingFolder is missing, using pwd() instead');
    copyDir = pwd();
end
[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
sceneCopy = fullfile(copyDir, [sceneBase, sceneExt]);
fprintf('PBRT needs to copy %s \n  to %s\n', sceneFile, sceneCopy);
[isSuccess, message] = copyfile(sceneFile, sceneCopy, 'f');

renderings = GetWorkingFolder('renderings', true, hints);
output = fullfile(renderings, [sceneBase '.dat']);

%% Invoke PBRT.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% find the PBRT executable
renderCommand = sprintf('%s --outfile %s %s', pbrt.executable, output, sceneCopy);
fprintf('%s\n', renderCommand);
[status, result] = RunCommand(renderCommand, hints);

% restore the library search path
setenv(libPathName, originalLibPath);

%% Show a warning or figure?
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneBase)
    
elseif hints.isPlot
    multispectral = ReadDAT(output, pbrt.S(3));
    toneMapFactor = 10;
    isScale = true;
    sRGB = MultispectralToSRGB(multispectral, pbrt.S, toneMapFactor, isScale);
    ShowXYZAndSRGB([], sRGB, sceneBase);
end
