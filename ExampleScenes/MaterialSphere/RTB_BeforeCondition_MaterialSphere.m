%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Modify a Collada document once per condition, before applying mappings.
%   @param docNode XML Collada document node Java object
%   @param mappings struct of mappings data from ParseMappings()
%   @param varNames cell array of conditions file variable names
%   @param varValues cell array of variable values for current condition
%   @param conditionNumber the number of the current condition
%   @param hints struct of RenderToolbox3 options
%
% @details
% This function remodels the MaterialSphere Collada parent scene by
% randomly jittering the vertex normals of the sphere.  This is applied
% separately for each condition, so the sphere in each condition should
% have different-looking bumps.
%
% @details
% See RTB_BeforeCondition_SampleRemodeler() for more about RenderToolbox3
% Remodeler BeforeCondition functions.
%
% Usage:
%   docNode = RTB_BeforeCondition_MaterialSphere(docNode, mappings, varNames, varValues, conditionNumber, hints)
function docNode = RTB_BeforeCondition_MaterialSphere(docNode, mappings, varNames, varValues, conditionNumber, hints)

% use SceneDOM functions to get the sphere normal coordinates
% this requires detailed knowledge of the Collada parent scene file
idMap = GenerateSceneIDMap(docNode);
normPath = {'Icosphere-mesh-normals-array'};
normString = GetSceneValue(idMap, normPath);
norm = StringToVector(normString);

% jitter all the normal components by a few percent
scale = 0.2;
jitter = (1-scale/2) + scale*rand(size(norm));
norm = norm .* jitter;

% update the Collada document with new normals
normString = VectorToString(norm);
SetSceneValue(idMap, normPath, normString);
