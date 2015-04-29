%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
#include "symboltable.h"
void yyerror(char *str){fprintf(stderr, "%d ERROR : %s\n", yylineno, str);}
int var_type;
int main(int argc, char *argv[ ])
{
	yyin=fopen("input.txt","r");
	yyparse();
	fclose(yyin);
}
%}
%union{struct Tnode* ptr;};
%token <ptr> NUM ID READ WRITE IF WHILE EQ NE GT LT LE GE ASG PLUS MINUS DIV MUL MOD TRUE FALSE AND OR NOT
%token THEN ENDIF DO ENDWHILE DECL ENDDECL INTEGER BOOLEAN BEGINS END MAIN ELSE
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
%left OR
%left AND 
%right NOT
%left LT GT ASG NE LE GE EQ
%left PLUS MINUS
%left MUL DIV MOD
%%

Prog: GDefblock Mainblock			{if(!error)
							Evaluate($2);
						else
							printf("....Please Correct Your Code...\n");
						exit(0);};

GDefblock : DECL GDefList ENDDECL 
		;
GDefList  : GDecl
	  | GDefList GDecl;
GDecl   : Type GIdList ';' ;
GIdList : GId
	| GIdList ',' GId;
GId : ID					{Ginstall($1->NAME,var_type,1);
						struct Gsymbol *entry = Glookup($1->NAME);
						$1->Gentry = entry;
						}
    | ID '['NUM']'				{Ginstall($1->NAME,var_type,$3->VALUE);
						struct Gsymbol *entry = Glookup($1->NAME);
						$1->Gentry = entry;
						};

Mainblock : INTEGER MAIN '('')' '{' Body '}'	{$$=$6;};		

Type: INTEGER					{var_type = INT_VAR_TYPE;}
    | BOOLEAN					{var_type = BOOL_VAR_TYPE;};

Body : BEGINS StmtList END			{$$=$2;};

StmtList: Stmt					{$$ = $1;}     
	| StmtList Stmt				{$$ = TreeCreate(DUMMY_TYPE, DUMMY_NODETYPE, 0 , NULL, $1, $2, NULL, NULL);};			
Stmt: ID ASG expr';' 				{struct Gsymbol *entry = Glookup($1->NAME);
						$1->Gentry = entry;
						if(typecheck($2,$1,$3)){$2->Ptr1 = $1;$2->Ptr2 = $3;$$ = $2;}
						else exit(0);}

    | ID '['expr']'ASG expr';'			{struct Gsymbol *entry = Glookup($1->NAME);
						$1->Gentry = entry;
						if((typecheck($5,$1,$6) + validate_array_index($1,$3,entry)) == 2){
							$5->Ptr1 = $1;
							$5->Ptr2 = $3;
							$5->Ptr3 = $6;
							$$=$5;
						}
						if(!typecheck($5,$1,$6))exit(0);
						}

    | READ'('ID')'';'				{struct Gsymbol *entry = Glookup($3->NAME);
						$3->Gentry = entry;
						if(typecheck($1,$3,NULL)){$1->Ptr1 = $3;$$ = $1;}
						else exit(0);}

    | READ'('ID'['expr']'')'';'			{struct Gsymbol *entry = Glookup($3->NAME);
						$3->Gentry = entry;
						if((typecheck($1,$3,NULL) + validate_array_index($3,$5,entry)) == 2){
								$1->Ptr1 = $3;
								$1->Ptr2 = $5;
								$$ = $1;
						}
						if(!typecheck($1,$3,NULL))exit(0);
						}

    | WRITE'('expr')'';' 			{if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $$ = $1;}else exit(0);}
    | IF'('expr')' THEN StmtList ENDIF';'	{if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;}else exit(0);}
    | IF'('expr')' THEN StmtList ELSE StmtList ENDIF';'	{if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $1->Ptr2 = $6; $1->Ptr3 = $8; $$ = $1;}else exit(0);}
    | WHILE'('expr')' DO StmtList ENDWHILE';'	{if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;}else exit(0);};

expr : expr PLUS expr 	{if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr MINUS expr 	{if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr DIV expr 	{if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr MUL expr 	{if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr MOD expr 	{if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr LT expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr GT expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr EQ expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr NE expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr LE expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr GE expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr AND expr    {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | expr OR expr     {if(typecheck($2,$1,$3)){$2->Ptr1 = $1; $2->Ptr2 = $3; $$ = $2;}else exit(0);}
     | NOT expr         {if(typecheck($1,$2,NULL)){$1->Ptr1 = $2;$$ = $1;}else exit(0);}
     | '('expr')' 	{$$ = $2;}
     | TRUE 		{$$ = $1;}
     | FALSE		{$$ = $1;}
     | NUM		{$$ = $1;}
     | ID  		{struct Gsymbol *entry = Glookup($1->NAME);
			if(entry != NULL){
				$1->Gentry = entry;	
				$$ = $1;
			}else{
				error = 1;
				printf("%d ERROR : %s is undeclared\n",yylineno,$1->NAME);
			}}				
     | ID'['expr']'	{struct Gsymbol *entry = Glookup($1->NAME);
			if(entry != NULL)
				$1->Gentry = entry;
			else{
				error = 1;
				printf("%d ERROR : %s is undeclared\n",yylineno,$1->NAME);
			}
			if(validate_array_index($1,$3,entry)){
				$1->Ptr1 = $3;
				$$ = $1;
			}};		
%%
int validate_array_index(struct Tnode* id, struct Tnode* size, struct Gsymbol* entry){
	int crt_index=1;

	if(size->TYPE == BOOL_TYPE){
		error = 1;crt_index = 0;
		printf("%d ERROR : Array \"%s\" index should be integer\n",yylineno,id->NAME);
	}else if (size->TYPE == VOID_TYPE){
		struct Gsymbol *e = size->Gentry;
		if(e != NULL && e->TYPE == BOOL_VAR_TYPE){
			error = 1;crt_index = 0;
			printf("%d ERROR : Array \"%s\" index should be integer\n",yylineno,id->NAME);
		}		
	}

	int s = Evaluate(size);

	if(crt_index && (s<0 || (entry != NULL && s>=entry->SIZE))){
		error = 1;crt_index = 0;
		printf("%d ERROR : Array \"%s\" out of bound\n",yylineno,id->NAME); 
	}

	if(crt_index)   return 1;
	else		return 0;
}

