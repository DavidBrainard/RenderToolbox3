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
if(hints.dockerFlag == 1)
    % We assume docker is installed on this system and we execute the
    % function in a docker container
    s = system('which docker');
    if s
        warning('Docker not found! \n (OSX) Are you sure you''re running MATLAB in a Docker Quickstart Terminal? ');
        % TODO: add in option to run on local if docker is not found
    else
        % Initialize the docker container
        dHub = 'vistalab/pbrt';  % Docker container at dockerhub
        fprintf('Checking for most recent docker container\n');
        system(sprintf('docker pull %s',dHub));
        
        % Start the docker container that runs pbrt
        dCommand = 'pbrt';       % Command run in the dockers
        [~,n,e] = fileparts(sceneCopy); % Get name of pbrt input file
        [~,outstem,outext] = fileparts(output); % Get name of output file
        
        % We need this line because RTB wants to place the output in
        % renderings and not just the recipe folder
        outputFile = fullfile('renderings','PBRT',[outstem outext]);
        
        % rm = clears the container when it is finished running
        % -t = terminal to grab tty output
        % -i = interactive (not sure it's needed)
        cmd = sprintf('docker run -t -i --rm -v %s:/data %s %s /data/%s --outfile /data/%s',copyDir,dHub,dCommand,[n,e],outputFile);

        % Execute the docker call
        [status,result] = system(cmd);
        if status, error('Docker execution failure %s\n',result);
        else disp('Docker appears to have run succesfully')
        end
        % disp(r);

        % Tell the user where the result iss
        fprintf('Wrote: %s\n',outputFile);
    end
else
    % Use local PBRT
    % set the dynamic library search path
    [newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();
    
    % find the PBRT executable
    renderCommand = sprintf('%s --outfile %s %s', pbrt.executable, output, sceneCopy);
    fprintf('%s\n', renderCommand);
    [status, result] = RunCommand(renderCommand, hints);
    
    % restore the library search path
    setenv(libPathName, originalLibPath);
end
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
