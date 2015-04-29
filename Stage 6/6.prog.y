%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
#include "symboltable.h"
void yyerror(char *str){fprintf(stderr, "ERROR : %s\n", str);}
int var_type;
int main(int argc, char *argv[ ])
{
	yyin=fopen("input.txt","r");
	yyparse();
	fclose(yyin);
}
%}
%union{struct Tnode* ptr;};
%token <ptr> NUM ID READ WRITE IF WHILE EQ GT LT ASG PLUS MUL TRUE FALSE
%token THEN ENDIF DO ENDWHILE DECL ENDDECL INTEGER BOOLEAN BEGINS END MAIN
%type <ptr> GDefblock
%type <ptr> GDefList
%type <ptr> GDecl
%type <ptr> GIdList
%type <ptr> GId
%type <ptr> Mainblock
%type <ptr> Type
%type <ptr> Body
%type <ptr> StmtList
%type <ptr> Stmt
%type <ptr> expr 
%nonassoc EQ LT GT
%left PLUS
%left MUL
%%

Prog: GDefblock Mainblock			{Evaluate($2);exit(0);};

GDefblock : DECL GDefList ENDDECL ;
GDefList  : GDecl
	  | GDefList GDecl;
GDecl   : Type GIdList ';' ;
GIdList : GId
	| GIdList ',' GId;
GId : ID					{$1->Gentry = Ginstall($1->NAME,var_type,1);}
    | ID '['NUM']'				{$1->Gentry = Ginstall($1->NAME,var_type,$3->VALUE);};

Mainblock : INTEGER MAIN '('')' '{' Body '}'	{$$=$6;};		

Type: INTEGER					{var_type = INT_VAR_TYPE;}
    | BOOLEAN					{var_type = BOOL_VAR_TYPE;};

Body : BEGINS StmtList END			{$$=$2;};

StmtList: Stmt					{$$ = $1;}     
	| StmtList Stmt				{$$ = TreeCreate(DUMMY_TYPE, DUMMY_NODETYPE, 0 , NULL, $1, $2, NULL, NULL, NULL);};			
Stmt: ID ASG expr';' 				{$2->Ptr1 = $1;$2->Ptr2 = $3;$$ = $2;}
    | ID '['expr']'ASG expr';'			{
							if(validate_array_index($5)){
								$5->Ptr1 = $1;
								$5->Ptr2 = $3;
								$5->Ptr3 = $6;
								$$=$5;
							}
						}
    | READ'('ID')'';'				{$1->Ptr1 = $3;$$ = $1;}
    | READ'('ID'['expr']'')'';'			{
							if(validate_array_index($5)){
								$1->Ptr1 = $3;
								$1->Ptr2 = $5;
								$$ = $1;
							}
						}
    | WRITE'('expr')'';' 			{$1->Ptr1 = $3; $$ = $1;}
    | IF'('expr')' THEN StmtList ENDIF';'	{$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;}
    | WHILE'('expr')' DO StmtList ENDWHILE';'	{$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;};

expr : expr PLUS expr 	{$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr MUL expr 	{$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr LT expr     {$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr GT expr     {$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | expr EQ expr     {$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}
     | '('expr')' 	{$$ = $2;}
     | TRUE 		{$$ = $1;}
     | FALSE		{$$ = $1;}
     | NUM		{$$ = $1;}
     | ID  		{$$ = $1;}
     | ID'['expr']'	{
				if(validate_array_index($3)){
						$1->Ptr1 = $3;
						$$ = $1;
				}	
			};		
%%
int validate_array_index(struct Tnode* ptr){
	if(ptr->TYPE == BOOL_TYPE){
		printf("INVALID : Array index should be integer");
		return 0;
	}
	return 1;
}
