%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
#include "tree.h"
void yyerror(char *str){fprintf(stderr, "ERROR : %s\n", str);}
int main(){return yyparse();}
%}
%union{struct Tnode* ptr;};
%token <ptr> NUM ID READ WRITE IF WHILE EQ GT LT ASG PLUS MUL
%token THEN ENDIF DO ENDWHILE
%type <ptr> expr
%type <ptr> Stmt
%type <ptr> StmtList 
%nonassoc EQ LT GT
%left PLUS
%left MUL
%%
Pgm : StmtList'\n' 	{Evaluate($1);exit(0);};
StmtList : Stmt					{$$ = $1;}
	 | StmtList Stmt			{$$ = TreeCreate(DUMMY_TYPE, DUMMY_NODETYPE, 0 , NULL, $1, $2, NULL);};
Stmt: ID ASG expr';' 				{$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
    | READ'('ID')'';'				{$1->Ptr1 = $3; $$ = $1;}
    | WRITE'('expr')'';' 			{$1->Ptr1 = $3; $$ = $1;}
    | IF'('expr')' THEN StmtList ENDIF';'	{$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;}
    | WHILE'('expr')' DO StmtList ENDWHILE';'	{$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;};
expr : expr PLUS expr 	{$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr MUL expr 	{$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr LT expr     {$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr GT expr     {$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr EQ expr     {$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | '('expr')' 	{$$ = $2;}
     | NUM		{$$ = $1;}
     | ID  		{$$ = $1;};
%%

