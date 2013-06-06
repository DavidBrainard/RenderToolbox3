%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada file to renderer scene files, with changing varibles.
%   @param colladaFile file name or path of a Collada scene file
%   @param conditionsFile file name or path of a conditions file
%   @param mappingsFile file name or path of a mappings file
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%   @param outPath path where to copy new scene files
%
% @details
% Creates multiple renderer-specific scene files, based on the given @a
% colladaFile, @a conditionsFile, and @a mappingsFile.  @a hints.renderer
% specifies which renderer to make scene files for.  @a outPath is
% optional, and may specify a folder path that should receive copies of the
% new scene files.
%
% @details
% @a colladaFile should be a Collada XML scene file.  @a colladaFile may be
% left empty, if the @a conditionsFile contains a 'colladaFile' variable.
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
% @a hints may be a struct with options that affect the conversion process,
% as returned from GetDefaultHints().  If @a hints is omitted, default
% options are used.  For example:
%   - @a hints.renderer specifies which renderer to make scene files for.
%   - @a hints.tempFolder is the default location for new scene files.
%   - @a hints.adjustmentsFile is a partial scene file with
%   renderer-specific values
%   - @a hints.filmType is a renderer-specific film type to specify in the
%   scene files.
%   - @a hints.imageHeight and @a hints.imageWidth specify the image pixel
%   dimensions to specify in the scene files.
%   - @a hints.whichConditions is an array of condition numbers used to
%   select lines from the @a conditionsFile.
%   .
%
% @details
% @a outPath is optional.  If provided, it should be the path to a folder
% where new scene files and auxiliary files should be copied.  New scene
% files will also be written to @a hints.tempFolder.
%
% @details
% Returns a cell array of file names for new renderer-specific scene
% files.  By default, each scene file will have the same base name as @a
% the given @a colladaFile, plus a numeric suffix.  If @a conditionsFile
% contains an 'imageName' variable, each scene file be named with the value
% of 'imageName'.
%
% @details
% Also retrurns a cell array of file names for auxiliary files on which the
% scene files depend, like images, spectrum files, and geometry files.
%
% @details
% For Mitsuba, renderer-specific scene files will be in Mitsuba's native
% .xml format.  For PBRT, files will be in RenderToolbox3's custom PBRT-XML
% .xml format.  PBRT-XML files can be converted to PBRT's native text
% format using WritePBRTFile().
%
% @details
% Usage:
%   [sceneFiles, auxiliaryFiles] = MakeSceneFiles(colladaFile, conditionsFile, mappingsFile, hints, outPath)
%
% @ingroup BatchRenderer
function [sceneFiles, auxiliaryFiles] = MakeSceneFiles(colladaFile, conditionsFile, mappingsFile, hints, outPath)

InitializeRenderToolbox();

%% Parameters
if nargin < 1 || isempty(colladaFile)
    colladaFile = '';
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

if nargin < 5 || isempty(outPath)
    outPath = '';
end

%% Read conditions file into memory.
if isempty(conditionsFile)
    % no conditions, do a single rendering
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

%% Create folders to receive new scene files for each renderer.
% determine which renderers will be used
isMatch = strcmp('renderer', varNames);
if any(isMatch)
    renderers = varValues{:, find(isMatch, 1, 'first')};
else
    renderers = {hints.renderer};
end

% create a temp folder for each renderer.
for ii = 1:numel(renderers)
    renderer = renderers{ii};
    tempFolder = fullfile(GetOutputPath('tempFolder', hints), renderer);
    if ~exist(tempFolder, 'dir')
        mkdir(tempFolder);
    end
end

%% Make a scene file for each condition.
sceneFiles = cell(1, nConditions);
auxiliaryFiles = {};

err = [];
try
    for cc = 1:nConditions
        % choose variable values for this condition
        if isempty(varValues)
            conditionVarValues = {};
        else
            conditionVarValues = varValues(cc,:);
        end
        
        % make a the scene file for this condition
        [sceneFiles{cc}, sceneAux] = ...
            makeConditionSceneFile(colladaFile, mappingsFile, ...
            cc, varNames, conditionVarValues, hints);
        
        % append to running list of auxiliary files
        auxiliaryFiles = cat(2, auxiliaryFiles, sceneAux);
    end
catch err
    disp('Scene conversion error!');
end

% only care about unique auxiliary files
auxiliaryFiles = unique(auxiliaryFiles);

% copy scene files and auxiliary files to an output folder?
if ~isempty(outPath)
    if ~exist(outPath, 'dir')
        mkdir(outPath);
    end
    
    for ii = 1:numel(sceneFiles)
        [status, result] = copyfile(sceneFiles{ii}, outPath);
    end

    for ii = 1:numel(auxiliaryFiles)
        [status, result] = copyfile(auxiliaryFiles{ii}, outPath);
    end
end

% report the error, if any
if ~isempty(err)
    rethrow(err)
end

% Render a scene condition and save a .mat data file.
function [sceneFile, auxiliary] = makeConditionSceneFile( ...
    colladaFile, mappingsFile, ...
    conditionNumber, varNames, varValues, hints)

sceneFile = '';
auxiliary = {};

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
isMatch = strcmp('colladaFile', varNames);
if any(isMatch)
    colladaFile = varValues{find(isMatch, 1, 'first')};
end
[scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
if isempty(scenePath) && exist(colladaFile, 'file')
    colladaFile = which(colladaFile);
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

% copy the collada file and reduce it to known characters and elements
tempFolder = fullfile(GetOutputPath('tempFolder', hints), hints.renderer);
colladaCopy = fullfile(tempFolder, [sceneBase sceneExt]);
[isSuccess, result] = copyfile(colladaFile, colladaCopy);
colladaCopy = WriteASCII7BitOnly(colladaCopy);
colladaCopy = WriteReducedColladaScene(colladaCopy);

% copy the adjustments file
[adjustPath, adjustBase, adjustExt] = fileparts(hints.adjustmentsFile);
adjustCopy = fullfile(tempFolder, [adjustBase adjustExt]);
if ~strcmp(tempFolder, scenePath)
    copyfile(hints.adjustmentsFile, adjustCopy);
end

% make a new, modified Collada file and adjustments file
[sceneTemp, adjustTemp, sceneResources] = WriteMappedSceneFiles( ...
    tempFolder, imageName, colladaCopy, adjustCopy, ...
    mappings, varNames, varValues, hints);

% convert Collada and adjustments to a renderer-specific scene file
switch hints.renderer
    case 'Mitsuba'
        % convert Collada to Mitsuba's .xml format
        sceneFile = fullfile(tempFolder, [imageName '.xml']);
        
        if hints.isReuseSceneFiles && exist(sceneFile, 'file');
            disp(sprintf('Reusing %s', sceneFile));
            sceneAux = {};
        else
            [sceneFile, sceneDoc, sceneAux] = ColladaToMitsuba( ...
                sceneTemp, sceneFile, adjustTemp, hints);
        end
        
    case 'PBRT'
        % convert Collada to PBRT-XML format
        pbrtFile = fullfile(tempFolder, [imageName '.pbrt']);
        pbrtXMLFile = fullfile(tempFolder, [imageName '.pbrt.xml']);
        
        if hints.isReuseSceneFiles && exist(pbrtXMLFile, 'file');
            disp(sprintf('Reusing %s', pbrtXMLFile));
            sceneAux = {};
        else
            [pbrtFile, pbrtXMLFile, pbrtDoc, sceneAux] = ColladaToPBRT( ...
                sceneTemp, pbrtFile, adjustTemp, hints);
        end
        sceneFile = pbrtXMLFile;
end

% combined list of dependencies for this scene
auxiliary = cat(2, sceneResources, sceneAux);
