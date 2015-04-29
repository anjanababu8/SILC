%{
#include "lex.yy.c"
#include <stdio.h>
#include <stdlib.h>
int sym[26];
%}

%token NUM VARIABLE
%left '+' '-'
%left '*' '/' '%'

%%
pgm : pgm statement
     | statement ;
	
statement: expr'\n' {printf("%d\n",$1);}
	 | VARIABLE '=' expr'\n' {sym[$1]=$3;};

expr : NUM {$$=$1;}
     | VARIABLE {$$=sym[$1];}
     | expr '+' expr {$$=$1+$3;}
     | expr '*' expr {$$=$1*$3;}
     | expr '-' expr {$$=$1-$3;}
     | expr '/' expr {$$=$1/$3;}
     | expr '%' expr {$$=$1%$3;}
     | '('expr')' {$$=$2;};
%%

int main()
{
return yyparse();
}
yyerror()
{
printf("\nError\n");
return;
}
