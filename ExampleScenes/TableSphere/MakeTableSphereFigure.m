%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Make a figure comparing TableSphere renderings.
clear;
clc;

%% Render the scene.
MakeTableSphere();

%% Make a figure with renderings and a plot of spectra.
fig = figure();
clf(fig);
set(fig, 'Name', 'TableSphere');
labelSize = 14;

% choose a pixel of interest
pixX = 160;
pixY = 125;

% chose sRGB conversion parameters
toneMapFactor = 10;
isScale = true;

% choose a range of spectrum to plot
wMin = 300;
wMax = 800;

%% For each batch renderer condition:
%   show the PBRT rendering
%   show the Mitsuba rendering
%   get the light spectrum
%   get the spectrum from a Mitsuba pixel of interest
%   get the spectrum from a PBRT pixel of interest
%   plot the light and pixel spectra
conditionsFile = 'TableSphereConditions.txt';
[names, values] = ParseConditions(conditionsFile);
lightSpectrums = values(:, strcmp('lightColor', names));
imageNames = values(:, strcmp('imageName', names));
nImages = numel(imageNames);

% choose where to look for renderings
dataFolder = getpref('RenderToolbox3', 'outputDataFolder');
for ii = 1:nImages
    % make a PBRT sRGB image and read the pixel of interest
    PBRTImage = FindFiles(dataFolder, ['PBRT.+' imageNames{ii}]);
    PBRTData = load(PBRTImage{1});
    PBRTSRGB = MultispectralToSRGB(PBRTData.multispectralImage, ...
        PBRTData.S, toneMapFactor, isScale);
    [PBRTPixWls, PBRTPixMags] = GetPixelSpectrum( ...
        PBRTData.multispectralImage, PBRTData.S, pixX, pixY);
    
    % make a Mitsuba sRGB image and read the pixel of interest
    mitsubaImage = FindFiles(dataFolder, ['Mitsuba.+' imageNames{ii}]);
    mitsubaData = load(mitsubaImage{1});
    mitsubaSRGB = MultispectralToSRGB(mitsubaData.multispectralImage, ...
        mitsubaData.S, toneMapFactor, isScale);
    [mitsubaPixWls, mitsubaPixMags] = GetPixelSpectrum( ...
        mitsubaData.multispectralImage, mitsubaData.S, pixX, pixY);
    
    % show sRGB images
    axPBRT = subplot(3, nImages, ii);
    imshow(uint8(PBRTSRGB), 'Parent', axPBRT);
    title(axPBRT, imageNames{ii}, 'FontSize', labelSize);
    axMitsuba = subplot(3, nImages, nImages+ii);
    imshow(uint8(mitsubaSRGB), 'Parent', axMitsuba);
    
    % read the input light spectrum
    [lightWls, lightMags] = ReadSpectrum(lightSpectrums{ii});
    
    % show input and output spectra
    axSpectra = subplot(3, nImages, 2*nImages+ii, ...
        'XTick', wMin:100:wMax, ...
        'XLim', [wMin wMax] + [-10 +10], ...
        'YLim', [0 1.1], ...
        'YTick', [0 1], ...
        'YTickLabel', []);
    
    xlabel(axSpectra, 'wavelength (nm)', 'FontSize', labelSize);
    line(lightWls, lightMags / max(lightMags), ...
        'Parent', axSpectra, ...
        'Color', 0.7*[1 1 1], ...
        'Marker', '.', ...
        'MarkerSize', 10, ...
        'LineStyle', ':');
    poiPBRTColor = [1 0.5 0];
    poiPBRTMarker = 'square';
    line(PBRTPixWls, PBRTPixMags / max(PBRTPixMags), ...
        'Parent', axSpectra, ...
        'Color', poiPBRTColor, ...
        'Marker', poiPBRTMarker, ...
        'LineStyle', 'none');
    poiMitsubaColor = [0 0 1];
    poiMitsubaMarker = '+';
    line(mitsubaPixWls, mitsubaPixMags / max(mitsubaPixMags), ...
        'Parent', axSpectra, ...
        'Color', poiMitsubaColor, ...
        'Marker', poiMitsubaMarker, ...
        'LineStyle', 'none');
    
    % special annotations for the leftmost image
    if ii == 1
        % locate the PBRT pixel of interest
        ylabel(axMitsuba, 'Mitsuba', 'FontSize', labelSize);
        line(pixX, pixY, ...
            'Parent', axPBRT, ...
            'Color', poiPBRTColor, ...
            'Marker', poiPBRTMarker, ...
            'MarkerSize', 10, ...
            'LineWidth', 2, ...
            'LineStyle', 'none');
        
        % locate the Mitsuba pixel of interest
        ylabel(axPBRT, 'PBRT', 'FontSize', labelSize);
        line(pixX, pixY, ...
            'Parent', axMitsuba, ...
            'Color', poiMitsubaColor, ...
            'Marker', poiMitsubaMarker, ...
            'MarkerSize', 10, ...
            'LineWidth', 2, ...
            'LineStyle', 'none');
        
        % spectrum traces?
        ylabel(axSpectra, 'SPD', 'FontSize', labelSize);
        set(axSpectra, 'YTickLabel', {'0', 'max'});
        legend(axSpectra, ...
            'illuminant', ...
            'PBRT pixel', ...
            'Mitsuba pixel', ...
            'Location', 'SouthEast');
    end
end
