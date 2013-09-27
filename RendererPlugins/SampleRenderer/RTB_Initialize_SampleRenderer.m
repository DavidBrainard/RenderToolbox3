%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Initialize the Sample Renderer.
%
% @details
% This function is a template for a RenderToolbox3 "Initialize" function.
%
% @details
% The name of an Initialize function must match a specific pattern: it must
% begin with "RTB_Initialize_", and it must end with the name of the
% renderer, for example, "SampleRenderer".  This pattern allows
% RenderToolbox3 to automatically locate the Initialize function for each
% renderer.  Initialize functions should be included in the Matlab path.
%
% @details
% An Initialize function must do any setup required to make a renderer
% available for rendering.  This setup might include determining whether
% the renderer is installed, starting an external renderer application, or
% anything else.
%
% @details
% Setup should also include creating a Matlab preferences entry for the
% renderer, using Matlab's setpref function.  The preferences group name
% should be the name of the renderer, for example, "SampleRenderer".  The
% specific preference names and values 
