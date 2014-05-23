%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a local absoute path to a relative working path.
%   @param originalPath string file name or absolute path to convert
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Converts the given @a originalPath to a relative path, relative to the
% working folder specified by the given @a hints.  See GetWorkingFolder().
%
% @details
% If @a originalPath can be found within the working folder specified by
% the given @a hints, returns the corresponding relative path, starting
% from the working folder.  Otherwise, returns ''.
%
% @details
% Usage:
%   relativePath = GetWorkingRelativePath(originalPath, hints)
%
% @ingroup Utilities
function relativePath = GetWorkingRelativePath(originalPath, hints)

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

% try to resolve using real, existing files
%   which works best for partial file names
workingFolder = GetWorkingFolder('', false, hints);
[isPrefix, relativePath] = IsPathPrefix(workingFolder, originalPath);
if isPrefix
    return
end

% fall back on string comparison of paths
matchIndex = strfind(originalPath, workingFolder);
if 1 == matchIndex
    relativePath = originalPath(numel(workingFolder)+2:end);
else
    relativePath = '';
end
