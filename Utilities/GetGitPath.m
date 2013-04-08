%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Find the path to the Git executable.
%
% @details
% Attempts to locate the Git executable on the current machine.  If "git"
% is on the Matlab path, returns that "git".  Otherwise, guesses at install
% locations for Windows or Unix-like systems, including OS X.
%
% @details
% GetGitPath() is based on GetSubversionPath() from Psychtoolbox.
%
% @details
% Returns a string path to the "git" exectuable.  If no "git" was found,
% returns an empty string.
function gitPath = GetGitPath()

%% Check the Matlab path.
if IsWin
    whichGit = which('git.exe');
else
    whichGit = which('git.');
end

if ~isempty(whichGit)
    [gitPath, gitName, gitExt] = fileparts(whichGit);
    gitPath = [gitPath filesep()];
    return;
end

%% Guess at system install locations.
if IsWin
    % hope that Windows knows where to find git
    gitPath = '';
    
else
    % check probable Unix install locations
    probables = { ...
        '/usr/local/git/bin', ...
        '/usr/bin'};
    gitPath = '';
    for ii = 1:numel(probables)
        guess = fullfile(probables{ii}, 'git');
        if exist(guess, 'file')
            gitPath = [probables{ii} filesep()];
            return;
        end
    end
end

