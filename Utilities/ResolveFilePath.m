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
% Returns an unambiguous path to the first file that matches @a fileName.
% If the match was found within @a rootFolder, this is the relative path to
% the matched file starting from @a rootFolder.  For example,
% @code
% % find a file within rootFolder
% unambiguousPath = ResolveFilePath(fileInRootFolder, rootFolder);
%
% % build the full absolute path, if needed
% fullPath = fullfile(rootFolder, unambiguousPath);
% @endcode
%
% @details
% If the match was found on the Matlab path, and not in @rootFolder,
% returns the full absolute path to the matched file.  For example,
% @code
% % find a file within on the Matlab path
% fullPath = ResolveFilePath(fileOnPath, rootFolder);
% @endcode
%
% @details
% If no match was found, returns an empty string ''.
%
% @details
% In all cases, also returns a logical flag indicating where the match was
% found, if any.  If the flag is true, the match was found within @a
% rootFolder. Otherwise, the flag is false.
%
% @details
% Also returns the root folder that was searched.  This may be equal to the
% given @a rootFolder, or the current folder if @a rootFolder was omitted.
%
% @details
% Usage:
%   [filePath, isRootFolderMatch, rootFolder] = ResolveFilePath(fileName, rootFolder)
%
% @ingroup Utilities
function [filePath, isRootFolderMatch, rootFolder] = ResolveFilePath(fileName, rootFolder)

if nargin < 2 || isempty(rootFolder)
    rootFolder = pwd();
end

matches = FindFiles(rootFolder, fileName);
if ~isempty(matches)
    isRootFolderMatch = true;
    firstMatch = matches{1};
    [isPrefix, filePath] = IsPathPrefix(rootFolder, firstMatch);
    return;
end

isRootFolderMatch = false;
filePath = which(fileName);
