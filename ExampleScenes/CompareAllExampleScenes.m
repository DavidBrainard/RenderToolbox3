%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Compare ExampleScenes/ outputs that were generated at different times.
%   @param outputRootA base path where to find data set A
%   @param outputRootB base path where to find data set B
%   @param filterExpression regular expression for filtering comparisons
%   @param visualize whether to plot renderings and comparisons
%
% @details
% Finds 2 sets of rendering outputs: set A includes output data located
% under the given @a outputRootA, set B includes output data located under
% @a outputRootB.  Attempts to match up data files from both sets that were
% generated by the same rendering script, as determined by the names of
% data subfolders.  For each matched pair of outputs, loads multispectral
% data and computes the difference of multispectral images, A minus B.
%
% @details
% Data sets must use an expected folder structure.  For each data file, the
% expected path is:
% @code
%   outputRoot/script-name/renderer-name/data-name.mat
% @end
% outputRoot is either @a outputRootA or @a outputRootB.  script-name must
% be the name of a rendering script such as "MakeDragon".  renderer-name
% must be the name of a renderer, either "PBRT" or "Mitsuba".  data-name
% must be the name of a multi-spectral data file, such as "Dragon-001".
%
% @details
% By default, compares all data files found in @a outputRootA, and @a
% outputRootB.  If @a filterExpression is provided, it must be a regular
% expression used to match file names.  Only data files that match this
% expression will be compared.
%
% @details
% If @a visualize is greater than 0 (the default), plots a grand summary
% of all matched output pairs.  The summary shows the name of each pair,
% and the minimuim and maximum difference between multispectral pixel
% components (A minus B).
%
% @details
% If @a visualize is greater than 1, makes a detailed figure for each
% matched pair.  Each detailed figure shows an sRGB representation of the
% rendering from A set, the B set, and the difference between the sets (A
% minus B).  The plot also shows a histogram of the differences between
% multispectral pixel components (A minus B).
%
% @details
% This function is intended to help validate RenderToolbox3 installations
% and detect bugs in the RenderToolbox3 code.  A potential use would
% compare renderings produced locally with archived renderings located on
% GitHub.  For example:
% @code
%   % produce renderings locally
%   TestAllExampleScenes('my/local/renderings');
%
%   % download archived renderings
%   git clone
%   https://github.com/DavidBrainard/RenderToolbox3-ReferenceData.git my/local/archive
%
%   % summarize local vs archived renderings
%   outputRootA = 'my/local/renderings/data';
%   outputRootA = 'my/local/archive/data';
%   visualize = 1;
%   matchInfo = CompareAllExampleScenes(outputRootA, outputRootB, '', visualize);
% @endcode
%
% @details
% Returns a struct array of info about each matched pair, including file
% names and differneces between multispectral images (A minus B).
%
% @details
% Also returns a cell array of paths for files in set A that did not match
% any of the files in set B.  Likewise, returns a cell array of paths for
% files in set B that did not match any of the files in set A.
%
% @details
% Usage:
%   [matchInfo, unmatchedA, unmatchedB] = CompareAllExampleScenes(outputRootA, outputRootB, filterExpression, visualize)
%
% @ingroup ExampleScenes
function [matchInfo, unmatchedA, unmatchedB] = CompareAllExampleScenes(outputRootA, outputRootB, filterExpression, visualize)

if nargin < 3 || isempty(filterExpression)
    filterExpression = '';
end

if nargin < 4 || isempty(visualize)
    visualize = 1;
end

matchInfo = [];
unmatchedA = {};
unmatchedB = {};

% find .mat files for sets A and B
fileFilter = [filterExpression '[^\.]*\.mat'];
filesA = FindFiles(outputRootA, fileFilter);
filesB = FindFiles(outputRootB, fileFilter);

if isempty(filesA)
    fprintf('Found no files for set A in: %s\n', outputRootA);
    return;
end

if isempty(filesB)
    fprintf('Found no files for set B in: %s\n', outputRootB);
    return;
end

% get expected path parts for each file:
%   root path/relative path, where
%   relative path = script-name/renderer-name/data-file-name
[rootA, relativeA, scriptA, rendererA, dataNameA] = scanDataPaths(filesA);
[rootB, relativeB, scriptB, rendererB, dataNameB] = scanDataPaths(filesB);

% report unmatched files
[setMatch, indexA, indexB] = intersect(relativeA, relativeB, 'stable');
filesMatched = filesA(indexA);
[unmatched, unmatchedIndex] = setdiff(relativeA, relativeB);
unmatchedA = filesA(unmatchedIndex);
[unmatched, unmatchedIndex] = setdiff(relativeB, relativeA);
unmatchedB = filesB(unmatchedIndex);

% allocate an info struct for image comparisons
matchInfo = struct( ...
    'fileA', filesA(indexA), ...
    'fileB', filesB(indexB), ...
    'outputRootA', outputRootA, ...
    'outputRootB', outputRootB, ...
    'relativeA', relativeA(indexA), ...
    'relativeB', relativeB(indexB), ...
    'samplingA', [], ...
    'samplingB', [], ...
    'maxDiff', nan, ...
    'minDiff', nan, ...
    'denominatorThreshold', 0.2, ...
    'maxDiffProportion', nan, ...
    'minDiffProportion', nan, ...
    'maxRatio', nan, ...
    'minRatio', nan, ...
    'corrcoef', nan, ...
    'diffHistCenters', [], ...
    'diffHistCounts', [], ...
    'isGoodComparison', false, ...
    'error', '');

% any comparisons to make?
nMatches = numel(matchInfo);
if nMatches > 0
    fprintf('Comparing %d matched pairs.\n', nMatches);
else
    fprintf('Found no matched pairs.\n');
    return;
end

% compare matched images!
nHistBins = 30;
for ii = 1:nMatches
    fprintf('%d of %d: %s\n', ii, nMatches, matchInfo(ii).relativeA);
    
    % load rendering A
    dataA = load(matchInfo(ii).fileA);
    if ~isfield(dataA, 'multispectralImage')
        matchInfo(ii).error = ...
            sprintf('No multispectral image found in %s', ...
            matchInfo(ii).fileA);
        continue;
    end
    multispectralA = dataA.multispectralImage;
    
    % load rendering B
    dataB = load(matchInfo(ii).fileB);
    if ~isfield(dataB, 'multispectralImage')
        matchInfo(ii).error = ...
            spritnf('No multispectral image found in %s', ...
            matchInfo(ii).fileB);
        continue;
    end
    multispectralB = dataB.multispectralImage;
    
    % check multispectral image dimensions
    if ~isequal(size(multispectralA), size(multispectralB))
        matchInfo(ii).error = ...
            sprintf('Image A[%s] is not the same size as image B[%s].', ...
            num2str(size(multispectralA)), num2str(size(multispectralB)));
        continue;
    end
    
    % check spectral sampling
    if ~isfield(dataA, 'S')
        matchInfo(ii).error = ...
            sprintf('Data file A has no spectral sampling variable ''S''.');
        continue;
    end
    matchInfo(ii).samplingA = dataA.S;
    if ~isfield(dataB, 'S')
        matchInfo(ii).error = ...
            sprintf('Data file B has no spectral sampling variable ''S''.');
        continue;
    end
    matchInfo(ii).samplingB = dataB.S;
    if ~isequal(dataA.S, dataB.S)
        matchInfo(ii).error = ...
            sprintf('Spectral sampling A[%s] is not the same as B[%s].', ...
            num2str(dataA.S), num2str(dataB.S));
        continue;
    end
    
    % comparison passes all sanity checks
    matchInfo(ii).isGoodComparison = true;
    
    % compute the difference image
    multispectralDiff = multispectralA - multispectralB;
    multispectralDiffProportion = multispectralDiff ./ multispectralA;
    cutoff = matchInfo(ii).denominatorThreshold;
    multispectralDiffProportion(multispectralA < cutoff) = nan;
    multispectralRatio = multispectralA ./ multispectralB;
    matchInfo(ii).maxDiff = max(multispectralDiff(:));
    matchInfo(ii).minDiff = min(multispectralDiff(:));
    matchInfo(ii).maxDiffProportion = max(multispectralDiffProportion(:));
    matchInfo(ii).minDiffProportion = min(multispectralDiffProportion(:));
    matchInfo(ii).maxRatio = max(multispectralRatio(:));
    matchInfo(ii).minRatio = min(multispectralRatio(:));
    r = corrcoef(multispectralA(:), multispectralB(:));
    matchInfo(ii).corrcoef = r(1, 2);
    [histCounts, histCenters] = hist(multispectralDiff(:), nHistBins);
    matchInfo(ii).diffHistCounts = histCounts;
    matchInfo(ii).diffHistCenters = histCenters;
    
    % plot difference image?
    if visualize > 1
        showDifferenceImage(matchInfo(ii), ...
            multispectralA, multispectralB, multispectralDiff);
    end
end

% plot a grand summary?
if visualize > 0
    showDifferenceSummary(matchInfo);
end


% Scan paths for expected parts:
%   root/script-name/renderer-name/data-name.mat
function [root, relative, script, renderer, dataName] = scanDataPaths(paths)
n = numel(paths);
root = cell(1, n);
relative = cell(1, n);
script = cell(1, n);
renderer = cell(1, n);
dataName = cell(1, n);
for ii = 1:n
    % break the path by file separator and "."
    separators = find(paths{ii} == filesep());
    nSeparators = numel(separators);
    
    if nSeparators >= 3
        % take root path
        first = 1;
        last = separators(nSeparators-2);
        root{ii} = paths{ii}(first:last);
    else
        root{ii} = '';
    end
    
    if nSeparators >= 2
        % take the script name
        first = separators(nSeparators-2) + 1;
        last = separators(nSeparators-1) - 1;
        script{ii} = paths{ii}(first:last);
    else
        script{ii} = '';
    end
    
    if nSeparators >= 1
        % take the renderer name
        first = separators(nSeparators-1) + 1;
        last = separators(nSeparators) - 1;
        renderer{ii} = paths{ii}(first:last);
        
        % take the data file name
        first = separators(nSeparators) + 1;
        last = numel(paths{ii});
        dataName{ii} = paths{ii}(first:last);
    else
        % take the data file name
        renderer{ii} = '';
        dataName{ii} = paths{ii};
    end
    
    % take extension off the dataName
    dots = find(dataName{ii} == '.');
    if ~isempty(dots)
        dataName{ii} = dataName{ii}(1:dots(1)-1);
    end
    
    % build a relative path, omitting any root
    relative{ii} = fullfile(script{ii}, renderer{ii}, dataName{ii});
end


% Show sRGB images and difference image, plot difference histogram.
function showDifferenceImage(info, A, B, difference)
toneMapFactor = 0;

% make SRGB images
sRGBA = MultispectralToSRGB(A, info.samplingA, toneMapFactor, true);
sRGBB = MultispectralToSRGB(B, info.samplingB, toneMapFactor, true);
sRGBDiff = MultispectralToSRGB(difference, info.samplingA, toneMapFactor, false);

% show images in a new figure
f = figure('Name', info.relativeA);

ax = subplot(2, 2, 2, 'Parent', f);
imshow(uint8(sRGBA), 'Parent', ax);
title(ax, ['A: ' info.outputRootA]);

ax = subplot(2, 2, 3, 'Parent', f);
imshow(uint8(sRGBB), 'Parent', ax);
title(ax, ['B: ' info.outputRootB]);

ax = subplot(2, 2, 1, 'Parent', f);
imshow(uint8(sRGBDiff), 'Parent', ax);
title(ax, 'Difference (A - B)');

ax = subplot(2, 2, 4, ...
    'Parent', f, ...
    'XLim', [min(info.diffHistCenters), max(info.diffHistCenters)], ...
    'YLim', [0, max(info.diffHistCounts)]);
line(info.diffHistCenters, info.diffHistCounts, ...
    'Parent', ax, ...
    'LineStyle', 'none', ...
    'Marker', '+');
title(ax, 'Difference Histogram');

drawnow();


% Show a summary of all difference images.
function showDifferenceSummary(info)
figureName = sprintf('A: %s vs B: %s', ...
    info(1).outputRootA, info(1).outputRootB);
f = figure('Name', figureName, 'NumberTitle', 'off');

% only summarize good comparisons
info = info([info.isGoodComparison]);

names = {info.relativeA};
n = numel(names);

% summarize data correlation coefficients
ax = subplot(1, 2, 1, ...
    'Parent', f, ...
    'YLim', [0 n+1], ...
    'YTick', 1:n, ...
    'YTickLabel', names);
line([info.corrcoef], 1:n, ...
    'Parent', ax, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'Color', [0 0 1])
title(ax, 'image correlation');
xlabel(ax, 'corrcoef of all pixel components A vs B');

% summarize min and max pixel differences
ax = subplot(1, 2, 2, ...
    'Parent', f, ...
    'YLim', [0 n+1], ...
    'YTick', 1:n, ...
    'YTickLabel', {});
line([info.minDiffProportion], 1:n, ...
    'Parent', ax, ...
    'LineStyle', 'none', ...
    'Marker', '+', ...
    'Color', [1 0 0])
line([info.maxDiffProportion], 1:n, ...
    'Parent', ax, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'Color', [0 0 0])
legend(ax, 'min', 'max', 'Location', 'northeast');
title(ax, 'extreme pixel components');
label = sprintf('relative difference (A - B) / A, if A >= %.1f', ...
    info(1).denominatorThreshold);
xlabel(ax, label);

