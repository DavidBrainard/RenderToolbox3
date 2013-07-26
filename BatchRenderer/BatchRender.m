%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render multiple scenes at once.
%   @param sceneFiles cell array of renderer-native scene file names
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Renders multiple renderer-native scene files in one batch.  @a sceneFiles
% should be a cell array of renderer-native scene files, such as those
% produced by MakeSceneFiles().  All renderer-native scene files should be
% intended for the same renderer, which should be specified in @a
% hints.renderer.
%
% @details
% Mitsuba-native scene files must use Mitsuba's own .xml file format.
% PBRT-native scene files should use RenderToolbox3's custom PBRT-XML file
% format with the extension .pbrt.xml, as produced by ColladaToPBRT().
% PBRT-native scene files may also use PBRT's own text file format, but
% these renderings might not be scaled properly into physical radiance
% units.
%
% @details
% @a hints may be a struct with options that affect the rendering process,
% as returned from GetDefaultHints().  If @a hints is omitted, default
% options are used.  For example:
%   - @a hints.renderer specifies which renderer to use
%   - @a hints.isParallel specifies whether to render in a "parfor" loop
%   - @a hints.outputDataFolder specefies where to store multi-spectral
%   radiance data files.
%   - @a hints.outputImageFolder specifies where to store RGB image files.
%   - @a hints.isDryRun specefies whether or not to skip actual rendering.
%   .
%
% @details
% Renders each renderer-native scene file in @a sceneFiles, and writes a
% new mat-file for each one.  Each mat-file will contain a multi-spectral
% rendering with two variables:
%   - multispectralImage - matrix of multi-spectral radiance data with size
%   [height width n]
%   - S - spectral band description for the rendering with elements [start
%   delta n]
%   .
% height and width are pixel image dimensions and n is the number of
% spectral bands in the image.  See the RenderToolbox3 wikiw for more about
% <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Spectrum-Bands">Spectrum Bands</a>.
%
% @details
% The each mat-file will also contain metadata about how the scene was
% rendered:
%   - sceneFile - the the name of the renderer-native scene file
%   - hints - the given @a hints struct, or default hints struct
%   - versionInfo - struct of version information about RenderToolbox3 and
%   its dependencies
%   - commandResult - text output from the shell command that invoked the
%   renderer
%   .
%
% @details
% The multi-spectral data in each .mat file will be scaled into physical
% radiance units using funtions like PBRTDataToRadiance() and
% MitsubaDataToRadiance().  These rely on renderer-specific scale factors
% computed previousy with ComputeRadiometricScaleFactors().  Each mat-file
% will also contain the radiometric scale factor that was used to convert
% data to radiance units: 
%   - radiometricScaleFactor - scale factor that was used to bring renderer
%   ouput into physical radiance units
%   .
%
% @details
% Returns a cell array of output mat-file names, with the same dimensions
% as the given @a sceneFiles.
%
% @details
% Usage:
%   outFiles = BatchRender(sceneFiles, hints)
%
% @ingroup BatchRenderer
function outFiles = BatchRender(sceneFiles, hints)

InitializeRenderToolbox();

%% Parameters
if nargin < 1 || isempty(sceneFiles)
    sceneFiles = {};
end

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Create the output folder for this renderer.
outPath = fullfile(GetOutputPath('outputDataFolder', hints), hints.renderer);
if ~exist(outPath, 'dir')
    mkdir(outPath);
end

%% Render each scene file.
% save toolbox version info with renderings
versionInfo = GetRenderToolbox3VersionInfo();

% render with local "for" or distributed "parfor" loop
nFiles = numel(sceneFiles);
outFiles = cell(size(sceneFiles));
fprintf('\nBatchRender started with isParallel=%d at %s.\n\n', ...
    hints.isParallel, datestr(now(), 0));
renderTick = tic();
err = [];
try
    if hints.isParallel
        % distributed "parfor" loop, don't time individual iterations
        parfor ii = 1:nFiles
            outFiles{ii} = ...
                renderScene(sceneFiles{ii}, versionInfo, hints);
        end
    else
        % local "for" loop, makes sense to time each iteration
        for ii = 1:nFiles
            fprintf('\nStarting scene %d of %d at %s (%.1fs elapsed).\n\n', ...
                ii, nFiles, datestr(now(), 0), toc(renderTick));
            
            outFiles{ii} = ...
                renderScene(sceneFiles{ii}, versionInfo, hints);
            
            fprintf('\nFinished scene %d of %d at %s (%.1fs elapsed).\n\n', ...
                ii, nFiles, datestr(now(), 0), toc(renderTick));
        end
    end
catch err
    disp('Rendering error!')
end

fprintf('\nBatchRender finished at %s (%.1fs elapsed).\n\n', ...
    datestr(now(), 0), toc(renderTick));

% report the error, if any
if ~isempty(err)
    rethrow(err)
end

% Render a scene file and save a .mat data file.
function outFile = renderScene(sceneFile, versionInfo, hints)

outFile = '';

% get the scene file parts
%   it may have a double extension, like base.pbrt.xml
[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
baseDot = find('.' == sceneBase, 1, 'first');
if ~isempty(baseDot)
    sceneBase = sceneBase(1:(baseDot-1));
end

% if this is a dry run, skip the rendering
if hints.isDryRun
    fprintf('Dry run of %s (%s).\n', sceneBase, hints.renderer);
    drawnow();
    return;
end

switch hints.renderer
    case 'Mitsuba'
        % invoke Mitsuba!
        [status, commandResult, output] = RunMitsuba(sceneFile);
        if status ~= 0
            error('Mitsuba rendering failed\n  %s\n  %s\n', ...
                sceneFile, commandResult);
        end
        
        % read raw output into memory
        %   including explicit spectral sampling, "S"
        [multispectralImage, wls, S] = ReadMultispectralEXR(output);
        
        % scale the output into radiance units
        mitsubaDoc = ReadSceneDOM(sceneFile);
        [multispectralImage, radiometricScaleFactor] = ...
            MitsubaDataToRadiance( ...
            multispectralImage, mitsubaDoc, hints);
        
    case 'PBRT'
        if strcmpi('.xml', sceneExt)
            % convert PBRT-XML to text, read scene document
            pbrtFile = fullfile(scenePath, [sceneBase '.pbrt']);
            if isempty(hints.filmType)
                hints.filmType = 'image';
            end
            WritePBRTFile(pbrtFile, sceneFile, hints);
            pbrtDoc = ReadSceneDOM(sceneFile);
            
        else
            % cannot read scene document from a text file!
            pbrtFile = sceneFile;
            pbrtDoc = [];
        end
        
        % invoke PBRT!
        [status, commandResult, output] = RunPBRT(pbrtFile);
        if status ~= 0
            error('PBRT rendering failed\n  %s\n  %s\n', ...
                pbrtFile, commandResult);
        end
        
        % read output into memory
        multispectralImage = ReadDAT(output);
        
        % scale the output into radiance units
        [multispectralImage, radiometricScaleFactor] = ...
            PBRTDataToRadiance( ...
            multispectralImage, pbrtDoc, hints);
        
        % interpret output according to PBRT's spectral sampling
        S = getpref('PBRT', 'S');
        
    otherwise
        S = [];
        multispectralImage = [];
        commandResult = '';
end

% save a .mat file with multispectral data and metadata
outPath = fullfile(GetOutputPath('outputDataFolder', hints), hints.renderer);
outFile = fullfile(outPath, [sceneBase '.mat']);
save(outFile, 'multispectralImage', 'S', 'radiometricScaleFactor', ...
    'hints', 'sceneFile', 'versionInfo', 'commandResult');
