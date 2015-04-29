/* Counts the number of characters, words, and lines in a file (similar to Unix wc) */
%{
	#include<stdio.h>
	#include<stdlib.h>
	int words=0,chars=0;
%}

digit [0-9]
letter [a-zA-Z]

%%
[\n]		{++yylineno;chars++;}
[^ \t\n]+	{++words;chars+=yyleng;}
.		++chars;
%%

int main()
{
 FILE* fp = fopen("abc.txt","r");
 yyin = fp;
 yylex();
 fclose(fp);
 printf("#Characters = %d\n#Words = %d\n#Lines = %d\n",chars,words,yylineno-1);
}

