%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Find the function_handle of a RenderToolbox3 renderer API function.
%   @param functionName the name of a renderer API function
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Attempts to locate the named API function for the given @a
% hints.renderer. Renderer API functions must on the Matlab path or within
% hints.workingFolder.  They must have names that folow the pattern RTB_@a
% functionName_@a renderer, for example RTB_ApplyMappings_SampleRenderer.
%
% @details
% @a hints.renderer may be the name of any supported renderer, for example,
% "SampleRenderer", "PBRT", or "Mitsuba".
%
% @details
% @a functionName must be the name of a RenderToolbox3 Renderer API
% function:
%   - @b ApplyMappings: the funciton that converts RenderToolbox3 mappings
%   to renderer-native scene adjustments
%   - @b ImportCollada: the function that converts Collada parent scene
%   files to the @a renderer-native format
%   - @b Render: the function that invokes the given @a hints.renderer
%   - @b DataToRadiance: the function that converts @a hints.renderer outputs to
%   physical radiance units
%   - @b VersionInfo: the function that returns version information about
%   a renderer.
%   .
%
% @details
% Returns the function_handle of the RenderToolbox3 Renderer API function,
% for the given @a hints.renderer and @a functionName.  If no such function
% is found, retuns an empty [].  Also returns the full path to the named
% function, if found.
%
% Usage:
%   [rendererFunction, functionPath] = GetRendererAPIFunction(functionName, hints)
%
% @ingroup RendererPlugins
function [rendererFunction, functionPath] = GetRendererAPIFunction(functionName, hints)

rendererFunction = [];
functionPath = '';

% is functionName part of the RenderToolbox3 renderer API?
validFunctionNames = ...
    {'ApplyMappings', 'ImportCollada', 'Render', 'DataToRadiance', 'VersionInfo'};
if ~any(strcmp(validFunctionNames, functionName))
    disp(['functionName ' functionName ' should be one of the following:'])
    disp(validFunctionNames)
    return
end

% build a standard function name
standardName = ['RTB_' functionName '_' hints.renderer];

% try to find the API function by name
info = ResolveFilePath(standardName, hints.workingFolder);
if isempty(info.resolvedPath)
    disp(['function not found: ' standardName])
    return
end

% return the API function as a function_handle
rendererFunction = str2func(standardName);