%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Write a given spectral power distribution to a text file.
%   @param wavelengths matrix of spectrum sampling wavelengths
%   @param magnitudes matrix of spectrum sample magnitudes
%   @param filename name of a text file to create or replace
%
% @details
% Writes the given @a wavelengths and @a magnitudes to a spectrum data text
% file, with the given @a filename.
%
% @details
% The text file will contain a wavelength-magnitude pair on each line.
% This format is suitable for specifying spectra to PBRT or Mitsuba.  For
% example:
% @code
%   300 0.1
%   550 0.5
%   800 0.9
% @endcode
% where 300, 550, and 800 are wavelengths in namometers, and 0.1, 0.5, and
% 0.9 are magnutudes for each wavelength.
%
% @details
% Returns the given @a filename, or a default file name if none was given.
%
% @details
% Usage:
%   filename = WriteSpectrumFile(wavelengths, magnitudes, filename)
%
% @ingroup Readers
function filename = WriteSpectrumFile(wavelengths, magnitudes, filename)

% choose default file name or extension, if none given
if nargin < 3
    filename = 'spectrum.spd';
end
[filePath, fileBase, fileExt] = fileparts(filename);
if ~isempty(filePath) && ~exist(filePath, 'dir')
    mkdir(filePath);
end
if isempty(fileExt)
    filename = fullfile(filePath, [fileBase, '.spd']);
end

% check sanity of wavelengths and magnitudes
nWls = numel(wavelengths);
nMags = numel(magnitudes);
if nMags ~= nWls
    warning('Number of wavelengths %d should match number of magnitudes %d.', ...
        nWls, nMags);
end

% write the spectrum to file
fid = fopen(filename, 'w');
nPairs = min(nWls, nMags);
for ii = 1:nPairs
    fprintf(fid, '%d %f\n', wavelengths(ii), magnitudes(ii));
end
fclose(fid);