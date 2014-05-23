%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Change to the given folder, create it if necessary.
%   @param folder path where to cd() to
%
% @details
% Just cd() to the @a folder.  Create it if it doesn't exist already.
%
% @details
% Returns true if @a folder had to be created.
%
% @details
% Usage:
%   wasCreated = ChangeToFolder(folder)
%
% @ingroup Utilities
function wasCreated = ChangeToFolder(folder)
wasCreated = false;

if ~exist(folder, 'dir')
    mkdir(folder);
    wasCreated = true;
end

cd(folder);
