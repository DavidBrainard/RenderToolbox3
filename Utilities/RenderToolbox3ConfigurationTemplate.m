%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Set up machine-specific RenderToolbox3 configuration, like file paths.
%
% This script is intended as an example only.  You should make a copy of
% this script and save it in a folder separate from RenderToolbox3.  You
% should customize your copy with values that are specific to your machine.
%
% The goal of this script is to set RenderToolbox3 preference values that
% you want to use for your machine.  These include file paths where
% RenderToolbox3 should look for renderers, and where it should write
% ouptut files.
%
% When you first install RenderToolbox3, you should copy this script,
% customize it, and run it.  You can also run it any time you want to make
% sure your RenderToolbox3 preferences are correct.
%
% After you run this script, you can run RenderToolbox3InstallationTest()
% to verify that your configuration is good.
%
% You can also run TestAllExampleScenes(), followed by
% CompareAllExampleScenes() to check example renderings for correctness.
%

%% Start with RenderToolbox3 "fresh out of the box" configuration.
InitializeRenderToolbox(true);


%% Tell RenderToolbox3 where to save outputs.
% choose Matlab's default "user folder"
myFolder = fullfile(GetUserFolder(), 'render-toolbox');

% or choose any folder that you want RenderToolbox3 to write to
%myFolder = 'choose/your/output/folder';

% save folders for three kinds of output
setpref('RenderToolbox3', 'tempFolder', fullfile(myFolder, 'temp'));
setpref('RenderToolbox3', 'outputDataFolder', fullfile(myFolder, 'data'));
setpref('RenderToolbox3', 'outputImageFolder', fullfile(myFolder, 'images'));


%% Tell RenderToolbox3 where you installed PBRT.
% use the default path for PBRT
myPBRT = '/usr/local/bin/pbrt';

% or choose where you installed PBRT
%myPBRT = '/my/path/for/pbrt';

% save the path for PBRT
setpref('PBRT', 'executable', myPBRT);


%% Tell RenderToolbox3 where you installed Mitsuba.
if ismac()
    % on OS X, Mitsuba is an "app bundle"
    
    % use the default app bundle path
    myMistubaApp = '/Applications/Mitsuba.app';
    
    % or choose where you installed Mitsuba
    %myMistubaApp = '/my/path/for/Mitsuba.app';
    
    % don't change these--
    %   they tell RenderToolbox3 where to look inside the app bundle
    myMistubaExecutable = 'Contents/MacOS/mitsuba';
    myMistubaImporter = 'Contents/MacOS/mtsimport';
    
else
    % on Linux and Windows, Mitsuba has separate executable files
    
    % use the default executable paths
    myMistubaExecutable = '/usr/local/bin/mitsuba';
    myMistubaImporter = '/usr/local/bin/mtsimport';
    
    % or choose where you installed Mitsuba
    %myMistubaExecutable = '/my/path/for/mitsuba';
    %myMistubaImporter = '/my/path/for/mtsimport';
    
    % don't change this--
    %   the "app" path is only meaningful for OS X
    myMistubaApp = '';
end

% save paths for Mitsuba
setpref('Mitsuba', 'app', myMistubaApp);
setpref('Mitsuba', 'executable', myMistubaExecutable);
setpref('Mitsuba', 'importer', myMistubaImporter);


%% Optional: choose PBRT spectral sampling.
% if you built PBRT with your own custom spectral sampling
% then uncomment these lines and edit the "S" value
% see https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands

% use the default spectral sampling
%S = [400 10 31];

% or chose your custom sampling
%S = [371 6 77];

% save PBRT's spectral sampling
%setpref('PBRT', 'S', S);
