%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Condense several multi-spectral images into one sRGB montage.
%   @param inFiles cell array of input .mat file names
%   @param outFile output montage file name (optional)
%   @param toneMapFactor how to truncate montage luminance (optional)
%   @param isScale whether or not to scale montage luminance (optional)
%
% @details
% Condenses several multi-spectral images stored in .mat files into a
% single sRGB montage.  Tiles the input images so that the montage has
% roughly the same aspect ratio as the input images.
%
% @details
% Attempts to conserve system memory by loading only one multi-spectral
% image at a time.
%
% @details
% @a inFiles must be a cell array of .mat file names, each of which must
% contain multi-spectral renderer output.  BatchRender() returns such a
% cell array.
%
% @details
% @a outFile determines where the montage is saved, and may include a path.
% The extension of @a outFile determines how the montage is saved:
%   - The default is '.mat', in which case the montage XYZ and sRGB
%   matrices are is saved to a new .mat file
%   - If the extension matches a standard image format, like '.tiff' or
%   '.png', the sRGB image will be saved in that format with Matlab's
%   built-in imwrite().
%   .
%
% @details
% If @a toneMapFactor is provided and greater than 0, montage luminances
% will be truncated above this factor times the mean luminance of the
% entire montage.
%
% @details
% If isScale is provided and true, montage luminances will be scaled so
% that the maximum input luminance matches the maximum possible output
% luminance.
%
% @details
% Returns a matrix containing the tone mapped, scaled, sRGB
% montage with size [height width 3].  Also returns a matrix containing XYZ
% image data with the same size.
%
% @details
% Usage:
%   [SRGBMontage, XYZMontage] = MakeMontage(inFiles, outFile, toneMapFactor, isScale)
%
% @ingroup BatchRender
function [SRGBMontage, XYZMontage] = MakeMontage(inFiles, outFile, toneMapFactor, isScale)

%% Parameters
if nargin < 2 || isempty(outFile)
    [inPath, inBase, inExt] = fileparts(inFiles{1});
    outFile = fullfile(inPath, [inBase '.mat']);
end
[outPath, outBase, outExt] = fileparts(outFile);

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 0;
end

if nargin < 4 || isempty(isScale)
    isScale = false;
end

%% Make a rectangular montage.
nIns = numel(inFiles);
nRows = floor(sqrt(nIns));
nCols = ceil(nIns / nRows);
for ii = 1:nIns
    % get hyperspectral data from disk
    inData = load(inFiles{ii});
    hyperImage = inData.hyperspectralImage;
    S = inData.S;
    
    % convert down to XYZ representation
    [SRGBImage, XYZImage] = MultispectralToSRGB( ...
        hyperImage, S, toneMapFactor, isScale);
    
    % first image, allocate a big XYZ montage
    if ii == 1
        h = size(XYZImage, 1);
        w = size(XYZImage, 2);
        XYZMontage = zeros(h*nRows, w*nCols, 3);
    end
    
    % insert the XYZ image into a cell of the montage
    row = 1 + mod(ii-1, nRows);
    col = 1 + floor((ii-1)/nRows);
    x = (col-1) * w;
    y = (row-1) * h;
    XYZMontage(y+(1:h), x+(1:w),:) = XYZImage;
end

%% cCnvert the whole big XYZ montage to SRGB.
SRGBMontage = XYZToSRGB(XYZMontage, toneMapFactor, 0, isScale);

%% Save to disk.
if strcmp(outExt, '.mat')
    save(outFile, 'SRGBMontage', 'XYZMontage');
else
    imwrite(uint8(SRGBMontage), outFile, outExt(2:end));
end

