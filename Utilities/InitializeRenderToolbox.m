%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Create Matlab preferences for RenderToolbox3.
%   @param isForce whether to create preferences from scratch (optional)
%
% @details
% Chooses paths and other constants related to Mitsuba, PBRT, and
% RenderToolbox3, and makes these available with Matlab's setpref() and
% getpref() functions.  Also sets the PATH environment variable, as used by
% the Matlab unix() command, so that it contains the paths to each
% renderer's executable.
%
% @details
% To see all the defaults, try:
% @code
%   InitializeRenderToolbox(true);
%   MitsubaPrefs = getpref('Mitsuba')
%   PBRTPrefs = getpref('PBRT')
%   RenderToolbox3Prefs = getpref('RenderToolbox3')
% @endcode
%
% @details
% You should set the paths to Mitsuba and PBRT on your machine:
% @code
%   % Mitsuba on OS X
%   setpref('Mitusba', 'app', path-to-Mitsuba);
%
%   % Mitsuba on other platforms
%   setpref('Mitusba', 'app', '');
%   setpref('Mitusba', 'executable', path-to-Mitsuba-executable);
%   setpref('Mitusba', 'importer', path-to-Mitsuba-importer);
%
%   % PBRT
%   setpref('PBRT', 'executable', path-to-PBRT);
% @endcode
%
% @details
% You can also set the paths where RenderToolbox3 will put new files.  If
% you leave as they are, RenderToolbox3 will put new files in the current
% folder.
% @code
%   % temporary scene files, etc.
%   setpref('RenderToolbox3', 'tempFolder', path-to-tempFolder);
%
%   % multi-spectral output data files
%   setpref('RenderToolbox3', 'outputDataFolder', path-to-outputDataFolder);
%
%   % RGB output image files
%   setpref('RenderToolbox3', 'outputImageFolder', path-to-outputImageFolder);
% @endcode
%
% @details
% You can also set other defaults that RenderToolbox3 will use when no
% "hints" are provided.  For example,
% @code
%   % default renderer to use
%   setpref('RenderToolbox3', 'renderer', 'Mitsuba');
%   % or
%   setpref('RenderToolbox3', 'renderer', 'PBRT');
%
%   % default ouput image dimensions
%   setpref('RenderToolbox3', 'imageHeight', 480);
%   setpref('RenderToolbox3', 'imageWidth', 640);
% @endcode
%
% @details
% Normally you should set these values with a temporary "hints" struct, and
% not with setpref().  See GetDefaultHints() for more.
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


%% For Mitsuba
if isForce
    % remove stale config
    if ispref('Mitsuba')
        rmpref('Mitsuba');
    end
    
    % default config
    Mitsuba.app = '/Applications/Mitsuba.app';
    Mitsuba.executable = fullfile('Contents', 'MacOS', 'mitsuba');
    Mitsuba.importer = fullfile('Contents', 'MacOS', 'mtsimport');
    Mitsuba.adjustmentsFile = fullfile(RenderToolboxRoot(), 'RenderData', 'MitsubaDefaultAdjustments.xml');
    
    % create or overwrite existing values
    setpref('Mitsuba', fieldnames(Mitsuba), struct2cell(Mitsuba));
    
else
    % use preexisting values
    Mitsuba = getpref('Mitsuba');
end


%% For PBRT
if isForce
    % remove stale config
    if ispref('PBRT')
        rmpref('PBRT');
    end
    
    % default config
    PBRT.executable = '/usr/local/bin/pbrt';
    PBRT.S = [400 10 31];
    PBRT.adjustmentsFile = fullfile(RenderToolboxRoot(), 'RenderData', 'PBRTDefaultAdjustments.xml');
    
    % create or overwrite existing values
    setpref('PBRT', fieldnames(PBRT), struct2cell(PBRT));
    
else
    % use preexisting values
    PBRT = getpref('PBRT');
end


%% For RenderToolbox3
if isForce
    % remove stale config
    if ispref('RenderToolbox3')
        rmpref('RenderToolbox3');
    end
    
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
    
    % default output locations
    userFolder = fullfile(GetUserFolder(), 'render-toolbox');
    RenderToolbox3.tempFolder = fullfile(userFolder, 'temp');
    RenderToolbox3.outputDataFolder = fullfile(userFolder, 'data');
    RenderToolbox3.outputImageFolder = fullfile(userFolder, 'images');
    RenderToolbox3.outputSubfolder = '';
    
    % default hints
    RenderToolbox3.renderer = 'Mitsuba';
    RenderToolbox3.filmType = '';
    RenderToolbox3.adjustmentsFile = '';
    RenderToolbox3.imageHeight = 240;
    RenderToolbox3.imageWidth = 320;
    RenderToolbox3.whichConditions = [];
    RenderToolbox3.isDryRun = false;
    RenderToolbox3.isReuseSceneFiles = false;
    RenderToolbox3.isParallel = false;
    RenderToolbox3.isPlot = true;
    RenderToolbox3.isAbsoluteResourcePaths = true;
    
    % default renderer radiometric unit scale factors
    %   these are in the RenderToolbox3 group so that they appear as hints
    RenderToolbox3.PBRTRadiometricScale = 0.0063831432;
    RenderToolbox3.MitsubaRadiometricScale = 0.0795827427;
    
    % create or overwrite existing values
    setpref('RenderToolbox3', ...
        fieldnames(RenderToolbox3), struct2cell(RenderToolbox3));
    
else
    % use preexisting values
    RenderToolbox3 = getpref('RenderToolbox3');
end


%% Prepare the unix() command environment.
% prepend renderer executable paths to the unix() PATH
PATH = getenv('PATH');
fullMitsuba = fullfile(Mitsuba.app, Mitsuba.executable);
mitsPATH = fileparts(fullMitsuba);
if isempty(strfind(PATH, mitsPATH))
    PATH = sprintf('%s:%s', mitsPATH, PATH);
end
pbrtPATH = fileparts(PBRT.executable);
if isempty(strfind(PATH, pbrtPATH))
    PATH = sprintf('%s:%s', pbrtPATH, PATH);
end
setenv('PATH', PATH);
