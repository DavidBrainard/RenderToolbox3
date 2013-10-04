%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Modify the MaterialSphere Collada document once.
%   @param docNode XML Collada document node Java object
%   @param hints struct of RenderToolbox3 options
%
% @details
% This function remodels the MaterialSphere Collada parent scene by
% making flat faces on the sphere.  This applies to all conditions.
%
% @details
% See RTB_BeforeAll_SampleRemodeler() for more about RenderToolbox3
% Remodeler BeforeAll functions.
%
% Usage:
%   docNode = RTB_BeforeAll_MaterialSphere(docNode, hints)
%
% @ingroup RemodelerPlugins
function docNode = RTB_BeforeAll_MaterialSphere(docNode, hints)

% use SceneDOM functions to get the sphere vertex positions
% this requires detailed knowledge of the Collada parent scene file
idMap = GenerateSceneIDMap(docNode);
posPath = {'Icosphere-mesh-positions-array'};
posString = GetSceneValue(idMap, posPath);
pos = StringToVector(posString);

% break position into xyz components
x = pos(1:3:end);
y = pos(2:3:end);
z = pos(3:3:end);

% get positions relative to sphere center
centerX = mean(x);
localX = x - centerX;
centerY = mean(y);
localY = y - centerY;
centerZ = mean(z);
localZ = z - centerZ;

% truncate vertex positions to add flat faces to the sphere
clip = 0.8 * max(localX);
localX(localX > clip) = clip;
localX(localX < -clip) = -clip;
localY(localY > clip) = clip;
localY(localY < -clip) = -clip;
localZ(localZ > clip) = clip;
localZ(localZ < -clip) = -clip;

% get new global positions
x = localX + centerX;
y = localY + centerY;
z = localZ + centerZ;
pos(1:3:end) = x;
pos(2:3:end) = y;
pos(3:3:end) = z;

% modify the Collada document with the jittered vertex positions
posString = VectorToString(pos);
SetSceneValue(idMap, posPath, posString);