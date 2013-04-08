%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Scan a mappings struct for Scene Target info.
%   @param map
%
% @details
% Scan the given mapping struct @a map, for scene target syntax.  @a map
% must be a mapping struct as returned from ParseMappings().  The mappings
% left hand value should contain Scene Target syntax.
%
% @details
% Returns a struct of information about the  Scene Target.  This "info
% struct" is an intermediate form, used when converting mappings syntax and
% generic scene elements.  The info struct will have the following fields:
%   - id - unique identifier of a scene element
%   - name - hint, category, or property of the scene element
%   - type - the element type or property type
%   - operator - operator from @a map
%   - value - right-hand value from @a map
%   - isDeclaration - whether @a map declares a new scene element
%
% See the Rendertoolbox3 wiki for more about <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Mappings-Syntax">Scene
% Targets </a>.
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   info = ParseSceneTarget(map)
%
% @ingroup SceneTargets
function info = ParseSceneTarget(map)

% fill in a default info struct
info.id = '';
info.name = '';
info.type = '';
info.operator = map.operator;
info.value = map.right.value;
info.isDeclaration = isempty(map.operator);

% scene target syntax is deliberately similar to scene DOM path syntax
%   the same parsing function works
mappingParts = PathStringToCell(map.left.value);
switch numel(mappingParts)
    case 3
        % extract id, name, and type
        info.id = mappingParts{1};
        [pathOp, info.name] = ScanPathPart(mappingParts{2});
        [pathOp, info.type] = ScanPathPart(mappingParts{3});
        
    case 2
        % extract id and name
        info.id = mappingParts{1};
        [pathOp, info.name] = ScanPathPart(mappingParts{2});
        
    otherwise
        warning('Cannot parse scene target left-hand value "%s".', ...
            map.left.value);
        return;
end