/*DECLARATION - directly copied by LEX to lex.yy.c */
%{
#include "y.tab.h"
#include<stdlib.h>
#include<stdio.h>
%}
/* REGULAR DEFINITION */
digit [0-9]

/* Since you don't override it. Tells yytext the end of input*/
%option noyywrap  

/* RULES - the action part is directly copied */	
%%
({digit})+ {yylval.val=atoi(yytext); return NUM;}
[-+*\n/] |
"(" |
")" |
"%" return *yytext;
[ \t] ;
. return *yytext;
%%
/*AUXILIARY FUNCTIONS 
main()
{
yylex();      
}
*/
