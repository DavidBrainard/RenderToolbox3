%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert Scene Target info to native Scene DOM path mappings.
%   @param genericInfo
%   @param hints
%
% @details
% Convert the given @a sceneTargetInfo struct into one or more mapping
% structs that contain renderer-native scene DOM paths.
%
% @details
% @a sceneTargetInfo must be an info struct as returned from
% ParseSceneTarget().
%
% @details
% @a hints must be a struct of batch renderer hints, as returned
% from GetDefaultHints().
%
% @details
% Returns a struct array with one or more mappings structs, based on @a
% sceneTargetInfo.  The left hand values will contain scene DOM paths,
% suitable for use with an adjustments file for the renderer in
% @a hints.renderer.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   pathMaps = MakeNativePathMappings(sceneTargetInfo, hints)
%
% @ingroup SceneTargets
function pathMaps = MakeNativePathMappings(sceneTargetInfo, hints)

% get an empty, template mappings struct
pathMaps = ParseMappings();

% fill in the mappings struct based on sceneTargetInfo
%   - left-hand values must be renderer scene DOM paths
switch hints.renderer
    case 'Mitsuba'
        if isempty(sceneTargetInfo.operator)
            % declare Mitsuba node: <name id="id" type="type">
            %   this takes one or two mappings
            
            % first mapping declares the node name
            path = {sceneTargetInfo.id, PrintPathPart('$')};
            pathMaps(1).left.value = PathCellToString(path);
            pathMaps(1).operator = '=';
            pathMaps(1).right.value = sceneTargetInfo.name;
            
            % second mapping may set the node "type" attribute
            if ~isempty(sceneTargetInfo.type)
                path = {sceneTargetInfo.id, PrintPathPart('.', 'type')};
                pathMaps(2).left.value = PathCellToString(path);
                pathMaps(2).operator = '=';
                pathMaps(2).right.value = sceneTargetInfo.type;
            end
            
        else
            % configure Mitsuba node: <type name="name" value="value">
            %   this takes one or two mappings
            
            % mapping specifies the node name, and "name" and "value"
            % attributes
            path = {sceneTargetInfo.id, ...
                PrintPathPart(':', sceneTargetInfo.type, 'name', sceneTargetInfo.name), ...
                PrintPathPart('.', 'value')};
            pathMaps(1).left.value = PathCellToString(path);
            pathMaps(1).operator = sceneTargetInfo.operator;
            pathMaps(1).right.value = sceneTargetInfo.value;
            
            % Mitsuba sometimes takes a "filename" instead of a "value"
            %   detect this as non-numeric value, with a non-string type
            if 0 == numel(StringToVector(sceneTargetInfo.value)) ...
                    && ~strcmp(sceneTargetInfo.type, 'string')
                % change the "value" attribute to a "filename" attribute
                path = {sceneTargetInfo.id, ...
                    PrintPathPart(':', sceneTargetInfo.type, 'name', sceneTargetInfo.name), ...
                    PrintPathPart('.', 'value', '$')};
                pathMaps(2).left.value = PathCellToString(path);
                pathMaps(2).operator = '=';
                pathMaps(2).right.value = 'filename';
            end
        end
        
    case 'PBRT'
        if isempty(sceneTargetInfo.operator)
            % declare PBRT node: <category id="id" type="type">
            %   this takes one or two mappings
            
            % first mapping declares the node name
            path = {sceneTargetInfo.id, PrintPathPart('$')};
            pathMaps(1).left.value = PathCellToString(path);
            pathMaps(1).operator = '=';
            pathMaps(1).right.value = sceneTargetInfo.name;
            
            % second mapping may set the node "type" attribute
            if ~isempty(sceneTargetInfo.type)
                path = {sceneTargetInfo.id, PrintPathPart('.', 'type')};
                pathMaps(2).left.value = PathCellToString(path);
                pathMaps(2).operator = '=';
                pathMaps(2).right.value = sceneTargetInfo.type;
            end
            
        else
            % configure PBRT node:
            %   <parameter type="type" name="name">value</parameter>
            %   this takes two mappings
            
            % first mapping sets the node name, "name" attribute, and
            % "type" attribute
            path = {sceneTargetInfo.id, ...
                PrintPathPart(':', 'parameter', 'name', sceneTargetInfo.name), ...
                PrintPathPart('.', 'type')};
            pathMaps(1).left.value = PathCellToString(path);
            pathMaps(1).operator = '=';
            pathMaps(1).right.value = sceneTargetInfo.type;
            
            % second mapping sets the node value
            path = {sceneTargetInfo.id, ...
                PrintPathPart(':', 'parameter', 'name', sceneTargetInfo.name)};
            pathMaps(2).left.value = PathCellToString(path);
            pathMaps(2).operator = sceneTargetInfo.operator;
            pathMaps(2).right.value = sceneTargetInfo.value;
        end
end