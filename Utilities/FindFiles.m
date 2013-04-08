%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Locate files at or below the given folder.
%   @param folder path where to start looking for files
%   @param filter optional regular expression for filtering files
%
% @details
% FindFiles() recursively searches @a folder and its subfolders for files.
% If @a folder is omitted, uses pwd().  By default, returns all files.  @a
% fileFilter may contain a regular expression, in which case only files
% whose names match @fileFilter are included.  Matching is performed on
% full, absolute path names.
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
%   fileList = FindFiles(folder, fileFilter)
%
% @ingroup Utilities
function fileList = FindFiles(folder, fileFilter)

if nargin < 2
    fileFilter = '';
end

if nargin < 1
    folder = pwd();
else
    % convert relative folder to absolute path
    initalFolder = pwd();
    cd(folder)
    folder = pwd();
    cd(initalFolder);
end

d = dir(folder);
isSubfolder = [d.isdir];
files = {d(~isSubfolder).name};
subfolders = {d(isSubfolder).name};

% append files from the present folder
fileList = {};
for ii = 1:numel(files)
    f = files{ii};
    if ~isempty(f) ...
            && f(1) ~= '.' ...
            && f(end) ~= '~' ...
            && isempty(regexpi(f, '.*\.asv'))
        
        absPathFile = fullfile(folder, f);
        if (isempty(fileFilter) ...
                || ~isempty(regexp(absPathFile, fileFilter, 'once')))
            fileList{end+1} = absPathFile;
        end
    end
end

% descend recursively into subfolders
for ii = 1:numel(subfolders)
    sf = subfolders{ii};
    if ~isempty(sf) && ~any(sf=='.')
        absSubfolder = fullfile(folder, sf);
        fileList = cat(2, fileList, FindFiles(absSubfolder, fileFilter));
    end
end
