%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get wavelengths and magnitudes from a spectrum string or text file.
%   @param spectrum string or file name (path optional) with spectrum data
%
% @details
% Scans the given @a spectrum for wavelength-magnitude pairs.  @a spectrum
% may be a string or a spectrum data text file.
%
% @details
% If @a spectrum is a string, it must contain wavelength:magnitude pairs,
% with spaces between pairs.  For example:
% @code
%   300:0.1 550:0.5 800:0.9
% @endcode
% where 300, 550, and 800 are wavelengths in namometers, and 0.1, 0.5, and
% 0.9 are magnutudes for each wavelength.
%
% @details
% If @a spectrum is a file name, the file must contain wavelength-magnitude
% pairs, with new lines between paris.  For example:
% @code
%   300 0.1
%   550 0.5
%   800 0.9
% @endcode
% where 300, 550, and 800 are wavelengths in namometers, and 0.1, 0.5, and
% 0.9 are magnutudes for each wavelength.
%
% @details
% Returns a 1 x n matrix of n wavelengths, and a corresponding 1 x n matrix
% of magnitudes.
%
% @details
% Usage:
%   [wavelengths, magnitudes] = ReadSpectrum(spectrum)
%
% @ingroup Readers
function [wavelengths, magnitudes] = ReadSpectrum(spectrum)

wavelengths = [];
magnitudes = [];

if ~ischar(spectrum)
    warning('Spectrum must be a string or filename.');
    return;
end

%% Scan the file or string.
if exist(spectrum, 'file')
    % open the file
    [fid, message] = fopen(spectrum, 'r');
    if fid < 0
        warning(message);
        return;
    end
    
    % scan the file for all numbers
    [numbers, count] = fscanf(fid, '%f');
    fclose(fid);
    
else
    % scan the string for colon-separated numbers
    [numbers, count] = sscanf(spectrum, '%f:%f');
end

%% Deal out wavelength-magnitude pairs.
wavelengths = numbers(1:2:end);
magnitudes = numbers(2:2:end);