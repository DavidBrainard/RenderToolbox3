%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Run a system command and capture results or display them live.
%   @param command string command to run with built-in system()
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% RunCommand() executes the given @a command string using Matlab's built-in
% system() function, and attempts to capture status codes and messages that
% result.  Attempts to never throw an exception.  Instead, captures and
% returns any exception thrown.
%
% @details
% If @a hints.isCaptureCommandResults is false, allows Matlab to print
% command results to the Command Window immediately as they happen, instead
% of capturing them.  If @hints is omitted, uses GetDefaultHints().
%
% @details
% Returns the numeric status code and string result from the system()
% function.  The result may be empty, if hints.isCaptureCommandResults is
% false. Also returns any exception that was thrown during command
% execution, or empty [] if no exception was thrown.
%
% @details
% Usage:
%   [status, result, exception] = RunCommand(command, hints)
%
% @ingroup Utilities
function [status, result, exception] = RunCommand(command, hints)

status = [];
result = '';
exception = [];

if nargin < 2
    hints = GetDefaultHints();
end

if ~IsStructFieldPresent(hints, 'isCaptureCommandResults')
    hints.isCaptureCommandResults = true;
end

if hints.isCaptureCommandResults
    try
        [status, result] = system(command);
    catch exception
    end
else
    try
        status = system(command);
    catch exception
    end
end
