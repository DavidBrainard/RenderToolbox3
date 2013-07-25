%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert a Psychtooblox colorimetric mat-file to text spd-files.
%   @param inFile input .mat file with Psychtooblox colorimetric data
%   @param outFile output file name for new text file(s)
%   @param isDivideBands whether to divide spectrum samples by band width
%
% @details
% Converts the Psychtoolbox colorimetric mat-file @a inFile to one or more
% text spd-files named @a outFile.  Text spd-files are suitable for use
% with PBRT and Mitsuba.
%
% @details
% @a inFile should be the name of a mat-file which obeys Psychtoolbox
% colorimetric mat file conventions.  The name should use a descriptive
% prefix, followed by an underscore, followed by a specific name.  For
% example, RenderToolbox includes "sur_mccBabel.mat":
%   - the prefix "sur" describes the data a surface reflectance
%   - the name "mccBabel" refers to Macbetch Color Checker data from the
%   BabelColor company.
%   .
%
% @details
% For more about Psychtooblox colorimetric mat-files and conventions, see
% the <a
% href="http://docs.psychtoolbox.org/PsychColorimetricMatFiles">Psychtoolbox web documentation</a>
% or the file
%   Psychtoolbox/PsychColorimetricData/PsychColorimetricMatFiles/Contents.m
%
% @details
% If @a inFile contains measurements for just one object, the new text file
% will have the given name @a outFile.  If @a inFile contains measurements
% for multiple objects, a separate text file will be written for each
% object, using the base name of @a outFile, plus a numeric suffix.  For
% example, "sur_mccBabel.mat" might produce a file named "mccBabel-24.spd".
%
% @details
% By convention, all Psychtoolbox colorimetric .mat files describe power
% spectra as power-per-wavelength-band.  This differs from text .spd files,
% which should describe power spectra as power-per-nanometer.  If @a inFile
% obeys Psychtoolbox conventions for spectral power .mat files, spectrum
% samples will be divided by the spectral band width to put them in units
% of power-per-nanometer.  Psychtoolbox conventions for power spectra
% include using prefix "spd", and storing data with one column per object.
%
% @details
% If @a isDivideBands is provided and true, spectrum samples will be
% divided by band width, regardless of Psychtoolbox conventions.  If @a
% isDivideBands is false, spectrum samples will be left unchanged,
% regardless of Psychtooblox conventions.  If @a isDivideBands is omitted,
% attempts to follow Psychtoolbox conventions.
%
% @details
% Returns a cell array of file names for new text spd-files.
%
% @details
% Usage:
%   outFiles = ImportPsychColorimetricMatFile(inFile, outFile, isDivideBands)
%
% @ingroup Utilities
function outFiles = ImportPsychColorimetricMatFile(inFile, outFile, isDivideBands)

[inPath, inBase, inExt] = fileparts(inFile);
if nargin < 2 || isempty(outFile)
    outFile = fullfile(inPath, [inBase '.spd']);
end
[outPath, outBase, outExt] = fileparts(outFile);

if nargin < 3 || isempty(isDivideBands)
    isObeyPsychConvention = true;
    isDivideBands = false;
else
    isObeyPsychConvention = false;
end


%% Read and interpret the Psychtoolbox data.
% determine the format of spectral data from Psychtoolbox conventions
[psychData, psychS, psychPrefix, psychName] = ...
    ParsePsychColorimetricMatFile(inFile);
psychWavelengths = SToWls(psychS);

% reformat specrtal data respecting Psychtoolbox conventions
%   for current purposes, want objects in matrix columns, and may need to
%   scale power units to be Power per Unit Wavelength
switch psychPrefix
    case {'B', 'den', 'sur', 'srf'}
        % for basis functions, optical densities, and reflectance spectra,
        % objects are already in data columns and there is no need to scale
        % data by sampling bandwidth.
        
    case 'spd'
        % for power distributins, objects are already in data columns but
        % we need to scale data by sampling bandwidth.
        if isObeyPsychConvention
            isDivideBands = true;
        end
        
    case 'T'
        % for matching functions and sensitivities, transpose data to put
        % objects in data columns, but there is no need to scale data by
        % sampling bandwidth.
        psychData = psychData';
        
    otherwise
        warning('Unknown Psychtooblox data prefix "%s" for file\n  %s', ...
            psychPrefix, inFile);
end

% "divide out" of Psychtoolbox convention of Power per Wavelength Band
if isDivideBands
    psychData = SpdPowerPerWlBandToPowerPerNm(psychData, psychS);
end

%% Write data to new text .spd files.

% create the output folder as needed
if ~exist(outPath, 'dir')
    mkdir(outPath);
end

% write a text file for the object in each data column
nObjects = size(psychData, 2);
outFiles = cell(1, nObjects);
for ii = 1:nObjects
    % choose a name for this output file
    if nObjects > 1
        outName = sprintf('%s-%d%s', outBase, ii, outExt);
    else
        outName = [outBase, outExt];
    end
    outFiles{ii} = fullfile(outPath, outName);
    
    % write a line for each wavelength sampled
    fid = fopen(outFiles{ii}, 'w');
    for w = 1:numel(psychWavelengths)
        fprintf(fid, '%d %f\n', psychWavelengths(w), psychData(w,ii));
    end
    fprintf(fid, '\n');
    fclose(fid);
end