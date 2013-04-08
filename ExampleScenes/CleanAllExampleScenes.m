%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Delete output subfolders in the ExampleScenes/ folder.
%   @param outputFolder name of the subfolders to delete
%   @param isDryRun whether to skip file deletion
%
% @details
% Finds all subfolders with the given @a outputFolder name in the
% RenderToolbox3 ExampleScenes/ folder, and deletes each one.  This can be
% used to clean up after TestAllExampleScenes().
%
% @details
% @a outputFolder must be a relative path to append to the path of each
% example scene folder.  If the subfolder path exists, the subfolder will
% be deleted.
%
% @details
% By default, does not actually delete any files.  If @a isDryRun is
% provided and false, really deletes subfolders.
%
% @details
% Returns a cell array of path strings for folders that were deleted (or
% would have been deleted, when @a isDryRun is true).
%
% @details
% Usage:
%   deletedPaths = CleanAllExampleScenes(outputFolder, isDryRun)
%
% @ingroup ExampleScenes
function deletedPaths = CleanAllExampleScenes(outputFolder, isDryRun)

if nargin < 1  || isempty(outputFolder)
    outputFolder = 'test-renderings';
end

if nargin < 2 || isempty(isDryRun)
    isDryRun = true;
end

% find all the ExampleScenes/ that contain outputFolder
exampleFolder = fullfile(RenderToolboxRoot(), 'ExampleScenes');
subfolders = FindFiles(exampleFolder, outputFolder, true);

% delete matching folders
nSubfolders = numel(subfolders);
isDeleted = false(1, nSubfolders);
for ii = 1:nSubfolders
    if exist(subfolders{ii}, 'dir')
        isDeleted(ii) = true;
        if isDryRun
            disp(sprintf('Dry run, would delete:\n  %s', subfolders{ii}));
        else
            rmdir(subfolders{ii}, 's');
        end
    end
end
deletedPaths = subfolders(isDeleted);