%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Generate scene files for all example scenes, but don't render them.
%
% @details
% This script is useful for generating lots and lots of scene files, to be
% rendererd later with RenderAllExampleScenes().  In some production
% settings, like computer clusters, it's useful to have a top-level script
% that takes no arguments, like this one.  You should edit parameter values
% in this script to agree with your system.
%
% @details
% For Mitsuba scene files, this script must be run from a machine that has
% OpenGL support.  This might not be the case for computer cluster worker
% nodes.
%

clear;
clc;

% choose global RenderToolbox3 behavior
setpref('RenderToolbox3', 'isParallel', false);
setpref('RenderToolbox3', 'isDryRun', true);
setpref('RenderToolbox3', 'isReuseSceneFiles', false);

% dry run on example scenes puts scene files in tempFolder
outputRoot = '/home2/brainard/test/epic-scene-test';
outputName = '';
exampleFolder = '';
results = TestAllExampleScenes(outputRoot, outputName, exampleFolder);

% make results available for later review
if ~exist(outputRoot, 'dir')
    mkdir(outputRoot);
end
resultsFile = fullfile(outputRoot, 'MakeAllExampleSceneFiles.mat');
save(resultsFile);
