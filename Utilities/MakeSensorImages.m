%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Write sensor image data files based on multi-spectral data files.
%   @param inFiles cell array of multi-spectral data file names
%   @param matchingFunctions color matching funciton matrices or filenames
%   @param matchingS matching function spectral sampling descriptions
%   @param matchingNames cell array of matching function names
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Writes new .mat data files that contain sensor images, one for each of
% the multi-spectral data files given in @a inFiles.  @a inFiles should be
% a cell array of multi-spectral .mat data files, as produced by
% BatchRender().
%
% @details
% @a matchingFunctions and @a matchingS specify the color matching
% functions used to convert multi-spectral data to sensor imgaes.  @a
% matchingFunctions should be a cell array, where each element specifies a
% separate color matching function.  Each element may have one of two
% forms: it may be a matrix containing color mathing data, or it may be the
% name of a Psychtoolbox colorimetric data file.
%
% @details
% @a matchingS is only required if @a matchingFunctions contains matrices.
% In that case, each element @a matchingS corresponds to an element of @a
% matchingFunctions, and must contain a description of the matching
% function's spectral sampling.
%
% @details
% See MultispectralToSensorImage() for more about matching functions and
% spectral sampling descriptions.  Elements of @a matchingFunctions are
% passed to MultispectralToSensorImage() as the "matchingFunction"
% argument.  Corresponding elements of @a matchingS are passed as the
% "matchingS" argument.
%
% @details
% @a matchingNames is optional.  If provided, each element @a matchingNames
% corresponds to an element of @a matchingFunctions, and may contain a
% descriptive name for that matching function.
%
% @details
% @a hints may be a struct with RenderToolbox3 options.  @a
% hints.outputDataFolder specifies where sensor image .mat data files will
% be written.
%
% @details
% Returns a cell array of sensor image data file names.  Rows of the
% cell array will correspond to elements of @a inFiles.  Columns of the
% cell array will corrrespond to elements of @a matchingFunctions.  Each
% data file name will start with the corresponding @a inFiles name and end
% with a descriptive suffix.  The suffix will be chosen from available
% sources, in order of preference:
%   - an element of the given @a matchingNames
%   - the name of a Psychtoolbox colorimetric data file
%   - a numeric suffix
%   .
%
% @details
% Usage:
%   outFiles = MakeSensorImages(inFiles, matchingFunctions, matchingS, matchingNames, hints)
%
% @ingroup Utilities
function outFiles = MakeSensorImages(inFiles, matchingFunctions, matchingS, matchingNames, hints)

if nargin < 4 || isempty(matchingS)
    matchingNames = cell(size(matchingFunctions));
end

if nargin < 5
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Resolve matching function matrices, spectral samplings, and names.
nMatching = numel(matchingFunctions);
matchFuncs = cell(1, nMatching);
matchS = cell(1, nMatching);
matchNames = cell(1, nMatching);
for ii = 1:nMatching
    % get data, sampling, and possible name
    if ischar(matchingFunctions{ii})
        % load Psychtoolbox colorimetric data and metadata
        [matchFuncs{ii}, matchS{ii}, category, name] = ...
            ParsePsychColorimetricMatFile(matchingFunctions{ii});
        
    else
        % take matching function and sampling directly, make up a name
        matchFuncs{ii} = matchingFunctions{ii};
        matchS{ii} = matchingS{ii};
        name = sprintf('%d', ii);
    end
    
    % use given name or fallback on automatically chosen name
    if ~isempty(matchingNames{ii}) && ischar(matchingNames{ii})
        matchNames{ii} = matchingNames{ii};
    else
        matchNames{ii} = name;
    end
end

%% Produce a sensor image for each input file and each matching function.
nMultispectral = numel(inFiles);
outFiles = cell(nMultispectral, nMatching);
if hints.isParallel
    % distributed "parfor"
    parfor ii = 1:nMultispectral
        outFiles(ii,:) = makeSensorImages(inFiles{ii}, ...
            matchFuncs, matchS, matchNames, hints);
    end
else
    % local "for"
    for ii = 1:nMultispectral
        outFiles(ii,:) = makeSensorImages(inFiles{ii}, ...
            matchFuncs, matchS, matchNames, hints);
    end
end


% Produce a sensor image for the input file and each matching function.
function outFiles = makeSensorImages(inFile, ...
    matchFuncs, matchS, matchNames, hints)

nMatching = numel(matchFuncs);
outFiles = cell(1, nMatching);

if ~exist(inFile, 'file')
    return;
end

% read multispectral image and metadata
inData = load(inFile);
[inPath, inBase, inExt] = fileparts(inFile);

% make a sensor image for each mapping function
for ii = 1:nMatching
    % convert multi-spectral to to sensor image
    multispectralImage = inData.multispectralImage;
    imageS = inData.S;
    matchingFunction = matchFuncs{ii};
    matchingS = matchS{ii};
    sensorImage = MultispectralToSensorImage( ...
        multispectralImage, imageS, matchingFunction, matchingS);
    
    % choose a name for the new data file of the form
    %   inputFileName_matchingFunctionName.mat
    outName = [inBase '_' matchNames{ii} '.mat'];
    outFiles{ii} = fullfile(GetOutputPath('outputDataFolder', hints), ...
        hints.renderer, outName);
    
    % save sensor image and some metadata
    save(outFiles{ii}, ...
        'sensorImage', ...
        'multispectralImage', ...
        'imageS', ...
        'matchingFunction', ...
        'matchingS');
end