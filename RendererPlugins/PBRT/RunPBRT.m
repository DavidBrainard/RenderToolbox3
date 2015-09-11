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
function [status, result, output, oi] = RunPBRT(sceneFile, hints, oiParams, pbrt)

if nargin < 2 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if nargin < 4 || isempty(pbrt)
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

% Copy normal PBRT file to the sceneCopy folder
[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
sceneCopy = fullfile(copyDir, [sceneBase, sceneExt]);
fprintf('PBRT needs to copy %s \n  to %s\n', sceneFile, sceneCopy);
[isSuccess, message] = copyfile(sceneFile, sceneCopy, 'f');

% Copy depth PBRT file to the sceneCopy folder
sceneCopyDepth = fullfile(copyDir, [sceneBase '_depth' sceneExt]);
[d,n,e] = fileparts(sceneFile);
sceneFileDepth = fullfile(d,[n '_depth' e]);
fprintf('PBRT needs to copy %s \n  to %s\n', sceneFileDepth, sceneCopyDepth);
[isSuccess, message] = copyfile(sceneFileDepth, sceneCopyDepth, 'f');

renderings = GetWorkingFolder('renderings', true, hints);
output = fullfile(renderings, [sceneBase '.dat']);

% Create a separate output folder for the depth. We need this so the output
% from the first render pass isn't overwritten during the second render
% pass. This folder is only temporary and gets cleared every run.
tempDepthDir = fullfile(renderings,'depthTemp');
if exist(tempDepthDir) % Clear the folder first (I encountered some bugs when overwriting files)
    rmdir(tempDepthDir,'s');
end
mkdir(tempDepthDir);
% ".dat" output in the depth folder, which is given to PBRT as the output
outputTempDir = fullfile(tempDepthDir, [sceneBase '.dat']);

%% Invoke PBRT.
    
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

renderCommand = sprintf('%s --outfile %s %s', pbrt.executable, output, sceneCopy);
fprintf('%s\n', renderCommand);
[status, result] = RunCommand(renderCommand, hints);
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneBase)
end

%% Run PBRT a second time to get depth maps

renderCommand = sprintf('%s --outfile %s %s', pbrt.executable, outputTempDir, sceneCopyDepth);
fprintf('%s\n', renderCommand);
[status, result] = RunCommand(renderCommand, hints);

%% Show a warning or figure?
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneBase)
    
elseif hints.isPlot
    multispectral = ReadDAT(output);
    toneMapFactor = 10;
    isScale = true;
    sRGB = MultispectralToSRGB(multispectral, pbrt.S, toneMapFactor, isScale);
    ShowXYZAndSRGB([], sRGB, sceneBase);
end

%% Copy files and create oi

% Create oi object
oi = RTB_pbrt2oi(output,oiParams,hints);
oi = oiSet(oi,'name',sceneBase);

% Copy depth files to original directory
outputDepth = fullfile(tempDepthDir, [sceneBase '_DM.dat']); % The *_DM.dat output specifically
copyfile(outputDepth,renderings);
fprintf('Depth image was copied from: \n %s \n to \n %s \n',outputDepth, renderings);

% Read depth map
dMapFile = fullfile(renderings, [sceneBase '_DM.dat']);
depthMap = RTB_ReadDepthMapFile(dMapFile, [hints.imageHeight hints.imageWidth]);

% Save depth map as an image
imageDir = fullfile(hints.workingFolder,hints.recipeName,'images',hints.renderer);
if ~exist(imageDir)
    mkdir(imageDir)
end
imageFile = fullfile(imageDir,[sceneBase '_depth.png']);
figure(10);
imagesc(depthMap); colorbar; colormap(flipud(gray));
axis image;
title(sceneBase);
print(imageFile,'-dpng')

% Set depth in oi
oi = oiSet(oi, 'depthmap', depthMap);

% restore the library search path
setenv(libPathName, originalLibPath);


