%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Locate the user's "MATLAB" documents folder.
%
% @details
% Use the built-in userpath() function to return the path to the user's
% "MATLAB" documents folder.  This folder is usually located in a
% "Documents" folder inside a user's home folder.  This is usually a
% location where Matlab will have permission to write files.
%
% @details
% Users can change their path configuration using userpath().  If for some
% reason userpath() does not return a valid location, returns ''.
%
% @details
% Returns the full absolute path to a user's "MATLAB" documents folder, or
% '' if the documents path could not be found.
%
% @details
% Usage:
%   userFolder = GetUserFolder()
%
% @ingroup Utilities
function userFolder = GetUserFolder()

% get the user's folder from Matlab
userFolder = userpath();

% want a regular path, not a "path string" with colon delimiters
colon = find(pathsep() == userFolder, 1, 'first');
if ~isempty(colon)
    userFolder = userFolder(1:colon-1);
end

% user folder root should not be empty for RenderToolbox3
if isempty(userFolder)
    warning('RenderToolbox3:EmptyUserFolder', ...
        ['Your Matlab user folder is empty!  ' ...
        'Please set one with the userpath() function.']);
end

% can we write into this folder?
[status, info] = fileattrib(userFolder);
if ~info.UserWrite
    warning('User does not have write permission for %s.', userFolder);
    userFolder = '';
end
