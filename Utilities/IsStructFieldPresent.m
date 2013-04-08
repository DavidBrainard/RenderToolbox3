%%% RenderToolbox3 Copyright (c) 2012 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Does a struct have a particular field?
%   @param s a struct
%   @param fieldName string field name
%
% @details
% Returns true if the given @a s has a field with the given @a fieldName,
% and if the field is not empty.  Otherwise returns false.
%
% @details
% Usage:
%   isPresent = IsStructFieldPresent(s, fieldName)
%
% @ingroup Utilities
function isPresent = IsStructFieldPresent(s, fieldName)
isPresent = isstruct(s) ...
    && isfield(s, fieldName) ...
    && ~isempty(s.(fieldName));