%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get the path to RenderToolbox3.
%
% @details
% Returns the absolute path to RenderToolbox3, based on the location of
% this file, RenderToolboxRoot.m.
%
% @details
% Usage:
%   rootPath = RenderToolboxRoot()
%
% @ingroup Utilities
function rootPath = RenderToolboxRoot()
filePath = mfilename('fullpath');
lastSeps = find(filesep() == filePath, 2, 'last');
rootPath = filePath(1:(lastSeps(1) - 1));