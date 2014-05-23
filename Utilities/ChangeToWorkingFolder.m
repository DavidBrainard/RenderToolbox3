%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Change to the working folder for a recipe, create it if necessary.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% cd() to the working folder for the given @a hints, used by a recipe.  See
% GetWorkingFolder().  Create the working folder if it doesn't exist yet.
%
% @details
% Returns true if @a folder had to be created.
%
% @details
% Usage:
%   wasCreated = ChangeToWorkingFolder(hints)
%
% @ingroup Utilities
function wasCreated = ChangeToWorkingFolder(hints)

if nargin < 1
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

workingFolder = GetWorkingFolder('', false, hints);
wasCreated = ChangeToFolder(workingFolder);
