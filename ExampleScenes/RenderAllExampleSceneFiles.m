%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render example scene files that were generated previously.
%
% @details
% This script is useful for rendering lots and lots of scene files that
% were generated previouslt with  MakeAllExampleSceneFiles().  In some
% production settings, like  computer clusters, it's useful to have a
% top-level script that takes no arguments, like this one.  You should edit
% parameter values in this script to agree with your system.
%

clear;
clc;

% choose global RenderToolbox3 behavior
setpref('RenderToolbox3', 'isParallel', true);
setpref('RenderToolbox3', 'isDryRun', false);
setpref('RenderToolbox3', 'isReuseSceneFiles', true);

% dry run on example scenes puts scene files in tempFolder
outputRoot = '/Users/ben/epic-scene-test';
outputName = '';
exampleFolder = 'CoordinatesTest';
results = TestAllExampleScenes(outputRoot, outputName, exampleFolder);