%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Write a default mappings file for the given Collada scene file.
%   @param colladaFile file name or path of the Collada scene file
%   @param mappingsFile file name or path for a new mappings file
%   @param includeFile file name or path for a mappings file to include
%   @param reflectances cell array of matte material reflectances
%   @param lightSpectra cell array of light source spectra
%   @param excludePattern regular expression to filter document elements
%
% @details
% Traverses the Collada document in the given @a colladaFile and writes a
% new @a mappingsFile suitable for use with BatchRender().  The @a
% mappingsFile will specify default values, including:
%   - mappings text in @a includeFile or RenderData/DefaultMappings.txt
%   - matte material for each geometry node
%   - a spectrum for each light source
%   .
% Each material or light source will use a spectrum from a default list, or
% a provided list.
%
% @details
% By default, prepends the text of RenderData/DefaultMappings.txt to the
% new mappings file.  If @a includeFile is provided it must specify another
% text file to prepend instead.
%
% @details
% By default, each matte material will use one of the Color Checker
% reflectance spectrums found in RenderData/Macbeth-ColorChecker.  If @a
% reflectances is provided, it must be a cell array of string reflectance
% values to use instead.
%
% @details
% By default, each light source will use the D65 light spectrum found in
% RenderData/D65.spd.  If @a lightSpectra is provided, it must be a cell
% array of string spectrum values to use instead.
%
% @details
% By default, writes mappings for all materials and light sources. If @a
% excludePattern is provided, it must be a regular expression to match
% against element id attributes.  Elements whose ids match @a
% excludePattern will be excluded from the @a mappingsFile.
%
% @details
% Returns the name of the new @a mappingsFile.
%
% @details
% Usage:
%   WriteDefaultMappingsFile(colladaFile, mappingsFile, includeFile, reflectances, lightSpectra, excludePattern)
%
% @ingroup BatchRender
function mappingsFile = WriteDefaultMappingsFile( ...
    colladaFile, mappingsFile, includeFile, reflectances, lightSpectra, excludePattern)

%% Check Parameters.
[colladaPath, colladaBase, colladaExt] = fileparts(colladaFile);

if nargin < 2 || isempty(mappingsFile)
    mappingsFile = fullfile(colladaPath, [colladaBase 'DefaultMappings.txt']);
end

if nargin < 3 || isempty(includeFile)
    includeFile = fullfile(RenderToolboxRoot(), 'RenderData', 'DefaultMappings.txt');
end

if nargin < 4 || isempty(reflectances)
    % find default Color Checker spectrum files
    macbethPath = fullfile(RenderToolboxRoot(), 'RenderData', 'Macbeth-ColorChecker');
    spdPaths = FindFiles(macbethPath, '\.spd$');
    reflectances = cell(size(spdPaths));
    
    % trim off the full path and sort by spectrum number
    for ii = 1:numel(spdPaths)
        [spdPath, spdBase, spdExt] = fileparts(spdPaths{ii});
        fileName = [spdBase spdExt];
        token = regexp(fileName, '([0-9]+)', 'tokens');
        number = StringToVector(token{1}{1});
        reflectances{number} = fileName;
    end
end

if isempty(reflectances)
    reflectances = {'300:0.5 800:0.5'};
end

if nargin < 5 || isempty(lightSpectra)
    lightSpectra = {'D65.spd'};
end

if nargin < 6
    excludePattern = '';
end

%% Scan the Collada file by element id.

% reduce the Collada file to known characters and elements.
collada7Bit = WriteASCII7BitOnly(colladaFile);
colladaReduced = WriteReducedColladaScene(collada7Bit);

% read the Collada document
[docNode, idMap] = ReadSceneDOM(colladaReduced);

% delete intermediate files
ids = idMap.keys();
nElements = numel(ids);

% delete intermediate files
delete(collada7Bit);
delete(colladaReduced);

% choose a specrtum for each material or light
elementInfo = struct( ...
    'id', ids, ...
    'category', [], ...
    'type', [], ...
    'propertyName', [], ...
    'propertyValue', [], ...
    'valueType', 'spectrum');
nMaterials = 0;
nLights = 0;
for ii = 1:nElements
    id = ids{ii};
    element = idMap(id);
    
    % exclude this element?
    if ~isempty(excludePattern) && ~isempty(regexp(id, excludePattern, 'once'))
        continue;
    end
    
    nodeName = char(element.getNodeName());
    switch nodeName
        case 'material'
            % choose a color for this material
            nMaterials = nMaterials + 1;
            index = 1 + mod(nMaterials-1, numel(reflectances));
            elementInfo(ii).category = 'material';
            elementInfo(ii).type = 'matte';
            elementInfo(ii).propertyValue = reflectances{index};
            elementInfo(ii).propertyName = 'diffuseReflectance';
            
        case 'light'
            % choose a spectrum for this light
            nLights = nLights + 1;
            index = 1 + mod(nLights-1, numel(lightSpectra));
            elementInfo(ii).category = 'light';
            elementInfo(ii).type = GetColladaLightType(element);
            elementInfo(ii).propertyValue = lightSpectra{index};
            elementInfo(ii).propertyName = 'intensity';
    end
end

%% Dump element info into a mappings file.
% start with the generic default mappings file
copyfile(includeFile, mappingsFile);
fid = fopen(mappingsFile, 'a');

% add a block with material colors
isMaterial = strcmp('material', {elementInfo.category});
writeMappingsBlock(fid, 'materials', 'Generic', elementInfo(isMaterial));

% add a block with light spectra
isLight = strcmp('light', {elementInfo.category});
writeMappingsBlock(fid, 'lights', 'Generic', elementInfo(isLight));

fclose(fid);

function writeMappingsBlock(fid, comment, blockName, elementInfo)
fprintf(fid, '\n\n%% %s\n', comment);
fprintf(fid, '%s {\n', blockName);
for ii = 1:numel(elementInfo)
    fprintf(fid, '\t%s:%s:%s\n', elementInfo(ii).id, ...
        elementInfo(ii).category, elementInfo(ii).type);
    fprintf(fid, '\t%s:%s.%s = %s\n\n', elementInfo(ii).id, ...
        elementInfo(ii).propertyName, elementInfo(ii).valueType, ...
        elementInfo(ii).propertyValue);
end
fprintf(fid, '}\n');