/*
 * Permission to use, copy, modify, and distribute this software and its
 * documentation under the terms of the GNU General Public License is hereby 
 * granted. No representations are made about the suitability of this software 
 * for any purpose. It is provided "as is" without express or implied warranty.
 * See the GNU General Public License for more details.
 *
 * By Ben Heasly (benjamin.heasly@gmail.com)
 *
 * Seeded from mtoc.l, by Ian Martins (ianxm@jhu.edu).
 * Thanks to lextut.pdf by Victor Eijkhout (www.cs.rug.nl/~jjan/vb/lextut.pdf)
 */

/* any C stuff */
%{
	int functionDepth = 0;
	int inheritDepth = 0;
	int classDepth = -1;
	
	char *memberType = NULL;
	char *memberAccess = NULL;
	short memberIsStatic = 0;
	
	void declareStatic();
	void functionBackout();
	void classBackout();
%}

/* regular expression definitions */
SPACE [ \t]
WORD [_a-zA-Z0-9]
NAME [a-zA-Z]+{WORD}*

ESCAPEDCOMMENT "%%%".*$
COMMENT "%".*$
ELLIPSIS "...".*\n
DOUBLEQUOTES "[^\n\r]*"
SINGLEQUOTES '[^\n\r]*'
PARENTHESES "("[^\n\r]*")"
CURLYBRACES "{"[^\n\r]*"}"
BRACKETS "["[^\n\r]*"]"

END "end"
ENDPREFIX "end"{WORD}+
ENDSUFFIX {WORD}+"end"

CONTROL ^{SPACE}*("for"|"while"|"switch"|"try"|"if")

CLASS ^"classdef"
FUNC ^{SPACE}*"function"
PROPS ^{SPACE}*"properties"
EVENTS ^{SPACE}*"events"
METHODS ^{SPACE}*"methods"

/* lex states */
%x FUNCDECL
%x FUNCINPUT
%x FUNCBLOCK
%x CLASSDECL
%x CLASSINHERITS
%x MEMBERDECL
%s MEMBERBLOCK

/* lex rules */
%%
<*>{ESCAPEDCOMMENT} ;
<*>{COMMENT} {if(yyleng>1) fprintf(yyout, "//!%s", yytext+1);}
<*>{ENDPREFIX} {ECHO;};
<*>{ENDSUFFIX} {ECHO;};
<*>{DOUBLEQUOTES} {ECHO;};
<*>{SINGLEQUOTES} {ECHO;};

<INITIAL,FUNCBLOCK,MEMBERBLOCK>{PARENTHESES} {ECHO;};
<INITIAL,FUNCBLOCK,MEMBERBLOCK>{CURLYBRACES} {ECHO;};
<INITIAL,FUNCBLOCK,MEMBERBLOCK>{BRACKETS} {ECHO;};

<FUNCDECL,FUNCINPUT>{ELLIPSIS} ;
<FUNCDECL,FUNCINPUT,CLASSDECL,CLASSINHERITS>{SPACE}* ;

{FUNC} {declareStatic(); BEGIN FUNCDECL;}
<FUNCDECL>[,\[\]\=] ;
<FUNCDECL>{NAME} {fprintf(yyout, "%s ", yytext);};
<FUNCDECL>"set." {fprintf(yyout, "set_");}
<FUNCDECL>"get." {fprintf(yyout, "get_");}
<FUNCDECL>"(" {ECHO;; BEGIN FUNCINPUT;}
<FUNCDECL>\n  {fprintf(yyout, "()\n{\n"); functionDepth=1; BEGIN FUNCBLOCK;}
<FUNCINPUT>{NAME} {fprintf(yyout, " %s", yytext);};
<FUNCINPUT>")" {fprintf(yyout, ")\n{\n"); functionDepth=1; BEGIN FUNCBLOCK;}
<FUNCBLOCK>{CONTROL} {ECHO; functionDepth++;}
<FUNCBLOCK>{END} functionBackout();

{END} classBackout();

{CLASS} {classDepth=1; fprintf(yyout, "class"); BEGIN CLASSDECL;}
<CLASSDECL>{NAME} {fprintf(yyout, " %s", yytext);}
<CLASSDECL>"<" {fprintf(yyout, " : ", yytext); inheritDepth=0; BEGIN CLASSINHERITS;}
<CLASSDECL,CLASSINHERITS>\n {fprintf(yyout, "\n{\n"); BEGIN INITIAL;}
<CLASSDECL,CLASSINHERITS>. ;
<CLASSINHERITS>{NAME}"." ;
<CLASSINHERITS>{NAME} {if(inheritDepth++){fprintf(yyout, ", public %s", yytext);} else {fprintf(yyout, "public %s", yytext);}}

{PROPS} {memberType="Property"; memberAccess="public"; BEGIN MEMBERDECL;}
{EVENTS} {memberType="Event"; memberAccess="public"; BEGIN MEMBERDECL;}
{METHODS} {memberIsStatic=0; memberAccess="public"; BEGIN MEMBERDECL;}
<MEMBERDECL>"Access".+"private" {memberAccess="private";}
<MEMBERDECL>"Access".+"protected" {memberAccess="protected";}
<MEMBERDECL>"Static".+"true" {memberIsStatic=1;}
<MEMBERDECL>"Static"[^=\n\r]*$ {memberIsStatic=1;}
<MEMBERDECL>"Static"[^=\n\r]*{WORD} {memberIsStatic=1;}
<MEMBERDECL>"Hidden".+"true" {memberAccess="private";}
<MEMBERDECL>"Hidden"[^=\n\r]*$ {memberAccess="private";}
<MEMBERDECL>"Hidden"[^=\n\r]*{WORD} {memberAccess="private";}
<MEMBERDECL>\n {fprintf(yyout, "%s:\n", memberAccess); classDepth++; BEGIN MEMBERBLOCK;}
<MEMBERDECL>. ;
<MEMBERBLOCK>{NAME}[^\n\r]*";" {fprintf(yyout, "%s %s", memberType, yytext);}

%%

/* any C stuff */
void declareStatic()
{
	if(memberIsStatic) fprintf(yyout, "static ");
}

void functionBackout()
{
	
	if(--functionDepth)
	{
		//fprintf(yyout, "<fd%d>", functionDepth);
		ECHO;
	}
	else
	{
		fprintf(yyout, "\n}\n");
		BEGIN INITIAL;
	}
}

void classBackout()
{
	if(--classDepth==0) fprintf(yyout, "};\n");
		
	memberIsStatic=0;
	BEGIN INITIAL;
}

main(int argc, char **argv)
{
  if(argc > 1)
    yyin = fopen(argv[1], "r");
  else
    yyin = stdin;

  if(argc > 2)
    yyout = fopen( argv[2], "w");
  else
    yyout = stdout;

  yylex();
}
