%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Check whether one file path is the parent of another.
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
%   isEqual = IsFilePathsEqual(pathA, pathB)
%
% @ingroup Utilities
function [isPrefix, remainder] = IsPathPrefix(pathA, pathB)

% strip off any file base names and extensions
if exist(pathA, 'dir')
    compareA = pathA;
elseif exist(pathA, 'file')
    compareA = fileparts(pathA);
else
    message = [pathA ' is not a file or folder name'];
    error('RenderToolbox3:IsFilePathsEqual', message);
end

if exist(pathB, 'dir')
    compareB = pathB;
    fileB = '';
elseif exist(pathB, 'file')
    [compareB, baseB, extB] = fileparts(pathB);
    fileB = [baseB extB];
else
    message = [pathB ' is not a file or folder name'];
    error('RenderToolbox3:IsFilePathsEqual', message);
end

% use pwd() to compare e.g. absolute and relative paths
startDir = pwd();
errorData = [];
isPrefix = false;
remainder = '';
try
    cd(compareA);
    realPathA = pwd();
    cd(compareB);
    realPathB = pwd();
    
    % match should always occur at beginning
    matchIndex = strfind(realPathB, realPathA);
    if 1 == matchIndex
        isPrefix = true;
        remainder = fullfile(realPathB(numel(realPathA)+2:end), fileB);
    end
    
catch errorData
    % fill in the placeholder, rethrow below
end
cd(startDir);

if ~isempty(errorData)
    rethrow(errorData)
end