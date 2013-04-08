%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Create Matlab preferences for RenderToolbox3.
%   @param isForce whether to create preferences from scratch (optional)
%
% @details
% Chooses paths and other constants related to the Mitsuba and PBRT
% renderers, and makes these available with Matlab's setpref() and
% getpref() functions.  Also sets the PATH environment variable, as used by
% the Matlab unix() command, to contain the paths to each renderer's
% executable.
%
% @details
% To see the paths and constants for each renderer, try:
% @code
%   InitializeRenderToolbox(true);
%   MitsubaPrefs = getpref('Mitsuba')
%   PBRTPrefs = getpref('PBRT')
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
% By default, leaves any existing RenderTooblox3 preferences in place.  If
% @a isForce is provided and true, replaces existing preferences with
% default values.
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
if isForce || ~ispref('Mitsuba')
    % default config
    Mitsuba.app = '~/RenderToolbox3/Mitsuba.app';
    Mitsuba.executable = fullfile('Contents', 'MacOS', 'mitsuba');
    Mitsuba.importer = fullfile('Contents', 'MacOS', 'mtsimport');
    Mitsuba.adjustmentsFile = fullfile(RenderToolboxRoot(), 'RenderData', 'MitsubaDefaultAdjustments.xml');
    Mitsuba.libPathName = 'DYLD_LIBRARY_PATH';
    Mitsuba.libPath = '';
    
    % create or overwrite existing values
    setpref('Mitsuba', fieldnames(Mitsuba), struct2cell(Mitsuba));
else
    % use preexisting values
    Mitsuba = getpref('Mitsuba');
end

%% For PBRT
if isForce || ~ispref('PBRT')
    % default config
    PBRT.executable = '~/RenderToolbox3/pbrt';
    PBRT.S = [400 10 31];
    PBRT.adjustmentsFile = fullfile(RenderToolboxRoot(), 'RenderData', 'PBRTDefaultAdjustments.xml');
    
    % create or overwrite existing values
    setpref('PBRT', fieldnames(PBRT), struct2cell(PBRT));
else
    % use preexisting values
    PBRT = getpref('PBRT');
end

%% Prepare the unix() command environment

% prepend renderer Paths to the unix() PATH
PATH = getenv('PATH');
mitsPATH = fileparts(Mitsuba.executable);
if isempty(strfind(PATH, mitsPATH))
    PATH = sprintf('%s:%s', mitsPATH, PATH);
end
pbrtPATH = fileparts(PBRT.executable);
if isempty(strfind(PATH, pbrtPATH))
    PATH = sprintf('%s:%s', pbrtPATH, PATH);
end
setenv('PATH', PATH);