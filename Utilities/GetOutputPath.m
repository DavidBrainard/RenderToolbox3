%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get a complete RenderToolbox3 output folder path.
%   @param pathName string name of a RenderToolbox3 output path
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Returns the full path to a the RenderToolbox3 output folder.  The full
% path is made from the named path, plus the outputSubfolder.
%
% @details
% @a pathName may be one of the folowing:
%   - 'tempFolder' - the path to temporary files
%   - 'outputDataFolder' - the path to output data files
%   - 'outputImageFolder' - the path to output image files
%   - 'resourcesFolder' - the path to recipe resource dependencies
%   .
%
% @details
% If @a hints is provided, uses @a hints.(@a pathName) and @a
% hints.outputSubfolder.  Otherwise, uses getpref('RenderToolbox3',
% @a pathName) and getpref('RenderToolbox3', 'outputSubfolder')
%
% @details
% Usage:
%   path = GetOutputPath(pathName, hints)
%
% @ingroup Utilities
function path = GetOutputPath(pathName, hints)

pathNames = {'tempFolder', 'outputDataFolder', 'outputImageFolder', 'resourcesFolder'};
if nargin < 1 || ~any(strcmp(pathName, pathNames))
    pathNamesString = evalc('disp(pathNames)');
    error('pathName must be one of the following: \n  %s', pathNamesString);
end

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

path = fullfile(hints.(pathName), hints.outputSubfolder);
