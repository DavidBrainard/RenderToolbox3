%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Find the function_handle of a RenderToolbox3 renderer API function.
%   @param functionName the name of a renderer API function
%   @param renderer the name of a renderer
%
% @details
% Attempts to locate the named API function for the given @a renderer.
% Renderer API functions must on the Matlab path.  They must have names
% that folow the pattern RTB_@a functionName_@a renderer, for example
% RTB_ApplyMappings_SampleRenderer.
%
% @details
% @renderer may be the name of any supported renderer, for example,
% "SampleRenderer", "PBRT", or "Mitsuba".
%
% @details
% @a functionName must be the name of a RenderToolbox3 API function:
%   - @b ApplyMappings: the funciton that converts RenderToolbox3 mappings
%   to renderer-native scene adjustments
%   - @b ImportCollada: the function that converts Collada parent scene
%   files to the @a renderer-native format
%   - @b Render: the function that invokes the given @a renderer
%   - @b DataToRadiance: the function that converts @a renderer outputs to
%   physical radiance units
%   - @b VersionInfo: the function that returns version information about
%   a renderer.
%   .
%
% @details
% Returns the function_handle of the RenderToolbox3 renderer API function,
% for the given @a renderer and @a functionName.  If no such function is
% found, retuns an empty [].  Also returns the full path to the named
% function, if found.
%
% Usage:
%   [rendererFunction, functionPath] = GetRendererAPIFunction(functionName, renderer)
%
% @ingroup RendererPlugins
function [rendererFunction, functionPath] = GetRendererAPIFunction(functionName, renderer)

rendererFunction = [];
functionPath = '';

% is functionName part of the RenderToolbox3 renderer API?
validFunctionNames = ...
    {'ApplyMappings', 'ImportCollada', 'Render', 'DataToRadiance', 'VersionInfo'};
if ~any(strcmp(validFunctionNames, functionName))
    disp(['rendererName ' functionName ' should be one of the following:'])
    disp(validFunctionNames)
    return
end

% build a standard function name
standardName = ['RTB_' functionName '_' renderer];

% try to find API the function by name
functionPath = which(standardName);
if isempty(functionPath)
    disp(['function not found: ' standardName])
    return
end

% return the API function as a function_handle
rendererFunction = str2func(standardName);