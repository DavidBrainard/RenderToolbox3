%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a local file path to a RenderToolbox3 "portable" path.
%   @param localPath string local file or path
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Scans the given @a localPath to determine whether it is located
% underneath one of the RenderToolbox3 configurable output folders, such as
%   - 'tempFolder' - the path to temporary files
%   - 'outputDataFolder' - the path to output data files
%   - 'outputImageFolder' - the path to output image files
%   - 'resourcesFolder' - the path to recipe resource dependencies
%   .
%
% @details
% If @a localPath path is located under one of these output paths, returns
% a "portable" version of the same path with the output path name replaced
% by a placeholder.  Otherwise, returns @a localPath unchanged.
%
% Use PortablePathtoLocal() to convert the returned portable path back to a
% local path, on this or another RenderToolbox3 machine.
%
% @details
% If @a hints is provided, uses RenderToolbox3 output path names like @a
% hings.tempFolder.  Otherwise uses getpref('RenderToolbox3',
% 'tempFolder').
%
% @details
% Usage:
%   portablePath = LocalPathToPortablePath(localPath, hints)
%
% @ingroup Utilities
function portablePath = LocalPathToPortablePath(localPath, hints)

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

% only interested in output path roots
hints.outputSubfolder = '';

pathNames = {'tempFolder', 'outputDataFolder', 'outputImageFolder', 'resourcesFolder'};
portablePath = localPath;
delimiter = '@RTB@';
for ii = 1:numel(pathNames)
    pathName = pathNames{ii};
    outputPath = GetOutputPath(pathName, hints);
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end
    [isPrefix, remainder] = IsPathPrefix(outputPath, localPath);
    if isPrefix
        portablePrefix = [delimiter pathName delimiter];
        portablePath = fullfile(portablePrefix, remainder);
        return
    end
end
