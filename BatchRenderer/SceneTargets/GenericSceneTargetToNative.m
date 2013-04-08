%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Scene Target info struct from generic to native info.
%   @param configInfo
%   @param defaultsInfo
%   @param hints
%
% @details
% Returns a Scene Target info struct like the given @a configInfo, with
% generic names, types, and values replaced with renderer-native values.
%
% @details
% @a configInfo must be an info struct as returned from ParseSceneTarget().
%
% @details
% @a defaultsInfo must be an info struct as reuturned from
% GetNativeObjectDefaults().
%
% @details
% @a hints must be a struct of batch renderer hints, as returned from
% GetDefaultHints().
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   nativeInfo = GenericSceneTargetToNative(configInfo, defaultsInfo, hints)
%
% @ingroup SceneTargets
function nativeInfo = GenericSceneTargetToNative(configInfo, defaultsInfo, hints)

% use given configInfo as template for nativeInfo
nativeInfo = configInfo;

%% Look up the renderer-native name for the given generic property name.
%   only the properties listed among the defaults get names converted
isDefaultProp = strcmp(configInfo.name, {defaultsInfo.genericName});
if any(isDefaultProp)
    whichProp = find(isDefaultProp, 1);
    nativeInfo.genericName = defaultsInfo(whichProp).genericName;
    nativeInfo.name = defaultsInfo(whichProp).name;
    
else
    warning('Object "%s" cannot use the given property "%s".', ...
        configInfo.id, configInfo.name);
end

%% Convert generic property values to native, as needed.
isMitsuba = strcmp(hints.renderer, 'Mitsuba');
isPBRT = strcmp(hints.renderer, 'PBRT');
switch configInfo.name
    case 'roughness'
        % scale down roughness for PBRT
        %   TODO: what is the real difference between microfacet models?
        if isMitsuba
            % do nothing
        elseif isPBRT
            num = StringToVector(nativeInfo.value);
            num = num ./ 5;
            nativeInfo.value = VectorToString(num);
        end
end