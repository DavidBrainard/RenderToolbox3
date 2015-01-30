%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Condense several multi-spectral renderings into one sRGB montage.
%   @param inFiles cell array of input mat-file names
%   @param outFile output montage file name (optional)
%   @param toneMapFactor how to truncate montage luminance (optional)
%   @param isScale whether or how to scale montage luminance (optional)
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Condenses several multi-spectral renderings stored in mat-files into a
% single sRGB montage.  By default, tiles the input images so that the
% montage has roughly the same aspect ratio as the input images.  If @a
% inFiles has size other than 1xn, the dimensions of @a inFiles determine
% the dimensions of the montage.
%
% @details
% Attempts to conserve system memory by loading only one multi-spectral
% image at a time.
%
% @details
% @a inFiles must be a cell array of mat-file names, each of which must
% contain multi-spectral renderer output.  BatchRender() returns such a
% cell array.
%
% @details
% @a outFile determines the file name of the new montage.  The file
% extension determines the file format:
%   - If the extension is '.mat', the montage XYZ and sRGB matrices
%   will be saved to a .mat data file.
%   - If the extension matches a standard image format, like '.tiff' or
%   '.png' (default), the sRGB image will be saved in that format, using
%   Matlab's built-in imwrite().
%   .
%
% @details
% If @a toneMapFactor is provided and greater than 0, montage luminances
% will be truncated above this factor times the mean luminance of the
% entire montage.
%
% @details
% If isScale is provided and logical true, montage luminances will be 
% scaled so that the maximum input luminance of the entire montage matches 
% the maximum possible RGB output luminance.  If isScale is a numeric
% scalar, the montage luminances will be scaled by this amount.
%
% @details
% @a hints may be a struct with options that affect the montage, such as
% the output folder, as returned from GetDefaultHints().  If @a hints is
% omitted, default options are used.
%
% @details
% Returns a matrix containing the tone mapped, scaled, sRGB
% montage with size [height width 3].  Also returns a matrix containing XYZ
% image data with the same size.  Also returns a scalar, the amount by
% which montage luminances were scaled.  This may be equal to the given @a
% isScale, or it might have been calculated.
%
% @details
% Usage:
%   [SRGBMontage, XYZMontage, luminanceScale] = MakeMontage(inFiles, outFile, toneMapFactor, isScale, hints)
%
% @ingroup BatchRenderer
function [SRGBMontage, XYZMontage, luminanceScale] = MakeMontage(inFiles, outFile, toneMapFactor, isScale, hints)

SRGBMontage = [];
XYZMontage = [];

if nargin < 1 || isempty(inFiles)
    return;
end

if nargin < 2 || isempty(outFile)
    [inPath, inBase, inExt] = fileparts(inFiles{1});
    outFile = [inBase '-montage.png'];
end
[outPath, outBase, outExt] = fileparts(outFile);

if isempty(outPath)
    outPath = GetWorkingFolder('images', true, hints);
end

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 0;
end

if nargin < 4 || isempty(isScale)
    isScale = false;
end

if nargin < 5
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% If this is a dry run, skip the montage.
if hints.isDryRun
    return;
end

%% Pick the montage dimensions.
nIns = numel(inFiles);
dims = size(inFiles);
if 1 == dims(1)
    % default to roughly square
    nRows = floor(sqrt(nIns));
else
    % use given dimensions
    nRows = dims(1);
end
nCols = ceil(nIns / nRows);

%% Assemble the montage.
for ii = 1:nIns
    % get multispectral data from disk
    inData = load(inFiles{ii});
    multiImage = inData.multispectralImage;
    S = inData.S;
    
    % convert down to XYZ representation
    XYZImage = MultispectralToSensorImage(multiImage, S, 'T_xyz1931');
    
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
    XYZMontage(y+(1:h), x+(1:w),:) = XYZImage(1:h, 1:w,:);
end

%% Convert the whole big XYZ montage to SRGB.
[SRGBMontage, rawImage, luminanceScale] = ...
    XYZToSRGB(XYZMontage, toneMapFactor, 0, isScale);

%% Save to disk.
outFullPath = fullfile(outPath, [outBase outExt]);
if strcmp(outExt, '.mat')
    % write multi-spectral data
    save(outFullPath, 'SRGBMontage', 'XYZMontage');
else
    % write RGB image
    imwrite(uint8(SRGBMontage), outFullPath, outExt(2:end));
end
