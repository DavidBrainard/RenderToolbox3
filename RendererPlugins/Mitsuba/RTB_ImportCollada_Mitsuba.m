%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file the Mitsuba native format
%   @param colladaFile input Collada parent scene file name or path
%   @param adjustments native adjustments data, or file name or path
%   @param outputFolder folder where to write new files
%   @param imageName the name to use for this scene and new files
%   @param hints struct of RenderToolbox3 options
%
% @details
% This is the RenderToolbox3 "ImportCollada" function for Mitsuba.
%
% @details
% For more about ImportCollada functions see
% RTB_ImportCollada_SampleRenderer().
%
% @details
% Usage:
%   [scene, requiredFiles] = RTB_ImportCollada_Mitsuba(colladaFile, adjustments, outputFolder, imageName, hints)
%
% @ingroup RendererPlugins
function [scene, requiredFiles] = RTB_ImportCollada_Mitsuba(colladaFile, adjustments, outputFolder, imageName, hints)

% declare new and required files
scene.colladaFile = colladaFile;
scene.mitsubaFile = fullfile(outputFolder, [imageName '.xml']);
scene.unadjustedMitsubaFile = fullfile(outputFolder, [imageName 'Unadjusted.xml']);
scene.adjustmentsFile = fullfile(outputFolder, [imageName 'Adjustments.xml']);
requiredFiles = ...
    {scene.mitsubaFile, scene.unadjustedMitsubaFile, scene.adjustmentsFile};

% high-dynamic-range is a good default film for Mitsuba
if isempty(hints.filmType)
    hints.filmType = 'hdrfilm';
end

%% Invoke the Mitsuba importer.
% set the dynamic library search path
[newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath();

% invoke the Mitsuba importer
[colladaPath, colladaBase, colladaExt] = fileparts(colladaFile);
importer = fullfile( ...
    getpref('Mitsuba', 'app'), ...
    getpref('Mitsuba', 'importer'));
fprintf('Converting %s\n  to %s.\n', colladaFile, scene.mitsubaFile);
importCommand = sprintf('%s -r %dx%d -l %s %s %s', ...
    importer, ...
    hints.imageWidth, hints.imageHeight, ...
    hints.filmType, ...
    [colladaBase colladaExt], ...
    scene.unadjustedMitsubaFile);

% run in the destination folder to capture all ouput there
originalFolder = pwd();
cd(outputFolder);
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
mitsubaDoc = ReadSceneDOM(scene.unadjustedMitsubaFile, excludePattern);
MergeAdjustments(mitsubaDoc, adjustments.docNode, excludePattern);
WriteSceneDOM(scene.mitsubaFile, mitsubaDoc);
WriteSceneDOM(scene.adjustmentsFile, adjustments.docNode);

%% Detect auxiliary geometry files.
auxiliaryFiles = FindFiles(outputFolder, '\.serialized');
requiredFiles = cat(2, requiredFiles, auxiliaryFiles);
