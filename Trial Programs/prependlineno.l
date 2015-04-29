/* Append the line number before each line - Take the input from file and display it on screen*/
%{
	#include<stdio.h>
	#include<stdlib.h>
%}

%%
[\n]	{printf("%d ",yylineno);++yylineno;ECHO;}
.	yymore();
%%

int main()
{
 FILE* fp = fopen("abc.txt","r");
 yyin = fp;
 yylex();
 fclose(fp);
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
