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

%% Check output folders for write permission.
% locate and test 3 different folders
outPrefs(1).prefGroup = 'RenderToolbox3';
outPrefs(1).prefName = 'tempFolder';
outPrefs(2).prefGroup = 'RenderToolbox3';
outPrefs(2).prefName = 'outputDataFolder';
outPrefs(3).prefGroup = 'RenderToolbox3';
outPrefs(3).prefName = 'outputImageFolder';

% try to write into each folder
for ii = 1:numel(outPrefs)
    outPath = getpref(outPrefs(ii).prefGroup, outPrefs(ii).prefName);
    
    fprintf('\nChecking %s:\n', outPrefs(ii).prefName);
    
    % make sure the folder exists
    if exist(outPath, 'dir')
        fprintf(' folder exists: %s\n', outPath);
    else
        fprintf('  creating folder: %s\n', outPath);
        [status, message] = mkdir(outPath);
        if 1 == status
            fprintf('  OK.\n');
        else
            error('Could not create folder %s:\n  %s\n', ...
                outPath, message);
        end
    end
    
    % make sure Matlab can write to the folder
    fprintf('Trying to write to %s:\n', outPrefs(ii).prefName);
    testFile = fullfile(outPath, 'test.txt');
    [fid, message] = fopen(testFile, 'w');
    if fid < 0
        error('Could not write to folder %s:\n  %s\n', ...
            outPath, message);
    end
    fclose(fid);
    delete(testFile);
    fprintf('  OK.\n');
end

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
        fprintf(' %s exists: %s\n', execPrefs(ii).prefName, execFile);
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
    localRoot = GetOutputPath('outputDataFolder');
    fprintf('\nComparing local renderings\n  %s\n', localRoot);
    fprintf('with reference renderings\n  %s\n', referenceRoot);
    fprintf('You should see several more figures.\n\n');
    comparison = CompareAllExampleScenes(localRoot, referenceRoot, '', 2);
else
    fprintf('\nNo referenceRoot provided.  Local renderings\n');
    fprintf('will not be compared with reference renderings.\n');
end
