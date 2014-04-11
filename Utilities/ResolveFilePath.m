%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Resolve a path to the given file.
%   @param fileName name or path to a file that exists
%   @param rootFolder path to a folder that might contain @a fileName
%
% @details
% Searches for the given @a fileName, which might be a plain file name, or
% a relative or absolute path to a file.  First searches within @a
% rootFolder and its subfolders for a file that matches @a fileName.  If no
% match is found within @a rootFolder, searches for a matching file on the
% Matlab path.
%
% @details
% If @a rootFolder is omitted, searches with the current folder and its
% subfolders instead.
%
% @details
% Returns a struct of info about the given @a fileName, with the following
% fields:
%   - @b verbatimName - @a fileName exactly as given
%   - @b rootFolder - @a rootFolder exactly as given, or pwd()
%   - @b isRootFolderMatch - true only if @a fileName was found within @a
%   rootFolder
%   - @b resolvedPath - An unambiguous path to the given @a fileName.
%   - @b absolutePath - full absolute path to the given @a fileName, if
%   found.
%   .
%
% @details
% @b resolvedPath will be an unambiguous path to the first file that
% matches @a fileName.   If the match was found within @a rootFolder, @b
% resolvedPath is the relative path to the matched file, starting from @b
% rootFolder.  If the match was found on the Matlab path, but not in
% @b rootFolder, @b resolvedPath is the full absolute path to the matched
% file.  If no match was found, @b resolvedPath is the empty string ''.
%
% @details
% In all cases, @b isRootFolderMatch indicates whether or not a match was
% found within @a rootFolder.  When @b isRootFolderMatch is true, @b
% resolvedPath should be treated as a relative path.
%
% @details
% Usage:
%   fileInfo = ResolveFilePath(fileName, rootFolder)
%
% @ingroup Utilities
function fileInfo = ResolveFilePath(fileName, rootFolder)

fileInfo = struct( ...
    'verbatimName', {}, ...
    'rootFolder', {}, ...
    'isRootFolderMatch', {}, ...
    'resolvedPath', {}, ...
    'absolutePath', {});

if nargin < 1 || isempty(fileName)
    return;
end

if nargin < 2 || isempty(rootFolder)
    rootFolder = pwd();
end

fileInfo(1).verbatimName = fileName;
fileInfo(1).rootFolder = rootFolder;
fileInfo(1).isRootFolderMatch = false;
if exist(fileName, 'file')
    whichFile = which(fileName);
    if isempty(whichFile)
        fileInfo(1).resolvedPath = fileName;
        fileInfo(1).absolutePath = fileName;
    else
        fileInfo(1).resolvedPath = whichFile;
        fileInfo(1).absolutePath = whichFile;
        
    end
end

matches = FindFiles(rootFolder, fileName, false, true);
if ~isempty(matches)
    firstMatch = matches{1};
    [isPrefix, relativePath] = IsPathPrefix(rootFolder, firstMatch);
    fileInfo(1).isRootFolderMatch = true;
    fileInfo(1).resolvedPath = relativePath;
    fileInfo(1).absolutePath = fullfile(rootFolder, relativePath);
end