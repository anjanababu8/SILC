%{
#include "lex.yy.c"
#include <stdio.h>
#include <stdlib.h>
int sym[26];

void yyerror(char *str){fprintf(stderr, "ERROR : %s\n", str);}
int main(){return yyparse();}
%}

%token NUM ID READ WRITE
%left '+' '-'
%left '*' '/' '%'

/*RULES*/
%%
pgm : statement 
     | pgm statement;

statement: ID '=' expr';' {sym[$1]=$3;}
          | READ'('ID')'';' {scanf("%d",&sym[$3]);}        
	  | WRITE'('expr')'';' {printf("%d\n",$3);}
         
expr : expr '+' expr {$$=$1+$3;}
     | expr '*' expr {$$=$1*$3;}
     | expr '-' expr {$$=$1-$3;}
     | expr '/' expr {$$=$1/$3;}
     | expr '%' expr {$$=$1%$3;}
     | '('expr')' {$$=$2;}
     | NUM {$$=$1;}
     | ID  {$$=sym[$1];};
%%
