%option noyywrap
%{
#include <stdlib.h>
#include <stdio.h>
%}
number [0-9]+
%%
{number} {
		int x = atoi(yytext);
		if(x%2 == 0) printf("%d is Even and %d digits long", atoi(yytext), yyleng);
		else printf("%d is Odd and %d digits long", atoi(yytext), yyleng);}
%%
int main()
{
yylex();
return 1;
} 
