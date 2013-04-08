%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Using the IlluminantMetamerExample() demo function, loop through all 24
% MCC surface spectra and save the computed D65 Metamers.

clear;
clc;

% allocate a matrix to hold many metamers
nSurfaces = 24;
S_mccD65Metamer = getpref('Mitsuba', 'S');
sur_mccD65Metamer = zeros(S_mccD65Metamer(3), nSurfaces);

%% compute a D65 metamer for each mcc surface color
for ii = 1:nSurfaces
    sur_mccD65Metamer(:,ii) = IlluminantMetamerExample(ii);
end
close all

%% save results to standard Colorimetric .mat file
outDir = fullfile(RenderToolboxRoot(), 'RenderData', 'Macbeth-D65Metamers');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end
name = 'sur_mccD65Metamer';
matFile = fullfile(outDir, [name '.mat']);
save(matFile, 'sur_mccD65Metamer', 'S_mccD65Metamer');

% generate .spd files
ImportPsychColorimetricMatFile(matFile, [name '.spd']);