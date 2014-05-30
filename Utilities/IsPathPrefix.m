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
%   pathB = '/foo/bar/baz';
%   shouldBeTrue = IsPathPrefix(pathA, pathB);
%
%   % full file paths
%   pathA = '/foo/bar/fileA.txt';
%   pathB = '/foo/bar/baz/fileB.png';
%   alsoShouldBeTrue = IsPathPrefix(pathA, pathB);
% @endcode
%
% @details
% If @a pathA can be considered a prefix of @a pathB, returns true.
% Otherwise returns false.  Also returns the remainder of @a pathB that
% follows @a pathA, if any.  For example,
% @code
%   pathA = '/foo/bar/';
%   pathB = '/foo/bar/baz/thing.txt';
%   [isPrefix, remainder] = IsPathPrefix(pathA, pathB);
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

[tokensA, baseA, extA] = pathTokens(pathA);
[tokensB, baseB, extB] = pathTokens(pathB);

nA = numel(tokensA);
nB = numel(tokensB);
nCompare = min(nA, nB);

if nA > nB
    % A cannot be a prefix because it's longer than B
    return;
end

for ii = 1:nCompare
    % A and B disagree about this parent folder
    if ~strcmp(tokensA{ii}, tokensB{ii})
        return;
    end
end

isPrefix = true;
remainder = fullfile(tokensB{nCompare+1:end}, [baseB, extB]);

%% Break a full path into separate tokens.
function [tokens, base, ext] = pathTokens(path)
[folder, base, ext] = fileparts(path);

if isempty(ext)
    % treat whole thing as a path
    tokens = folderTokens(fullfile(folder, base));
    base = '';
else
    % take off trailing file name
    tokens = folderTokens(fullfile(folder));
end


%% Break a folder path into folder tokens.
function tokens = folderTokens(path)
if isempty(path)
    tokens = {};
    return;
end
scanResult = textscan(path, '%s', 'Delimiter', filesep());
tokens = scanResult{1};
