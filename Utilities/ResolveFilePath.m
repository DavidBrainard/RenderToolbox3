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

blank = {[]};
fileInfo = struct( ...
    'verbatimName', blank, ...
    'rootFolder', blank, ...
    'isRootFolderMatch', blank, ...
    'resolvedPath', blank, ...
    'absolutePath', blank);

if nargin < 1 || isempty(fileName)
    return;
end

if nargin < 2 || isempty(rootFolder)
    rootFolder = pwd();
end

% basic info as given
fileInfo(1).verbatimName = fileName;
fileInfo(1).rootFolder = rootFolder;

% given a path relative to workingFolder?
rootRelative = fullfile(rootFolder, fileName);
if exist(rootRelative, 'file')
    fileInfo(1).absolutePath = rootRelative;
    [fileInfo(1).isRootFolderMatch, fileInfo(1).resolvedPath] = ...
        checkRootPath(rootRelative, rootFolder);
    return;
end

% given a plain file within workingFolder?
matches = FindFiles(rootFolder, fileName, false, true);
if ~isempty(matches)
    fileInfo(1).absolutePath = matches{1};
    [fileInfo(1).isRootFolderMatch, fileInfo(1).resolvedPath] = ...
        checkRootPath(matches{1}, rootFolder);
    return;
end

% given a path relative to pwd()?
pwdRelative = fullfile(pwd(), fileName);
if exist(pwdRelative, 'file')
    fileInfo(1).absolutePath = pwdRelative;
    [fileInfo(1).isRootFolderMatch, fileInfo(1).resolvedPath] = ...
        checkRootPath(pwdRelative, rootFolder);
    return;
end

% given an absolute path or a plain file on the Matlab path?
whichFile = which(fileName);
if ~isempty(whichFile)
    fileInfo(1).absolutePath = whichFile;
    [fileInfo(1).isRootFolderMatch, fileInfo(1).resolvedPath] = ...
        checkRootPath(whichFile, rootFolder);
    return;
end

% file doesn't seem to exist, but try to resolve it based on syntax alone
[matchesRoot, resolvedPath] = checkRootPath(fileName, rootFolder);
if matchesRoot
    fileInfo(1).absolutePath = fullfile(rootFolder, fileName);
    fileInfo(1).isRootFolderMatch = true;
    fileInfo(1).resolvedPath = resolvedPath;
else
    fileInfo(1).absolutePath = '';
    fileInfo(1).isRootFolderMatch = false;
    fileInfo(1).resolvedPath = '';
end


%% Get relative path from rootFolder, if any.
function [isPrefix, resolvedPath] = checkRootPath(path, rootFolder)
[isPrefix, relativePath] = IsPathPrefix(rootFolder, path);
if isPrefix
    resolvedPath = relativePath;
else
    resolvedPath = path;
end
