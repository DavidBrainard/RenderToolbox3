%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make sure a new RenderToolbox3 installation is working.
%   @param referenceRoot path to RenderTooblox3 reference data
%
% @details
% Initialize RenderToolbox3 after installation and then put it through some
% basic tests.  If this functin runs properly, you're off to the races.
%
% @details
% If @a referenceRoot is provided, it must be the path to a set of
% RenderToolbox3 reference data.  Rendering produced locally will be
% compared to renderings in the reference data set. You can download
% reference data set or clode the reference data repository from GitHub:
% <a href="https://github.com/DavidBrainard/RenderToolbox3-ReferenceData">RenderToolbox3-ReferenceData</a>.
%
% @details
% Returns a struct of results from rendering test scenes.  If @a
% referenceRoot is provided, also returns a struct of comparisons between
% local renderings and reference renderings.
%
% @details
% Usage:
%   [renderResults, comparison] = RenderToolbox3InstallationTest(referenceRoot)
%
% @ingroup Utilities
function [renderResults, comparison] = RenderToolbox3InstallationTest(referenceRoot)
% 5/30/13  ncp  Wrote.
% 5/31/13  dhb  Expanded and tweaked.
% 6/6/13   bsh  Changed to RenderToolbox3 code style.

if nargin < 1
    referenceRoot = '';
end

renderResults = [];
comparison = [];

%% Get a user folder with write permission.
% get the default user folder, or let the user choose
userFolder = GetUserFolder();
if isempty(userFolder) || ~ischar(userFolder)
    title = 'Choose a folder that you own.';
    userFolder = uigetdir(pwd(), title);
end

if isempty(userFolder) || ~ischar(userFolder)
    error('You must choose a folder for RenderToolbox3.');
end

% make sure Matlab can write to the folder
fprintf('\nChecking user folder for write permission:\n  %s\n', userFolder);
testFile = fullfile(userFolder, 'test.txt');
[fid, message] = fopen(testFile, 'w');
if fid < 0
    error('Could not write to folder:\n  %s\n', message)
end
fclose(fid);
delete(testFile);
fprintf('  OK.\n');

%% Initialize RenderToolbox3 preferences.
InitializeRenderToolbox(true);

%% Locate Mitsuba and pbrt executables.
if ismac()
    % must locate Mitsuba.app
    executable(1).prefGroup = 'Mitsuba';
    executable(1).prefName = 'app';
    executable(1).fileName = 'Mitsuba.app';
    
    % locate Mitsuba executables relative to the app
    setpref('Mitsuba', 'executable', 'Contents/MacOS/mitsuba');
    setpref('Mitsuba', 'importer', 'Contents/MacOS/mtsimport');
    
    % must locate pbrt
    executable(2).prefGroup = 'PBRT';
    executable(2).prefName = 'executable';
    executable(2).fileName = 'pbrt';
    
else
    % must locate Mitsuba executable
    executable(1).prefGroup = 'Mitsuba';
    executable(1).prefName = 'executable';
    executable(1).fileName = 'mitsuba';
    
    % must locate Mitsuba importer
    executable(2).prefGroup = 'Mitsuba';
    executable(2).prefName = 'importer';
    executable(2).fileName = 'mtsimport';
    
    % there is no Mitsuba.app
    setpref('Mitsuba', 'app', '');
    
    % must locate pbrt
    executable(3).prefGroup = 'PBRT';
    executable(3).prefName = 'executable';
    executable(3).fileName = 'pbrt';
end

% locate each executable or let the user choose
for ii = 1:numel(executable)
    % get the default executable path from preferences
    execPath = getpref(executable(ii).prefGroup, executable(ii).prefName);
    if ~exist(execPath)
        title = sprintf('Choose the %s %s: "%s"', ...
            executable(ii).prefGroup, ...
            executable(ii).prefName, ...
            executable(ii).fileName);
        [getFile, getPath] = uigetfile('*.*', title, 'MultiSelect', 'off');
        execPath = fullfile(getPath, getFile);
    end
    
    if isempty(execPath) || ~ischar(execPath) || ~exist(execPath)
        error('Could not find any %s %s', ...
            executable(ii).prefGroup, ...
            executable(ii).prefName)
    else
        
        fprintf('\nFound %s %s:\n  %s\n', ...
            executable(ii).prefGroup, ...
            executable(ii).prefName, ...
            execPath);
        setpref(executable(ii).prefGroup, executable(ii).prefName, execPath);
    end
end

%% Render a few example scenes.
testScenes = { ...
    'MakeCoordinatesTest.m', ...
    'MakeCheckerboard.m', ...
    'MakeMaterialSphere.m'};

fprintf('\nTesting rendering with %d example scripts.\n', numel(testScenes));
fprintf('You should see several figures with rendered images.\n\n');
renderResults = TestAllExampleScenes([], testScenes);

if all([renderResults.isSuccess])
    fprintf('\nYour RenderToolbox3 installation seems to be working!\n');
end

%% Compare renderings to reference renderings?
if ~isempty(referenceRoot)
    localRoot = GetOutputPath('outputDataFolder');
    fprintf('\nComparing local renderings\n  %s\n', localRoot);
    fprintf('with reference renderings\n  %s\n', referenceRoot);
    fprintf('You should see several more figures.\n\n');
    comparison = CompareAllExampleScenes(localRoot, referenceRoot, '', 2);
end
