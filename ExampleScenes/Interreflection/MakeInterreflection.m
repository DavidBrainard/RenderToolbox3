%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render two panels with light reflecting betwen them.

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
sceneFile = 'Interreflection.dae';
conditionsFile = 'InterreflectionConditions.txt';
mappingsFile = 'InterreflectionMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.imageHeight = 100;
hints.imageWidth = 160;
hints.outputSubfolder = mfilename();

%% Render with Mitsuba and PBRT.
% make an sRGB montage with each renderer
toneMapFactor = 10;
isScaleGamma = true;
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 3 multi-spectral renderings, saved in .mat files
    sceneFiles = MakeSceneFiles(sceneFile, conditionsFile, mappingsFile, hints);
    outFiles = BatchRender(sceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('%s (%s)', 'Interreflection', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end