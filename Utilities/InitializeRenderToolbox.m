%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Create Matlab preferences for RenderToolbox3.
%   @param isForce whether to create preferences from scratch (optional)
%
% @details
% Chooses paths and other constants for RenderToolbox3, and makes these
% available with Matlab's setpref() and getpref() functions.
%
% @details
% See RenderToolbox3ConfigurationTemplate.m for examples of how to set up
% custom RenderToolbox3 preferences.
%
% @details
% To see all the RenderToolbox3 default preferences, try:
% @code
%   InitializeRenderToolbox(true);
%   RenderToolbox3Prefs = getpref('RenderToolbox3')
% @endcode
%
% @details
% You can also set the folder where RenderToolbox3 will look for files and
% write new files.
% @code
%   setpref('RenderToolbox3', 'workingFolder', path-to-tempFolder);
% @endcode
%
% @details
% You can also set other defaults that RenderToolbox3 will use when no
% "hints" are provided.  For example,
% @code
%   % default ouput image dimensions
%   setpref('RenderToolbox3', 'imageHeight', 480);
%   setpref('RenderToolbox3', 'imageWidth', 640);
% @endcode
%
% @details
% Setting these values with setpref() makes the changes persistent.
% Normally you can set the same values in a temporary way, using a "hints"
% struct.  See GetDefaultHints().
%
% @details
% By default, leaves any existing preferences in place.  If @a isForce is
% provided and true, replaces existing preferences with default values.
%
% @details
% Usage:
%   InitializeRenderToolbox(isForce)
%
% @ingroup Utilities
function InitializeRenderToolbox(isForce)

if nargin < 1
    isForce = false;
end

%% Choose "out of the box" configuration.

% default input and output location
defaultConfig.workingFolder = fullfile(GetUserFolder(), 'render-toolbox');
defaultConfig.recipeName = '';

% default scene file and rendering options
defaultConfig.renderer = 'SampleRenderer';
defaultConfig.remodeler = '';
defaultConfig.filmType = '';
defaultConfig.imageHeight = 240;
defaultConfig.imageWidth = 320;
defaultConfig.whichConditions = [];
defaultConfig.isDryRun = false;
defaultConfig.isReuseSceneFiles = false;
defaultConfig.isParallel = false;
defaultConfig.isPlot = true;
defaultConfig.isCaptureCommandResults = true;
defaultConfig.dockerFlag = 0;

% default dynamic library path names and default values
%   these are applied automatically, via SetRenderToolboxLibraryPath()
if ispc()
    % use windows PATH as-is (TODO: is this correct?)
    defaultConfig.libPathName = 'PATH';
    defaultConfig.libPath = [];
    defaultConfig.libPathLast = 'matlab|MATLAB';
    
elseif ismac()
    % don't use OS X DYLD_LIBRARY_PATH at all
    defaultConfig.libPathName = 'DYLD_LIBRARY_PATH';
    defaultConfig.libPath = '';
    defaultConfig.libPathLast = '';
    
else
    % sort Linux LD_LIBRARY_PATH with "matlab" entries last
    defaultConfig.libPathName = 'LD_LIBRARY_PATH';
    defaultConfig.libPath = [];
    defaultConfig.libPathLast = 'matlab|MATLAB';
end


%% Replace or update current preferences.
RENDER_TOOLBOX_3 = 'RenderToolbox3';
if isForce && ispref(RENDER_TOOLBOX_3)
    % start config from scratch
    rmpref(RENDER_TOOLBOX_3);
end

configFields = fieldnames(defaultConfig);
for ii = 1:numel(configFields)
    field = configFields{ii};
    if ~ispref(RENDER_TOOLBOX_3, field)
        setpref(RENDER_TOOLBOX_3, field, defaultConfig.(field));
    end
end
