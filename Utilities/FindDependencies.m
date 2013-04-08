%% Which Brainard Lab Toolbox functions does Render Toolbox 3 use?
clear;

%% record function calls with the profiler
scene = 'MakeMaterialSphere';
profile('on', '-history')

% run through representative example scenes
MakeInterreflectionFigure;
MakeSimpleSphereFigure;
MakeMaterialSphere;
MakeSpectralIllusion;

% what did the profiler see?
data = profile('info');
profile('off');

% save results of the run-through, which takes a while
save('FindDependencies-data.mat', 'data');

%% Look for dependencies that match a file path pattern.
load('FindDependencies-data.mat');

pathPattern = 'stats';
nFunctions = numel(data.FunctionTable);
isBrainard = false(1, nFunctions);
for ii = 1:nFunctions
    filePath = data.FunctionTable(ii).FileName;
    isMatch(ii) = ~isempty(regexp(filePath, pathPattern, 'once'));
end

%% Summarize the dependencies.
clc;
nMatches = sum(isMatch);
disp(sprintf('\nFound %d functions matching "%s":\n', ...
    nMatches, pathPattern))

for ii = find(isMatch)
    disp(data.FunctionTable(ii).FileName)
    parentFunctions = data.FunctionTable(ii).Parents;
    if ~isempty(parentFunctions)
        disp('called by')
        for pp = 1:numel(parentFunctions)
            name = data.FunctionTable(parentFunctions(pp).Index).FileName;
            disp(['  ' name])
        end
    end
    disp(' ')
end