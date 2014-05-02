%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Update mappings by resolving expressions to concrete values.
%   @param mappings struct of mappings data from ParseMappings()
%   @param varNames cell array of variable names to be replaced
%   @param varValues cell array of variable values to replace names
%   @param colladaFile name or path of a Collada parent scene file
%   @param adjustments renderer-native adjustments from an ApplyMappings
%   function
%   @param hints struct of RenderToolbox3 options
%
% @details
% Updates the given @a mappings, as returned from ParseMappings(), by
% replacing expressions with concrete values.  Several different kinds of
% expression will be replaced, as described below.
%
% @details
% Replaces parenthetical () expressions that contain variable names with
% corresponding variable values.  For example, would replace all occurences
% of the expression (foo) with the value of the foo variable.  @a varNames
% should be a cell array of string variable names.  @a varValues should be
% a cell array of variable values, with the same size as @a varNames.
%
% @details
% For right-hand values, expressions in square brackets [] should contain
% Scene DOM Paths that refer to nodes in the @a colladaFile.  These
% expressions will be replaced with the string values of the referenced
% nodes.  For example, the expression [Camera:translate|sid=location] might
% be replaces with XYZ coordinates such as "2 2 25".
%
% @details
% For right-hand values, expressions in angle brackets <> should contain
% Scene DOM Paths that refer to nodes in renderer @a adjustments.  The
% presence of these expressions assumes that @a adjustments contains the
% name of an XML adjustments file, which may not be true for all renderers.
% These expressions will be replaced with the string values of the
% referenced nodes.  For example, the expression
% [integrator:parameter|name=pixelsamples] might be replaces with a string
% like "8".
%
% @details
% All right-hand values will be evaluated as expressions that might match
% the names of files within @a hints.workingFolder or on the Matlab path.
% Whenever a right-hand value does match the name of such a a file, the
% value will be replaced with an unambiguous path to the matched file.
% Matched files that are within @a hints.workingFolder will be replaced
% with relative paths starting at @a hints.workingFolder.  Matched files
% from the Matlab path will be replaced with full absoulte path names.
%
% @details
% Returns the given @a mappings, updated with expressions replaced by
% concrete values.  Also returns a struct array describing files
% encountered during processing, as returned from ResolveFilePath().
%
% @details
% Used internally by MakeSceneFiles().
%
% @details
% Usage:
%   [mappings, requiredFiles] = ResolveMappingsValues(mappings, varNames, varValues, colladaFile, adjustments, hints)
%
% @ingroup Mappings
function [mappings, requiredFiles] = ResolveMappingsValues(mappings, varNames, varValues, colladaFile, adjustments, hints)
requiredFiles = ResolveFilePath('');

% read the colladaFile
[colladaDoc, colladaIDMap] = ReadSceneDOM(colladaFile);

% read adjustments XML file, if any
adjustDoc = [];
adjustIDMap = [];
if ischar(adjustments)
    [adjustDoc, adjustIDMap] = ReadSceneDOM(adjustments);
end

for mm = 1:numel(mappings)
    % replace (varName) expressions with varValue values
    map = mappings(mm);
    for nn = 1:numel(varNames);
        varPattern = ['\(' varNames{nn} '\)'];
        map.left.value = ...
            regexprep(map.left.value, varPattern, varValues{nn});
        map.right.value = ...
            regexprep(map.right.value, varPattern, varValues{nn});
    end
    
    % replace [] and <> expressions with XML node values
    if strcmp('[]', map.right.enclosing)
        % '[]' look up a Collada scene path
        map.right.value = GetSceneValue(colladaIDMap, map.right.value);
        
    elseif ~isempty(adjustIDMap) && strcmp('<>', map.right.enclosing)
        % '<>' look up an adjustments file scne path
        map.right.value = GetSceneValue(adjustIDMap, map.right.value);
    end
    
    % find files within working folder or on Matlab path
    if ~isempty(regexp(map.right.value, '\.\S*$', 'once'))
        fileInfo = ResolveFilePath(map.right.value, hints.workingFolder);
        if ~isempty(fileInfo) && ~isempty(fileInfo.resolvedPath)
            requiredFiles(end+1) = fileInfo;
            map.right.value = fileInfo.resolvedPath;
        end
    end
    
    mappings(mm) = map;
end
