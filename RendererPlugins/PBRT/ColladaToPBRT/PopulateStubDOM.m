%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Populate a PBRT-XML "stub" document with Collada data.
%   @param stubIDMap
%   @param colladaIDMap
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Fills in a PBRT-XML stub document with data from a Collada scene file.
% @a stubIDMap must be an "id map" as returned from CreateStubDOM().  @a
% colladaIDMap must be an "id map" as returned from ReadSceneDom().  @a
% hints is a struct of parameters that inform the converions, such as
% desired image dimensions.
%
% @details
% Used internally by ColladaToPBRT().
%
% @details
% Usage:
%   PopulateStubDOM(stubIDMap, colladaIDMap, hints)
%
% @ingroup ColladaToPBRT
function PopulateStubDOM(stubIDMap, colladaIDMap, hints)

% both documents must have the same IDs
stubIDs = stubIDMap.keys();
colladaIDs = colladaIDMap.keys();
if ~all(strcmp(sort(stubIDs), sort(colladaIDs)))
    error('Stub IDs and Collada IDs must match.');
end

% iterate node IDs.
for ii = 1:numel(stubIDs)
    id = stubIDs{ii};
    % ignore the top-level document node
    if strcmp('document', id)
        continue;
    end
    colladaNode = colladaIDMap(id);
    nodeType = char(colladaNode.getNodeName());
    
    % delegate conversion for each node type.
    switch nodeType
        case 'node'
            isConverted = ConvertNode(id, stubIDMap, colladaIDMap, hints);
            
        case 'camera'
            isConverted = ConvertCamera(id, stubIDMap, colladaIDMap, hints);
            
        case 'light'
            isConverted = ConvertLight(id, stubIDMap, colladaIDMap, hints);
            
        case 'material'
            % looks at Collada "effect" and "image" as well
            isConverted = ConvertMaterial(id, stubIDMap, colladaIDMap, hints);
            
        case 'geometry'
            isConverted = ConvertGeometry(id, stubIDMap, colladaIDMap, hints);
            
        case 'effect'
            % remove from the output (handled in material case)
            isConverted = false;
            
        case 'image'
            % remove from the output (handled in material case)
            isConverted = false;
            
        case 'source'
            % remove from the output (handled in geometry case)
            isConverted = false;
            
        case 'float_array'
            % remove from the output (handled in geometry case)
            isConverted = false;
            
        case 'vertices'
            % remove from the output (handled in geometry case)
            isConverted = false;
            
        case 'visual_scene'
            % remove from the output (redundant)
            isConverted = false;
            
        otherwise
            fprintf('Not converted: "%s" %s.\n', id, nodeType);
            isConverted = false;
    end
    
    if isConverted
        % find "instance" references to other nodes
        ConvertReferences(id, stubIDMap, colladaIDMap);
    else
        % remove node from the output
        RemoveSceneNode(stubIDMap, {id});
    end
end