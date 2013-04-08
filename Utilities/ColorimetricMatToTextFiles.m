%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Convert colorimetric data from a .mat file to multiple text files.
%   @param inFile input .mat file with colorimetric data
%   @param outDir output folder for text files (optional)
%   @param outBase stem for output file names (optional)
%   @param outExt extension for output file names (optional)
%
% @details
% Converts colorimetric data from the given @a inFile .mat file to
% multiple text files which are formatted for use by PBRT and Mitsuba.
%
% @details
% @a inFile should be the name of a .mat file which obeys Psychtoolbox
% colorimetric mat file conventions.  The name should use a prefix,
% followed by an underscore, followed by a descriptive name.  For example,
% RenderToolbox includes "sur_mccBabel.mat": "sur" is the prefix,
% "mccBabel" is the descriptve name.
%
% @details
% @a inFile should contain two variables.  The first should have the
% same name as @a inFile, minus the ".mat".  For example,
% "sur_mccBabel.mat" contains the variable "sur_mccBabel".  This variable
% should be an m x n matrix of colorimatric data points, where m is the
% number of samples taken across the spectrum, and n is the number of
% different objects measured.
%
% @details
% The second variable should be named like the @a inFile, but with an "S"
% instead of the original prefix.  For example, "sur_mccBabel.mat" contains
% the variable "S_mccBabel".  This variable describes the samples taken
% across the spectrum.  It has the format [start delta m], where start and
% delta are wavelenghts in nanometers and m is the number of samples taken
% across the spectrum.
%
% @details
% Produces multiple text files in the given @a outDir, with each file name
% starting with the given @a outBase and ending with the given @a outExt.
% If there are multiple objects measured (n > 1) each filename will contain
% a numeric suffix.  For example, "sur_mccBabel.mat" might produce a file
% named "mccBabel-24.spd".
%
% If @a outDir is omitted, pwd() is used instead.  If @a outBase is
% omitted, an output name is chosen automatically based on @a  inFile.  If
% @a outExt is omitted, ".spd" is used.
%
% @details
% Usage:
%   ColorimetricToSPDFiles(inFile, outDir, outBase, outExt)
%
% @ingroup Utilities
function ColorimetricMatToTextFiles(inFile, outDir, outBase, outExt)

%% Parameters

% parse the input name
[inPath, inBase, inExt] = fileparts(inFile);
underscore = find(inBase == '_');
inName = inBase(underscore+1:end);

if nargin < 2
    outDir = pwd();
end

if nargin < 3
    outBase = inName;
end

if nargin < 4
    outExt = 'spd';
end


%% load the input data
inData = load(inFile);
data = inData.(inBase);
nObjects = size(data, 2);

% get the full list of wavelength samples
inS = sprintf('S_%s', inName);
S = inData.(inS);
wls = SToWls(S);

% create the output folder as needed
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% write a file for each object measured.
for o = 1:nObjects
    if nObjects > 1
        outFileName = sprintf('%s-%d.%s', outBase, o, outExt);
    else
        outFileName = sprintf('%s.%s', outBase, outExt);
    end
    outFilePath = fullfile(outDir, outFileName);
    fid = fopen(outFilePath, 'w');
    
    % write a line for each wavelength sampled
    for w = 1:numel(wls)
        fprintf(fid, '%d %f\n', wls(w), data(w,o));
    end
    
    fclose(fid);
end