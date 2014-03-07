%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Check whether two given file paths are equivalent.
%   @param pathA string path for a file or folder that exists
%   @param pathB string path for another file or folder that exists
%
% @details
% Returns true if the given @a pathA refers to the same location as @a
% pathB.  Attempts to compare paths using the file system, not just by
% comparing strings.
%
% @details
% Only compares leading paths to files, and not file names themselves.  For
% example, the following eamples should both return true:
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
% Usage:
%   isEqual = IsFilePathsEqual(pathA, pathB)
%
% @ingroup Utilities
function isEqual = IsFilePathsEqual(pathA, pathB)

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
elseif exist(pathB, 'file')
    compareB = fileparts(pathB);
else
    message = [pathB ' is not a file or folder name'];
    error('RenderToolbox3:IsFilePathsEqual', message);
end

% use pwd() to compare e.g. absolute and relative paths
startDir = pwd();
errorData = [];
isEqual = false;
try
    cd(compareA);
    realPathA = pwd();
    cd(compareB);
    realPathB = pwd();
    isEqual = strcmp(realPathA, realPathB);
    
catch errorData
    % fill in the placeholder, rethrow below
end
cd(startDir);

if ~isempty(errorData)
    rethrow(errorData)
end