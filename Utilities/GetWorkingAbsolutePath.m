%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a relative working path to a local absoute path.
%   @param originalPath string relative working path to convert
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Converts the given @a originalPath to a local absolute path.  Assumes
% that @a originalPath is a relative path relative to the working folder
% specified by the given @a hints.  See GetWorkingFolder().
%
% @details
% Usage:
%   absolutePath = GetWorkingAbsolutePath(originalPath, hints)
%
% @ingroup Utilities
function absolutePath = GetWorkingAbsolutePath(originalPath, hints)

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

workingFolder = GetWorkingFolder('', false, hints);
absolutePath = fullfile(workingFolder, originalPath);
