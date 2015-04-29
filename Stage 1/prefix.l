/*Prefix Notation*/
%{
#include "y.tab.h"
#include<stdlib.h>
#include<stdio.h>
%}

digit [0-9]

%option noyywrap  

%%
({digit})+ {yylval.val=atoi(yytext);return NUM;}
[-+*\n/] |
"(" |
")" |
"%" return *yytext;
[ \t] ;
. return *yytext;
%%

