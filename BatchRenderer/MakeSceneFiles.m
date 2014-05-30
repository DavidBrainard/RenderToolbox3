%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Make a family of renderer-native scenes based on a Collada parent scene.
%   @param colladaFile file name or path of a Collada parent scene file
%   @param conditionsFile file name or path of a conditions file
%   @param mappingsFile file name or path of a mappings file
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Creates a family of renderer-native scenes, based on the given @a
% colladaFile, @a conditionsFile, and @a mappingsFile.  @a hints.renderer
% specifies which renderer to target.
%
% @details
% @a colladaFile should be a Collada XML parent scene file.  @a colladaFile
% may be left empty, if the @a conditionsFile contains a 'colladaFile'
% variable.
%
% @details
% @a conditionsFile must be a RenderToolbox3 <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Conditions-File-Format">Conditions File</a>.
% @a conditionsFile may be omitted or left empty, if only one
% renderer-native scene file is to be produced.
%
% @details
% @a mappingsFile must be a RenderToolbox3 <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Mappings-File-Format">Mappings File</a>.
% @a mappingsFile may be omitted or left empty if only one
% renderer-native scene file is to be produced, or if @a conditionsFile
% contains a 'mappingsFile' variable.
%
% @details
% @a hints may be a struct with options that affect the process generating
% of renderer-native scene files.  If @a hints is omitted, values are taken
% from GetDefaultHints().
%   - @a hints.renderer specifies which renderer to target
%   - @a hints.tempFolder is the default location for new renderer-native
%   scene files
%   - @a hints.filmType is a renderer-specific film type to specify for the
%   scene
%   - @a hints.imageHeight and @a hints.imageWidth specify the image pixel
%   dimensions to specify for the scene
%   - @a hints.whichConditions is an array of condition numbers used to
%   select rows from the @a conditionsFile.
%   - @a hints.isReuseSceneFiles specefies whether or not renderer
%   ImportCollada functions should attempt to to skip actual scene file
%   creation, and use existing files instead.
%   .
%
% @details
% This function uses RenderToolbox3 renderer API functions "ApplyMappings"
% and "ImportCollada".  These functions, for the renderer specified in @a
% hints.renderer, must be on the Matlab path.
%
% @details
% Returns a cell array of new renderer-native scene descriptions.  Each
% scene description.  By default, each scene file will have the same base
% name as the given @a colladaFile, plus a numeric suffix.  If @a
% conditionsFile contains an 'imageName' variable, each scene file be named
% with the value of 'imageName'.
%
% @details
% Usage:
%   scenes = MakeSceneFiles(colladaFile, conditionsFile, mappingsFile, hints)
%
% @ingroup BatchRenderer
function scenes = MakeSceneFiles(colladaFile, conditionsFile, mappingsFile, hints)

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

fprintf('\nMakeSceneFiles started at %s.\n\n', datestr(now(), 0));

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

%% Call out the original Collada authoring tool (Blender, etc.)
%   any remodelling function might have modified the authoring info
authoringTool = GetColladaAuthorInfo(colladaFile);
fprintf('Original Collada scene authored with %s.\n\n', authoringTool);

%% Allow remodeler to modify Collada document before all else.
colladaFile = remodelCollada(colladaFile, hints, 'BeforeAll');

%% Make a scene file for each condition.
scenes = cell(1, nConditions);

err = [];
try
    fprintf('\nMakeSceneFiles started with isParallel=%d at %s.\n\n', ...
        hints.isParallel, datestr(now(), 0));
    renderTick = tic();
    
    if hints.isParallel
        % distributed "parfor" loop
        parfor cc = 1:nConditions
            % choose variable values for this condition
            if isempty(varValues)
                conditionVarValues = {};
            else
                conditionVarValues = varValues(cc,:);
            end
            
            % make a the scene file for this condition
            scenes{cc} = makeSceneForCondition( ...
                colladaFile, mappingsFile, cc, ...
                varNames, conditionVarValues, hints);
        end
    else
        % local "for" loop
        for cc = 1:nConditions
            % choose variable values for this condition
            if isempty(varValues)
                conditionVarValues = {};
            else
                conditionVarValues = varValues(cc,:);
            end
            
            % make a the scene file for this condition
            scenes{cc} = makeSceneForCondition( ...
                colladaFile, mappingsFile, cc, ...
                varNames, conditionVarValues, hints);
        end
    end
    
    fprintf('\nMakeSceneFiles finished at %s (%.1fs elapsed).\n\n', ...
        datestr(now(), 0), toc(renderTick));
    
catch err
    disp('Scene conversion error!');
end

% report any error
if ~isempty(err)
    rethrow(err)
end


%% Remodel the Collada file into a new file.
function colladaCopy = remodelCollada(colladaFile, hints, functionName, varargin)
colladaCopy = colladaFile;
if ~isempty(colladaFile) && ~isempty(hints.remodeler)
    % get the user-defined remodeler function
    remodelerFunction = GetRemodelerAPIFunction(functionName, hints);
    if ~isempty(remodelerFunction)
        % read original Collada document into memory
        [scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
        if isempty(scenePath) && exist(colladaFile, 'file')
            info = ResolveFilePath(colladaFile, GetWorkingFolder('', false, hints));
            colladaFile = info.absolutePath;
        end
        colladaDoc = ReadSceneDOM(colladaFile);
        
        % apply the remodeler function with given arguments
        colladaDoc = feval(remodelerFunction, colladaDoc, varargin{:}, hints);
        
        % write modified document to new file
        tempFolder = fullfile(GetWorkingFolder('temp', true, hints));
        colladaCopy = fullfile(tempFolder, [sceneBase '-' functionName sceneExt]);
        WriteSceneDOM(colladaCopy, colladaDoc);
    end
end


%% Create a renderer-native scene description for one condition.
function scene = makeSceneForCondition(colladaFile, mappingsFile, ...
    conditionNumber, varNames, varValues, hints)

scene = [];

%% Choose parameter values from conditions file or hints.
isMatch = strcmp('renderer', varNames);
if any(isMatch)
    hints.renderer = varValues{find(isMatch, 1, 'first')};
end

isMatch = strcmp('colladaFile', varNames);
if any(isMatch)
    colladaFile = varValues{find(isMatch, 1, 'first')};
end
[scenePath, sceneBase, sceneExt] = fileparts(colladaFile);
if isempty(scenePath) && exist(colladaFile, 'file')
    fileInfo = ResolveFilePath(colladaFile, GetWorkingFolder('', false, hints));
    colladaFile = fileInfo.absolutePath;
end

isMatch = strcmp('mappingsFile', varNames);
if any(isMatch)
    mappingsFile = varValues{find(isMatch, 1, 'first')};
end
mappings = ParseMappings(mappingsFile);

isMatch = strcmp('imageName', varNames);
if any(isMatch)
    imageName = varValues{find(isMatch, 1, 'first')};
else
    imageName = sprintf('%s-%03d', sceneBase, conditionNumber);
end

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

isMatch = strcmp('groupName', varNames);
if any(isMatch)
    groupName = varValues(find(isMatch, 1, 'first'));
else
    groupName = '';
end


%% Copy the collada file and reduce to known characters and elements.
tempFolder = GetWorkingFolder('temp', true, hints);
colladaCopy = fullfile(tempFolder, [sceneBase '-' imageName sceneExt]);
[isSuccess, result] = copyfile(colladaFile, colladaCopy);
colladaCopy = WriteASCII7BitOnly(colladaCopy);
colladaCopy = WriteReducedColladaScene(colladaCopy);

%% Initialize renderer-native adjustments to receive mappings data.
applyMappingsFunction = ...
    GetRendererAPIFunction('ApplyMappings', hints);
if isempty(applyMappingsFunction)
    return;
end
adjustments = feval(applyMappingsFunction, [], []);

%% Apply mappings to the renderer-native adjustments.
% replace various mappings file expressions with concrete values
mappings = ResolveMappingsValues( ...
    mappings, varNames, varValues, colladaCopy, adjustments, hints);

%% Allow remodeler to modify Collada document before each condition.
colladaCopy = remodelCollada(colladaCopy, hints, 'BeforeCondition', ...
    mappings, varNames, varValues, conditionNumber);

%% Update the renderer-native adjustments to for each block of mappings.
blockNums = [mappings.blockNumber];
rendererName = hints.renderer;
rendererPathName = [rendererName '-path'];
if ~isempty(mappings)
    for bb = unique(blockNums)
        
        % get all mappings from one block
        blockMappings = mappings(bb == blockNums);
        blockGroup = blockMappings(1).group;
        blockType = blockMappings(1).blockType;
        
        % choose mappings for an active groupName
        isInGroup = isempty(groupName) ...
            || isempty(blockGroup) || strcmp(groupName, blockGroup);
        
        if any(isInGroup)
            switch blockType
                case 'Collada'
                    % DOM paths apply directly to Collada
                    [colladaDoc, colladaIDMap] = ReadSceneDOM(colladaCopy);
                    ApplySceneDOMPaths(colladaIDMap, blockMappings);
                    WriteSceneDOM(colladaCopy, colladaDoc);
                    
                case 'Generic'
                    % scene targets apply to adjustments
                    objects = MappingsToObjects(blockMappings);
                    objects = SupplementGenericObjects(objects);
                    adjustments = ...
                        feval(applyMappingsFunction, objects, adjustments);
                    
                case rendererName
                    % scene targets to apply to adjustments
                    objects = MappingsToObjects(blockMappings);
                    adjustments = ...
                        feval(applyMappingsFunction, objects, adjustments);
                    
                case rendererPathName
                    adjustments = ...
                        feval(applyMappingsFunction, blockMappings, adjustments);
            end
        end
    end
end

%% Allow remodeler to modify Collada document after each condition.
colladaCopy = remodelCollada(colladaCopy, hints, 'AfterCondition', ...
    mappings, varNames, varValues, conditionNumber);

%% Produce a renderer-native scene from Collada and adjustments.
importColladaFunction = ...
    GetRendererAPIFunction('ImportCollada', hints);
if isempty(importColladaFunction)
    return;
end
scene = feval( ...
    importColladaFunction, colladaCopy, adjustments, imageName, hints);
[scene.imageName] = deal(imageName);

% store Collada authoring info along with the scene description
%   authoring info may have been set by a remodeler!
[authoringTool, asset] = GetColladaAuthorInfo(colladaCopy);
authorInfo.authoringTool = authoringTool;
authorInfo.asset = asset;
[scene.authorInfo] = deal(authorInfo);
