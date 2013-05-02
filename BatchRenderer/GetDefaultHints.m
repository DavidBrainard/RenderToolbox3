%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get default hints to pass to the batch renderer.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Creates a struct of options for the batch renderer to use, or fills in
% missing parts of a the given @a hints struct.  Batch renderer options
% include things like renderer name, image film size, and whether or not to
% delete intermediate files used in the batch rendering process.
%
% @details
% If provided, @a hints should be a struct of renderer options with option
% names as fields.  Fills in any missing options with default values.  If
% @a hints is missing or not a struct, creates a new struct with all
% default values.
%
% @details
% Default hint values can be set with Matlab's setpref() function.  For
% example:
% @code
%   % default renderer to use
%   setpref('RenderToolbox3', 'renderer', 'Mitsuba');
%   % or
%   setpref('RenderToolbox3', 'renderer', 'PBRT');
%
%   % default ouput image dimensions
%   setpref('RenderToolbox3', 'imageHeight', 480);
%   setpref('RenderToolbox3', 'imageWidth', 640);
%
%   % review all the hints
%   hints = GetDefaultHints()
% @endcode
%
% @details
% Returns a new or modified struct of batch renderer options.
% output.
%
% @details
% Usage:
%   hints = GetDefaultHints(hints)
%
% Usage examples:
% @code
%   hints = GetDefaultHints(hints);
%   hints.whichConditions = [1 3 5];
%   BatchRender(..., hints);
%   MakeMontage(..., hints);
% @endcode
%
% @ingroup BatchRender
function hints = GetDefaultHints(hints)

if nargin < 1 || ~isstruct(hints)
    hints = struct();
end

InitializeRenderToolbox();

% supplement given hints with default hints
RenderToolbox3 = getpref('RenderToolbox3');
hintNames = fieldnames(RenderToolbox3);
for ii = 1:numel(hintNames)
    name = hintNames{ii};
    if ~IsStructFieldPresent(hints, name)
        % hint is missing, fill in the default
        hints.(name) = getpref('RenderToolbox3', name);
    end
end
