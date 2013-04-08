%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Compare ExampleScenes/ outputs that were generated at different times.
%   @param outputRootA base path where to find data set A
%   @param outputNameA trailing path where to find data set A
%   @param outputRootB base path where to find data set B
%   @param outputNameB trailing path where to find data set B
%   @param exampleFolder name of an ExampleScenes/ subfolder
%   @param visualize whether to plot renderings and comparisons
%
% @details
% Finds 2 sets of ouput folders in RenderToolbox3 ExampleScenes/.  Set A
% includes output folders located under @a outputRootA, with an optional
% trailing subfolder name @a outputNameA.  Likewise, Set B includes
% output folders located under @a outputRootB, with an optional
% trailing subfolder name @a outputNameB.  @a outputRootA and @a
% outputRootB may be the same, as long as @a outputNameA and @a
% outputNameB are different.
%
% @details
% Attempts to locate renderer output data files sets A and B, and to match
% up outputs that have the same name in both sets.  For each matched pair
% of outputs, loads multispectral data and computes the difference of
% normalized multispectral images, A minus B.
%
% @details
% If @a outputRootA is omitted, uses the deafult location in
% getpref('RenderToolbox3', 'outputDataFolder').  % If @a outputRootB is
% omitted, uses the RenderToolbox3 ExampleScenes/ folder.
%
% @details
% If @a outputNameA and @a outputNameB are optional.  If @a outputRootB is
% omitted, uses the name of a recently generated set of RenderToolbox3
% reference data, such as 'Output-Generated-21-Feb-2013'.
%
% @details
% If @a exampleFolder is provided, only compares outputs in the named
% ExampleScenes/ subfolder, such as "CubanSphere".  Otherwise, compares
% outputs for all example scenes.
%
% @details
% If @a visualize is greater than 0 (the default), plots a grand summary
% of all matched output pairs.  The summary shows the name of each pair,
% and the minimuim and maximum difference between normalized multispectral
% pixel components (A minus B).
%
% @details
% If @a visualize is greater than 1, makes a detailed figure for each
% matched pair.  Each detailed figure shows an sRGB representation of the
% rendering from A set, the B set, and the difference between the sets (A
% minus B).  The plot also shows a histogram of the differences between
% normalized multispectral pixel components (A minus B).
%
% @details
% Returns a struct array of info about each matched pair, including file
% names and differneces between normalized multispectral images (A minus
% B).
%
% @details
% Also returns a cell array of paths for files in set A that did not match
% any of the files in set B.  Likewise, returns a cell array of paths for
% files in set B that did not match any of the files in set A.
%
% @details
% Usage:
%   [matchInfo, unmatchedA, unmatchedB] = CompareAllExampleScenes(outputRootA, outputNameA, outputRootA, outputNameA, exampleFolder, visualize)
%
% @ingroup ExampleScenes
function [matchInfo, unmatchedA, unmatchedB] = CompareAllExampleScenes(outputRootA, outputNameA, outputRootB, outputNameB, exampleFolder, visualize)

if nargin < 1  || isempty(outputRootA)
    outputRootA = getpref('RenderToolbox3', 'outputDataFolder');
end

if nargin < 2  || isempty(outputNameA)
    outputNameA = '';
end

if nargin < 3  || isempty(outputRootB)
    outputRootB = fullfile(RenderToolboxRoot(), 'ExampleScenes');
end

if nargin < 4  || isempty(outputNameB)
    outputNameB = 'Output-Generated-21-Feb-2013';
end

if nargin < 5 || isempty(exampleFolder)
    exampleFolder = '';
end

if nargin < 6 || isempty(visualize)
    visualize = 1;
end

matchInfo = [];
unmatchedA = {};
unmatchedB = {};

% make titles that summarize sets A and B
if isempty(outputNameA)
    titleA = outputRootA;
else
    titleA = outputNameA;
end

if isempty(outputNameB)
    titleB = outputRootB;
else
    titleB = outputNameB;
end

% find .mat files for sets A and B
filesA = FindFiles(outputRootA, [outputNameA '.+\.mat']);
filesB = FindFiles(outputRootB, [outputNameB '.+\.mat']);

if isempty(filesA)
    fprintf('Found no files for set A: %s\n', titleA);
    return;
end

if isempty(filesB)
    fprintf('Found no files for set B: %s\n', titleB);
    return;
end

% strip out the known root and name from each file path
%   get a mashup that can be compared between sets A and B
%   of the form subfolder renderer fileName
mashUpA = mashPaths(filesA, outputRootA, outputNameA);
mashUpB = mashPaths(filesB, outputRootB, outputNameA);

% report unmatched files
[setMatch, indexA, indexB] = intersect(mashUpA, mashUpB, 'stable');
filesMatched = filesA(indexA);
unmatchedA = setdiff(filesA, filesMatched);
unmatchedB = setdiff(filesB, filesMatched);

% allocate an info struct for image comparisons
matchInfo = struct( ...
    'name', mashUpA(indexA), ...
    'pathA', filesA(indexA), ...
    'pathB', filesB(indexB), ...
    'outputRootA', outputRootA, ...
    'outputRootB', outputRootB, ...
    'outputNameA', outputNameA, ...
    'outputNameB', outputNameB, ...
    'titleA', titleA, ...
    'titleB', titleB, ...
    'samplingA', [], ...
    'samplingB', [], ...
    'maxDiff', nan, ...
    'minDiff', nan, ...
    'diffHistCenters', [], ...
    'diffHistCounts', [], ...
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
    % load rendering A
    dataA = load(matchInfo(ii).pathA);
    if isfield(dataA, 'multispectralImage')
        maxA = max(dataA.multispectralImage(:));
        normalizedA = dataA.multispectralImage ./ maxA;
    else
        matchInfo(ii).error = ...
            sprintf('No multispectral image found in %s', ...
            matchInfo(ii).pathA);
        continue;
    end
    
    % load rendering B
    dataB = load(matchInfo(ii).pathB);
    if isfield(dataB, 'multispectralImage')
        maxB = max(dataB.multispectralImage(:));
        normalizedB = dataB.multispectralImage ./ maxB;
    else
        matchInfo(ii).error = ...
            spritnf('No multispectral image found in %s', ...
            matchInfo(ii).pathB);
        continue;
    end
    
    % check multispectral image dimensions
    if ~isequal(size(normalizedA), size(normalizedB))
        matchInfo(ii).error = ...
            sprintf('Image A[%s] is not the same size as image B[%s].', ...
            num2str(size(normalizedA)), num2str(size(normalizedB)));
        continue;
    end
    
    % check spectral sampling
    matchInfo(ii).samplingA = dataA.S;
    matchInfo(ii).samplingB = dataB.S;
    if ~isequal(dataA.S, dataB.S)
        matchInfo(ii).error = ...
            sprintf('Spectral sampling A[%s] is not the same as B[%s].', ...
            num2str(dataA.S), num2str(dataB.S));
        continue;
    end
    
    % compute the difference image
    normalizedDifference = normalizedA - normalizedB;
    matchInfo(ii).maxDiff = max(normalizedDifference(:));
    matchInfo(ii).minDiff = min(normalizedDifference(:));
    [histCounts, histCenters] = hist(normalizedDifference(:), nHistBins);
    matchInfo(ii).diffHistCounts = histCounts;
    matchInfo(ii).diffHistCenters = histCenters;
    
    % plot difference image?
    if visualize > 1
        showDifferenceImage(matchInfo(ii), ...
            normalizedA, normalizedB, normalizedDifference);
    end
end

% plot a grand summary?
if visualize > 0
    showDifferenceSummary(matchInfo);
end

% Break a path into parts: root (subfolder) name (renderer) (file)
%   return a mash-up of the subfolder, renderer, and file
function mashUps = mashPaths(paths, root, name)
n = numel(paths);
mashUps = cell(1, n);
rootLength = numel(root);
for ii = 1:n
    % bite off the file name
    [filePath, fileBase, fileExt] = fileparts(paths{ii});
    file = [fileBase fileExt];
    
    % locate all the file separators
    seps = find(filesep() == filePath);
    
    % take the renderer as the last folder on the path
    renderer = filePath(seps(end)+1:end);
    
    % take the first subfolder after the root, if any
    subSeps = find(seps > rootLength);
    if 2 <= numel(subSeps)
        % take the first subfolder
        subStart = seps(subSeps(1)) + 1;
        subEnd = seps(subSeps(2)) - 1;
        subfolder = filePath(subStart:subEnd);
        
    else
        % no subfolder to take
        subfolder = '';
    end
    
    mashUps{ii} = [subfolder ' ' renderer ' ' file];
end


% Show sRGB images and difference image, plot difference histogram.
function showDifferenceImage(info, A, B, difference)
toneMapFactor = 0;

% make SRGB images
sRGBA = MultispectralToSRGB(A, info.samplingA, toneMapFactor, true);
sRGBB = MultispectralToSRGB(B, info.samplingB, toneMapFactor, true);
sRGBDiff = MultispectralToSRGB(difference, info.samplingA, toneMapFactor, false);

% show images in a new figure
f = figure('Name', info.name);

ax = subplot(2, 2, 2, 'Parent', f);
imshow(uint8(sRGBA), 'Parent', ax);
title(ax, ['A: ' info.titleA]);

ax = subplot(2, 2, 3, 'Parent', f);
imshow(uint8(sRGBB), 'Parent', ax);
title(ax, ['B: ' info.titleB]);

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
f = figure('Name', 'Output Differences');
names = {info.name};
maxes = [info.maxDiff];
mins = [info.minDiff];
n = numel(names);

ax = axes( ...
    'Parent', f, ...
    'YLim', [0 n+1], ...
    'YTick', 1:n, ...
    'YTickLabel', names);
line(mins, 1:n, ...
    'Parent', ax, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'Color', [0 0 1])
line(maxes, 1:n, ...
    'Parent', ax, ...
    'LineStyle', 'none', ...
    'Marker', '+', ...
    'Color', [1 0 0])
title(ax, sprintf('A: %s, B: %s', ...
    info(1).titleA, info(1).titleB));
xlabel(ax, 'Normalized multispectral pixel components A - B');
legend(ax, 'difference min', 'difference max', 'Location', 'northeast');