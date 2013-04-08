%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the PBRT renderer.
%   @param sceneFile filename or path of a .pbrt scene file.
%
% @details
% Invoke the PBRT renderer on the given .pbrt @a sceneFile.  This function
% handles some of the boring details of invoking PBRT with Matlab's unix()
% command.
%
% @details
% Returns the numeric status code and text output from the unix() command.
% Also returns the name of the expected output file from PBRT.
%
% Usage:
%   [status, result, output] = RunPBRT(sceneFile)
%
% @ingroup Utilities
function [status, result, output] = RunPBRT(sceneFile)

InitializeRenderToolbox();

%% Where to get/put the input/output
[scenePath, sceneBase] = fileparts(sceneFile);
output = fullfile(scenePath, [sceneBase '.dat']);

%% Invoke PBRT.
pbrt = getpref('PBRT', 'executable');
renderCommand = sprintf('%s --outfile %s %s', pbrt, output, sceneFile);
fprintf('%s\n', renderCommand);
[status, result] = unix(renderCommand);
if status ~= 0
    warning(result)
    warning('Could not render scene "%s".', sceneBase)
end