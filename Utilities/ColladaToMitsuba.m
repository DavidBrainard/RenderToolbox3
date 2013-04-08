%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada scene file to a Mitusuba scene file.
%   @param colladaFile input Collada file name or path
%   @param mitsubaFile output Mitsuba file name or path (optional)
%   @param adjustmentsFile adjustments file name or path (optional)
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Converts the given @a colladaFile ('.dae' or '.xml') to a mitsuba .xml
% file with the name (and path) given in @a mitsubaFile.
%
% @details
% If @a adjustmentsFile is provided, it should be the name of a partial
% Mitsuba scence file in .xml format.  Elements of @a adjustmentsFile will
% replace or modify elements of the converted scene file according to
% matching "id" attributes.
%
% @details
% Note that RenderToolbox3 uses a custom mechanism for applying adjustments
% to Mitsuba scenes, instead of the built-in Mitusba mechanism.  This
% allows finer-grained adjustments to scene elements.
%
% @details
% @a hints may be a struct with additional parameters for the converter.
% See GetDefaultHints() for more about batch renderer hints.
%
% @details
% Returns the file name of the new Mitsuba file, which might be the same as
% the given @a mitsubaFile.  Also returns an XML Document Object Model
% (DOM) document node that represenets the Mitsuba file.
%
% @details
% Usage:
%   [mitsubaFile, mitsubaDoc] = ColladaToMitsuba(colladaFile, mitsubaFile, adjustmentsFile, hints)
%
% @ingroup Utilities
function [mitsubaFile, mitsubaDoc] = ColladaToMitsuba(colladaFile, mitsubaFile, adjustmentsFile, hints)

%% Parameters
[colladaPath, colladaBase, colladaExt] = fileparts(colladaFile);

if nargin < 2 || isempty(mitsubaFile)
    mitsubaFile = fullfile(colladaPath, [colladaBase '.xml']);
end
[mitsubaPath, mitsubaBase, mitsubaExt] = fileparts(mitsubaFile);
unadjustedFile = fullfile(mitsubaPath, [mitsubaBase 'Unadjusted.xml']);

if nargin < 3 || isempty(adjustmentsFile)
    adjustmentsFile = getpref('Mitsuba', 'adjustmentsFile');
end

if nargin < 4
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Choose film type
if isempty(hints.filmType)
    filmType = 'hdrfilm';
else
    filmType = hints.filmType;
end

%% Invoke the Mitsuba importer.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% find the Mitsuba importer
%   don't pass the adjustments file to the converter
importer = fullfile( ...
    getpref('Mitsuba', 'app'), ...
    getpref('Mitsuba', 'importer'));
fprintf('Converting %s\n  to %s.\n', colladaFile, mitsubaFile);
importCommand = sprintf('%s -r %dx%d -l %s %s %s', ...
    importer, ...
    hints.imageWidth, hints.imageHeight, ...
    filmType, ...
    [colladaBase colladaExt], unadjustedFile);

% run in the destination folder to capture all ouput there
originalFolder = pwd();
cd(mitsubaPath);
[status, result] = unix(importCommand);
cd(originalFolder)
if status ~= 0
    error('Mitsuba file conversion failed\n  %s\n  %s\n', ...
        colladaFile, result);
end

% restore the library search path
setenv(libPathName, originalLibPath);

%% Apply adjustments using the RenderToolbox3 custom mechanism.
%   Mitsuba nodes named "ref" have "id" attrubutes, but are not "id" nodes
excludePattern = '^ref$';
mitsubaDoc = ReadSceneDOM(unadjustedFile, excludePattern);
adjustmentsDoc = ReadSceneDOM(adjustmentsFile, excludePattern);
MergeAdjustments(mitsubaDoc, adjustmentsDoc, excludePattern);
WriteSceneDOM(mitsubaFile, mitsubaDoc);
