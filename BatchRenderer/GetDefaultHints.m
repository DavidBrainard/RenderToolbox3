%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get default hints to pass to the batch renderer.
%   @param hints partial struct of batch renderer options (optional)
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
% default  values.
%
% @details
% Returns a new or modified struct of batch renderer options.
% output.
%
% @details
% Usage:
%   hints = GetDefaultHints(hints)
%
% @ingroup BatchRender
function hints = GetDefaultHints(hints)

if nargin < 1 || ~isstruct(hints)
    hints = struct();
end

% the default renderer is Mitsuba
if ~IsStructFieldPresent(hints, 'renderer')
    hints.renderer = 'Mitsuba';
end

% the default film type is up to the scene file converter
if ~IsStructFieldPresent(hints, 'filmType')
    hints.filmType = '';
end

% the default adjustments file is up to the scene file converter
if ~IsStructFieldPresent(hints, 'adjustmentsFile')
    hints.adjustmentsFile = '';
end

% by default, delete intermediate files
if ~IsStructFieldPresent(hints, 'isDeleteIntermediates')
    hints.isDeleteIntermediates = true;
end

% the default rendering output folder is the current folder
if ~IsStructFieldPresent(hints, 'outputFolder')
    hints.outputFolder = pwd();
end

% the default output image is 320 wide x 240 tall
if ~IsStructFieldPresent(hints, 'imageWidth')
    hints.imageWidth = 320;
end

if ~IsStructFieldPresent(hints, 'imageHeight')
    hints.imageHeight = 240;
end

% by default, render all conditions
if ~IsStructFieldPresent(hints, 'whichConditions')
    hints.whichConditions = [];
end