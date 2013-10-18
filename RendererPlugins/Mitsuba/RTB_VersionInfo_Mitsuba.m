%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get version information about the Mitsuba.
%
% @details
% This is the RenderToolbox3 "VersionInfo" function for Mitsuba.
%
% @details
% See RTB_VersionInfo_SampleRenderer() for more about VersionInfo
% functions.
%
% Usage:
%   versionInfo = RTB_VersionInfo_Mitsuba()
function versionInfo = RTB_VersionInfo_Mitsuba()

% Mitsuba executable date stamp
try
    executable = fullfile( ...
        getpref('Mitsuba', 'app'), getpref('Mitsuba', 'executable'));
    versionInfo = dir(executable);
catch err
    versionInfo = err;
end
