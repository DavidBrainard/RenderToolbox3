%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Condense several multi-spectral images into one sRGB montage.
%   @param inFiles cell array of input .mat file names
%   @param outFile output montage file name (optional)
%   @param toneMapFactor how to truncate montage luminance (optional)
%   @param isScale whether or not to scale montage luminance (optional)
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
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
% @a outFile determines the file name of the new montage.  The file
% extension determines the file format:
%   - If the extension is '.mat', the montage XYZ and sRGB matrices are
%   will be saved to a .mat data file.
%   - If the extension matches a standard image format, like '.tiff' or
%   '.png' (default), the sRGB image will be saved in that format, using
%   Matlab's built-in imwrite().
%   .
%
% @details
% @a outFile does not determine where the montage will be saved.  If @a
% hints is provided and contains a @b outputImageFolder field, the montage
% will be saved in that folder.  Otherwise, the montage will be saved in a
% default location given by:
% @code
%   folder = getpref('RenderToolbox3', 'outputImageFolder')
% @endcode
%
% @details
% If @a toneMapFactor is provided and greater than 0, montage luminances
% will be truncated above this factor times the mean luminance of the
% entire montage.
%
% @details
% If isScale is provided and true, montage luminances will be scaled so
% that the maximum input luminance of the entire montage matches the
% maximum possible RGB output luminance.
%
% @details
% @a hints may be a struct with options that affect the montage, such as
% the output folder, as returned from GetDefaultHints().  If @a hints is
% omitted, default options are used.
%
% @details
% Returns a matrix containing the tone mapped, scaled, sRGB
% montage with size [height width 3].  Also returns a matrix containing XYZ
% image data with the same size.
%
% @details
% Usage:
%   [SRGBMontage, XYZMontage] = MakeMontage(inFiles, outFile, toneMapFactor, isScale, hints)
%
% @ingroup BatchRenderer
function [SRGBMontage, XYZMontage] = MakeMontage(inFiles, outFile, toneMapFactor, isScale, hints)

%% Parameters
if nargin < 2 || isempty(outFile)
    [inPath, inBase, inExt] = fileparts(inFiles{1});
    outFile = [inBase '-montage.png'];
end
[outPath, outBase, outExt] = fileparts(outFile);

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
    SRGBMontage = [];
    XYZMontage = [];
    return;
end

%% Make a rectangular montage.
nIns = numel(inFiles);
nRows = floor(sqrt(nIns));
nCols = ceil(nIns / nRows);
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
SRGBMontage = XYZToSRGB(XYZMontage, toneMapFactor, 0, isScale);

%% Save to disk.
imageFolder = fullfile(hints.outputImageFolder, hints.outputSubfolder);
if ~exist(imageFolder, 'dir')
    mkdir(imageFolder)
end

outFullPath = fullfile(imageFolder, [outBase outExt]);
if strcmp(outExt, '.mat')
    % write multi-spectral data
    save(outFullPath, 'SRGBMontage', 'XYZMontage');
else
    % write RGB image
    imwrite(uint8(SRGBMontage), outFullPath, outExt(2:end));
end
