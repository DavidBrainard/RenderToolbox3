%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a "node" node from a Collada document to a PBRT-XML document.
%   @param id
%   @param stubIDMap
%   @param colladaIDMap
%   @param hints
%
% @details
% Cherry pick from a Collada "node" node in the Collada document
% represented by the given @a colladaIDMap, and populate the corresponding
% node of the stub PBRT-XML document represented by the given @a
% stubIDMap.  @a id is the unique identifier of the "node" node.  @a
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
%   isConverted = ConvertNode(id, stubIDMap, colladaIDMap, hints)
%
% @ingroup ColladaToPBRT
function isConverted = ConvertNode(id, stubIDMap, colladaIDMap, hints)

isConverted = true;

% declare a top-level world object
SetType(stubIDMap, id, 'Attribute', '');

% get translations
colladaPath = {id, ':translate|sid=location'};
colladaValue = GetSceneValue(colladaIDMap, colladaPath);
AddTransform(stubIDMap, id, 'location', 'Translate', colladaValue);

% get X, Y, and Z rotations
colladaPath = {id, ':rotate|sid=rotationZ'};
colladaValue = getConvertedRotation(colladaIDMap, colladaPath);
AddTransform(stubIDMap, id, 'rotationZ', 'Rotate', colladaValue);

colladaPath = {id, ':rotate|sid=rotationY'};
colladaValue = getConvertedRotation(colladaIDMap, colladaPath);
AddTransform(stubIDMap, id, 'rotationY', 'Rotate', colladaValue);

colladaPath = {id, ':rotate|sid=rotationX'};
colladaValue = getConvertedRotation(colladaIDMap, colladaPath);
AddTransform(stubIDMap, id, 'rotationX', 'Rotate', colladaValue);

% get scaling
colladaPath = {id, ':scale|sid=scale'};
colladaValue = GetSceneValue(colladaIDMap, colladaPath);
AddTransform(stubIDMap, id, 'scale', 'Scale', colladaValue);

% Get Collada [x y z angle], convert to PBRT [angle x y z]
function pbrtNum = getConvertedRotation(colladaIDMap, colladaPath)
rotationString = GetSceneValue(colladaIDMap, colladaPath);
rotationNum = StringToVector(rotationString);
pbrtNum = rotationNum([4 1 2 3]);