%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Find all "Make*" functions in the ExampleScenes/ folder.  Run them all to
% make sure they work.
%

function results = TestAllExampleScenes()

% find all the m-functions named "Make*", in ExampleScenes/
exampleFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');
makeFunctions = FindFiles(exampleFolder, 'Make\w+\.m');

% allocate a struct for test results
results = struct( ...
    'sceneFunction', makeFunctions, ...
    'isSuccess', false, ...
    'error', []);

% try to render each example scene
for ii = 1:numel(makeFunctions)
    % prepare for the next scene
    evalin('base', 'clear');
    
    try
        % make the example scene!
        [makePath, makeName, makeExt] = fileparts(makeFunctions{ii});
        makeCommand = fullfile(makePath, makeName);
        evalin('base', ['run ' makeCommand]);
        results(ii).isSuccess = true;
        
    catch err
        % the scene failed
        results(ii).isSuccess = false;
        results(ii).error = err;
    end
end

% how did it go?
isExampleSuccess = [results.isSuccess];
fprintf('\n%d scenes succeeded.\n\n', sum(isExampleSuccess));
for ii = find(isExampleSuccess)
    disp(results(ii).sceneFunction)
end

fprintf('\n%d scenes failed.\n\n', sum(~isExampleSuccess));
for ii = find(~isExampleSuccess)
    disp('----')
    disp(results(ii).sceneFunction)
    disp(results(ii).error)
    disp(' ')
end