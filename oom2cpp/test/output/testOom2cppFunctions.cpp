


testOom2cppFunctions ()
{
//!A bunch of test cases for the oom2cpp parser

//!   These functions should be valid in Matlab.  The oom2cpp parser should
//!   be able to convert them into valid C/C++ function definitions.

}


a b c multipleInAndOut ( x, y, z)
{

//! function [a, b, c] = multipleInAndOut(x, y, z)


}


multipleInNoneOut ( x, y, z)
{

//! function multipleInNoneOut(x, y, z)

}



a b c noneInMultipleOut ( x, y, z)
{

//! function [a, b, c] = noneInMultipleOut(x, y, z)

}


noneInNoneOut ()
{
//! function noneInNoneOut

}


a noneInOneOut ()
{
//! function a = noneInOneOut

}


oneInNoneOut ( a)
{

//! function oneInNoneOut(a)

}


abusiveUseOfend(endNotReally)
{

//! function abusiveUseOfend(endNotReally)
    //! end end
    thisIsNotend = endNotReally(end - 1: end);
    thisIsNotend = 'end to end';
    thisIsNotend = 'end, where "end" is a stupid word';
    thisIsNotend = 'end vs. end(end+3) - "end without the matching double quote';

}


x abusiveSpacing ( a, b, c)
{

//! function      x  =abusiveSpacing        (a,b,   c)

}


z abusiveEllipses ()
{


//! function z ...
//!     = ...
//!     abusiveEllipses ...
//!     ( ...
//!     )

}



