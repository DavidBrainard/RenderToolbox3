%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Collada scene file to a Mitusuba scene file.
%   @param colladaFile input Collada file name or path
%   @param mitsubaFile output Mitsuba file name or path (optional)
%   @param adjustmentsFile adjustments file name or path (optional)
%   @param hints struct of hints from GetDefaultHints() (optional)
%
% @details
% Converts the given @a colladaFile ('.dae' or '.xml') to a mitsuba .xml
% file with the name (and path) given in @a mitsubaFile.
%
% @details
% If @a adjustmentsFile is provided, it should be the name of a partial
% Mitsuba scence file in .xml format.  Elements of @a adjustmentsFile will
% replace or modify elements of the converted scene file according to
% matching "id" attributes.
%
% @details
% @a hints may be a struct with additional parameters for the converter.
% See GetDefaultHints() for more about batch renderer hints.
%
% @details
% Usage:
%   ColladaToMitsuba(colladaFile, mitsubaFile, adjustmentsFile, hints)
%
% @ingroup Utilities
function ColladaToMitsuba(colladaFile, mitsubaFile, adjustmentsFile, hints)

%% Parameters
[colladaPath, colladaBase, colladaExt] = fileparts(colladaFile);

if nargin < 2 || isempty(mitsubaFile)
    mitsubaFile = [colladaBase '.xml'];
end

if nargin < 3 || isempty(adjustmentsFile)
    adjustmentsFile = getpref('Mitsuba', 'adjustmentsFile');
end

if nargin < 4
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Choose film type
if isempty(hints.filmType)
    filmType = 'hdrfilm';
else
    filmType = hints.filmType;
end

%% Change the dynamic library path, which can interfere with Mitsuba.
libPathName = getpref('Mitsuba', 'libPathName');
libPath = getpref('Mitsuba', 'libPath');
MatlabLibPath = getenv(libPathName);
setenv(libPathName, libPath);

%% Invoke the Mitsuba importer.
fprintf('Converting %s\n  to %s.\n', colladaFile, mitsubaFile);

importer = fullfile( ...
    getpref('Mitsuba', 'app'), ...
    getpref('Mitsuba', 'importer'));
importCommand = sprintf('%s -r %dx%d -l %s %s %s %s', ...
    importer, ...
    hints.imageWidth, hints.imageHeight, ...
    filmType, ...
    [colladaBase colladaExt], mitsubaFile, adjustmentsFile);
[status, result] = unix(importCommand);
if status ~= 0
    error('Mitsuba file conversion failed\n  %s\n  %s\n', ...
        colladaFile, result);
end

%% Restore the dynamic library path for Matlab.
setenv(libPathName, MatlabLibPath);

%% Clean up.
% Mitsuba importer creates a "textures" folder, even when unnecessary.
textureDir = fullfile(colladaPath, 'textures');
if isempty(ls(textureDir))
    rmdir(textureDir);
end
