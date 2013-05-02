%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Add the given file or folder to the Matlab path.
%   @param working string path to a file or folder
%   @param isRecursive whether to add subfolders of @a working folder
%
% @details
% Adds to the Matlab path, starting with the given @a working file or path.
% If @a working is a file, determines the file's folder using the built-in
% which() function.  If @a isRecursive is provided and true, recursively
% adds subfolders of @a working, using the built-in genpath().  Prepends
% new path entries to the current Matlab path.
%
% @details
% Attempts to add new path entries only if they are not already part of the
% current path.  Ignores ".svn" and ".git" path entries.
%
% @details
% Does not invoke savepath(), so changes to the Matlab path will remain
% only for the current Matlab session.
%
% @details
% Returns the new Matlab path, with new @a working folder path entries
% prepended.  Also returns the new entries that were added to the path.
%
% @details
% Usage:
%   [updatedPath, newEntries] = AddWorkingPath(working, isRecursive)
%
% @ingroup Utilities
function [updatedPath, newEntries] = AddWorkingPath(working, isRecursive)

if 2 == exist(working, 'file')
    % get the folder of the file
    working = fileparts(which(working));
end

if nargin < 2 || isempty(isRecursive)
    isRecursive = false;
end

% add path entries below the working folder?
if isRecursive
    workingPath = genpath(working);
else
    workingPath = working;
end

% check which entries are already on the Matlab path
%   and are not silly .svn or .git folders
matlabPath = path();
workingPathParts = textscan(workingPath, '%s', 'Delimiter', ':');
nParts = length(workingPathParts{1});
isNeeded = false(1, nParts);
for ii = 1:nParts
    entry = workingPathParts{1}{ii};
    isNeeded(ii) = isempty(strfind(matlabPath, entry)) ...
        && isempty(regexp(entry, '\.git|\.svn', 'once'));
end

% prepend entries to the path
newEntries = sprintf('%s:', workingPathParts{1}{isNeeded});
path(newEntries, matlabPath);

% return the updated path
updatedPath = path();