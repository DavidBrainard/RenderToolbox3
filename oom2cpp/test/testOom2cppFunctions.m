%%% This text should be ignored.
%%% So should this text be ignored.

function testOom2cppFunctions
%A bunch of test cases for the oom2cpp parser
%
%   These functions should be valid in Matlab.  The oom2cpp parser should
%   be able to convert them into valid C/C++ function definitions.
end

function [a, b, c] = multipleInAndOut(x, y, z)
% function [a, b, c] = multipleInAndOut(x, y, z)
%%% This text should be ignored.
end

function multipleInNoneOut(x, y, z)
% function multipleInNoneOut(x, y, z)
end

%%% This text should be ignored.
function [a, b, c] = noneInMultipleOut(x, y, z)
% function [a, b, c] = noneInMultipleOut(x, y, z)
end

function noneInNoneOut
% function noneInNoneOut
end

function a = noneInOneOut
% function a = noneInOneOut
end

function oneInNoneOut(a)
% function oneInNoneOut(a)
end

function abusiveUseOfend(endNotReally)
% function abusiveUseOfend(endNotReally)
    % end end
    thisIsNotend = endNotReally(end - 1: end);
    thisIsNotend = 'end to end';
    thisIsNotend = 'end, where "end" is a stupid word';
    thisIsNotend = 'end vs. end(end+3) - "end without the matching double quote';
end

function      x  =abusiveSpacing        (a,b,   c)
% function      x  =abusiveSpacing        (a,b,   c)
end

function z ...
    = ...
    abusiveEllipses ...
    ( ...
    )

% function z ...
%     = ...
%     abusiveEllipses ...
%     ( ...
%     )
end

%%% This text should be ignored.
