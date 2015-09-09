%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get multispectral image data out of a .dat file from Stanford.
%   @param filename string file name (path optional) of the .dat file
%   @param maxPlanes read only this many spectral planes (optional)
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
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands">Spectrum Bands</a>, and how RenderToolbox3 determines the spectral sampling of
% PBRT .dat files.
%
% @details
% Returns a matrix of multispectral image data, with size [height width n],
% where height and width are image size in pixels, and n is the number of
% spectral planes.
%
% @details
% Also returns the multispectral image dimensions [height width n].
%
% @details
% If @a maxPlanes is provided, n is limited to this number of planes.
%
% @details
% If the given .dat file contains an optional lens description, also
% returns a struct of lens data with fields @b focalLength, @b fStop,
% and @b fieldOfView.
%
% @details
% Usage:
%   [imageData, imageSize, lens] = ReadDAT(filename, maxPlanes)
%
% @ingroup Readers
function [imageData, imageSize, lens] = ReadDAT(filename, maxPlanes)

if nargin < 2 || isempty(maxPlanes)
    maxPlanes = [];
end

imageData = [];
imageSize = [];
lens = [];

%% Try to open the file
fprintf('Opening file "%s".\n', filename);
[fid, message] = fopen(filename, 'r');
if fid < 0
    error(message);
end

%% Read header line to get image size.
sizeLine = fgetl(fid);
dataPosition = ftell(fid);
[imageSize, count, err] = lineToMat(sizeLine);
if count ~=3
    fclose(fid);
    error('Could not read image size: %s', err);
end
wSize = imageSize(1);
hSize = imageSize(2);
nPlanes = imageSize(3);
imageSize = [hSize, wSize, nPlanes];

fprintf('  Reading image h=%d x w=%d x %d spectral planes.\n', ...
    hSize, wSize, nPlanes);

%% Optional second header line might contain realistic lens info.
lensLine = fgetl(fid);
[lensData, count, err] = lineToMat(lensLine);
if count == 3
    dataPosition = ftell(fid);
    lens.focalLength = lensData(1);
    lens.fStop = lensData(2);
    lens.fieldOfView = lensData(3);
    fprintf('  Found lens data focalLength=%d, fStop=%d, fieldOfView=%d.\n', ...
        lens.focalLength, lens.fStop, lens.fieldOfView);
end

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

if ~isempty(maxPlanes) && maxPlanes < nPlanes
    fprintf('  Limiting %d planes to maxPlanes = %d.\n', imageSize(3), maxPlanes);
    imageSize(3) = maxPlanes;
    imageData = imageData(:, :, 1:maxPlanes);
end

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