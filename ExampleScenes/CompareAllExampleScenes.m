%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Compare recipe renderings that were generated at different times.
%   @param workingFolderA base path where to find data set A
%   @param workingFolderB base path where to find data set B
%   @param filterExpression regular expression for filtering comparisons
%   @param visualize whether or not to plot renderings and comparisons
%
% @details
% Finds 2 sets of rendering outputs: set A includes renderings located
% under the given @a workingFolderA, set B includes renderings located
% under @a workingFolderB.  Attempts to match up data files from both sets,
% based on recipe names and renderer names.  Computes comparison statistics
% and shows difference images for each matched pair.
%
% @details
% Data sets must use a particular folder structure, consistent with
% GetWorkingFolder().  For each rendering data file, the expected path is:
% @code
%   workingFolder/recipeName/rendererName/renderings/fileName.mat
% @endcode
% workingFolder is either @a workingFolderA or @a workingFolderB.
% @b recipeName must be the name of a recipe such as "MakeDragon".
% @b rendererName must be the name of a renderer, like "PBRT" or "Mitsuba".
% @b fileName must be the name of a multi-spectral data file, such as
% "Dragon-001".
%
% @details
% If @a workingFolderA or @a workingFolderB is omitted or empty, uses the
% default working folder from GetWorkingFolder().
%
% @details
% By default, compares all renderings matched in @a workingFolderA, and @a
% workingFolderB.  If @a filterExpression is provided, it must be a regular
% expression used to match file paths.  Only data files whose paths match
% this expression will be compared.
%
% @details
% For example, you could use @a filterExpression to match only those
% renderings that came from the CoordinatesTest and Checherboard example
% scenes:
% @code
% CompareAllExampleScenes(workingFolderA, workingFolderB, 'CoordinatesTest|Checkerboard', 2);
% @endcode
%
% @details
% If @a visualize is greater than 0 (the default), plots a grand summary
% of all matched rendering pairs.  The summary shows the name of each pair,
% and some difference statistics for multi-spectral data A vs B.  Also
% saves a Matlab figure-file for the summary figure in the folder given by
% GetfileName('images').
%
% @details
% If @a visualize is greater than 1, makes a detailed figure for each
% matched pair.  Each figure shows sRGB representations of multi-spectral
% renderings and rendering differences: A, B, A-B, and B-A.  Also
% saves each detail figure as a Matlab fig-file and a png-file image,
% in the folder given by GetWorkingFolder('images').
%
% @details
% This function is intended to help validate RenderToolbox3 installations
% and detect bugs in the RenderToolbox3 code.  A potential use would
% compare renderings produced locally with archived renderings located at
% GitHub.  For example:
% @code
%   % produce renderings locally
%   TestAllExampleScenes('my/local/renderings');
%
%   % download archived renderings to 'my/local/archive'
%
%   % summarize local vs archived renderings
%   workingFolderA = 'my/local/renderings/data';
%   workingFolderA = 'my/local/archive/data';
%   visualize = 1;
%   matchInfo = CompareAllExampleScenes(workingFolderA, workingFolderB, '', visualize);
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
%   [matchInfo, unmatchedA, unmatchedB] = CompareAllExampleScenes(workingFolderA, workingFolderB, filterExpression, visualize)
%
% @ingroup ExampleScenes
function [matchInfo, unmatchedA, unmatchedB] = CompareAllExampleScenes(workingFolderA, workingFolderB, filterExpression, visualize)

if nargin < 1 || isempty(workingFolderA)
    workingFolderA = GetWorkingFolder();
end

if nargin < 2 || isempty(workingFolderB)
    workingFolderB = GetWorkingFolder();
end

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
fileFilter = [filterExpression '[^\.]*\.mat$'];
filesA = FindFiles(workingFolderA, fileFilter);
filesB = FindFiles(workingFolderB, fileFilter);

if isempty(filesA)
    fprintf('Found no files for set A in: %s\n', workingFolderA);
    return;
end

if isempty(filesB)
    fprintf('Found no files for set B in: %s\n', workingFolderB);
    return;
end

% get expected path parts for each file:
infoA = scanDataPaths(filesA);
infoB = scanDataPaths(filesB);

% report unmatched files
relativeA = {infoA.relativePath};
relativeB = {infoB.relativePath};
[setMatch, indexA, indexB] = intersect( ...
    relativeA, relativeB, 'stable');
[unmatched, unmatchedIndex] = setdiff(relativeA, relativeB);
unmatchedA = filesA(unmatchedIndex);
[unmatched, unmatchedIndex] = setdiff(relativeB, relativeA);
unmatchedB = filesB(unmatchedIndex);

% allocate an info struct for image comparisons
filesA = {infoA.original};
filesB = {infoB.original};
matchInfo = struct( ...
    'fileA', filesA(indexA), ...
    'fileB', filesB(indexB), ...
    'workingFolderA', workingFolderA, ...
    'workingFolderB', workingFolderB, ...
    'relativeA', relativeA(indexA), ...
    'relativeB', relativeB(indexB), ...
    'samplingA', [], ...
    'samplingB', [], ...
    'denominatorThreshold', 0.2, ...
    'subpixelsA', [], ...
    'subpixelsB', [], ...
    'normA', [], ...
    'normB', [], ...
    'normDiff', [], ...
    'absNormDiff', [], ...
    'relNormDiff', [], ...
    'corrcoef', nan, ...
    'isGoodComparison', false, ...
    'detailFigure', nan, ...
    'error', '');

% any comparisons to make?
nMatches = numel(matchInfo);
if nMatches > 0
    fprintf('Found %d matched pairs of data files.\n', nMatches);
else
    fprintf('Found no matched pairs.\n');
    return;
end

% compare matched images!
hints.recipeName = mfilename();
comparisonFolder = GetWorkingFolder('images', false, hints);
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
    
    % compute per-pixel component difference stats
    normA = multispectralA / max(multispectralA(:));
    normB = multispectralB / max(multispectralB(:));
    normDiff = normA - normB;
    absNormDiff = abs(normDiff);
    relNormDiff = absNormDiff ./ normA;
    cutoff = matchInfo(ii).denominatorThreshold;
    relNormDiff(normA < cutoff) = nan;
    
    % summarize differnece stats
    matchInfo(ii).subpixelsA = summarizeData(multispectralA);
    matchInfo(ii).subpixelsB = summarizeData(multispectralB);
    matchInfo(ii).normA = summarizeData(normA);
    matchInfo(ii).normB = summarizeData(normB);
    matchInfo(ii).normDiff = summarizeData(normDiff);
    matchInfo(ii).absNormDiff = summarizeData(absNormDiff);
    matchInfo(ii).relNormDiff = summarizeData(relNormDiff);
    
    % compute correlation among pixel components
    r = corrcoef(multispectralA(:), multispectralB(:));
    matchInfo(ii).corrcoef = r(1, 2);
    
    % plot difference image?
    if visualize > 1
        f = showDifferenceImage( ...
            matchInfo(ii), multispectralA, multispectralB);
        matchInfo(ii).detailFigure = f;
        
        % save detail figure to disk
        drawnow();
        [imagePath, imageName] = fileparts(matchInfo(ii).relativeA);
        imageCompPath = fullfile(comparisonFolder, imagePath);
        if ~exist(imageCompPath, 'dir')
            mkdir(imageCompPath);
        end
        figName = fullfile(imageCompPath, [imageName '.fig']);
        saveas(f, figName, 'fig');
        pngName = fullfile(imageCompPath, [imageName '.png']);
        saveas(f, pngName, 'png');
        
        close(f);
    end
end

% plot a grand summary?
if visualize > 0
    f = showDifferenceSummary(matchInfo);
    
    % save summary figure to disk
    if ~exist(comparisonFolder, 'dir')
        mkdir(comparisonFolder);
    end
    imageName = sprintf('%s-summary', mfilename());
    figName = fullfile(comparisonFolder, [imageName '.fig']);
    saveas(f, figName, 'fig');
end

if visualize > 1
    fprintf('\nSee comparison images saved in:\n  %s\n', comparisonFolder);
end


% Scan paths for expected parts:
%   root/recipeName/subfolderName/rendererName/fileName.extension
function info = scanDataPaths(paths)
n = numel(paths);
rootPath = cell(1, n);
relativePath = cell(1, n);
recipeName = cell(1, n);
subfolderName = cell(1, n);
rendererName = cell(1, n);
fileName = cell(1, n);
for ii = 1:n
    % break off the file name
    [parentPath, baseName, extension] = fileparts(paths{ii});
    fileName{ii} = [baseName extension];
    
    % break out subfolder names
    scanResult = textscan(parentPath, '%s', 'Delimiter', filesep());
    tokens = scanResult{1};
    
    % is there a renderer folder?
    if any(strcmp(tokens{end}, {'PBRT', 'Mitsuba'}))
        rendererName{ii} = tokens{end};
        subfolderNameIndex = numel(tokens) - 1;
    else
        rendererName{ii} = '';
        subfolderNameIndex = numel(tokens);
    end
    
    % get the named subfolder name
    subfolderName{ii} = tokens{subfolderNameIndex};
    
    % get the recipe name
    recipeName{ii} = tokens{subfolderNameIndex-1};
    
    % get the root path
    rootPath{ii} = fullfile(tokens{1:subfolderNameIndex-2});
    
    % build the rootless relative path
    relativePath{ii} = fullfile(recipeName{ii}, subfolderName{ii}, ...
        rendererName{ii}, fileName{ii});
end

info = struct( ...
    'original', paths, ...
    'fileName', fileName, ...
    'rendererName', rendererName, ...
    'recipeName', recipeName, ...
    'subfolderName', subfolderName, ...
    'rootPath', rootPath, ...
    'relativePath', relativePath);

% Show sRGB images and sRGB difference images
function f = showDifferenceImage(info, A, B)

% make SRGB images
S = info.samplingA;
isScale = true;
toneMapFactor = 0;
imageA = MultispectralToSRGB(A, S, toneMapFactor, isScale);
imageB = MultispectralToSRGB(B, S, toneMapFactor, isScale);
imageAB = MultispectralToSRGB(A-B, S, toneMapFactor, isScale);
imageBA = MultispectralToSRGB(B-A, S, toneMapFactor, isScale);

% show images in a new figure
name = sprintf('sRGB scaled: %s', info.relativeA);
f = figure('Name', name, 'NumberTitle', 'off');

ax = subplot(2, 2, 2, 'Parent', f);
imshow(uint8(imageA), 'Parent', ax);
title(ax, ['A: ' info.workingFolderA]);

ax = subplot(2, 2, 3, 'Parent', f);
imshow(uint8(imageB), 'Parent', ax);
title(ax, ['B: ' info.workingFolderB]);

ax = subplot(2, 2, 1, 'Parent', f);
imshow(uint8(imageAB), 'Parent', ax);
title(ax, 'Difference: A - B');

ax = subplot(2, 2, 4, 'Parent', f);
imshow(uint8(imageBA), 'Parent', ax);
title(ax, 'Difference: B - A');


% Show a summary of all difference images.
function f = showDifferenceSummary(info)
figureName = sprintf('A: %s vs B: %s', ...
    info(1).workingFolderA, info(1).workingFolderB);
f = figure('Name', figureName, 'NumberTitle', 'off');

% sort the summary by size of error
diffSummary = [info.relNormDiff];
errorStat = [diffSummary.max];
[sorted, order] = sort(errorStat);
info = info(order);

% summarize good comparisons
info = info([info.isGoodComparison]);
names = {info.relativeA};
nLines = numel(names);

% summarize data correlation coefficients
nLinesAtATime = 25;
corr = [info.corrcoef];
ax(1) = subplot(1, 2, 1, ...
    'Parent', f, ...
    'YTick', 1:nLines, ...
    'YTickLabel', names, ...
    'YGrid', 'on', ...
    'XLim', [min(corr), max(corr)]);
line(corr, 1:nLines, ...
    'Parent', ax(1), ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'Color', [0 0 1])
title(ax(1), 'rendering correlation');
xlabel(ax(1), 'corrcoef of pixel components A vs B');

% summarize mean and max subpixel differences
diffSummary = [info.relNormDiff];
maxes = [diffSummary.max];
means = [diffSummary.mean];
ax(2) = subplot(1, 2, 2, ...
    'Parent', f, ...
    'YTick', 1:nLines, ...
    'YTickLabel', 1:nLines, ...
    'YAxisLocation', 'right', ...
    'YGrid', 'on', ...
    'XLim', [min(means), max(maxes)]);
line(maxes, 1:nLines, ...
    'Parent', ax(2), ...
    'LineStyle', 'none', ...
    'Marker', '+', ...
    'Color', [1 0 0])
line(means, 1:nLines, ...
    'Parent', ax(2), ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'Color', [0 0 0])
legend(ax(2), 'max', 'mean', 'Location', 'northeast');
title(ax(2), 'extreme pixel components');
label = sprintf('relative diff |A-B|/A, where A/max(A) > %.1f', ...
    info(1).denominatorThreshold);
xlabel(ax(2), label);

% let the user scroll both axes at the same time
scrollerData.axes = ax;
scrollerData.nLinesAtATime = nLinesAtATime;
scroller = uicontrol( ...
    'Parent', f, ...
    'Units', 'normalized', ...
    'Position', [.95 0 .05 1], ...
    'Callback', @scrollSummaryAxes, ...
    'Min', 1, ...
    'Max', max(2, nLines), ...
    'Value', nLines, ...
    'Style', 'slider', ...
    'SliderStep', [1 2], ...
    'UserData', scrollerData);
scrollSummaryAxes(scroller, []);


% Summarize a distribuition of data with a struct of stats.
function summary = summarizeData(data)
finiteData = data(isfinite(data));
summary.min = min(finiteData);
summary.mean = mean(finiteData);
summary.max = max(finiteData);


% Scroll summary axes together.
function scrollSummaryAxes(object, event)
scrollerData = get(object, 'UserData');
topLine = get(object, 'Value');
yLimit = topLine + [-scrollerData.nLinesAtATime 1];
set(scrollerData.axes, 'YLim', yLimit);