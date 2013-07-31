%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Run all "Make*" executive scripts in the ExampleScenes/ folder.
%   @param outputRoot base path where to save output data
%   @param makeFunctions cell array of executive scripts to invoke
%
% @details
% By default, renders example scenes by invoking all of the "Make*"
% executive sripts found within the ExampleScenes/ folder.  If @a
% makeFunctions is provided, it must be a cell array of executive scripts
% to invoke instead.
%
% @details
% @a outputRoot is the base path under which all output data should be
% saved.  If outputRoot is missing or empty, uses default folders from
% getpref('RenderToolbox3').
%
% @details
% Returns a struct with information about each executive script, such as
% whether the script executed successfully, any Matlab error that was
% thrown, and when the script completed.
%
% @details
% Saves a mat-file with several variables about test parameters and
% results:
%   - outputRoot, the given @a outputRoot
%   - makeFunctions, the given @a makeFunctions
%   - hints, RenderToolbox3 options, as returned from GetDefaultHints()
%   - results, the returned struct of results about rendering scripts
% .
% @details
% The mat-file will be saved in the given @a outputRoot folder.  It will
% have a name that that includes the name of this m-file, plus the date and
% time.  If @a outputRoot is omited, uses getpref('RenderToolbox3',
% 'outputDataFolder').
%
% @details
% Usage:
%   results = TestAllExampleScenes(outputRoot, makeFunctions)
%
% @ingroup ExampleScenes
function results = TestAllExampleScenes(outputRoot, makeFunctions)

if nargin < 1  || isempty(outputRoot)
    outputRoot = '';
end

if nargin < 2 || isempty(makeFunctions)
    % find all the m-functions named "Make*", in ExampleScenes/
    makePattern = 'Make\w+\.m';
    exampleRoot = fullfile(RenderToolboxRoot(), 'ExampleScenes');
    makeFunctions = FindFiles(exampleRoot, makePattern);
    
    % exclude functions that don't work yet
    notWorkingPath = fullfile(exampleRoot, 'NotYetWorking');
    notWorkingFunctions = FindFiles(notWorkingPath, makePattern);
    makeFunctions = setdiff(makeFunctions, notWorkingFunctions);
end

testTic = tic();

% allocate a struct for test results
results = struct( ...
    'makeFile', makeFunctions, ...
    'isSuccess', false, ...
    'error', [], ...
    'elapsed', []);

% remember original folder and preferences
%   since they change during testing
originalFolder = pwd();
originalPrefs = getpref('RenderToolbox3');

% choose where to write all outputs
if ~isempty(outputRoot)
    setpref('RenderToolbox3', ...
        'tempFolder', fullfile(outputRoot, 'temp'));
    setpref('RenderToolbox3', ...
        'outputDataFolder', fullfile(outputRoot, 'data'));
    setpref('RenderToolbox3', ...
        'outputImageFolder', fullfile(outputRoot, 'images'));
end

% turn of warnings about scaling for this run, so as not
% to alarm the user of the test program.
warnState(1) = warning('off','RenderToolbox3:PBRTXMLIncorrectlyScaled');
warnState(2) = warning('off','RenderToolbox3:DefaultParamsIncorrectlyScaled');

% try to render each example scene
for ii = 1:numel(makeFunctions)
    
    [makePath, makeName, makeExt] = fileparts(makeFunctions{ii});
    
    try
        % make the example scene!
        evalin('base', 'clear');
        evalin('base', ['run ' fullfile(makePath, makeName)]);
        results(ii).isSuccess = true;
        
    catch err
        % trap the error
        results(ii).isSuccess = false;
        results(ii).error = err;
    end
    
    % sometimes the Matlab java heap files up.  If
    % the jheapcl function is on the path, call it
    % to clear the Java heap.  This may help a bit.
    if (exist('jheapcl','file'))
        jheapcl;
    end
    
    % close figures so as to avoid filling up 
    % memory
    close all;
    
    % keep track of timing
    results(ii).elapsed = toc(testTic);
end

% restore warning state
for ii = 1:length(warnState)
    warning(warnState(ii).state,warnState(ii).identifier);
end

% how did it go?
isExampleSuccess = [results.isSuccess];
fprintf('\n%d scenes succeeded.\n\n', sum(isExampleSuccess));
for ii = find(isExampleSuccess)
    disp(sprintf('%d %s', ii, results(ii).makeFile))
end

fprintf('\n%d scenes failed.\n\n', sum(~isExampleSuccess));
for ii = find(~isExampleSuccess)
    disp('----')
    disp(sprintf('%d %s', ii, results(ii).makeFile))
    disp(results(ii).error)
    disp(' ')
end

toc(testTic)

% restore original folder and preferences
cd(originalFolder)
setpref('RenderToolbox3', ...
    fieldnames(originalPrefs), struct2cell(originalPrefs));

%% Save lots of results to a .mat file.
hints = GetDefaultHints();
if isempty(outputRoot)
    resultsPath = getpref('RenderToolbox3', 'outputDataFolder');
else
    resultsPath = outputRoot;
end

if ~isempty(resultsPath) && ~exist(resultsPath, 'dir')
    mkdir(resultsPath);
end
baseName = mfilename();
dateTime = datestr(now(), 30);
resultsBase = sprintf('%s-%s', baseName, dateTime);
resultsFile = fullfile(resultsPath, resultsBase);
save(resultsFile, 'outputRoot', 'makeFunctions', 'results', 'hints');