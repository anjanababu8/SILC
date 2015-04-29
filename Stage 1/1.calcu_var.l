/*DECLARATION - directly copied by LEX to lex.yy.c */
%{
#include "y.tab.h"
#include<stdlib.h>
#include<stdio.h>
%}

digit [0-9]

%%
[a-z]	{yylval = *yytext - 'a'; return VARIABLE;}
({digit})+ {yylval=atoi(yytext); return NUM;}
[-+*\n/=()\%] return *yytext;
. ;
%%

