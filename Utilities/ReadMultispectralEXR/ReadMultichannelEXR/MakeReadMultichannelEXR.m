%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Compile the MakeReadMultichannelEXR Mex-function.
%
% @details
% Compiles the ReadMultichannelEXR() mex function from source.  Assumes
% that the OpenEXR libraries have been installed on the system at
% user/, user/local/, or opt/local/.  If the libraries are installed
% somewhere else on your system, you should copy this file and edit the 
% INC and LINC variables to contain the correct include and library paths 
% for your OpenEXR installation.
%
% @details
% On Ubuntu, you may wish to run the following command to get the 
% dependencies you need:
% @code
% sudo apt-get install openexr libopenexr-dev libilmbase-dev zlib1g-dev
% @endcode
%
% @details
% Should produce a new MakeReadMultichannelEXR() function with a
% platform-specific Mex-function extension.  See Matlab's mexext().
%
% @details
% Attempts to read a sample OpenEXR image and plot channel data in a new
% figure, to verify that the funciton compiled successfully.
%
% @details
% Usage:
%   MakeReadMultichannelEXR()
%
% @ingroup Mex
function MakeReadMultichannelEXR()

%% Choose the source and function files
cd(fullfile(RenderToolboxRoot(), 'Utilities', 'ReadMultispectralEXR', 'ReadMultichannelEXR'));
source = 'ReadMultichannelEXR.cpp';
output = '-output ReadMultichannelEXR';

%% Choose library files to include and link with.
INC = '-I/usr/local/include/OpenEXR'; %-I/usr/include/OpenEXR -I/opt/local/include/OpenEXR';
%LINC = '-L/usr/local/lib'; %-L/usr/lib  -L/opt/local/lib ';
LINC = '-L/usr/local/Cellar/openexr/2.1.0/lib/';
LIBS = '-lIlmImf -lz -lImath -lHalf -lIex -lIlmThread -lpthread';

%% Build the function.
mexCmd = sprintf('mex %s %s %s %s %s', INC, LINC, LIBS, output, source);
fprintf('%s\n', mexCmd);
eval(mexCmd);

%% Test the function with a sample EXR file.
testFile = 'TestSphereMitsuba.exr';
%testFile = 'TestSphereBlender.exr';
[sliceInfo, data] = ReadMultichannelEXR(testFile);

fprintf('If you see a figure with several images, MakeReadMultichannelEXR() is working.\n');

% show each image layer
close all;
PlotSlices(sliceInfo, data);
