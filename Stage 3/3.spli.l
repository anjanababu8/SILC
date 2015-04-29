/*Stage 3*/
%{
#include "y.tab.h"
#include<stdlib.h>
#include<stdio.h>
int yylval;
%}

%option noyywrap  

%%
"read" 			return READ;
"write" 		return WRITE;
[-+*%/=;()] 		return *yytext;
[a-z] 			{yylval = *yytext - 'a'; return ID;}
[0-9]+	 		{yylval = atoi(yytext); return NUM;}
[ \n\t] 		{}
. 			{}
%%

