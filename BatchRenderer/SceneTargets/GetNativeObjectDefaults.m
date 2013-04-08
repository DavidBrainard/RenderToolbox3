%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get renderer-native declaration and defaults, for a generic declaration.
%   @param genericInfo
%   @param hints
%
% @details
% Converts a generic object declaration info struct into to as struct array
% with renderer-native object declaration and default properties.
%
% @details
% @a genericInfo must be an info struct as returned from
% ParseGenericMapping().
%
% @details
% @a hints must be a struct of batch renderer hints, as returned
% from GetDefaultHints().
%
% @details
% Returns a struct array of renderer-native mappings info, with the same
% fields as @a genericInfo.  The first element of the returned
% struct will contain the renderer-native category name and type name that
% correspond to the given generic categorty and type.
%
% @details
% Subsequent elements of the returned struct array will contain default,
% renderer-native property names, type names, and values.
%
% @details
% The returned struct will contain a new 'genericName' field, which may
% contain a generic object type name or property name.  This establishes
% the mapping between generic names and renderer-native names.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   nativeInfo = GetNativeObjectDefaults(genericInfo, hints)
%
% @ingroup SceneTargets
function nativeInfo = GetNativeObjectDefaults(genericInfo, hints)

% use given generic info as template for native info
nativeInfo = genericInfo;
nativeInfo.genericName = genericInfo.name;

%% Convert the generic hint or category name.
isMitsuba = strcmp(hints.renderer, 'Mitsuba');
isPBRT = strcmp(hints.renderer, 'PBRT');
switch genericInfo.name
    case 'material'
        if isMitsuba
            nativeInfo.name = 'bsdf';
        elseif isPBRT
            nativeInfo.name = 'Material';
        end
        
    case 'light'
        % generic lights modify existing lights
        if isMitsuba
            nativeInfo.name = 'append';
        elseif isPBRT
            nativeInfo.name = 'merge';
        end
        
    otherwise
        nativeInfo = [];
        warning('Unsupported generic object category, "%s".', ...
            genericInfo.name);
end

%% Convert the generic object type name and define default properties.
if isempty(genericInfo.type)
    % no type to convert
    return;
end

% define renderer-native default properties and values
names = {};
genericNames = {};
types = {};
values = {};
switch genericInfo.type
    case 'matte'
        if isMitsuba
            nativeInfo.type = 'roughdiffuse';
            names = {'reflectance', 'alpha'};
            genericNames = {'diffuseReflectance', 'roughness'};
            types = {'spectrum', 'float'};
            values = {'300:0.5 800:0.5', '0.0'};
            
        elseif isPBRT
            nativeInfo.type = 'matte';
            names = {'Kd', 'sigma'};
            genericNames = {'diffuseReflectance', 'roughness'};
            types = {'spectrum', 'float'};
            values = {'300:0.5 800:0.5', '0.0'};
        end

    case 'anisoward'
        if isMitsuba
            nativeInfo.type = 'ward';
            names = {'diffuseReflectance', 'specularReflectance', 'alphaU', 'alphaV', 'variant'};
            genericNames = {'diffuseReflectance', 'specularReflectance', 'alphaU', 'alphaV', ''};
            types = {'spectrum', 'spectrum', 'float', 'float', 'string'};
            values = {'300:0.5 800:0.5', '300:0.5 800:0.5', '0.1', '0.1', 'ward'};
            
        elseif isPBRT
            nativeInfo.type = 'anisoward';
            names = {'Kd', 'Ks', 'alphaU', 'alphaV'};
            genericNames = {'diffuseReflectance', 'specularReflectance', 'alphaU', 'alphaV'};
            types = {'spectrum', 'spectrum', 'float', 'float'};
            values = {'300:0.5 800:0.5', '300:0.5 800:0.5', '0.1', '0.1'};
        end

    case 'metal'
        defaultEta = which('Cu.eta.spd');
        defaultK = which('Cu.k.spd');
        
        if isMitsuba
            nativeInfo.type = 'roughconductor';
            names = {'eta', 'k', 'alpha'};
            genericNames = {'eta', 'k', 'roughness'};
            types = {'spectrum', 'spectrum', 'float'};
            values = {defaultEta, defaultK, '0.4'};
            
        elseif isPBRT
            nativeInfo.type = 'metal';
            names = {'eta', 'k', 'roughness'};
            genericNames = {'eta', 'k', 'roughness'};
            types = {'spectrum', 'spectrum', 'float'};
            values = {defaultEta, defaultK, '0.08'};
        end
        
    case 'point'
        if isMitsuba
            nativeInfo.type = 'point';
            names = {'intensity'};
            genericNames = {'intensity'};
            types = {'spectrum'};
            values = {'300:1.0 800:1.0'};
            
        elseif isPBRT
            nativeInfo.type = 'point';
            names = {'I'};
            genericNames = {'intensity'};
            types = {'spectrum'};
            values = {'300:0.5', '0.0'};
        end
        
    case 'directional'
        if isMitsuba
            nativeInfo.type = 'directional';
            names = {'irradiance'};
            genericNames = {'intensity'};
            types = {'spectrum'};
            values = {'300:1.0 800:1.0'};
            
        elseif isPBRT
            nativeInfo.type = 'distant';
            names = {'L'};
            genericNames = {'intensity'};
            types = {'spectrum'};
            values = {'300:0.5', '0.0'};
        end
        
    case 'spot'
        if isMitsuba
            nativeInfo.type = 'spot';
            names = {'intensity'};
            genericNames = {'intensity'};
            types = {'spectrum'};
            values = {'300:1.0 800:1.0'};
            
        elseif isPBRT
            nativeInfo.type = 'spot';
            names = {'I'};
            genericNames = {'intensity'};
            types = {'spectrum'};
            values = {'300:0.5', '0.0'};
        end
        
    otherwise
        nativeInfo = [];
        warning('Unsupported generic object type, "%s".', ...
            genericInfo.type);
end

%% Append default property info to the declaration info.
nativeInfo = repmat(nativeInfo, 1, 1+numel(names));
for ii = 1:numel(names)
    nativeInfo(ii+1).name = names{ii};
    nativeInfo(ii+1).type = types{ii};
    nativeInfo(ii+1).operator = '=';
    nativeInfo(ii+1).value = values{ii};
    nativeInfo(ii+1).isDeclaration = false;
    nativeInfo(ii+1).genericName = genericNames{ii};
end
