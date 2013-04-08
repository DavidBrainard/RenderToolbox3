%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada scene file to a PBRT scene file.
%   @param colladaFile input Collada file name or path
%   @param pbrtFile output PBRT file name or path (optional)
%   @param adjustmentsFile adjustments file name or path (optional)
%   @param hints struct of hints from GetDefaultHints() (optional)
%
% @details
% Converts the given @a colladaFile ('.dae' or '.xml') to a PBRT .pbrt
% file with the name (and path) given in @a pbrtFile.
%
% @details
% If @a adjustmentsFile is provided, it should be the name of a PBRT-XML
% adjustments file in .xml format.  Elements of @a adjustmentsFile will
% replace or modify elements of the converted scene file according to
% matching "id" attributes.
%
% @details
% @a hints may be a struct with additional parameters for the converter.
% See GetDefaultHints() for more about batch renderer hints.
%
% @details
% Usage:
%   ColladaToPBRT(colladaFile, pbrtFile, adjustmentsFile, hints)
%
% @ingroup Utilities
function ColladaToPBRT(colladaFile, pbrtFile, adjustmentsFile, hints)

%% Parameters
[colladaPath, colladaBase, colladaExt] = fileparts(colladaFile);

if nargin < 2 || isempty(pbrtFile)
    pbrtFile = fullfile(colladaPath, [colladaBase '.pbrt']);
end
[pbrtPath, pbrtBase, pbrtExt] = fileparts(pbrtFile);
xmlFile = fullfile(pbrtPath, [pbrtBase '.pbrt.xml']);

if nargin < 3 || isempty(adjustmentsFile)
    adjustmentsFile = getpref('PBRT', 'adjustmentsFile');
end

if nargin < 4
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Choose film type and adjustments file.
if isempty(hints.filmType)
    hints.filmType = 'image';
end

%% Invoke several Collada to PBRT utilities.
fprintf('Converting %s\n  to %s.\n', colladaFile, pbrtFile);

% read the collada file
[colladaDoc, colladaIDMap] = ReadSceneDOM(colladaFile);

% create a new PBRT-XML file
%   merge in nodes from the adjustments file
[pbrtDoc, pbrtIDMap] = CreateStubDOM(colladaIDMap, 'pbrt_xml');
[adjustmentsDoc, adjustmentsIDMap] = ReadSceneDOM(adjustmentsFile);
PopulateStubDOM(pbrtIDMap, colladaIDMap, hints);
MergeAdjustments(pbrtIDMap, adjustmentsIDMap);
WriteSceneDOM(xmlFile, pbrtDoc);

% dump the PBRT-XML file into a .pbrt text file
WritePBRTFile(pbrtFile, xmlFile, hints);

% clean up the intermediate PBRT-XML file
if hints.isDeleteIntermediates
    delete(xmlFile);
end