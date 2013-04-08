%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert geometry from a Collada document to a PBRT-XML document.
%   @param id
%   @param stubIDMap
%   @param colladaIDMap
%   @param hints
%
% @details
% Cherry pick from Collada "geometry", "source", "float_array", and
% "mesh" nodes in the Collada document represented by the given @a
% colladaIDMap, and populate the corresponding node of the stub PBRT-XML
% document represented by the given @a stubIDMap.  @a id is the unique
% identifier of the geometry node.  @a hints is a struct of conversion
% hints.
%
% @details
% Returns true if the conversion was successful.
%
% @details
% Used internally by ColladaToPBRT().
%
% @details
% Usage:
%   isConverted = ConvertGeometry(id, stubIDMap, colladaIDMap, hints)
%
% @ingroup ColladaToPBRT
function isConverted = ConvertGeometry(id, stubIDMap, colladaIDMap, hints)

isConverted = true;

%% Find data from the "polylist", the top level for geometry data
%   get a "VERTEX" reference and a polylist offset
colladaPath = {id, ':mesh', ':polylist', ':input|semantic=VERTEX', '.source'};
vertexID = GetSceneValue(colladaIDMap, colladaPath);
vertexID = vertexID(vertexID ~= '#');
colladaPath = {id, ':mesh', ':polylist', ':input|semantic=VERTEX', '.offset'};
vertexOffset = str2double(GetSceneValue(colladaIDMap, colladaPath));

% follow the "VERTEX" reference, get another reference to "POSITION" data
colladaPath = {vertexID, ':input|semantic=POSITION', '.source'};
positionID = GetSceneValue(colladaIDMap, colladaPath);
positionID = positionID(positionID ~= '#');

% follow the "POSITION" reference to actual vertex position data
%   make sure the data are 3-element XYZ
colladaPath = {positionID, ':technique_common', ':accessor' '.stride'};
stride = str2double(GetSceneValue(colladaIDMap, colladaPath));
if stride ~= 3
    warning('"%s" position data are not packed XYZ, not converted', id);
    isConverted = false;
    return
end

% read actual position data
colladaPath = {positionID, ':float_array'};
positionString = GetSceneValue(colladaIDMap, colladaPath);
position = reshape(StringToVector(positionString), 3, []);

% get a "NORMAL" reference and a polylist offset
colladaPath = {id, ':mesh', ':polylist', ':input|.semantic=NORMAL', '.source'};
normalID = GetSceneValue(colladaIDMap, colladaPath);
normalID = normalID(normalID ~= '#');
colladaPath = {id, ':mesh', ':polylist', ':input|.semantic=NORMAL', '.offset'};
normalOffset = str2double(GetSceneValue(colladaIDMap, colladaPath));

% follow the "NORMAL" reference to actial vertex normal data
%   make sure the data are 3-element XYZ
colladaPath = {normalID, ':technique_common', ':accessor' '.stride'};
stride = str2double(GetSceneValue(colladaIDMap, colladaPath));
if stride ~= 3
    warning('"%s" normal data are not packed XYZ, not converted', id);
    isConverted = false;
    return
end

% read actual normal data
colladaPath = {normalID, ':float_array'};
normalsString = GetSceneValue(colladaIDMap, colladaPath);
normal = reshape(StringToVector(normalsString), 3, []);

% get number of polygons, polygon vertex counts, and indices from polylist
colladaPath = {id, ':mesh', ':polylist', '.count'};
nPolysString = GetSceneValue(colladaIDMap, colladaPath);
nPolys = StringToVector(nPolysString);

colladaPath = {id, ':mesh', ':polylist', ':vcount'};
vCountsString = GetSceneValue(colladaIDMap, colladaPath);
vCounts = StringToVector(vCountsString);

colladaPath = {id, ':mesh', ':polylist', ':p'};
polyIndicesString = GetSceneValue(colladaIDMap, colladaPath);
polyIndices = StringToVector(polyIndicesString);

%% Convert to PBRT-style geometry
% There are two big differences between Collada and PBRT geometry:
%   1. Collada uses n-sided polygons, where PBRT needs triangles.  We can
%   convert polygons to equivalent triangles, and use new indices.
%   2. Collada indexes positions and normals separately, then mixes and
%   matches them for each polygon, where PBRT indexes positions and normals
%   jointly.  This makes it hard to reuse position and normal data: a PBRT
%   vertex index corresponds to the *combination* of Collada position index
%   and normal index.

% make PBRT vertices from Collada combinations of position and normal
nVertices = sum(vCounts);
indexStride = numel(polyIndices) / nVertices;
vertexData = repmat(struct('position', [], 'normal', []), 1, nVertices);
vertexCount = 0;
for ii = 1:indexStride:numel(polyIndices)
    % locate Collada position and normal data
    posIndex = 1 + polyIndices(ii + vertexOffset);
    normIndex = 1 + polyIndices(ii + normalOffset);
    
    % save a new PBRT vertex
    vertexCount = vertexCount + 1;
    vertexData(vertexCount).position = position(:,posIndex);
    vertexData(vertexCount).normal = normal(:,normIndex);
end

% convert polygons to equivalent triangels
%   each vertex more than 3 incurs a new triangle
nTriangles = sum(vCounts - 2);
pbrtIndices = zeros(1, 3*nTriangles);
pbrtCount = 0;
polyStartIndices = 1 + [0; cumsum(vCounts(1:end-1))];
for ii = 1:nPolys
    nVerts = vCounts(ii);
    vertIndices = polyStartIndices(ii) + (0:(nVerts-1));
    
    if nVerts == 3
        % already a triangle, copy indices (as zero-based)
        zeroIndices = vertIndices - 1;
        pbrtIndices(pbrtCount + (1:3)) = zeroIndices;
        pbrtCount = pbrtCount + 3;
        
    elseif nVerts > 3
        % compute equivalent triangles for a polygon
        polyData = vertexData(vertIndices);
        polyPos = cat(2, polyData.position)';
        
        % rotate polygon into principal component space
        [coefs, rotated] = princomp(polyPos);
        
        % compute 2D Delaunay triangulation on rotated polygon
        %   ignore rotated z data, which should be all 0
        triIndices = delaunay(rotated(:,1:2));
        
        % copy indices for each Delaunay triangle (as zero-based)
        for tt = 1:size(triIndices, 1)
            zeroIndices = vertIndices(triIndices(tt,:)) - 1;
            pbrtIndices(pbrtCount + (1:3)) = zeroIndices;
            pbrtCount = pbrtCount + 3;
        end
        
    else
        % not a polygon!
        warning('"%s" polygon #%d has only %d vertices--ignored.', ...
            id, ii, nVerts);
    end
end

%% Write mesh data to a PBRT include file.
%   We could add mesh data directly to the PBRT stub document, but large
%   meshes make it hard for humans to read the document, and very large
%   meshes cause the XML DOM to run out of memory!

% create a new file with the node id in the file name
fileName = sprintf('mesh-data-%s.pbrt', id);
fid = fopen(fileName, 'w');
fprintf(fid, '# mesh data %s\n', id);

% fill it with a giant PBRT statement
identifier = 'Shape';
type = 'trianglemesh';
pbrtPositions = cat(1, vertexData.position);
pbrtNormals = cat(1, vertexData.normal);
params = struct( ...
    'name', {'P', 'N', 'indices'}, ...
    'type', {'point', 'normal', 'integer'}, ...
    'value', {pbrtPositions, pbrtNormals, pbrtIndices});
PrintPBRTStatement(fid, identifier, type, params);
fclose(fid);

%% Add a reference to the new file to the PBRT stub document.
SetType(stubIDMap, id, 'Shape', 'trianglemesh');
AddReference(stubIDMap, id, 'mesh-data', 'Include', fileName);
