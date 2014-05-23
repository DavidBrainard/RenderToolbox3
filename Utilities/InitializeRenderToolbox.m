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

if isForce
    % remove stale config
    if ispref('RenderToolbox3')
        rmpref('RenderToolbox3');
    end
    
    % default input and output location
    userFolder = fullfile(GetUserFolder(), 'render-toolbox');
    RenderToolbox3.workingFolder = userFolder;
    RenderToolbox3.recipeName = '';
    
    % default hints
    RenderToolbox3.renderer = 'SampleRenderer';
    RenderToolbox3.remodeler = '';
    RenderToolbox3.filmType = '';
    RenderToolbox3.imageHeight = 240;
    RenderToolbox3.imageWidth = 320;
    RenderToolbox3.whichConditions = [];
    RenderToolbox3.isDryRun = false;
    RenderToolbox3.isReuseSceneFiles = false;
    RenderToolbox3.isParallel = false;
    RenderToolbox3.isPlot = true;
    RenderToolbox3.isCaptureCommandResults = true;
    
    % choose dynamic library path names and default values
    %   these are applied automatically, via SetRenderToolboxLibraryPath()
    if ispc()
        % use windows PATH as-is (TODO: is this correct?)
        RenderToolbox3.libPathName = 'PATH';
        RenderToolbox3.libPath = [];
        RenderToolbox3.libPathLast = 'matlab|MATLAB';
        
    elseif ismac()
        % don't use OS X DYLD_LIBRARY_PATH at all
        RenderToolbox3.libPathName = 'DYLD_LIBRARY_PATH';
        RenderToolbox3.libPath = '';
        RenderToolbox3.libPathLast = '';
        
    else
        % sort Linux LD_LIBRARY_PATH with "matlab" entries last
        RenderToolbox3.libPathName = 'LD_LIBRARY_PATH';
        RenderToolbox3.libPath = [];
        RenderToolbox3.libPathLast = 'matlab|MATLAB';
    end
    
    % create or overwrite existing values
    setpref('RenderToolbox3', ...
        fieldnames(RenderToolbox3), struct2cell(RenderToolbox3));
    
else
    % use preexisting values
    RenderToolbox3 = getpref('RenderToolbox3');
end
