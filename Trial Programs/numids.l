/* Append the line number before each line - Take the input from file and display it on screen*/
%{
	#include<stdio.h>
	#include<stdlib.h>
	int count=0;
%}

digit [0-9]
letter [a-zA-Z]

%%
{letter}({letter}|{digit})*	++count;
. ;
%%

int main()
{
 yylex();
 printf("%d\n",count);
}

/* ANOTHER METHOD
%%
^(.*)\n		printf("%4d\t%s", ++yylineno, yytext);
%%

int main(int argc, char *argv[])
{
yyin = fopen(argv[1], "r");
yylex();
}
*/
