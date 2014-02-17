%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Render multiple scenes at once.
%   @param scenes cell array of renderer-native scene descriptions or files
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Renders multiple renderer-native scene files in one batch.  @a scenes
% should be a cell array of renderer-native scene descriptions or scene
% files, such as those produced by MakeSceneFiles().  All renderer-native
% files should be intended for the same renderer, which should be specified
% in @a hints.renderer.
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
% Renders each renderer-native scene n @a scenes, and writes a new mat-file
% for each one.  Each mat-file will contain several variables including:
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
% The each mat-file will also contain variables with metadata about how the
% scene was made and rendererd:
%   - scene - the renderer-native scene description (e.g. file name,
%   Collada author info)
%   - hints - the given @a hints struct, or default hints struct
%   - versionInfo - struct of version information about RenderToolbox3,
%   its dependencies, and the current renderer
%   - commandResult - text output from the the current renderer
%   - radiometricScaleFactor - scale factor that was used to bring renderer
%   ouput into physical radiance units
%   .
%
% @details
% This function uses RenderToolbox3 renderer API functions "Render",
% "DataToRadiance", and "VersionInfo".  These functions, for the renderer
% specified in @a hints.renderer, must be on the Matlab path.
%
% @details
% Returns a cell array of output mat-file names, with the same dimensions
% as the given @a scenes.
%
% @details
% Usage:
%   outFiles = BatchRender(scenes, hints)
%
% @ingroup BatchRenderer
function outFiles = BatchRender(scenes, hints)

InitializeRenderToolbox();

%% Parameters
if nargin < 1 || isempty(scenes)
    scenes = {};
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
nScenes = numel(scenes);
outFiles = cell(size(scenes));
fprintf('\nBatchRender started with isParallel=%d at %s.\n\n', ...
    hints.isParallel, datestr(now(), 0));
renderTick = tic();
err = [];
try
    if hints.isParallel
        % distributed "parfor" loop, don't time individual iterations
        parfor ii = 1:nScenes
            outFiles{ii} = ...
                renderScene(scenes{ii}, versionInfo, hints);
        end
    else
        % local "for" loop, makes sense to time each iteration
        for ii = 1:nScenes
            fprintf('\nStarting scene %d of %d at %s (%.1fs elapsed).\n\n', ...
                ii, nScenes, datestr(now(), 0), toc(renderTick));
            
            outFiles{ii} = ...
                renderScene(scenes{ii}, versionInfo, hints);
            
            fprintf('\nFinished scene %d of %d at %s (%.1fs elapsed).\n\n', ...
                ii, nScenes, datestr(now(), 0), toc(renderTick));
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

% Render a scene and save a .mat data file.
function outFile = renderScene(scene, versionInfo, hints)

outFile = '';

% if this is a dry run, skip the rendering
if hints.isDryRun
    disp(['Dry run of ' hints.renderer ' scene:'])
    disp(scene)
    drawnow();
    return;
end

% record renderer version info
versionInfoFunction = GetRendererAPIFunction('VersionInfo', hints.renderer);
if ~isempty(versionInfoFunction)
    versionInfo.rendererVersionInfo = feval(versionInfoFunction);
end

% render the scene
renderFunction = GetRendererAPIFunction('Render', hints.renderer);
if isempty(renderFunction)
    return
end

% renderer plugin need not preview results
hints.isPlot = false;
[status, commandResult, multispectralImage, S] = ...
    feval(renderFunction, scene, hints);
if 0 ~= status
    return
end

% convert rendered image to radiance units
dataToRadianceFunction = ...
    GetRendererAPIFunction('DataToRadiance', hints.renderer);
if isempty(dataToRadianceFunction)
    return
end
[multispectralImage, radiometricScaleFactor] = ...
    feval(dataToRadianceFunction, multispectralImage, scene, hints);

% save a .mat file with multispectral data and metadata
outPath = fullfile(GetOutputPath('outputDataFolder', hints), hints.renderer);
outFile = fullfile(outPath, [scene(1).imageName '.mat']);
save(outFile, 'multispectralImage', 'S', 'radiometricScaleFactor', ...
    'hints', 'scene', 'versionInfo', 'commandResult');
