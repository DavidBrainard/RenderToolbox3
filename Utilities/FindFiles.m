%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Locate files at or below the given folder.
%   @param folder path where to start looking for files
%   @param filter optional regular expression for filtering files
%   @param isFolders whether to search for files as well as folders
%   @param isExact whether to use @a filter for exact file name matching
%
% @details
% FindFiles() recursively searches @a folder and its subfolders for files.
% If @a folder is omitted, uses pwd().  By default, returns all files.  @a
% filter may contain a regular expression, in which case only files
% whose names match @filter are included.  Matching is performed on
% full, absolute path names.
%
% @details
% By default, only returns file names, not folder names.  If @a isFolders
% is provided and true, returns folder names as well as file names.
%
% @details
% Ignores subfolders that contain '.'.  Ignores files that start with '.'
% or end with "~" or "ASV".
%
% @details
% Returns a cell array of string which are the full, absolute path names of
% files that were found and matched.
%
% @details
% Usage:
%   fileList = FindFiles(folder, filter, isFolders, isExact)
%
% @ingroup Utilities
function fileList = FindFiles(folder, filter, isFolders, isExact)

if nargin < 4 || isempty(isExact)
    isExact = false;
end

if nargin < 3 || isempty(isFolders)
    isFolders = false;
end

if nargin < 2
    filter = '';
end

if nargin < 1 || isempty(folder)
    folder = pwd();
    
else
    % convert relative folder to absolute path
    initalFolder = pwd();
    cd(folder)
    folder = pwd();
    cd(initalFolder);
end

% find all files in the present folder
d = dir(folder);
isSubfolder = [d.isdir];
files = {d(~isSubfolder).name};
subfolders = {d(isSubfolder).name};

% include the present folder itself?
if isFolders && checkMatch(folder, filter, isExact)
    fileList = {folder};
else
    fileList = {};
end

% append files from the present folder
for ii = 1:numel(files)
    f = files{ii};
    if ~isempty(f) ...
            && f(1) ~= '.' ...
            && f(end) ~= '~' ...
            && isempty(regexpi(f, '.*\.asv'))
        
        absPathFile = fullfile(folder, f);
        if checkMatch(absPathFile, filter, isExact)
            fileList{end+1} = absPathFile;
        end
    end
end

% descend recursively into subfolders
for ii = 1:numel(subfolders)
    sf = subfolders{ii};
    if ~isempty(sf) && ~any(sf=='.')
        absSubfolder = fullfile(folder, sf);
        fileList = cat(2, fileList, ...
            FindFiles(absSubfolder, filter, isFolders, isExact));
    end
end

function isMatch = checkMatch(filePath, filter, isExact)
if isExact
    [pathPrefix, baseName, extension] = fileparts(filePath);
    isMatch = strcmp(filter, [baseName, extension]) ...
        || strcmp(filter, filePath);
else
    isMatch = isempty(filter) || ~isempty(regexp(filePath, filter, 'once'));
end
