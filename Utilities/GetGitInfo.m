%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Get information about a Git repository.
% @param repositoryPath a directory inside a Git repository.
%
% @details
% Uses the "git" command to gather information about a Git repository.  @a
% repositoryPath must be the path to one of the folders inside of a Git
% repository's working copy.
%
% @details
% This tool is based on a Bash script written by Duane Johnson, mentioned
% here: http://stackoverflow.com/questions/924574/git-alternatives-to-svn-info-that-can-be-included-in-a-build-for-traceability
% The script has this header:
%   author: Duane Johnson
% 	email: duane.johnson@gmail.com
% 	date: 2008 Jun 12
% 	license: MIT
%   Based on discussion at http://kerneltrap.org/mailarchive/git/2007/11/12/406496
%
% @details
% Returns a struct with various facts about the Git repository, including
% repository configuration and the working copy's revision id.
function info = GetGitInfo(repositoryPath)

if nargin < 1
    repositoryPath = pwd();
end

% note what folder the user started in
originalFolder = pwd();

try
    % cd to the given path, them up to the repository root
    cd(repositoryPath);
    while ~exist('.git', 'dir') && 4 < numel(pwd())
        cd('..');
    end
    
    if ~exist('.git', 'dir')
        % repositoryPath was not really a Git repository path
        warning('Not a Git repository path: \n  %s', repositoryPath);
        info = [];
        
    else
        % find the git executable
        gitPath = GetGitPath();
        
        % get revision number
        [status, result] = system([gitPath 'git rev-parse HEAD']);
        info.Revision = getStringLines(result);
        
        % get recent commit
        %   send to file, because terminal is shell is non-interactive
        tempFile = 'gitTemp.log';
        [status, result] = system([gitPath 'git log --max-count=1 > ' tempFile]);
        fid = fopen(tempFile);
        result = char(fread(fid))';
        info.LastCommit = getStringLines(result);
        fclose(fid);
        delete(tempFile);
        
        % get remote repository urls
        [status, result] = system([gitPath 'git remote -v']);
        info.RemoteRepository = getStringLines(result);
        
        % get remote branches
        [status, result] = system([gitPath 'git branch -r']);
        info.RemoteBranch = getStringLines(result);
        
        % get local branches
        [status, result] = system([gitPath 'git branch']);
        info.LocalBranch = getStringLines(result);
        
        % get overall configuration
        fid = fopen('.git/config');
        result = char(fread(fid))';
        info.Config = getStringLines(result);
        fclose(fid);
    end
    
catch err
    % go back to the original folder
    cd(originalFolder);
    rethrow(err);
end

% go back to the original folder
cd(originalFolder);


%% Break a multi-line string into a cell array of lines.
function lines = getStringLines(string)
tokens = regexp(string, '([^\r\n]*)\r?\n?', 'tokens');
nLines = numel(tokens);
if 0 == nLines
    lines = {};
elseif 1 == nLines
    lines = tokens{1}{1};
else
    lines = cell(1, nLines);
    for ii = 1:nLines
        lines{ii} = tokens{ii}{1};
    end
end