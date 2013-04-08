%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Tell the operating system where to find RenderToolbox3 dynamic libraries.
%
% @details
% Configures the operating system environment to locate dynamic libraries
% that are required for RenderToolbox3.  The correct dynamic library
% configuration is highly platform-specific. On some machines setting up
% the library path is trivial, on others it is a pain in the neck.
%
% @details
% Uses configuration values stored with Matlab's built-in getpref() and
% setpref() functions.  Reasonable default values are chosen in
% InitializeRenderToolbox().  Most users will not need to change these.  If
% you know what you're doing, you can customize these values using
% setpref():
%   - setpref('RenderToolbox3', 'libPathName', name) - this will choose the
%   name of the operating system environment variable that stores the
%   dynamic library search path, for example, "PATH", "DYLD_LIBRARY_PATH",
%   or "LD_LIBRARY_PATH".
%   - setpref('RenderToolbox3', 'libPath', path) - this will set the value
%   of the dynamic library search path.  Non-string values, like [], will
%   cause RenderToolbox3 to leave the existing library search path
%   unchanged.  String values, including the empty '', will replace the
%   existing library search path.
%   - setpref('RenderToolbox3', 'libPathLast', matching) - this will set
%   a regular expression used to sort entries of the library search path.
%   Path entries that match the given matching expression will be moved so
%   that they appear last in the library path.  For example, setting
%   matching to 'matlab|MATLAB' will move built-in Matlab path entries to
%   the end of the path, allowing user-specified paths entries to take
%   precedence.
%   .
%
% @details
% Modifies the system's dynamic library search path, using the values
% stored in getpref('RenderToolbox3', 'libPathName'),
% getpref('RenderToolbox3', 'libPath'), and getpref('RenderToolbox3',
% 'libPathLast').
%
% @details
% Returns the new value of the system dynamic library search path.  Also
% returns the original path value.  Also returns the name of the dynamic
% library search path environment variable.
%
% @details
% Usage:
%   [newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath()
%
% @details
% Example usage:
% @code
% % configure the dynamic library search path for RenderToolbox3
% [newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath()
%
% % restore the original library path
% setenv(libPathName, originalLibPath);
% @endcode
%
% @ingroup Utilities
function [newLibPath, originalLibPath, libPathName] = SetRenderToolboxLibraryPath()

newLibPath = '';
originalLibPath = '';
libPathName = '';

% get the platform-specific path config values
InitializeRenderToolbox();
libPathName = getpref('RenderToolbox3', 'libPathName');
libPath = getpref('RenderToolbox3', 'libPath');
libPathLast = getpref('RenderToolbox3', 'libPathLast');

% remember the original value of the library path
originalLibPath = getenv(libPathName);

% replace the lib path, or use the original
if ischar(libPath)
    newLibPath = libPath;
else
    newLibPath = originalLibPath;
end

% set the system environmet variable with the new library path
setenv(libPathName, newLibPath);

% re-sort the lib path based on the matching expression?
if ischar(libPathLast)
    newLibPath = DemoteEnvPathEntries(libPathName, libPathLast);
end
