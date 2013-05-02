%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a material from a Collada document to a PBRT-XML document.
%   @param id
%   @param stubIDMap
%   @param colladaIDMap
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Cherry pick from Collada "material" and "effect" nodes in the Collada
% document represented by the given @a colladaIDMap, and populate the
% corresponding node of the stub PBRT-XML document represented by the given
% @a stubIDMap.  @a id is the unique identifier of the material node.  @a
% hints is a struct of conversion hints.
%
% @details
% Returns true if the conversion was successful.
%
% @details
% Used internally by ColladaToPBRT().
%
% @details
% Usage:
%   isConverted = ConvertMaterial(id, stubIDMap, colladaIDMap, hints)
%
% @ingroup ColladaToPBRT
function isConverted = ConvertMaterial(id, stubIDMap, colladaIDMap, hints)

isConverted = true;

% get the id of the corresponding effect (without the '#')
colladaPath = {id, ':instance_effect', '.url'};
effectID = GetSceneValue(colladaIDMap, colladaPath);
effectID = effectID(effectID ~= '#');

% declare an uber material
SetType(stubIDMap, id, 'Material', 'uber');

% look for material type "lambert" or "phong"
commonPath = {effectID, ':profile_COMMON', ':technique|.sid=common'};
phongPath = cat(2, commonPath, {':phong'});
lambertPath = cat(2, commonPath, {':lambert'});
if ~isempty(SearchScene(colladaIDMap, phongPath))
    materialType = ':phong';
    
elseif ~isempty(SearchScene(colladaIDMap, lambertPath))
    materialType = ':lambert';
    
else
    materialType = '';
end

if isempty(materialType)
    % use default color and refraction
    diffuse = '1 1 1';
    refractIndex = '1';
else
    % use phong or lambert
    materialPath = cat(2, commonPath, materialType);
    
    % get diffuse color and index of refraction
    colladaPath = cat(2, materialPath, {':diffuse', ':color'});
    diffuse = GetSceneValue(colladaIDMap, colladaPath);
    if isempty(diffuse)
        diffuse = '0.5 0.5 0.5';
    end
    colladaPath = cat(2, materialPath, {':index_of_refraction', ':float'});
    refractIndex = GetSceneValue(colladaIDMap, colladaPath);
    if isempty(refractIndex)
        refractIndex = '1.0';
    end
end

% convert 4-element color to RGB
diffuseNum = StringToVector(diffuse);
diffuseRGB = diffuseNum(1:3);

% create Kd and index parameters
AddParameter(stubIDMap, id, 'Kd', 'rgb', diffuseRGB);
AddParameter(stubIDMap, id, 'index', 'float', refractIndex);
