%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% @defgroup BatchRenderer Batch Renderer
% Render a family of related scenes based on a Collada parent scene.
% @details
% These functions make up the RenderToolox3 batch renderer, which takes a
% Collada parent scene file, applies manipulations specified in a
% conditions file and a mappings file, and produces a family of
% renderer-native scene files and renderings.
%
% @defgroup Mappings Mappings
% Functions that support the Batch Renderer.
% @details
% These functions support the batch renderer.  They mostly deal with
% reading manipulations specified in the the conditions file and mappings
% files, formatting it properly, and applying it to the Collada parent
% scene.  Users don't usually need to call these functions.
%
% @defgroup SceneDOM Scene DOM
% Work with XML documents.
% @details
% These functions are for reading and writing XML documents, like Collada
% scene files and renderer-native scene XML files.  Notably, these
% functions deal with <a
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Scene-DOM-Paths">Scene
% DOM Paths</a>.
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
% @defgroup ColladaToPBRT
% Convert Collada scenes to PBRT.
% @details
% Theses functions make up the RenderToolbox3 Collada to PBRT scene file
% converter.  Users should not use most of these functions directly.  Just
% use the ColladaToPBRT() function.
%
% @defgroup Mex
% Build Mex-functions from source.
% @details
% These functions are the "Make" functions that compile and link
% Mex-functions for use with the local hardware and operating system.
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