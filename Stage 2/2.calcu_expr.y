/*
	INPUT : sequence of tokens
	OUTPUT : parse tree (y.tab.c)
*/

/*DECLARATIONS*/
/* i . C declarations - items used in actions and auxi functions*/
%{
#include "lex.yy.c"
#include "exprtree.h"
#include <stdio.h>
#include <stdlib.h>
%}

%union{    /*Defines YYSTYPE(yyStackType)*/
int val;
struct tree_node *ptr;
};

/* ii. YACC declarations - items used in rules part - decl of tokens returned by lex analyser*/
%token <val> NUM
%type <ptr> expr
%left '+' '-'
%left '*' '/' '%'

/*RULES*/
%%
pgm : expr '\n' {postorder($1);printf("\nComplete Answer %d\n",evaluate($1));exit(0);};
expr : expr '+' expr {$$=mkOpNode('+',$1,$3);}
     | expr '*' expr {$$=mkOpNode('*',$1,$3);}
     | expr '-' expr {$$=mkOpNode('-',$1,$3);}
     | expr '/' expr {$$=mkOpNode('/',$1,$3);}
     | expr '%' expr {$$=mkOpNode('%',$1,$3);}
     | '('expr')' {$$=$2;}
     | NUM {$$=mkLeafNode($1);};
%%
/*AUXILIARY FUNCTIONS*/	
int main()
{
return yyparse();   /* Implementation of PDA in C - invokes yylex() to read the tokens */
	/* yylex() is either supplied by lex.yy.c or is to be explicitly written by us in auxiliary functions*/
}
yyerror()
{
printf("\nError\n");
return;
}
