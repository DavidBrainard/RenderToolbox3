%%% RenderToolbox3 Copyright (c) 2012-2015 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% This demo was generously contributed by Gizem Kucukoglu in March 2015.
%
% The demo renders a sphere using a light field.  The light probe was
% generously supplied by Bernhard Vogl and downloaded from:
%   http://dativ.at/lightprobes/
%
% Usage notes:
%	- The .dae file needs to have a hemi-light.
%	- The light field needs to be in rectangular format.
%	- The conditions file has various values for alpha parameter. To make
%	the sphere a mirror, set alpha to be very small. But do not set it to
%   zero.
%   .
%
%   Currently this example only works with Mitsuba.  But other renderers
%   like PBRT should be possible.
%
%% Render the Light Field Sphere Scene.

%% Choose example files.

parentSceneFile = 'LightFieldSphere.dae';
mappingsFile = 'LightFieldSphereMappings.txt';
conditionsFile = 'LightFieldSphereConditions.txt';

%% Choose batch renderer options.

% which conditions to render, [] means all
hints.whichConditions = [];

% pixel size of each rendering
hints.imageWidth = 320;
hints.imageHeight = 240;

% put outputs in a subfolder named like this script
hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

%% Render with Mitsuba.

% how to convert multi-spectral images to sRGB
toneMapFactor = 100;
isScaleGamma = true;

% make a montage and sensor images with each renderer
for renderer = {'Mitsuba'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 3 multi-spectral renderings, saved in .mat files
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('LightFieldSphere (%s)', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
