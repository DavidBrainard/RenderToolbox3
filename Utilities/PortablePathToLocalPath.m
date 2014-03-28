%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a RenderToolbox3 "portable" path to a local path.
%   @param portablePath string portable path from LocalPathToPortablePath()
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Scans the given @a portablePath to determine whether it contains a
% placeholder for one of the RenderToolbox3 configurable output folders,
% such as
%   - 'tempFolder' - the path to temporary files
%   - 'outputDataFolder' - the path to output data files
%   - 'outputImageFolder' - the path to output image files
%   - 'resourcesFolder' - the path to recipe resource dependencies
%   .
%
% @details
% If @a portablePath does contain such a placeholder, it is considered a
% "portable" version of an actual local file path.  The placeholder is
% replaced with the value of the corresponding RenderToolbox3 output path,
% as configured on the local machine and the new local path is returned.
% Otherwise, returns @a portablePath unchanged.
%
% Use LocalPathToPortablePath() to convert local paths to portable paths
% that can be shared across RenderToolbox3 machines.
%
% @details
% If @a hints is provided, uses RenderToolbox3 output path names like @a
% hings.tempFolder.  Otherwise uses getpref('RenderToolbox3',
% 'tempFolder').
%
% @details
% Usage:
%   localPath = PortablePathToLocalPath(portablePath, hints)
%
% @ingroup Utilities
function localPath = PortablePathToLocalPath(portablePath, hints)

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

% only interested in output path roots
hints.outputSubfolder = '';

pathNames = {'tempFolder', 'outputDataFolder', 'outputImageFolder', 'resourcesFolder', 'workingFolder'};
localPath = portablePath;
delimiter = '@RTB@';
for ii = 1:numel(pathNames)
    pathName = pathNames{ii};
    portablePrefix = [delimiter pathName delimiter];
    matchIndex = strfind(portablePath, portablePrefix);
    if 1 == matchIndex
        remainder = portablePath(numel(portablePrefix) + 2:end);
        outputPath = GetOutputPath(pathName, hints);
        localPath = fullfile(outputPath, remainder);
        return
    end
end
