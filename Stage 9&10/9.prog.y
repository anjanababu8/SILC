%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
#include "symboltables.h"
#include "codeGen.h"
#include "structures.h"
#include "typecheck.h"

void yyerror(char *str){fprintf(stderr, "%d ERROR : %s\n", yylineno, str);}

FILE *outfile;
int var_type,arg_type,func_type;

void isNotArray(struct Tnode* ptr);
void idLookUp(struct Tnode* ptr);
void arrayLookUp(struct Tnode* ptr);
void functionLookUp(struct Tnode* ptr);
struct Tnode* MakeLinkedList(struct Tnode* exprList);

int main(int argc, char *argv[ ])
{
	yyin=fopen("input.txt","r");
	outfile = fopen("machinecode","w");
	yyparse();
	fclose(outfile);
	fclose(yyin);
}
%}
%union{
struct Tnode* ptr;
};
%token <ptr> NUM ID READ WRITE IF WHILE EQ NE GT LT LE GE ASG PLUS MINUS DIV MUL MOD TRUE FALSE AND OR NOT MAIN 
%token THEN ENDIF DO ENDWHILE DECL ENDDECL INTEGER BOOLEAN BEGINS END ELSE RETURN
%type <ptr> GDecBlock FDefList Mainblock GDecList GDecl ArgType ArgList Arg FDef FDef_ArgList LDecBlock LDecList LDecl LIdList LId StmtList GIdList GId FType Type Stmt expr Id IdList NonEmptyExprList ExprList Main

%right ASG
%left OR
%left AND 
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT
%%
Prog : GDecBlock FDefList Mainblock		{exit(0);};

GDecBlock : DECL GDecList ENDDECL 		{$$=$2;};
GDecList  : GDecl
	  | GDecList GDecl;
GDecl   : Type GIdList ';' ;
GIdList : GId
	| GIdList ',' GId ;
GId : ID					{Ginstall($1->NAME,var_type,1,NULL,0);}
    | ID '['NUM']'				{Ginstall($1->NAME,var_type,$3->VALUE,NULL,1);}
    | ID '(' ArgList ')'			{Ginstall($1->NAME,var_type,10000,argHead,0);
						 setArgListBinding(argHead,argCount);
					 	 argHead = NULL; argCount = 0;
						};			



FDefList: FDef
	| FDefList FDef ;



FDef : FType ID '(' FDef_ArgList ')' '{' LDecBlock BEGINS StmtList RETURN expr ';' END '}'	{
						 // ID FUNCTYPE ARGHEAD RETURNEXPR

						 $2->TYPE = func_type;
                   			         $2->ArgList = argHead; 
		
						 functionLookUp($2);

					 	 $2->Lentry = lhead; lhead = NULL;
						 currentTable = $2->Lentry;

						 struct Arg* FDecArgHead = Glookup($2->NAME)->ARGLIST;

                      			         if(typeFuncDef($2,func_type,FDecArgHead,$11)){
							  $2->NODETYPE = FUNCTION_NODETYPE;		
							  setArgListBinding(argHead,argCount);
							  argCount = 0; argHead = NULL;
							  $2->Ptr1 = $9;
							  $2->Ptr2 = $11;
							  $2->VALUE = lVariables-1; lVariables = 1;

						  	  codeGenFuncEntry($2);						 
						  }else exit(0);
						 };

FType: INTEGER					{func_type = INT_TYPE;} 
     | BOOLEAN					{func_type = BOOL_TYPE;};

Mainblock : INTEGER Main '('')' '{' LDecBlock BEGINS StmtList RETURN '('NUM')'';' END '}'	{
						$2->Lentry = lhead; lhead = NULL;
						$2->Ptr1 = $8;
						$2->Ptr2 = $11;
						$2->VALUE = lVariables-1; lVariables = 1;
						currentTable = $2->Lentry;

						codeGenMainEntry($2); 
						};		

Main: MAIN					{currentTable = NULL;};


FDef_ArgList : ArgList				{currentTable = NULL;ArgLinstall(argHead,argCount);};
ArgList : 					{}
	| Arg
	| ArgList ';' Arg ;
Arg : ArgType IdList;
ArgType : INTEGER				{arg_type = INT_TYPE;}
	| BOOLEAN				{arg_type = BOOL_TYPE;};
IdList : Id
       | IdList ',' Id;
Id : ID						{++argCount;MakeArgList($1->NAME,arg_type,0);} 
   | '&' ID					{++argCount;MakeArgList($2->NAME,arg_type,1);};//1-Pass By Reference


							
LDecBlock : DECL LDecList ENDDECL 		{currentTable=lhead;$$=$2;};
LDecList  : LDecl
	  | LDecList LDecl;
LDecl   : Type LIdList ';' ;
LIdList : LId
	| LIdList ',' LId ;
LId : ID					{Linstall($1->NAME,var_type,lVariables++);};



Type: INTEGER					{var_type = INT_TYPE;}
    | BOOLEAN					{var_type = BOOL_TYPE;};



StmtList: Stmt					{$$ = $1;}			   
	| StmtList Stmt				{$$ = TreeCreate(DUMMY_TYPE, DUMMY_NODETYPE, 0 , NULL, $1, $2, NULL);};			

Stmt: ID ASG expr';' 				{	
							idLookUp($1);
							isNotArray($1);
							if(typecheck($2,$1,$3)){	
								$2->Ptr1 = $1;
								$2->Ptr2 = $3;
								$$ = $2;
							}
							else exit(0);	
						}

    | ID '['expr']'ASG expr';'			{	arrayLookUp($1);
							struct Gsymbol* entry = Glookup($1->NAME);
							if((typecheck($5,$1,$6) + validate_array_index($1,$3,entry)) == 2){
								$5->Ptr1 = $1;
								$5->Ptr2 = $3;
								$5->Ptr3 = $6;
								$$=$5;
							}
							if(!typecheck($5,$1,$6)) exit(0);
						}

    | READ'('ID')'';'				{	idLookUp($3);
							isNotArray($3);
							if(typecheck($1,$3,NULL)){
								$1->Ptr1 = $3; 
								$$ = $1;
							}
							else exit(0);
						}

    | READ'('ID'['expr']'')'';'			{	arrayLookUp($3);
							struct Gsymbol* entry = Glookup($3->NAME);
							if((typecheck($1,$3,NULL) + validate_array_index($3,$5,entry)) == 2){
								$1->Ptr1 = $3;
								$1->Ptr2 = $5;
								$$ = $1;
							}
							if(!typecheck($1,$3,NULL)) exit(0);
						}

    | WRITE'('expr')'';' 			{ if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $$ = $1;}else exit(0);}
    | IF'('expr')' THEN StmtList ENDIF';'	{ if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;}else exit(0);}
    | IF'('expr')' THEN StmtList ELSE StmtList ENDIF';' { if(typecheck($1,$3,NULL)){$1->Ptr1=$3;$1->Ptr2=$6;$1->Ptr3=$8;$$=$1;}else exit(0);}
    | WHILE'('expr')' DO StmtList ENDWHILE';'	{ if(typecheck($1,$3,NULL)){$1->Ptr1 = $3; $1->Ptr2 = $6; $$ = $1;}else exit(0);};



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
     | ID  		{idLookUp($1);isNotArray($1);}				
     | ID'['expr']'	{	arrayLookUp($1);
				struct Gsymbol* entry = Glookup($1->NAME);	
				if(validate_array_index($1,$3,entry)){
					$1->Ptr1 = $3;
					$$ = $1;
				}
			}
     | ID '(' ExprList ')'	{
					$1->NODETYPE = FUNCTION_NODETYPE;
					functionLookUp($1);
					$1->ArgList = Glookup($1->NAME)->ARGLIST;
			
					struct Tnode* expHead = MakeLinkedList($3);	
					$1->Ptr1 = expHead; // Traverse back a,b =>   b->a
			
					typeFunCall($1->NAME,$1->ArgList,expHead);
					$$ = $1;
					
							
				};

ExprList : 			{$$ = NULL;}
	 | NonEmptyExprList	{$$ = $1;}; 
NonEmptyExprList: expr				{$$=TreeCreate(DUMMY_TYPE,DUMMY_NODETYPE,0,NULL,NULL,$1,NULL);}	
	 	| NonEmptyExprList ',' expr  	{$$=TreeCreate(DUMMY_TYPE,DUMMY_NODETYPE,0,NULL,$1,$3,NULL);}
%%

struct Tnode* MakeLinkedList(struct Tnode* expList){
	struct Tnode* head = NULL;
	struct Tnode* tail = NULL;
	if(expList != NULL){
		do{
			struct Tnode* ptr = malloc(sizeof(struct Tnode));
			ptr = expList->Ptr2;
			if(head == NULL){	
				head = ptr;			
				head->PREV = NULL;
			}else{
				ptr->PREV = tail;
				tail->NEXT = ptr;
			}
			ptr->NEXT = NULL;
			tail = ptr;
			expList = expList->Ptr1;
		}while(expList != NULL);
	}
	return tail;				
}

void isNotArray(struct Tnode* ptr){
	struct Lsymbol *entryl = Llookup(lhead,ptr->NAME);						
	struct Gsymbol *entryg = Glookup(ptr->NAME);
	if(entryl==NULL && entryg!=NULL && entryg->ISARRAY){
		printf("%d ERROR : \"%s\" is declared as an array => Refer it like %s[index]\n",yylineno,ptr->NAME,ptr->NAME); exit(0);	
	}
}
void idLookUp(struct Tnode* ptr){	
	struct Lsymbol *entryl = Llookup(lhead,ptr->NAME);						
	struct Gsymbol *entryg = Glookup(ptr->NAME);
	if(entryl != NULL)
		ptr->Lentry = entryl;
	else if(entryg != NULL){	
		ptr->Gentry = entryg;

	}
	else{
		printf("%d ERROR : %s is undeclared\n",yylineno,ptr->NAME); exit(0);
	}
}
void arrayLookUp(struct Tnode* ptr){
	struct Gsymbol *entry = Glookup(ptr->NAME);
	if(entry != NULL){
		if(entry->SIZE > 1)
			ptr->Gentry = entry;
		else{
			printf("%d ERROR : %s is not declared as an array\n",yylineno,ptr->NAME); exit(0);
		}
	}
	else{
		printf("%d ERROR : %s is undeclared\n",yylineno,ptr->NAME);exit(0);
	}
}
void functionLookUp(struct Tnode* ptr){
	struct Gsymbol *entry = Glookup(ptr->NAME);
	if(entry != NULL){	
		ptr->Gentry = entry;
	}	
	else{
		printf("%d ERROR : Function \"%s\" is undeclared\n",yylineno,ptr->NAME);exit(0);
	}
}

int validate_array_index(struct Tnode* id, struct Tnode* size, struct Gsymbol* entry){
	int crt_index=1;

	if(size->TYPE == BOOL_TYPE){
		crt_index = 0;
		printf("%d ERROR : Array \"%s\" index should be integer\n",yylineno,id->NAME);exit(0);
	}else if (size->TYPE == VOID_TYPE){
		struct Gsymbol *e = size->Gentry;
		if(e != NULL && e->TYPE == BOOL_TYPE){
			crt_index = 0;
			printf("%d ERROR : Array \"%s\" index should be integer\n",yylineno,id->NAME);exit(0);
		}		
	}
	if(crt_index)   return 1;
	else		return 0;
}
