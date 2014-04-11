%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Scan recipe inputs to determine files required for rendering.
%   @param parentSceneFile name of a Collada scene file
%   @param conditionsFile name of a RenderToolbox3 conditions file
%   @param mappingsFile name of a RenderToolbox3 mappings file
%   @param hints struct of RenderToolbox3 options
%
% @details
% Scans the given @a parentSceneFile, @a conditionsFile, and @a
% mappingsFile, input files to determine other file dependencies that are
% required for rendering.  These file dependencies might include texture
% image files and spectrum definition files that are referred to in the
% given input files.  This allows all RenderToolbox3 to locate all required
% files before doing any work like making scene files and doing rendering.
%
% @details
% Also attempts to obtain the adjustments for the given @a hints.renderer,
% and if the adjustments is an XML file, includes the adjustments in the
% scan for dependencies.  See RTB_ApplyMappings_SampleRenderer.m for more
% about renderer adjustments.
%
% @details
% Returns a struct array with one element per detected dependency, as
% returned from ResolveFilePath().  Each element will have an additional
% field as well:
%   - @b portablePath - a "portable" representation of the @b
%   absolutePath, that uses placeholders for RenderToolbox3 output paths
%   as returned from GetOutputPath().
%   .
%
% @details
% Usage:
%   dependencies = FindDependentFiles(parentSceneFile, conditionsFile, ...
% mappingsFile, hints)
%
% @ingroup Mappings
function dependencies = FindDependentFiles(parentSceneFile, conditionsFile, mappingsFile, hints)

dependencies = [];

if nargin < 1 || isempty(parentSceneFile)
    parentSceneFile = '';
end

if nargin < 2 || isempty(conditionsFile)
    conditionsFile = '';
end

if nargin < 3 || isempty(mappingsFile)
    mappingsFile = fullfile( ...
        RenderToolboxRoot(), 'RenderData', 'DefaultMappings.txt');
end

if nargin < 4
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end


%% Locate renderer-native adjustments.
applyMappingsFunction = ...
    GetRendererAPIFunction('ApplyMappings', hints.renderer);
if isempty(applyMappingsFunction)
    adjustments = [];
else
    adjustments = feval(applyMappingsFunction, [], []);
end

%% Scan input files to find other required files.
mappings = ParseMappings(mappingsFile);
[varNames, varValues] = ParseConditions(conditionsFile);
if isempty(hints.whichConditions)
    whichConditions = 1:size(varValues, 1);
else
    whichConditions = hints.whichConditions;
end
for ii = whichConditions
    [resolvedMappings, deps] = ResolveMappingsValues(mappings, ...
        varNames, varValues(ii,:), parentSceneFile, adjustments, hints);
    if 1 == ii
        dependencies = deps;
    else
        dependencies = cat(2, dependencies, deps);
    end
end

% only care about unique dependencies
[uniques, uniqueIndices] = unique({dependencies.absolutePath});
dependencies = dependencies(uniqueIndices);

%% Get a RenderTooblox3 "portable" path for each local path.
for ii = 1:numel(dependencies)
    dependencies(ii).portablePath = ...
        LocalPathToPortablePath(dependencies(ii).absolutePath, hints);
end