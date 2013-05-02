%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Reduce a Collada scene file to basic geometry and materials.
%   @param colladaFile file name or path of a Collada scene file
%   @param reducedFile file name or path of the new, reuduced scene
%
% @details
% Traverses the Collada document in the given @a colladaFile and creates a
% new, reduced version of the document, at the given @a reducedFile.  The
% reduced document will contain all of the basic scene elements including
% cameras, some types of lights, and geometry.  It will not contain
% fancier scene elemnets like textured materials, animations, controllers,
% and physics.
%
% @details
% Attempts to obey the Collada 1.4 schema, so that the new @a reducedFile
% will be a valid Collada file.  See
%   http://www.khronos.org/collada/
% for more about the Collada XML schema.  This cheat sheet is especially
% useful:
%   http://www.khronos.org/files/collada_reference_card_1_4.pdf
%
% @details
% Returns the name of the new, reduced scene file.
%
% @details
% Usage:
%   reducedFile = WriteReducedColladaScene(colladaFile, reducedFile)
%
% @ingroup SceneDOM
function reducedFile = WriteReducedColladaScene(colladaFile, reducedFile)

%% Check inputs.
[colladaPath, colladaBase, colladaExt] = fileparts(colladaFile);
if nargin < 2
    reducedFile = fullfile(colladaPath, [colladaBase '-reduced' colladaExt]);
end

%% Read the original Collada document.

% open the original Collada File, get the root node
colladaDoc = ReadSceneDOM(colladaFile);
colladaRoot = colladaDoc.getDocumentElement();

% create a new, empty XML document
docName = char(colladaRoot.getNodeName());
reducedDoc = com.mathworks.xml.XMLUtils.createDocument(docName);
reducedRoot = reducedDoc.getDocumentElement();

% define which Collada top-level "metadata" nodes to ignore
ignoredElements = { ...
    'library_animations', ...
    'library_animation_clips', ...
    'library_controllers', ...
    'library_force_fields', ...
    'library_images', ...
    'library_physics_materials', ...
    'library_physics_models', ...
    'library_physics_scenes', ...
    };

% check each of the top-level Collada nodes
%   make deep copies of basic scene elements
%   ignore fancier scene elements
metadataElements = GetElementChildren(colladaRoot);
nElements = numel(metadataElements);
for ii = 1:nElements
    element = metadataElements{ii};
    elementName = char(element.getNodeName());
    
    switch elementName
        case ignoredElements
            % ignore fancy scene elements
            continue;
            
        case 'library_materials'
            % make special placeholder materials
            elementClone = reducedDoc.importNode(element, false);
            reducedRoot.appendChild(elementClone);
            makeBasicMaterials(element, elementClone);
            
        case 'library_effects'
            % make special placeholder effects
            colors = getEffectMatteColor(element);
            elementClone = reducedDoc.importNode(element, false);
            reducedRoot.appendChild(elementClone);
            makeBasicEffects(element, elementClone, colors);
            
        case 'library_lights'
            % convert some lights to point lights
            elementClone = reducedDoc.importNode(element, false);
            reducedRoot.appendChild(elementClone);
            makeBasicLights(element, elementClone);
            
        otherwise
            % make deep copies of basic scene elements
            elementClone = reducedDoc.importNode(element, true);
            reducedRoot.appendChild(elementClone);
    end
end

%% Write the new, reduced Collada document to file.
WriteSceneDOM(reducedFile, reducedDoc);


%% Drill into each effect for a matte color, or use default.
function colors = getEffectMatteColor(effectLibrary)

effects = GetElementChildren(effectLibrary, 'effect');
nEffects = numel(effects);
colors = cell(1, nEffects);
for ii = 1:nEffects
    % default to gray color
    colors{ii} = '0.5 0.5 0.5 1';
    
    % drill into the effect
    profile = GetElementChildren(effects{ii}, 'profile_COMMON');
    if isempty(profile)
        continue;
    end
    technique = GetElementChildren(profile{1}, 'technique', 'sid', 'common');
    if isempty(technique)
        continue;
    end
    type = GetElementChildren(technique, 'lambert');
    if isempty(type)
        type = GetElementChildren(technique, 'phong');
        if isempty(type)
            continue;
        end
    end
    diffuse = GetElementChildren(type{1}, 'diffuse');
    if isempty(diffuse)
        continue;
    end
    colorElement = GetElementChildren(diffuse{1}, 'color', 'sid', 'diffuse');
    if isempty(colorElement)
        continue;
    end
    
    % found a matte color
    colors{ii} = char(colorElement.getTextContent());
end


%% Make a basic material for each original material.
function makeBasicMaterials(colladaElement, reducedElement)
materialElements = GetElementChildren(colladaElement, 'material');
nElements = numel(materialElements);
reducedDoc = reducedElement.getOwnerDocument();
for ii = 1:nElements
    % shallow copy each material
    colladaMaterial = materialElements{ii};
    reducedMaterial = reducedDoc.importNode(colladaMaterial, false);
    reducedElement.appendChild(reducedMaterial);
    
    % shallow copy an effect reference
    colladaRef = GetElementChildren(colladaMaterial, 'instance_effect');
    if ~isempty(colladaRef)
        reducedRef = reducedDoc.importNode(colladaRef{1}, false);
        reducedMaterial.appendChild(reducedRef);
    end
end

%% Make a basic material for each original material.
function makeBasicEffects(colladaElement, reducedElement, colors)
effectElements = GetElementChildren(colladaElement, 'effect');
nElements = numel(effectElements);
reducedDoc = reducedElement.getOwnerDocument();
for ii = 1:nElements
    % shallow copy each effect
    colladaEffect = effectElements{ii};
    reducedEffect = reducedDoc.importNode(colladaEffect, false);
    reducedElement.appendChild(reducedEffect);
    
    % fill in a basic Lambertian effect
    profile = CreateElementChild(reducedEffect, 'profile_COMMON');
    technique = CreateElementChild(profile, 'technique');
    technique.setAttribute('sid', 'common');
    lambert = CreateElementChild(technique, 'lambert');
    diffuse = CreateElementChild(lambert, 'diffuse');
    colorElement = CreateElementChild(diffuse, 'color');
    colorElement.setAttribute('sid', 'diffuse');
    colorElement.setTextContent(colors{ii});
end

%% Make a light in place of fancy lights.
function makeBasicLights(colladaElement, reducedElement)
lightElements = GetElementChildren(colladaElement, 'light');
nElements = numel(lightElements);
reducedDoc = reducedElement.getOwnerDocument();
for ii = 1:nElements
    % check for common light types
    colladaLight = lightElements{ii};
    lightType = GetColladaLightType(colladaLight);
    switch lightType
        case {'point', 'directional', 'spot'}
            % make deep copies of basic light types
            reducedLight = reducedDoc.importNode(colladaLight, true);
            reducedElement.appendChild(reducedLight);
            
        case 'ambient'
            % make shallow copies of ambient lights
            reducedLight = reducedDoc.importNode(colladaLight, false);
            reducedElement.appendChild(reducedLight);
            
            % replace the ambient lights with point lights
            technique = CreateElementChild(reducedLight, 'technique_common');
            point = CreateElementChild(technique, 'point');
            color = CreateElementChild(point, 'color');
            color.setAttribute('sid', 'color');
            color.setTextContent('1 1 1');
            constant_attenuation = CreateElementChild(point, 'constant_attenuation');
            constant_attenuation.setTextContent('1');
            linear_attenuation = CreateElementChild(point, 'linear_attenuation');
            linear_attenuation.setTextContent('0');
            quadratic_attenuation = CreateElementChild(point, 'quadratic_attenuation');
            quadratic_attenuation.setTextContent('1');
    end
end
