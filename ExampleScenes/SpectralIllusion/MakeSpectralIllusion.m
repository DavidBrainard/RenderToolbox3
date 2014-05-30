%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render the SpectralIllusion scene, with sampled spectra on a cube.

%% Choose example files, make sure they're on the Matlab path.
parentSceneFile = 'SpectralIllusion.dae';
mappingsFile = 'SpectralIllusionMappings.txt';
initialConditionsFile = 'SpectralIllusionConditionsInitial.txt';
cleverConditionsFile = 'SpectralIllusionConditionsClever.txt';

%% Choose batch renderer options.
hints = GetDefaultHints();
hints.renderer = 'Mitsuba';
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

resources = GetWorkingFolder('resources', false, hints);

toneMapFactor = 100;
isScale = true;

%% Write some initial spectrum files.
% get basis CIE daylight basis vectors
load B_cieday

% make the bright yellow sun
temp = 4000;
scale = 1;
spd = scale * GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, ...
    fullfile(resources, sprintf('CIE-daylight-%d.spd', temp)));

% make the dimmer blue sky
temp = 10000;
scale = 0.001;
spd = scale * GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, ...
    fullfile(resources, sprintf('CIE-daylight-%d.spd', temp)));

% make a target reflectance that is not too bright
originalSpectrum = 'mccBabel-11.spd';
[wls, originalReflect] = ReadSpectrum(originalSpectrum);
scale = 1;
srf = scale * originalReflect;
targetSpectrumFile = fullfile(resources, 'SpectralIllusionTarget.spd');
WriteSpectrumFile(wls, srf, targetSpectrumFile);

%% Plot the initial target and destination reflectances.
% read target and destination reflectances from conditions file
[names, values] = ParseConditions(initialConditionsFile);
targSpectrum = values{strcmp(names, 'targetColor')};
destSpectrum = values{strcmp(names, 'destinationColor')};
[targWls, targReflect] = ReadSpectrum(targSpectrum);
[destWls, destReflect] = ReadSpectrum(destSpectrum);

if hints.isPlot
    f = figure('UserData', 'SpectralIllusion');
    axReflect = subplot(5, 1, 3, 'Parent', f);
    plot(axReflect, ...
        targWls, targReflect, 'square', ...
        destWls, destReflect, 'o');
    xlim(axReflect, [350 750]);
    ylabel(axReflect, 'reflectance');
    legend(axReflect, 'target', 'destination', ...
        'Location', 'northwest')
    set(axReflect,  'UserData', 'reflectance', 'Box', 'off');
    drawnow();
end

%% Do the initial rendering.
nativeSceneFiles = MakeSceneFiles(parentSceneFile, initialConditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('SpectralIllusionInitial (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);

% only makes sense to proceed with fresh renderings and scene files
if hints.isReuseSceneFiles || hints.isDryRun
    return;
end

%% Plot the initial rendering.
if hints.isPlot
    axInitial = subplot(5, 2, [1 3], 'Parent', f);
    imshow(uint8(SRGBMontage), 'Parent', axInitial);
    title('initial');
    set(axInitial, 'UserData', 'initial');
    drawnow();
end

%% Read the initial rendering and compute a clever destination spectrum.
% locate the target and destination pixels in the rendering
rendering = load(radianceDataFiles{1});
height = size(rendering.multispectralImage, 1);
width = size(rendering.multispectralImage, 2);
targX = round(width * (165/320));
targY = round(height * (68/240));
destX = round(width * (211/320));
destY = round(height * (151/240));

% get the target and destination pixel spectra
targPixel = squeeze(rendering.multispectralImage(targY, targX, :));
destPixel = squeeze(rendering.multispectralImage(destY, destX, :));

% compute the target and destination apparent illumination
targPixelResampled = SplineRaw(rendering.S, targPixel, targWls);
targIllum = targPixelResampled ./ targReflect;
destPixelResampled = SplineRaw(rendering.S, destPixel, destWls);
destIllum = destPixelResampled ./ destReflect;

%% Plot target and destination pixels and apparent illumination.
% show target and destination pixel locations
if hints.isPlot
    line(targX, targY, ...
        'Parent', axInitial, ...
        'Marker', 'square', ...
        'Color', [0 0 1]);
    line(destX, destY, ...
        'Parent', axInitial, ...
        'Marker', 'o', ...
        'Color', [0 1 0]);
    
    % show apparent illumination
    axIllum = subplot(5, 1, 4, 'Parent', f);
    plot(axIllum, ...
        targWls, targIllum, 'square', ...
        destWls, destIllum, 'o');
    ylabel(axIllum, 'illumination');
    xlim(axIllum, [350 750]);
    set(axIllum, 'UserData', 'illumination', 'Box', 'off');
    drawnow();
    
    % show rendered pixel spectra
    wls = SToWls(rendering.S);
    axPixel = subplot(5, 1, 5, 'Parent', f);
    plot(axPixel, ...
        wls, targPixel, 'square', ...
        wls, destPixel, 'o');
    ylabel(axPixel, 'pixel');
    xlim(axPixel, [350 750]);
    set(axPixel, 'UserData', 'reflected', 'Box', 'off');
    drawnow();
end

%% Compute a clever new destination spectrum and write it to file.
destIllumNonzero = max(destIllum, 0.001);
cleverReflect = targPixelResampled ./ destIllumNonzero;
destinationSpectrumFile = fullfile(resources, 'SpectralIllusionDestination.spd');
WriteSpectrumFile(destWls, cleverReflect, destinationSpectrumFile);

%% Plot the clever new reflectance
if hints.isPlot
    line(destWls, cleverReflect, ...
        'Parent', axReflect, ...
        'LineStyle', 'none', ...
        'Marker', '*', ...
        'Color', [1 0 0])
    legend(axReflect, 'target', 'destination', 'illusion destination', ...
        'Location', 'northwest')
end

%% Render the illusion using the clever destination spectrum.
nativeSceneFiles = MakeSceneFiles(parentSceneFile, cleverConditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('SpectralIllusionClever (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);

%% Plot the clever rendering.
if hints.isPlot
    axClever = subplot(5, 2, [2 4], 'Parent', f);
    imshow(uint8(SRGBMontage), 'Parent', axClever);
    title('illusion');
    set(axClever,  'UserData', 'illusion');
    drawnow();
end

%% Read the destination pixel from the clever rendering.
rendering = load(radianceDataFiles{1});
height = size(rendering.multispectralImage, 1);
width = size(rendering.multispectralImage, 2);
destPixel = squeeze(rendering.multispectralImage(destY, destX, :));

% compute the destination pixel apparent illumination
destPixelResampled = SplineRaw(rendering.S, destPixel, destWls);
destIllum = destPixelResampled ./ cleverReflect;

%% Plot clever destination pixel spectrum and apparent illumination.
% apparent illumination
if hints.isPlot
    line(destWls, destIllum, ...
        'Parent', axIllum, ...
        'LineStyle', 'none', ...
        'Marker', '*', ...
        'Color', [1 0 0])
    
    % pixel spectrum
    wls = SToWls(rendering.S);
    line(wls, destPixel, ...
        'Parent', axPixel, ...
        'LineStyle', 'none', ...
        'Marker', '*', ...
        'Color', [1 0 0])
end
