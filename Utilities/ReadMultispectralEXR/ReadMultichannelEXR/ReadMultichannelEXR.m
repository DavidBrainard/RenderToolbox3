%%% RenderToolbox3 Copyright (c) 2012-2015 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read an OpenEXR image with multiple channels.
%   @param exrFile file name or path of an OpenEXR file
%
% @details
% Reads an OpenEXR image with an arbitrary number of channels, aka "image
% planes", aka "slices".
%
% @details
% The given @a exrFile should be an OpenEXR image file.  It may have any
% number of channels.
%
% @details
% Returns a struct array n elements, one for each image channel.  Each
% element describes the channel, including its @b name, @b pixelType, @a
% xSampling, @a ySampling, and @b isLinear.  You probably only care about
% the @b name!
%
% @details
% Also returns a double array with size [height width n] containing the
% full image.  height and width refer to image spatial dimenstions.  n
% refers to the number of channels in the image.
%
% @details
% ReadMultichannelEXR is a mex-function.  This means you need to build it
% locally for your machine.  Please see MakeReadMultichannelEXR().
%
% @details
% Usage:
%   [channelInfo, imageData] = ReadMultichannelEXR(exrFile);
%
% @ingroup Readers
