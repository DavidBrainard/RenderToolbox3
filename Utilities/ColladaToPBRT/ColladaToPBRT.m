%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada scene file to a PBRT scene file.
%   @param colladaFile input Collada file name or path
%   @param pbrtFile output PBRT file name or path (optional)
%   @param adjustmentsFile adjustments file name or path (optional)
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
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
% Returns the file name of the new PBRT file, which might be the same as
% the given @a pbrtFile.  Also returns the PBRT-XML Document Object Model
% (DOM) document node from which the PBRT file was generated.
%
% @details
% Usage:
%   [pbrtFile, pbrtDoc] = ColladaToPBRT(colladaFile, pbrtFile, adjustmentsFile, hints)
%
% @ingroup Utilities
function [pbrtFile, pbrtDoc] = ColladaToPBRT(colladaFile, pbrtFile, adjustmentsFile, hints)

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

% run in the destination folder to capture all ouput there
originalFolder = pwd();
cd(pbrtPath);

% read the collada file
[colladaDoc, colladaIDMap] = ReadSceneDOM(colladaFile);

% create a new PBRT-XML file
%   merge in nodes from the adjustments file
[pbrtDoc, pbrtIDMap] = CreateStubDOM(colladaIDMap, 'pbrt_xml');
adjustmentsDoc = ReadSceneDOM(adjustmentsFile);
PopulateStubDOM(pbrtIDMap, colladaIDMap, hints);
MergeAdjustments(pbrtDoc, adjustmentsDoc);
WriteSceneDOM(xmlFile, pbrtDoc);

% dump the PBRT-XML file into a .pbrt text file
WritePBRTFile(pbrtFile, xmlFile, hints);

cd(originalFolder)

% clean up the intermediate PBRT-XML file
if hints.isDeleteTemp
    delete(xmlFile);
end