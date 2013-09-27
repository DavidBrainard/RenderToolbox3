%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Invoke the Sample Renderer.
%   @param scene data or file name specifying a scene to be rendererd
%   @param isShow whether or not to display the output image in a figure
%
% @details
% This function is a template for a RenderToolbox3 "Render" function.
%
% @details
% The name of a Render function must match a specific pattern: it must
% begin with "RTB_Render_", and it must end with the name of the renderer,
% for example, "SampleRenderer".  This pattern allows RenderToolbox3 to
% automatically locate the Render function for each renderer.  Render
% functions should be included in the Matlab path.
%
% @details
% A Render function must invoke a renderer using the given @a scene.  @a
% scene may be of any type or file format, as long as the renderer can
% interpret the @a scene natively.  A Render function must also accept the
% parameter @a isShow.  When @a isShow is true, it may optionally display
% rendering results in a figure.
%
% @details
% RenderToolbox3 does not care how the renderer is invoked.  Some
% possibilities are:
%	- use Matlab's system() command to invoke an external application
%   - call another m-function
%   - call a Java method directly from Matlab
%   - call a mex function directly from Matlab
%   .
%
% @details
% A Render function must return three outputs:
%   - @b status: numeric status code that is 0 when rendering succeeds,
%   non-zero otherwise
%   - @b result: any text output from the renderer, or empty ''
%   - @b multispectralImage: double matrix with rendererd multispectral
%   image, of size [height width nSpectralPlanes]
%   - @b S: description of wavelengths for multispectralImage spectral
%   planes, of the form [start, delta, nSpectralPlanes].  See Psychtoolbox
%   WlsToS().
%
% @details
% This template function returns sample values but does not render anyting.
%
% Usage:
%   [status, result, multispectralImage, S] = RTB_Render_SampleRenderer(scene, isShow)
%
% @ingroup RendererPlugins
function [status, result, multispectralImage, S] = RTB_Render_SampleRenderer(scene, isShow)

        if strcmpi('.xml', sceneExt)
            % convert PBRT-XML to text, read scene document
            pbrtFile = fullfile(scenePath, [sceneBase '.pbrt']);
            if isempty(hints.filmType)
                hints.filmType = 'image';
            end
            WritePBRTFile(pbrtFile, scene, hints);
            pbrtDoc = ReadSceneDOM(scene);
            
        else
            % cannot read scene document from a text file!
            pbrtFile = scene;
            pbrtDoc = [];
        end
        
        % invoke PBRT!
        [status, commandResult, output] = RunPBRT(pbrtFile);
        if status ~= 0
            error('PBRT rendering failed\n  %s\n  %s\n', ...
                pbrtFile, commandResult);
        end
        
        % read output into memory
        multispectralImage = ReadDAT(output);
                
        % interpret output according to PBRT's spectral sampling
        S = getpref('PBRT', 'S');