%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Find the function_handle of a RenderToolbox3 Remodeling API function.
%   @param functionName the name of a collada API function
%   @param remodeler the name of a set of Remodeling API functions
%
% @details
% Attempts to locate the named Remodeling API function that belogs to the
% named "remodeler", or set of remodeling functions.  Remodeler API
% functions must on the Matlab path.  They must have names that folow the
% pattern RTB_@a functionName_@a remodeler, for example
% RTB_BeforeAll_SampleRemodeler.
%
% @details
% @a remodeler may be the name of any set of user-defined remodeler
% functions, for exampole, "SampleRemodeler".
%
% @details
% @a functionName must be the name of a RenderToolbox3 Remodeler API
% function:
%   - @b BeforeAll: may modify the Collada parent scene document once,
%   before all other RenderToolbox3 processing.
%   - @b BeforeCondition: may modify the Collada parent scene document once
%   per condition, before mappings are applied.
%   - @b AfterCondition: may modify the Collada parent scene document once
%   per condition, after mappings are applied and before conversion to a
%   renderer-native scene.
%   .
%
% @details
% Returns the function_handle of the RenderToolbox3 Remodeler API function,
% for the given @a remodeler and @a functionName.  If no such function is
% found, retuns an empty [].  Also returns the full path to the named
% function, if found.
%
% Usage:
%   [remodelerFunction, functionPath] = GetRemodelerAPIFunction(functionName, remodeler)
%
% @ingroup RemodelerPlugins
function [remodelerFunction, functionPath] = GetRemodelerAPIFunction(functionName, remodeler)

remodelerFunction = [];
functionPath = '';

% is functionName part of the RenderToolbox3 remodeler API?
validFunctionNames = ...
    {'BeforeAll', 'BeforeCondition', 'AfterCondition'};
if ~any(strcmp(validFunctionNames, functionName))
    disp(['functionName ' functionName ' should be one of the following:'])
    disp(validFunctionNames)
    return
end

% build a standard function name
standardName = ['RTB_' functionName '_' remodeler];

% try to find the API function by name
functionPath = which(standardName);
if isempty(functionPath)
    disp(['function not found: ' standardName])
    return
end

% return the API function as a function_handle
remodelerFunction = str2func(standardName);