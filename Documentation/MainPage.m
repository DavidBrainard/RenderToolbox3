%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% @defgroup BatchRender Batch Renderer
% Render scenes multiple times with changing variables.
% @details
% These functions make up the RenderToolox3 batch renderer, which can
% render the same basic scene multiple times, with changing variables.
% Users should not use most of these functions directly.  Just use the
% BatchRender() and MakeMontage() functions.
%
% @defgroup Readers
% Read multi-spectral data from various image file formats.
% @details
% These functions read multi-spectral data from image files.  Each one
% oparates on a particular image file format.  They all return
% multi-spectral images with size [height, width, n], where n is the number
% of image spectral planes.
%
% @defgroup Utilities
% Miscellaneous utilities.
%
% @defgroup SceneDOM Scene DOM
% Work with XML documents.
% @details
% These functions are for reading and writing XML documents, like Collada
% scene files and renderer adjustments files.  Notably, these functions
% deal with <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Scene-DOM-Paths">Scene
% DOM Paths</a>.
%
% @defgroup MappingsObjects Mappings Objects
% Process mappings and apply them to the scene.
% @details
% These functions process the mappings from the <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Mappings-File-Format">mappings
% file</a>.  In particular, they supplement <a
% https://github.com/DavidBrainard/RenderToolbox3/wiki/Generic-Scene-Elements">generic
% scene elements with default property values and convert them to
% renderer-native formats.
% @details
% Users should not use these functions directly.  Just use the
% BatchRender() function.
%
% @defgroup Mex
% Build Mex-functions from source.
% @details
% These functions are the "Make" functions that compile and link
% Mex-functions for use with a particular platform.
%
% @defgroup ColladaToPBRT
% Convert Collada scenes to PBRT.
% @details
% Theses functions make up the RenderToolbox3 Collada to PBRT scene file
% converter.  Users should not use most of these functions directly.  Just
% use the ColladaToPBRT() function.
%
% @defgroup ExampleDocs Example Documentation
% Dummy functions to Explain Documentation
% @details
% RenderToolbox3 functions are documented in groups of related functions
% called <a href="modules.html">Modules</a>.  Each module gets its own
% page with:
%   - A list of @b Funcitons (above).  Output values appear on
% the left-hand side.  Function names and parameters appear on the
% right-hand side.  Function names are links to detailed documentation.
%   - A @b Detailed @b Description of the module (this section).
%   - @b Function @b Documentaion detailing each function (below).  The
% documentation describes function parameters, what the function does,
% and what the function returns, and shows the Matlab usage syntax.
%   .
%
% @mainpage Doxygen Reference
% @par
% Welcome to the <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki">RenderToolbox3</a>
% function reference!
% @par
% Functions are documented on the <a href="modules.html">Modules</a> page.
% @par
% These docs are generated automatically from comments in the the
% RenderToolbox3 source code, using <a
% href="http://www.stack.nl/~dimitri/doxygen/">Doxygen</a>.  The <a
% href="group___example_docs.html">ExampleDocs</a> module describes the
% documentation format.
%