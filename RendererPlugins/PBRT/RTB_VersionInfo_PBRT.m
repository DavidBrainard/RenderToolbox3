%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get version information about the PBRT.
%
% @details
% This is the RenderToolbox3 "VersionInfo" function for PBRT.
%
% @details
% See RTB_VersionInfo_SampleRenderer() for more about VersionInfo
% functions.
%
% Usage:
%   versionInfo = RTB_VersionInfo_PBRT()
%
% @ingroup RendererPlugins
function versionInfo = RTB_VersionInfo_PBRT()

% PBRT executable date stamp
try
    versionInfo = dir(getpref('PBRT', 'executable'));
catch err
    versionInfo = err;
end
