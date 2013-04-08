%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Read mappings data from a text file.
%   @param mappingsFile
%
% @details
% Reads batch renderer mappings from the given @a mappingsFile.  See the
% RenderToolbox3 wiki for more about <a 
% href="https://github.com/DavidBrainard/RenderToolbox3/wiki/Mappings-File-Format">Mappings
% Files</a>.
%
% @details
% Returns a 1xn struct array with mapping data.  The struct array will have
% one element per mapping, and the following fields:
%   - text - raw text before parsing
%   - block - block type, 'Collada', 'Generic', 'Mitsuba', or 'PBRT'
%   - left - a struct of info about the left-hand string
%   - operator - the operator string
%   - right - a struct of info about the right-hand string
%   .
%
% @details
% Each 'left' or 'right' field will contain a struct with data about a
% string, with the following fields
%   - text - the raw text before parsing
%   - enclosing - the enclosing brackets, if any, '[]', '<>', or ''
%   - value - the text found within enclising brackets
%   .
%
% @details
% Used internally by BatchRender().
%
% @details
% Usage:
%   mappings = ParseMappings(mappingsFile)
%
% @ingroup BatchRender
function mappings = ParseMappings(mappingsFile)

%% Make a default mappints struct.
mappings = struct( ...
    'text', {}, ...
    'block', {}, ...
    'group', {}, ...
    'left', {}, ...
    'operator', {}, ...
    'right', {});

%% Prepare to read the mappings file.
if nargin < 1 || ~exist(mappingsFile, 'file')
    return;
end

fid = fopen(mappingsFile, 'r');
if -1 == fid
    warning('Cannot open mappings file "".', mappingsFile);
    return;
end

% comments have % as the first non-whitespace
commentPattern = '^\s*\%';

% blocks start with one word followed by {
blockStartPattern = '([^{\s]+)\s+([^{\s]+)\s*{|([^{\s]+)\s*{';

% blocks end with }
blockEndPattern = '}';

% "values" contain words, spaces, braces, and some punctuation
%   but they can't end with punctuation
valuePattern = '[\w\-\.\:\$\(\)\[\]\<\> ]*[^\+\-\*/=\.\:]';

% scene paths contain values, and |= internally
pathPattern = [valuePattern '\|' valuePattern '\=' valuePattern];

% operators might start with +-*\, and end with =
opPattern = '[\+\-\*/]?=';

% mappings contain scene paths, operators, or values
mappingPattern = ['(' pathPattern '|' opPattern '|' valuePattern ')'];

%% Read one line at a time, look for blocks and mappings.
blockName = '';
groupName = '';
nextLine = '';
while ischar(nextLine)
    % read a line of the mappings file
    nextLine = fgetl(fid);
    if ~ischar(nextLine)
        break;
    end
    
    % skip comment lines
    if regexp(nextLine, commentPattern, 'once')
        continue;
    end
    
    % enter a new block?
    tokens = regexp(nextLine, blockStartPattern, 'tokens');
    if ~isempty(tokens)
        if 1 == numel(tokens{1})
            % start a block with no group name
            blockName = tokens{1}{1};
            groupName = '';
            continue;
            
        elseif 2 == numel(tokens{1})
            % start a block with a group name
            blockName = tokens{1}{1};
            groupName = tokens{1}{2};
            continue;
        end
    end
    
    % close the current block?
    if regexp(nextLine, blockEndPattern, 'once')
        blockName = '';
        groupName = '';
        continue;
    end
    
    % read a mapping?
    tokens = regexp(nextLine, mappingPattern, 'tokens');
    if ~isempty(tokens)
        % append a new mapping struct
        n = numel(mappings) + 1;
        mappings(n).text = nextLine;
        mappings(n).block = blockName;
        mappings(n).group = groupName;
        
        switch numel(tokens)
            case 3
                % full mapping with left, operator, right
                mappings(n).left = unwrapString(tokens{1}{1});
                mappings(n).operator = tokens{2}{1};
                mappings(n).right = unwrapString(tokens{3}{1});
                
            case 2
                % short mapping with left, operator
                mappings(n).left = unwrapString(tokens{1}{1});
                mappings(n).operator = tokens{2}{1};
                mappings(n).right = unwrapString('');
                
            case 1
                % short mapping with only left
                mappings(n).left = unwrapString(tokens{1}{1});
                mappings(n).operator = '';
                mappings(n).right = unwrapString('');
        end
        continue;
    end
end

%% Done with file
fclose(fid);


% Dig a string out of enclosing braces, if any.
function info = unwrapString(string)
% fill in default info
info.enclosing = '';
info.text = string;
info.value = '';

if isempty(string)
    return;
end

% check for enclosing brackets
if ~isempty(strfind(string, '<'))
    % angle brackets
    info.enclosing = '<>';
    valuePattern = '<(.+)>';
    
elseif ~isempty(strfind(string, '['))
    % square brackets
    info.enclosing = '[]';
    valuePattern = '\[(.+)\]';
    
else
    % plain string, strip some whitespace
    info.enclosing = '';
    valuePattern = '(\S.*\S)|(\S?)';
end

% dig out the value
valueToken = regexp(string, valuePattern, 'tokens');
info.value = valueToken{1}{1};