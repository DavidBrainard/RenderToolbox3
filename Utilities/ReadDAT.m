%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get hyperspectral image data out of a .dat file from Stanford.
%   @param filename string file name (path optional) of the .dat file
%
% @details
% Reads the given multi-spectral .dat file from @a filename.  The .dat
% format is described by Andy Lin on the Stanford Vision and Imaging
% Science and Technology <a
% href="http://white.stanford.edu/pdcwiki/index.php/PBRTFileFormat">wiki</a>.
% (If not, a description may be there soon.)
%
% @details
% See the RenderToolbox3 wiki for more about image <a 
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands">Spectrum
% Bands</a>, and how RenderToolbox3 determines the spectral sampling of
% PBRT .dat files.
%
% @details
% Returns a matrix of hyperspectral image data, with size [height width n],
% where height and width are image size in pixels, and n is the number of
% spectral planes.
%
% @details
% Also returns the hyperspectral image dimensions [height width n].
%
% @details
% Usage:
%   [imageData, imageSize] = ReadDAT(filename)
%
% @ingroup Readers
function [imageData, imageSize] = ReadDAT(filename)

imageData = [];
imageSize = [];

%% Try to open the file
fprintf('Opening file "%s".\n', filename);
[fid, message] = fopen(filename, 'r');
if fid < 0
    error(message);
end

%% Read header line to get image size
sizeLine = fgetl(fid);
dataPosition = ftell(fid);
[mifSize, count, err] = lineToMat(sizeLine);
if count <= 0
    fclose(fid);
    error('Could not read image size: %s', err);
end
wSize = mifSize(1);
hSize = mifSize(2);
nPlanes = mifSize(3);
imageSize = [hSize, wSize, nPlanes];

fprintf('  Reading image h=%d x w=%d x %d spectral planes.\n', ...
    hSize, wSize, nPlanes);

%% Read the whole .dat into memory
fseek(fid, dataPosition, 'bof');
serializedImage = fread(fid, inf, 'double');
fclose(fid);

fprintf('  Read %d pixel elements for image.\n', numel(serializedImage));

if numel(serializedImage) ~= prod(imageSize)
    error('Image should have %d pixel elements.\n', prod(imageSize))
end

%% shape the serialized data to image dimensions
imageData = reshape(serializedImage, hSize, wSize, nPlanes);

fprintf('OK.\n');

function [mat, count, err] = lineToMat(line)
% is it an actual line?
if isempty(line) || (isscalar(line) && line < 0)
    mat = [];
    count = -1;
    err = 'Invalid line.';
    return;
end

% scan line for numbers
[mat, count, err] = sscanf(line, '%f', inf);