%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read data and metadata from a Psychtoolbox colorimetric .mat file.
%   @param dataFile name of a Psychtoolbox colorimetric .mat file.
%
% @details
% Reads the colorimetric data and associated spectral sampling from the
% given @a dataFile, which should be a Psychtoolbox colorimetric .mat file.
% Also parses the name of @a dataFile according to Pyschtoolox conventions.
%
% @details
% For more about Psychtooblox colorimetric .mat files and conventions, see
% the <a
% href="http://docs.psychtoolbox.org/PsychColorimetricMatFiles">Psychtoolbox
% web documentation</a> or the file
%   Psychtoolbox/PsychColorimetricData/PsychColorimetricMatFiles/Contents.m
%
% @details
% Returns colorimetric data matrix from the given @a dataFile, the "S"
% description of the data's spectral sampling, the category prefix from the
% file name, and the descriptive base file name.
%
% @details
% Usage:
%   [data, S, prefix, name] = ParsePsychColorimetricMatFile(dataFile)
%
% @ingroup Utilities
function [data, S, category, name] = ParsePsychColorimetricMatFile(dataFile)

% parse the file name for its category and descriptive name
[matPath, matBase, matExt] = fileparts(dataFile);
nameBreak = find('_' == matBase, 1, 'first');
category = matBase(1:nameBreak-1);
name = matBase(nameBreak+1:end);

% read colorimetric data and sampling from conventional variable names
matData = load(dataFile);
data = matData.(matBase);
samplingName = sprintf('S_%s', name);
S = matData.(samplingName);
