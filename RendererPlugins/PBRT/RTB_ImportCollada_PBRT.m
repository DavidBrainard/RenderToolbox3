%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada parent scene file the PBRT native format
%   @param colladaFile input Collada parent scene file name or path
%   @param adjustments native adjustments data, or file name or path
%   @param imageName the name to use for this scene and new files
%   @param hints struct of RenderToolbox3 options
%
% @details
% This is the RenderToolbox3 "ImportCollada" function for PBRT.
%
% @details
% For more about ImportCollada functions see
% RTB_ImportCollada_SampleRenderer().
%
% @details
% Usage:
%   scene = RTB_ImportCollada_PBRT(colladaFile, adjustments, imageName, hints)
function scene = RTB_ImportCollada_PBRT(colladaFile, adjustments, imageName, hints)

% choose new files to create
scenesFolder = GetWorkingFolder('scenes', true, hints);
tempFolder = GetWorkingFolder('temp', true, hints);
pbrtFile = fullfile(scenesFolder, [imageName '.pbrt']);
pbrtXMLFile = fullfile(tempFolder, [imageName 'pbrt.xml']);
adjustmentsFile = fullfile(tempFolder, [imageName 'Adjustments.xml']);

% report new files as relative paths
scene.colladaFile = GetWorkingRelativePath(colladaFile, hints);
scene.pbrtFile = GetWorkingRelativePath(pbrtFile, hints);
scene.pbrtXMLFile = GetWorkingRelativePath(pbrtXMLFile, hints);
scene.adjustmentsFile = GetWorkingRelativePath(adjustmentsFile, hints);

% image is a safe default film for PBRT
if isempty(hints.filmType)
    hints.filmType = 'image';
end

if hints.isReuseSceneFiles
    % locate exsiting scene files, but don't produce new ones
    disp('Reusing scene files for PBRT scene:')
    disp(scene)
    drawnow();
    
else
    %% Invoke several Collada to PBRT utilities.
    fprintf('Converting %s\n  to %s.\n', colladaFile, pbrtFile);
    
    % read the collada file
    [colladaDoc, colladaIDMap] = ReadSceneDOM(colladaFile);
    
    % create a new PBRT-XML document
    [pbrtDoc, pbrtIDMap] = CreateStubDOM(colladaIDMap, 'pbrt_xml');
    PopulateStubDOM(pbrtIDMap, colladaIDMap, hints);
    
    % add a film node to the to the adjustments document
    filmNodeID = 'film';
    filmPBRTIdentifier = 'Film';
    adjustRoot = adjustments.docNode.getDocumentElement();
    filmNode = CreateElementChild(adjustRoot, filmPBRTIdentifier, filmNodeID);
    adjustments.idMap(filmNodeID) = filmNode;
    
    % fill in the film parameters
    SetType(adjustments.idMap, filmNodeID, filmPBRTIdentifier, hints.filmType);
    AddParameter(adjustments.idMap, filmNodeID, ...
        'xresolution', 'integer', hints.imageWidth);
    AddParameter(adjustments.idMap, filmNodeID, ...
        'yresolution', 'integer', hints.imageHeight);
    
    % write the adjusted PBRT-XML document to file
    MergeAdjustments(pbrtDoc, adjustments.docNode);
    WriteSceneDOM(pbrtXMLFile, pbrtDoc);
    WriteSceneDOM(adjustmentsFile, adjustments.docNode);
    
    % dump the PBRT-XML document into a .pbrt text file
    WritePBRTFile(pbrtFile, pbrtXMLFile, hints);
end
