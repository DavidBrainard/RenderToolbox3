%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Is the first path a prefix (i.e. parent) of the second?
%   @param pathA string path for a file or folder that exists
%   @param pathB string path for another file or folder that exists
%
% @details
% Checks whether the given @a pathA is a parent of @a pathB, or if @a pathA
% and @a pathB are equivalent.  If so, @a pathA can be treated as a prefix
% of @a pathB.
%
% @details
% Only compares leading folder paths, and not file names.  For example, in
% both of the following eamples, @a pathA is considered a prefix of @a
% pathB.
% @code
%   % folder paths
%   pathA = '/foo/bar/';
%   pathB = '/foo/bar/';
%   shouldBeTrue = IsFilePathsEqual(pathA, pathB);
%
%   % full file paths
%   pathA = '/foo/bar/fileA.txt';
%   pathB = '/foo/bar/fileB.png';
%   alsoShouldBeTrue = IsFilePathsEqual(pathA, pathB);
% @endcode
%
% @details
% If @a pathA can be considered a prefix of @a pathB, returns true.
% Otherwise returns false.  Also returns the remainder of @a pathB that
% follows @a pathA, if any.  For example,
% @code
%   pathA = '/foo/bar/';
%   pathB = '/foo/bar/baz';
%   [isPrefix, remainder] = IsFilePathsEqual(pathA, pathB);
%   % remainder == 'baz';
%
%   % reproduce pathB
%   pathB = fullfile(pathA, remainder);
% @endcode
%
% @details
% Usage:
%   [isPrefix, remainder] = IsPathPrefix(pathA, pathB)
%
% @ingroup Utilities
function [isPrefix, remainder] = IsPathPrefix(pathA, pathB)

isPrefix = false;
remainder = '';

% strip off any file base names and extensions
if exist(pathA, 'dir')
    compareA = pathA;
elseif exist(pathA, 'file')
    compareA = fileparts(pathA);
    if isempty(compareA) && ~exist(fullfile(pwd(), pathA), 'file')
        % file exists on path, not at pwd()
        compareA = fileparts(which(pathA));
    end
else
    return;
end

if exist(pathB, 'dir')
    compareB = pathB;
    fileB = '';
elseif exist(pathB, 'file')
    [compareB, baseB, extB] = fileparts(pathB);
    if isempty(compareB) && ~exist(fullfile(pwd(), pathB), 'file')
        % file exists on path, not at pwd()
        [compareB, baseB, extB] = fileparts(which(pathB));
    end
    fileB = [baseB extB];
else
    return;
end

% use pwd() to compare e.g. absolute and relative paths
startDir = pwd();
isPrefix = false;
remainder = '';
try
    cd(compareA);
    realPathA = pwd();
catch errorData
    warning(errorData.identifier, errorData.message)
    cd(startDir);
    return;
end
cd(startDir);

try
    cd(compareB);
    realPathB = pwd();
catch errorData
    warning(errorData.identifier, errorData.message)
    cd(startDir);
    return;
end
cd(startDir);

% match should always occur at beginning
matchIndex = strfind(realPathB, realPathA);
if 1 == matchIndex
    isPrefix = true;
    remainder = fullfile(realPathB(numel(realPathA)+2:end), fileB);
end
