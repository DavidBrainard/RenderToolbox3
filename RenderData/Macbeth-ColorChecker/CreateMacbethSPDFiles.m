%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Import Macbeth ColorChecker colorimetric from Psychtoolbox format. 

% convert Psychtoolbox colorimetric mat-files to spd-files expected by PBRT
% and Mitsuba
[macbethPath, macbethName] = fileparts(mfilename('fullpath'));
matFile = fullfile(macbethPath, 'sur_mccBabel.mat');
outFiles = ImportPsychColorimetricMatFile(matFile);