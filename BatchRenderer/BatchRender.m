%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render a scene multiple times, with changing varibles.
%   @param sceneFile file name or path of a Collada scene file
%   @param conditionsFile file name or path of a conditions file
%   @param mappingsFile file name or path of a mappings file
%   @param hints struct of options for the batch renderer
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
% ioptions are used.  @a hints specifies which renderer to use.
%
% @details
% Renders the scene one or more times, and writes a .mat file each time.
% The .mat file will contain multi-spectral renderer output in two
% variables:
%   - hyperspectralImage - matrix of hyperspectral image data with size
%   [height width n]
%   - S - spectral plane description, [start delta n]
%   .
% where height and width are pixel image dimensions and n is the number of
% spectral bands in the image.  See the RenderToolbox3 wikiw for more about
% <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands">Spectrum Bands</a>.
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

%% Make a private working folder and an output folder
% working folder
originalPath = pwd();
batchRenderPath = fullfile(originalPath, 'batch-render-temp');
if ~exist(batchRenderPath, 'dir')
    mkdir(batchRenderPath);
end

% output folder
if ~exist(hints.outputFolder, 'dir')
    mkdir(hints.outputFolder);
end

%% Render for each condition.
outFiles = cell(1, nConditions);
renderTick = tic();
for cc = 1:nConditions
    fprintf('\nRendering condition %d of %d (%.1fs).\n\n', ...
        cc, nConditions, toc(renderTick));
    
    %% Let conditions file variables override arguments and defaults.
    % which renderer?
    isMatch = strcmp('renderer', varNames);
    if any(isMatch)
        % choose the renderer and update dependent defaults
        hints.renderer = varValues{cc, find(isMatch, 1, 'first')};
    end
    
    % which adjustments file?
    isMatch = strcmp('adjustmentsFile', varNames);
    if any(isMatch)
        hints.adjustmentsFile = varValues{cc, find(isMatch, 1, 'first')};
    end
    if isempty(hints.adjustmentsFile)
        hints.adjustmentsFile = getpref(hints.renderer, 'adjustmentsFile');
    end
    
    % which sceneFile?
    isMatch = strcmp('sceneFile', varNames);
    if any(isMatch)
        sceneFile = varValues{cc, find(isMatch, 1, 'first')};
    end
    [scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
    
    % which mappingsFile?
    isMatch = strcmp('mappingsFile', varNames);
    if any(isMatch)
        mappingsFile = varValues{cc, find(isMatch, 1, 'first')};
    end
    mappings = ParseMappings(mappingsFile);
    
    % output image name?
    isMatch = strcmp('imageName', varNames);
    if any(isMatch)
        imageName = varValues{cc, find(isMatch, 1, 'first')};
    else
        imageName = sprintf('%s-%03d', sceneBase, cc);
    end
    
    %% Copy scene files to a renderer-specific working folder.
    workingPath = fullfile(batchRenderPath, hints.renderer);
    if ~exist(workingPath, 'dir')
        mkdir(workingPath);
    end
    
    % copy scene and adjustments files to private folder
    %   cd to original folder to handle relative paths
    cd(originalPath);
    sceneCopy = fullfile(workingPath, [sceneBase sceneExt]);
    copyfile(sceneFile, sceneCopy);
    [adjustPath, adjustBase, adjustExt] = fileparts(hints.adjustmentsFile);
    adjustCopy = fullfile(workingPath, [adjustBase adjustExt]);
    copyfile(hints.adjustmentsFile, adjustCopy);
    
    % cd to the new working folder
    %   now that relative paths are taken care of
    cd(workingPath);
    
    %% Copy and modify scene and adjustments files for this condition.
    if isempty(varValues)
        conditionVarValues = {};
    else
        conditionVarValues = varValues(cc,:);
    end
    [sceneTemp, adjustTemp] = WriteMappedSceneFiles( ...
        workingPath, imageName, sceneCopy, adjustCopy, ...
        mappings, varNames, conditionVarValues, hints);
    
    %% Render the scene!
    switch hints.renderer
        case 'Mitsuba'
            % convert Collada to Mitsuba's .xml format
            mitsubaFile = [imageName '.xml'];
            ColladaToMitsuba(sceneTemp, mitsubaFile, adjustTemp, hints);
            
            % invoke Mitsuba!
            [status, result, output] = RunMitsuba(mitsubaFile);
            if status ~= 0
                error('Mitsuba rendering failed\n  %s\n  %s\n', ...
                    mitsubaFile, result);
            end
            
            % read output into memory
            %   including explicit spectral sampling, "S"
            [hyperspectralImage, wls, S] = ReadMultispectralEXR(output);
            
        case 'PBRT'
            % convert Collada to PBRT's text format
            pbrtFile = [imageName '.pbrt'];
            ColladaToPBRT(sceneTemp, pbrtFile, adjustTemp, hints);
            
            % invoke PBRT!
            [status, result, output] = RunPBRT(pbrtFile);
            if status ~= 0
                error('PBRT rendering failed\n  %s\n  %s\n', ...
                    pbrtFile, result);
            end
            
            % read output into memory
            hyperspectralImage = ReadDAT(output);
            
            % interpret output according to PBRT's spectral sampling
            S = getpref('PBRT', 'S');
            
        otherwise
            S = [];
            hyperspectralImage = [];
    end
    
    % save a .mat file with hyperspectral data
    %   cd to original folder in case of relative a relative output path
    cd(originalPath);
    outFile = fullfile(hints.outputFolder, [imageName '.mat']);
    save(outFile, 'hyperspectralImage', 'S');
    outFiles{cc} = outFile;
end

% delete temporary, intermediate files?
cd(originalPath);
if hints.isDeleteIntermediates
    rmdir(batchRenderPath, 's');
end

fprintf('\nFinished %d conditions (%.1fs).\n\n', ...
    nConditions, toc(renderTick));