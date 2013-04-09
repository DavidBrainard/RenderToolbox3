%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render a scene multiple times, with changing varibles.
%   @param sceneFile file name or path of a Collada scene file
%   @param conditionsFile file name or path of a conditions file
%   @param mappingsFile file name or path of a mappings file
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Renders a scene multiple times, with variable values changing each time.
% Uses <a
% href="group___scene_d_o_m.html">Scene DOM</a> functions and <a
% href="group___scene_targets.html">Scene Target</a> functions to apply
% variable values to the Collada @a sceneFile and renderer-specific
% adjustments files.  Values for each condition come from the given @a
% conditionsFile. The @a mappingsFile specifies how to apply variables to
% the scene.
%
% @details
% @a sceneFile must be a Collada XML scene file.  @a sceneFile may be left
% empty, if the @a conditionsFile contains a 'sceneFile' variable.
%
% @details
% @a conditionsFile must be a RenderToolbox3 <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Conditions-File-Format">Conditions File</a>.
% @a conditionsFile may be omitted or left empty, if the scene
% is to be rendered only once.
%
% @details
% @a mappingsFile must be a RenderToolbox3 <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Mappings-File-Format">Mappings File</a>.
% @a mappingsFile may be omitted or left empty, if the scene
% is to be rendered only once, or if the @a conditionsFile contains a
% 'mappingsFile' variable.
%
% @details
% @a hints may be a struct with options that affect the rendering process,
% as returned from GetDefaultHints().  If @a hints is omitted, default
% options are used.  For example:
%   - @a hints.renderer specifies which renderer to use.
%   - @a hints.isParallel specifies whether to render in a "parfor" loop
%   .
% @details
% Renders the scene one or more times, and writes a .mat file each time.
% The .mat file will contain multi-spectral renderer output in two
% variables:
%   - multispectralImage - matrix of multispectral image data with size
%   [height width n]
%   - S - spectral plane description, [start delta n]
%   .
% where height and width are pixel image dimensions and n is the number of
% spectral bands in the image.  See the RenderToolbox3 wikiw for more about
% <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands">Spectrum Bands</a>.
%
% @details
% The .mat file will also contain variables with data about how the scene
% was rendered:
%   - sceneFile - the given @a sceneFile, if any
%   - conditionsFile - the given @a conditionsFile, if any
%   - mappingsFile - the given @a mappingsFile, if any
%   - hints - the given @a hints struct, or default hints struct
%   - versionInfo - struct of version information about RenderToolbox3 and
%   its dependencies
% .
%
% @details
% The multi-spectral data in each .mat file will be scaled into radiance
% units using funtions like PBRTDataToRadiance() and
% MitsubaDataToRadiance().  These rely on pre-computed renderer-specific
% scale factors computed in ComputeRadiometricScaleFactors().
%
% @details
% By default, each .mat file will have the same base name as @a sceneFile,
% plus a numeric suffix.  If @a conditionsFile contains an 'imageName'
% variable, each ouput file be named with the value of 'imageName'.
%
% @details
% Returns a cell array of string output file names, or an empty cell if no
% output.
%
% @details
% Usage:
%   outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints)
%
% @ingroup BatchRender
function outFiles = BatchRender(sceneFile, conditionsFile, mappingsFile, hints)

InitializeRenderToolbox();

%% Parameters
if nargin < 1 || isempty(sceneFile)
    sceneFile = '';
end

if nargin < 2 || isempty(conditionsFile)
    conditionsFile = '';
end

if nargin < 3 || isempty(mappingsFile)
    mappingsFile = fullfile( ...
        RenderToolboxRoot(), 'RenderData', 'DefaultMappings.txt');
end

if nargin < 4
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Read conditions file into memory.
if isempty(conditionsFile)
    % no conditions
    %   do a single rendering
    nConditions = 1;
    varNames = {};
    varValues = {};
    
else
    % read variables and values for each condition
    [varNames, varValues] = ParseConditions(conditionsFile);
    
    % choose which conditions to render
    if isempty(hints.whichConditions)
        hints.whichConditions = 1:size(varValues, 1);
    end
    nConditions = numel(hints.whichConditions);
    varValues = varValues(hints.whichConditions,:);
end

%% Create output folders that will be used during rendering.
% determine which renderers will be used
isMatch = strcmp('renderer', varNames);
if any(isMatch)
    renderers = varValues{:, find(isMatch, 1, 'first')};
else
    renderers = {hints.renderer};
end

% each renderer needs a temp folder and an output folder
nRenderers = numel(renderers);
tempFolders = cell(1, nRenderers);
for ii = 1:numel(renderers)
    renderer = renderers{ii};
    tempFolder = fullfile(hints.tempFolder, renderer);
    if ~exist(tempFolder, 'dir')
        mkdir(tempFolder);
    end
    tempFolders{ii} = tempFolder;
    
    rendererOutputPath = fullfile(hints.outputDataFolder, renderer);
    if ~exist(rendererOutputPath, 'dir')
        mkdir(rendererOutputPath);
    end
end

%% Render each condition.
% save toolbox version info with renderings
versionInfo = GetRenderToolbox3VersionInfo();

% add the the current folder and subfolders to the Matlab path
originalPath = path();
AddWorkingPath(pwd());
workingPath = path();

% render with local "for" or distributed "parfor" loop
outFiles = cell(1, nConditions);
err = [];
fprintf('\nBatchRender started at %s.\n\n', datestr(now(), 0));
renderTick = tic();
try
    if hints.isParallel
        % distributed "parfor" loop, don't time individual iterations
        parfor cc = 1:nConditions
            % choose variable values for this condition
            if isempty(varValues)
                conditionVarValues = {};
            else
                conditionVarValues = varValues(cc,:);
            end
            
            % render this condition
            outFiles{cc} = renderCondition(sceneFile, mappingsFile, ...
                cc, varNames, conditionVarValues, ...
                versionInfo, workingPath, hints);
        end
    else
        % local "for" loop, makes sense to time each iteration
        for cc = 1:nConditions
            fprintf('\nStarting condition %d of %d at %s (%.1fs elapsed).\n\n', ...
                cc, nConditions, datestr(now(), 0), toc(renderTick));
            
            % choose variable values for this condition
            if isempty(varValues)
                conditionVarValues = {};
            else
                conditionVarValues = varValues(cc,:);
            end
            
            % render this condition
            outFiles{cc} = renderCondition(sceneFile, mappingsFile, ...
                cc, varNames, conditionVarValues, ...
                versionInfo, workingPath, hints);
            
            fprintf('\nFinished condition %d of %d at %s (%.1fs elapsed).\n\n', ...
                cc, nConditions, datestr(now(), 0), toc(renderTick));
        end
    end
catch err
    disp('Rendering error!')
end

fprintf('\nBatchRender finished at %s (%.1fs elapsed).\n\n', ...
    datestr(now(), 0), toc(renderTick));

% clean up after rendering or error
path(originalPath);

% report the error, if any
if ~isempty(err)
    rethrow(err)
end

% Render a scene condition and save a .mat data file.
function outFile = renderCondition(sceneFile, mappingsFile, ...
    conditionNumber, varNames, varValues, ...
    versionInfo, workingPath, hints)

outFile = '';

% use the given working path
path(workingPath);

% choose the renderer
isMatch = strcmp('renderer', varNames);
if any(isMatch)
    hints.renderer = varValues{find(isMatch, 1, 'first')};
end

% choose the adjustments file
isMatch = strcmp('adjustmentsFile', varNames);
if any(isMatch)
    hints.adjustmentsFile = varValues{find(isMatch, 1, 'first')};
end
if isempty(hints.adjustmentsFile)
    hints.adjustmentsFile = getpref(hints.renderer, 'adjustmentsFile');
end

% choose the scene file
isMatch = strcmp('sceneFile', varNames);
if any(isMatch)
    sceneFile = varValues{find(isMatch, 1, 'first')};
end
[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
if isempty(scenePath) && exist(sceneFile, 'file')
    sceneFile = which(sceneFile);
end

% choose the mappings file
isMatch = strcmp('mappingsFile', varNames);
if any(isMatch)
    mappingsFile = varValues{find(isMatch, 1, 'first')};
end
mappings = ParseMappings(mappingsFile);

% choose the output name
isMatch = strcmp('imageName', varNames);
if any(isMatch)
    imageName = varValues{find(isMatch, 1, 'first')};
else
    imageName = sprintf('%s-%03d', sceneBase, conditionNumber);
    
end

% choose the output image size
isMatch = strcmp('imageHeight', varNames);
if any(isMatch)
    num = StringToVector(varValues{find(isMatch, 1, 'first')});
    hints.imageHeight = num;
end
isMatch = strcmp('imageWidth', varNames);
if any(isMatch)
    num = StringToVector(varValues{find(isMatch, 1, 'first')});
    hints.imageWidth = num;
end

% copy scene files
%   renderer-specific temp folder
%   condition-specific file name
tempFolder = fullfile(hints.tempFolder, hints.renderer);
copyBase = sprintf('%s-%03d', sceneBase, conditionNumber);
sceneCopy = fullfile(tempFolder, [copyBase sceneExt]);
copyfile(sceneFile, sceneCopy);

[adjustPath, adjustBase, adjustExt] = fileparts(hints.adjustmentsFile);
adjustCopy = fullfile(tempFolder, [adjustBase adjustExt]);
copyfile(hints.adjustmentsFile, adjustCopy);

% reduce the Collada file to known characters and elements
sceneCopy = WriteASCII7BitOnly(sceneCopy);
sceneCopy = WriteReducedColladaScene(sceneCopy);

% copy and modify scene and adjustments files for this condition
[sceneTemp, adjustTemp] = WriteMappedSceneFiles( ...
    tempFolder, imageName, sceneCopy, adjustCopy, ...
    mappings, varNames, varValues, hints);

% if this is a dry run, skip the rendering
if hints.isDryRun
    fprintf('Dry run of %s (%s).\n', imageName, hints.renderer);
    drawnow();
    return;
end

% render the scene
switch hints.renderer
    case 'Mitsuba'
        % convert Collada to Mitsuba's .xml format
        mitsubaFile = fullfile(tempFolder, [imageName '.xml']);
        [mitsubaFile, mitsubaDoc] = ColladaToMitsuba( ...
            sceneTemp, mitsubaFile, adjustTemp, hints);
        
        % invoke Mitsuba!
        [status, result, output] = RunMitsuba(mitsubaFile);
        if status ~= 0
            error('Mitsuba rendering failed\n  %s\n  %s\n', ...
                mitsubaFile, result);
        end
        
        % read raw output into memory
        %   including explicit spectral sampling, "S"
        [multispectralImage, wls, S] = ReadMultispectralEXR(output);
        
        % scale the output into radiance units
        multispectralImage = MitsubaDataToRadiance( ...
            multispectralImage, mitsubaDoc, hints);
        
    case 'PBRT'
        % convert Collada to PBRT's text format
        pbrtFile = fullfile(tempFolder, [imageName '.pbrt']);
        [pbrtFile, pbrtXMLFile, pbrtDoc] = ColladaToPBRT( ...
            sceneTemp, pbrtFile, adjustTemp, hints);
        
        % invoke PBRT!
        [status, result, output] = RunPBRT(pbrtFile);
        if status ~= 0
            error('PBRT rendering failed\n  %s\n  %s\n', ...
                pbrtFile, result);
        end
        
        % read output into memory
        multispectralImage = ReadDAT(output);
        
        % scale the output into radiance units
        multispectralImage = PBRTDataToRadiance( ...
            multispectralImage, pbrtDoc, hints);
        
        % interpret output according to PBRT's spectral sampling
        S = getpref('PBRT', 'S');
        
    otherwise
        S = [];
        multispectralImage = [];
end

% save a .mat file with multispectral data and metadata
rendererOutputPath = fullfile(hints.outputDataFolder, hints.renderer);
outFile = fullfile(rendererOutputPath, [imageName '.mat']);
save(outFile, 'multispectralImage', 'S', 'hints', ...
    'sceneFile', 'varNames', 'varValues', 'mappingsFile', 'versionInfo');
