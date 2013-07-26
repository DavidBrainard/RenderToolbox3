%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a sphere with conditions that might affect output scaling.

%% Choose example files, make sure they're on the Matlab path.
AddWorkingPath(mfilename('fullpath'));
parentSceneFile = 'ScalingTest.dae';
conditionsFile = 'ScalingTestConditions.txt';
mappingsFile = 'ScalingTestMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = [];
hints.outputSubfolder = mfilename();
hints.PBRTRadiometricScale = 1;
hints.MitsubaRadiometricScale = 1;

%% Render with Mitsuba and PBRT.
% make an sRGB montage with each renderer
toneMapFactor = 10;
isScaleGamma = true;
for renderer = {'Mitsuba', 'PBRT'}
    
    % choose one renderer
    hints.renderer = renderer{1};
    
    % make 3 multi-spectral renderings, saved in .mat files
    nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
    radianceDataFiles = BatchRender(nativeSceneFiles, hints);
    
    % condense multi-spectral renderings into one sRGB montage
    montageName = sprintf('%s (%s)', 'ScalingTest', hints.renderer);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScaleGamma, hints);
    
    % display the sRGB montage
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
