%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Probe the RGB spectral promotion algortigms of renderers.
clear;
clc;

%% Choose some illuminants and RGB colors to render
% yellow daylight
load B_cieday
temp = 4000;
spd = GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
yellowDay = WriteSpectrumFile(wls, spd, sprintf('CIE-day-%d.spd', temp));

% blue daylight
temp = 10000;
spd = GenerateCIEDay(temp, B_cieday);
wls = SToWls(S_cieday);
blueDay = WriteSpectrumFile(wls, spd, sprintf('CIE-day-%d.spd', temp));

illuminants = {yellowDay, blueDay};
RGBs = {[.8 .1 .4], [.5 .5 .5]};

%% Get RGB promotions from PBRT and Mitsuba
renderers = {'Mitsuba', 'PBRT'};
nRenderers = numel(renderers);
nIlluminants = numel(illuminants);
nRGBs = numel(RGBs);
promotions = cell(nRenderers, nIlluminants, nRGBs);
SOuts = cell(nRenderers, nIlluminants, nRGBs);
RGBOuts = cell(nRenderers, nIlluminants, nRGBs);
dataFiles = cell(nRenderers, nIlluminants, nRGBs);
for rend = 1:nRenderers
    for illum = 1:nIlluminants
        for rgb = 1:nRGBs
            hints.renderer = renderers{rend};
            [promoted, S, RGB, dataFile] = ...
                PromoteRGBReflectance(RGBs{rgb}, illuminants{illum}, hints);
            promotions{rend, illum, rgb} = promoted;
            SOuts{rend, illum, rgb} = S;
            RGBOuts{rend, illum, rgb} = RGB;
            dataFiles{rend, illum, rgb} = dataFile;
        end
    end
end

%% Plot RGB, and promoted spectra.
close all
hints = GetDefaultHints();
RGBMarkers = {'x', 'o'};
RGBOutMarkers = {'+', 'square'};
spectrumMarkers = {'x', 'o'};
RGBLegend = {};
labelSize = 14;
if hints.isPlot
    fig = figure();
    nCols = nRGBs * 2;
    nRows = nIlluminants;
    for illum = 1:nIlluminants
        for rgb = 1:nRGBs
            % for plotting RGB values
            row = illum;
            sp = (2*rgb-1) + (illum-1)*nCols;
            axRGB = subplot(nRows, nCols, sp, ...
                'Parent', fig, ...
                'YLim', [0 1.1], ...
                'YTick', [0 1], ...
                'XLim', [.9 3.1], ...
                'XTick', 1:3, ...
                'XTickLabel', {});
            
            % for plotting promoted spectra
            outWls = MakeItWls(SOuts{1, illum, rgb});
            axSpectra = subplot(nRows, nCols, sp+1, ...
                'Parent', fig, ...
                'YLim', [0 1.1], ...
                'YTick', [0 1], ...
                'YAxisLocation', 'right', ...
                'XLim', [min(outWls) max(outWls)] + [-.1 .1], ...
                'XTick', [min(outWls) max(outWls)], ...
                'XTickLabel', {}, ...
                'XDir', 'reverse');
            
            % label outside plots
            if 1 == illum
                rgbName = sprintf('RGB=[%0.1f %0.1f %0.1f]', ...
                    RGBs{rgb}(1), RGBs{rgb}(2), RGBs{rgb}(3));
                title(axRGB, rgbName, 'FontSize', labelSize);
                title(axSpectra, 'promoted', 'FontSize', labelSize);
            end
            
            if 1 == rgb
                [illumPath, illumName] = fileparts(illuminants{illum});
                ylabel(axRGB, 'reflectance', 'FontSize', labelSize);
            end
            
            if nRGBs == rgb
                ylabel(axSpectra, illumName, ...
                    'Rotation', 0, ...
                    'HorizontalAlignment', 'left', ...
                    'FontSize', labelSize);
            end
            
            if illum == nIlluminants
                set(axRGB, 'XTickLabel', {'R', 'G', 'B'});
                xlabel(axRGB, 'component', 'FontSize', labelSize);
                set(axSpectra, 'XTickLabel', [min(outWls) max(outWls)])
                xlabel(axSpectra, 'wavelength (nm)', 'FontSize', labelSize);
            end
            
            for rend = 1:nRenderers
                % plot original RGB
                plotColor = RGBs{rgb};
                line(1:3, RGBs{rgb}, ...
                    'Parent', axRGB, ...
                    'Color', plotColor, ...
                    'Marker', RGBMarkers{rend}, ...
                    'LineStyle', 'none');
                
                % plot recovered RGB
                line(1:3, RGBOuts{rend, illum, rgb}, ...
                    'Parent', axRGB, ...
                    'Color', plotColor, ...
                    'Marker', RGBOutMarkers{rend}, ...
                    'LineStyle', 'none');
                
                % plot promoted spectra
                line(outWls, promotions{rend, illum, rgb}, ...
                    'Parent', axSpectra, ...
                    'Color', plotColor, ...
                    'Marker', spectrumMarkers{rend}, ...
                    'LineStyle', 'none');
                
                % remember RGB legend info
                rgbIndex = (rend-1)*nRenderers;
                RGBLegend{rgbIndex+1} = sprintf('in %s', renderers{rend});
                RGBLegend{rgbIndex+2} = sprintf('out %s', renderers{rend});
            end
        end
    end
end

% put a legend on the last axes
legend(axRGB, RGBLegend, 'Location', 'southwest');
legend(axSpectra, renderers, 'Location', 'southwest');