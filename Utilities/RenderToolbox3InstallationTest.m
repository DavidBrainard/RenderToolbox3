%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make sure a new RenderToolbox3 installation is working.
%   @param referenceRoot path to RenderTooblox3 reference data
%
% @details
% Initialize RenderToolbox3 after installation and then put it through some
% basic tests.  If this function runs properly, you're off to the races.
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

if nargin < 1
    referenceRoot = '';
end

renderResults = [];
comparison = [];

%% Check working folder for write permission.
workingFolder = GetWorkingFolder();
fprintf('\nChecking working folder:\n');

% make sure the folder exists
if exist(workingFolder, 'dir')
    fprintf('  folder exists: %s\n', workingFolder);
    fprintf('  OK.\n');
else
    fprintf('  creating folder: %s\n', workingFolder);
    [status, message] = mkdir(workingFolder);
    if 1 == status
        fprintf('  OK.\n');
    else
        error('Could not create folder %s:\n  %s\n', ...
            workingFolder, message);
    end
end

% make sure Matlab can write to the folder
testFile = fullfile(workingFolder, 'test.txt');
fprintf('Trying to write: %s\n', testFile);
[fid, message] = fopen(testFile, 'w');
if fid < 0
    error('Could not write to folder %s:\n  %s\n', ...
        workingFolder, message);
end
fclose(fid);
delete(testFile);
fprintf('  OK.\n');

%% Locate Mitsuba and pbrt executables.
if ismac()
    % locate Mitsuba.app
    execPrefs(1).prefGroup = 'Mitsuba';
    execPrefs(1).prefName = 'app';
    
    % locate pbrt
    execPrefs(2).prefGroup = 'PBRT';
    execPrefs(2).prefName = 'executable';
    
else
    % locate Mitsuba executable
    execPrefs(1).prefGroup = 'Mitsuba';
    execPrefs(1).prefName = 'executable';
    
    % locate Mitsuba importer
    execPrefs(2).prefGroup = 'Mitsuba';
    execPrefs(2).prefName = 'importer';
    
    % locate pbrt
    execPrefs(3).prefGroup = 'PBRT';
    execPrefs(3).prefName = 'executable';
end

% locate each executable or let the user choose
for ii = 1:numel(execPrefs)
    % get the default executable path from preferences
    execFile = getpref(execPrefs(ii).prefGroup, execPrefs(ii).prefName);
    
    fprintf('\nChecking %s %s:\n', ...
        execPrefs(ii).prefGroup, execPrefs(ii).prefName);
    
    % make sure the executable exists
    if exist(execFile, 'file')
        fprintf('  %s exists: %s\n', execPrefs(ii).prefName, execFile);
        fprintf('  OK.\n');
    else
        error('Could not find %s %s:\n  %s\n', ...
            execPrefs(ii).prefGroup, execPrefs(ii).prefName, execFile);
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
    localRoot = GetWorkingFolder('renderings');
    fprintf('\nComparing local renderings\n  %s\n', localRoot);
    fprintf('with reference renderings\n  %s\n', referenceRoot);
    fprintf('You should see several more figures.\n\n');
    comparison = CompareAllExampleScenes(localRoot, referenceRoot, '', 2);
else
    fprintf('\nNo referenceRoot provided.  Local renderings\n');
    fprintf('will not be compared with reference renderings.\n');
end
