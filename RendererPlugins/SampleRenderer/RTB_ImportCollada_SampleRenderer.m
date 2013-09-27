%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file to a PBRT-native scene file.
%   @param colladaFile input Collada parent scene file name or path
%   @param pbrtFile output PBRT-native scene file name or path (optional)
%   @param adjustmentsFile PBRT-native adjustments file name or path (optional)
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Converts the given @a colladaFile ('.dae' or '.xml') to a PBRT .pbrt
% file with the name (and path) given in @a pbrtFile.
%
% @details
% If @a adjustmentsFile is provided, it should be the name of a PBRT-XML
% adjustments xml-file.  Elements of @a adjustmentsFile will
% replace or modify elements of the converted scene file according to
% matching "id" attributes.
%
% @details
% @a hints may be a struct with additional parameters for the converter.
% See GetDefaultHints() for more about batch renderer hints.
%
% @details
% Returns the file name of the new PBRT-native scene file, which might be
% the same as the given @a pbrtFile.  Also returns the PBRT-XML file and
% XML Document Object Model (DOM) document object from which the PBRT file
% was generated.  Also returns a cell array of file names for auxiliary
% files, like geometry files that the PBRT files depends on.
%
% @details
% Usage:
%   [pbrtFile, pbrtXMLFile, pbrtDoc, auxiliary] = ColladaToPBRT(colladaFile, pbrtFile, adjustmentsFile, hints)
%
% @ingroup Utilities
function [pbrtFile, pbrtXMLFile, pbrtDoc, auxiliary] = ColladaToPBRT(colladaFile, pbrtFile, adjustmentsFile, hints)
