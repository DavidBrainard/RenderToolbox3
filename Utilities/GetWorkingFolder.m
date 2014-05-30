%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get a complete RenderToolbox3 working folder folder.
%   @param folderName string name of a RenderToolbox3 recipe folder
%   @param isRendererSpecific whether or not folder is renderer specific
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Returns the full path to a RenderToolbox3 recipe folder.  This will
% include the given @hints.workingFolder and @hints.recipeName, plus an
% optional @a folderName name like "resources" or "renderings".  If @a
% isRendererSpecific is true, also includes a subfolder named for the given
% @a hints.renderer.
%
% @details
% If the returned folder does not exist yet, creates it.
%
% @details
% @a folderName may be one of the folowing:
%   - 'resources' - where to look for input resources like spectra and
%   textures
%   - 'scenes' - where to put generated scene files
%   - 'renderings' - where to put renderer output data files
%   - 'images' - where to put processed image files
%   - 'temp' - where to put temporary files like intermediate copies of
%   scene files
%   .
%
% @details
% If @a hints is not provided, uses GetDefaultHints() instead.
%
% @details
% Usage:
%   folder = GetWorkingFolder(folderName, isRendererSpecific, hints)
%
% @ingroup Utilities
function folder = GetWorkingFolder(folderName, isRendererSpecific, hints)

if nargin < 2
    isRendererSpecific = false;
end

if nargin < 3
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if isRendererSpecific
    renderer = hints.renderer;
else
    renderer = '';
end

% just the base folder if no named folder given
if nargin < 1 || isempty(folderName)
    folder = fullfile(hints.workingFolder, hints.recipeName, renderer);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    return;
end

% only allow certain named subfolders
folderNames = {'resources', 'scenes', 'renderings', 'images', 'temp'};
if ~any(strcmp(folderName, folderNames))
    pathNamesString = evalc('disp(folderNames)');
    error('RenderToolbox3:UnknownWorkingFolder', ...
        'folderName <%s> must be one of the following: \n  %s', ...
        folderName, pathNamesString);
end

folder = fullfile(hints.workingFolder, hints.recipeName, folderName, renderer);
if ~exist(folder, 'dir')
    mkdir(folder);
end
