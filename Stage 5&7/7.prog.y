%{
#include <stdio.h>
#include <stdlib.h>
#include "lex.yy.c"
#include "symboltable7.h"
void yyerror(char *str){fprintf(stderr, "%d ERROR : %s\n", yylineno, str);}

FILE *outfile;
int var_type;
int count = -1;
int label = 0;
int getBind(char* varname);
int getReg();
void freeReg();
int getLabel();
int codeGen(struct Tnode* t);
int main(int argc, char *argv[ ])
{
	yyin=fopen("input.txt","r");
	
	outfile = fopen("machinecode","w");
	fprintf(outfile,"START\n");
	
	yyparse();

	
	fclose(outfile);
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
%right ASG
%left OR
%left AND 
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT
%%
Prog: GDefblock Mainblock			{if(!error){
							codeGen($2);fprintf(outfile,"HALT");}
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

	/*int s = Evaluate(size);

	if(crt_index && (s<0 || (entry != NULL && s>=entry->SIZE))){
		error = 1;crt_index = 0;
		printf("%d ERROR : Array \"%s\" out of bound\n",yylineno,id->NAME); 
	}*/
	if(crt_index)   return 1;
	else		return 0;
}


int getBind(char* varname){
	struct Gsymbol* ptr = Glookup(varname);
	return ptr->BINDING;
}
int codeGen(struct Tnode* t){
	switch(t->TYPE){
		case DUMMY_TYPE:
			codeGen(t->Ptr1);
			codeGen(t->Ptr2);
			break;
		case INT_TYPE:
			switch(t->NODETYPE){				
				case NUM_NODETYPE:{
					int r = getReg();
					fprintf(outfile,"MOV R%d,%d\n",r,t->VALUE);
					return r;}
				case PLUS_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"ADD R%d,R%d\n",r1,r2);
					freeReg();
					return r1;}
				case MINUS_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"SUB R%d,R%d\n",r1,r2);
					freeReg();
					return r1;}
				case MUL_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"MUL R%d,R%d\n",r1,r2);
					freeReg();
					return r1;}
		                case DIV_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"DIV R%d,R%d\n",r1,r2);
					freeReg();
					return r1;}
			        case MOD_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"MOD R%d,R%d\n",r1,r2);
					freeReg();
					return r1;}
				case ASG_NODETYPE:{
					int loc = getBind(t->Ptr1->NAME);
					if(t->Ptr3 == NULL){
						int val   = codeGen(t->Ptr2);
						fprintf(outfile,"MOV [%d],R%d\n",loc,val);
						freeReg();
						return;
					}else{
						int rl = codeGen(t->Ptr2);
						int val = codeGen(t->Ptr3);
						int temp = getReg();

						fprintf(outfile,"MOV R%d,%d\n",temp,loc);						
						fprintf(outfile,"ADD R%d,R%d\n",rl,temp);
						freeReg();
						fprintf(outfile,"MOV [R%d],R%d\n",rl,val);
						freeReg();
						freeReg();
						return;
					}}
			}break;
		case BOOL_TYPE:
			 switch(t->NODETYPE){
				case LT_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					
					fprintf(outfile,"LT R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}
				case GT_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"GT R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}	 
				case LE_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"LE R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}
				case GE_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"GE R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}
				case EQ_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"EQ R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}
				case NE_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"NE R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}
				case AND_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"MUL R%d,R%d\n",r1,r2);

					freeReg();
					return r1;}	
				case OR_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);

					fprintf(outfile,"ADD R%d,R%d\n",r1,r2);
					freeReg();

					int r = getReg();

					fprintf(outfile,"MOV R%d,%d\n",r,1);
					fprintf(outfile,"GE R%d,R%d\n",r1,r);
					freeReg();
					return r1;}
				case NOT_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r  = getReg();

					fprintf(outfile,"MOV R%d,%d\n",r,1);
					fprintf(outfile,"ADD R%d,R%d\n",r1,r);	
					fprintf(outfile,"MOV R%d,%d\n",r,2);
					fprintf(outfile,"MOD R%d,R%d\n",r1,r);
					freeReg();
					return r1;}								
				case TRUE_NODETYPE:{
					int r = getReg();

					fprintf(outfile,"MOV R%d,1\n",r);

					return r;} 
				case FALSE_NODETYPE:{
					int r = getReg();

					fprintf(outfile,"MOV R%d,0\n",r);

					return r;}
			     }break;
		case VOID_TYPE:
			 switch(t->NODETYPE){
				case READ_NODETYPE:{
					int loc = getBind(t->Ptr1->NAME);
					int r   = getReg();

					fprintf(outfile,"IN R%d\n",r);					

					if(t->Ptr2 == NULL){
						fprintf(outfile,"MOV [%d],R%d\n",loc,r);
					}else{
						int rl = getReg();
						fprintf(outfile,"MOV R%d,%d\n",rl,loc);
						int off = codeGen(t->Ptr2);						
						fprintf(outfile,"ADD R%d,R%d\n",rl,off);
						freeReg();
						fprintf(outfile,"MOV [R%d],R%d\n",rl,r);
						freeReg();	
					}
					freeReg();
					return;}
				case WRITE_NODETYPE:{
						int r = codeGen(t->Ptr1);

						fprintf(outfile,"OUT R%d\n",r);
						freeReg();
						return;} 
				case IF_NODETYPE: {
					int l1 = getLabel();
					int l2 = getLabel();

					int r1 = codeGen(t->Ptr1);					
					fprintf(outfile,"JZ R%d,L%d\n",r1,l1);
					freeReg();

					codeGen(t->Ptr2);/*This is a stmt so it is -1*/
					fprintf(outfile,"JMP L%d\n",l2);
					fprintf(outfile,"L%d:\n",l1);
				
					if(t->Ptr3 != NULL)
						codeGen(t->Ptr3);/*This is a stmt so it is -1*/
					fprintf(outfile,"L%d:\n",l2);					
					return;}
				case WHILE_NODETYPE:{
					int l1 = getLabel();
					int l2 = getLabel();

					fprintf(outfile,"L%d:\n",l1);
					
					int r = codeGen(t->Ptr1);
					fprintf(outfile,"JZ R%d,L%d\n",r,l2);
					freeReg();

					codeGen(t->Ptr2);
					fprintf(outfile,"JMP L%d\n",l1);
						
					fprintf(outfile,"L%d:\n",l2);
					break;}	 
				case ID_NODETYPE:{
					int loc = getBind(t->NAME);
					int r   = getReg(); 
					if(t->Ptr1 == NULL){										
						fprintf(outfile,"MOV R%d,[%d]\n",r,loc);
						return r; 
					}else{
						int off = codeGen(t->Ptr1);
						int rl = getReg();
						fprintf(outfile,"MOV R%d,%d\n",rl,loc);						
						fprintf(outfile,"ADD R%d,R%d\n",rl,off);
						fprintf(outfile,"MOV R%d,[R%d]\n",r,rl);
						freeReg();
						freeReg();
						return r;	
					}}
			     }break;
	}
}
int getReg(){
	++count;
	return count;
}
void freeReg(){
	--count;
}
int getLabel(){
	++label;
	return label;
}


