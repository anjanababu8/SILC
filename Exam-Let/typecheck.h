#ifndef TYPECHECK_H
#define TYPECHECK_H
#include <stdio.h>
#include <stdlib.h>
#include "symboltables.h"
#include "structures.h"

#define INT_TYPE	100
#define BOOL_TYPE	200
#define VOID_TYPE	300

#define DUMMY_TYPE 	0
#define DUMMY_NODETYPE	0

#define READ_NODETYPE	1
#define WRITE_NODETYPE	2
#define IF_NODETYPE	3
#define WHILE_NODETYPE	4
#define NUM_NODETYPE	5
#define ID_NODETYPE	6

#define PLUS_NODETYPE	7
#define MINUS_NODETYPE  17
#define DIV_NODETYPE	18
#define MOD_NODETYPE    19
#define MUL_NODETYPE	8
#define ASG_NODETYPE	9
#define LT_NODETYPE	10
#define GT_NODETYPE	11
#define EQ_NODETYPE	12
#define NE_NODETYPE	25
#define LE_NODETYPE	20
#define GE_NODETYPE	21
#define AND_NODETYPE	22
#define OR_NODETYPE	23
#define NOT_NODETYPE	24

#define TRUE_NODETYPE   15
#define FALSE_NODETYPE  16

#define FUNCTION_NODETYPE 26
#define LET_NODETYPE 27

int typecheck(struct Tnode* Ptr1, struct Tnode* Ptr2,struct Tnode* Ptr3);
int typeFuncDef(struct Tnode* ptr, int ftype, struct Arg* head, struct Tnode* rexpr); // ID FUNCTYPE ARGHEAD RETURNEXPR
	int matchReturn(struct Tnode* f, struct Tnode* rexpr);
	int matchArgs(char* fname, struct Arg* farg,struct Arg* darg);
int typeFunCall(char* fname, struct Arg* argList, struct Tnode* expList);

int getIDType(char* name){
	if(isLet == 1){ /*Added*/
		if(letHead == NULL){
				printf("dahgdhG");exit(0);
		}
		struct Lsymbol* t = letHead;
		while(t->PREV!=NULL && strcmp(t->NAME,name))
			t= t->PREV;
		if(t->PREV!=NULL && !strcmp(t->NAME,name)){		
			struct Lsymbol *entryl = Llookup(currentTable,name);
			return entryl->TYPE;
		} 	
	}

	struct Lsymbol* l = Llookup(currentTable,name);
	if(l != NULL)
		return l->TYPE;
	struct Gsymbol* g = Glookup(name);
	if(g != NULL)
		return g->TYPE;
}

int typeFunCall(char* fname,struct Arg* argList, struct Tnode* expList){
	int i = 0;
	if(expList != NULL && argList != NULL){
		do{
			++i;
			if(expList->TYPE != VOID_TYPE){
				if(expList->TYPE != argList->TYPE){
				 printf("%d ERROR : In Function Call to \"%s\" TypeMismatch in argument %d\n",yylineno,fname,i); exit(0);
				}
			}else{
				if(getIDType(expList->NAME) != argList->TYPE){
			         printf("%d ERROR : In Function Call to \"%s\" TypeMismatch in argument %d\n",yylineno,fname,i); exit(0);
				}
			}
			if(argList->ISREF && expList->NODETYPE!=ID_NODETYPE){
				 printf("%d ERROR : In Function Call to \"%s\" Reference argument %d is not ID\n",yylineno,fname,i); exit(0);
			}
				
			expList = expList->PREV;
			argList = argList->NEXT;
		}while(expList != NULL && argList != NULL);
	}					
	if((argList == NULL && expList != NULL) || (argList != NULL && expList == NULL)){
		printf("%d ERROR : # of arguments mismatch in Function Call to \"%s\"\n",yylineno,fname); exit(0);
	}	
}



int typeFuncDef(struct Tnode* ptr, int ftype, struct Arg* head, struct Tnode* rexpr){
	if (ptr->Gentry->TYPE != ftype){
		printf("%d ERROR : Function \"%s\" is declared to be of different type\n",yylineno,ptr->NAME);return 0;
	}else if (!matchReturn(ptr,rexpr)){	
		printf("%d ERROR : Function \"%s\" is returning a value of unexpected type\n",yylineno,ptr->NAME);return 0;
	}else if (!matchArgs(ptr->NAME, ptr->ArgList, head)){
		return 0;
	}else
		return 1;

}	
int matchReturn(struct Tnode* f, struct Tnode* rexpr){
	if(rexpr->TYPE != VOID_TYPE){
		if(f->TYPE != rexpr->TYPE) return 0;
		else 	                   return 1;
	}else {
		struct Lsymbol* l = Llookup(currentTable,rexpr->NAME);
		if(l != NULL){
			if(l->TYPE != f->TYPE) return 0;
			else 		       return 1;
		}
		struct Gsymbol* g = Glookup(rexpr->NAME);
		if(g != NULL){
			if(g->TYPE != f->TYPE) return 0;
			else 		       return 1;
		}
		return 0;
	}
}
int matchArgs(char* fname, struct Arg* farg,struct Arg* darg){
	if(farg == NULL && darg == NULL){
		return 1;
	}
	else if((farg != NULL && darg == NULL) || (farg == NULL && darg != NULL)){
		return 0;
	}
	else{
		int i = 1;
		while(farg != NULL && darg != NULL){
			if(farg->TYPE != darg->TYPE){
				printf("%d ERROR : In Function \"%s\" TypeMismatch in argument %d\n",yylineno,fname,i); return 0;
			}else if(farg->ISREF != darg->ISREF){
				printf("%d ERROR : In Function \"%s\" ReferenceMismatch in argument %d\n",yylineno,fname,i); return 0;
			}else if(strcmp(farg->NAME,darg->NAME)){
				printf("%d ERROR : In Function \"%s\" NameMismatch in argument %d\n",yylineno,fname,i); return 0;
			}
			farg = farg->NEXT; darg = darg->NEXT; i++;
		}
		if(farg == NULL && darg == NULL)
			return 1;
		else{
			printf("%d ERROR : In Function \"%s\" # of arguments mismatch\n",yylineno,fname); return 0;
		}
	}		
}

/**Typecheck for each operator nodes are done...
Read & Assg will also have ID validation here...*/
int typecheck(struct Tnode* Ptr1, struct Tnode* Ptr2,struct Tnode* Ptr3){
int crt_type = 1;
switch(Ptr1->TYPE){
	case INT_TYPE:
		switch(Ptr1->NODETYPE){
			case PLUS_NODETYPE:
			case MINUS_NODETYPE: 
			case DIV_NODETYPE:
			case MOD_NODETYPE: 
			case MUL_NODETYPE: 
						if(Ptr2->TYPE == BOOL_TYPE || Ptr3->TYPE == BOOL_TYPE) crt_type = 0;
						else{ 
							if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE!=ID_NODETYPE && Ptr2->NODETYPE!=FUNCTION_NODETYPE) 										crt_type = 0;
								else if(getIDType(Ptr2->NAME) != INT_TYPE)
									crt_type = 0;

							}
							if(crt_type && Ptr3->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr3->NODETYPE!=ID_NODETYPE && Ptr3->NODETYPE!=FUNCTION_NODETYPE) 										crt_type = 0;
								else if(getIDType(Ptr3->NAME) != INT_TYPE)
									crt_type = 0;

							}
						}
						if(!crt_type){printf("%d ERROR : Type Mismatch in ARITHMETIC OPERATOR\n",yylineno);exit(0);}
						else return 1;					
			case ASG_NODETYPE:
						if(Ptr2->TYPE != VOID_TYPE) crt_type = 0;
						else if(Ptr2->NODETYPE != ID_NODETYPE) crt_type = 0;
						else{
							if(getIDType(Ptr2->NAME) == INT_TYPE){
								if(Ptr3->TYPE == BOOL_TYPE) crt_type=0;
								else if(Ptr3->TYPE == VOID_TYPE){
									if(Ptr3->NODETYPE!=ID_NODETYPE && Ptr3->NODETYPE!=FUNCTION_NODETYPE)
										crt_type = 0;
									else if(getIDType(Ptr3->NAME) == BOOL_TYPE)
										crt_type = 0;
								}
							}else if(getIDType(Ptr2->NAME) == BOOL_TYPE){
								if(Ptr3->TYPE == INT_TYPE) crt_type=0;
								else if(Ptr3->TYPE == VOID_TYPE){
									if(Ptr3->NODETYPE!=ID_NODETYPE && Ptr3->NODETYPE!=FUNCTION_NODETYPE)
										crt_type = 0;
									else if(getIDType(Ptr3->NAME) == INT_TYPE)
										crt_type = 0;
								}
							}
						}
						if(!crt_type){printf("%d ERROR : Type Mismatch in '='\n",yylineno);exit(0);
						}else return 1;
		}break;
	case BOOL_TYPE:
			switch(Ptr1->NODETYPE){
				case LT_NODETYPE:
				case GT_NODETYPE:
				case LE_NODETYPE:
				case GE_NODETYPE:
				case NE_NODETYPE:
				case EQ_NODETYPE:{	
							if(Ptr2->TYPE == BOOL_TYPE || Ptr3->TYPE == BOOL_TYPE) crt_type = 0;
							else{ 
								if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
									if(Ptr2->NODETYPE!=ID_NODETYPE && Ptr2->NODETYPE!=FUNCTION_NODETYPE) 											crt_type = 0;
									else if(getIDType(Ptr2->NAME) == BOOL_TYPE)
										crt_type = 0;
								}
								if(crt_type && Ptr3->TYPE == VOID_TYPE){//Identifier&Function
									if(Ptr3->NODETYPE!=ID_NODETYPE && Ptr3->NODETYPE!=FUNCTION_NODETYPE) 											crt_type = 0;
									else if(getIDType(Ptr3->NAME) == BOOL_TYPE)
										crt_type = 0;
								}
							}
							if(!crt_type){
								printf("%d ERROR : Type Mismatch in LOGICAL OPERATOR\n",yylineno);exit(0);
							}else	return 1;
						 }
				case AND_NODETYPE:
				case OR_NODETYPE:
						if(Ptr2->TYPE == INT_TYPE || Ptr3->TYPE == INT_TYPE) crt_type = 0;
						else{ 
							if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE!=ID_NODETYPE && Ptr2->NODETYPE!=FUNCTION_NODETYPE) 										crt_type = 0;
								else if(getIDType(Ptr2->NAME) != BOOL_TYPE)
									crt_type = 0;

							}
							if(crt_type && Ptr3->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr3->NODETYPE!=ID_NODETYPE && Ptr3->NODETYPE!=FUNCTION_NODETYPE) 										crt_type = 0;
								else if(getIDType(Ptr3->NAME) != BOOL_TYPE)
									crt_type = 0;

							}
						}
						if(!crt_type){printf("%d ERROR : Type Mismatch in RELATIONAL OPERATOR \n",yylineno);exit(0);}
						else	return 1;
				case NOT_NODETYPE:	
						if(Ptr2->TYPE == INT_TYPE) crt_type = 0;
						else{ 
							if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE!=ID_NODETYPE && Ptr2->NODETYPE!=FUNCTION_NODETYPE) 										crt_type = 0;
								else if(getIDType(Ptr2->NAME) != BOOL_TYPE)
									crt_type = 0;
							}
						}
						if(!crt_type){printf("%d ERROR : Type Mismatch in RELATIONAL OPERATOR\n",yylineno);exit(0);}
						else return 1;				
			}break;
	case VOID_TYPE:
			switch(Ptr1->NODETYPE){
				case IF_NODETYPE:
				case WHILE_NODETYPE:{
							if(Ptr2->TYPE == INT_TYPE) crt_type = 0;
							else if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE!=ID_NODETYPE && Ptr2->NODETYPE!=FUNCTION_NODETYPE) 										crt_type = 0;
								else if(getIDType(Ptr2->NAME) != BOOL_TYPE)
									crt_type = 0;
							}
							if(!crt_type){
								if(Ptr1->NODETYPE == IF_NODETYPE)
									printf("%d ERROR : Type Mismatch in IF\n",yylineno);
								else
									printf("%d ERROR : Type Mismatch in WHILE\n",yylineno);
								exit(0);
							}else	return 1;
						    }
				case READ_NODETYPE:{
							if(Ptr2->TYPE == BOOL_TYPE) crt_type = 0;
							else if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE!=ID_NODETYPE) 									crt_type = 0;
								else if(getIDType(Ptr2->NAME) != INT_TYPE)
									crt_type = 0;
							}		
							if(!crt_type){printf("%d ERROR : Type Mismatch in READ\n",yylineno);exit(0);}
							else return 1;
						   }	
				case WRITE_NODETYPE:{	
							if(Ptr2->TYPE == BOOL_TYPE ){
								crt_type=0;
							}else if (Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE != ID_NODETYPE && Ptr2->NODETYPE != FUNCTION_NODETYPE)
									crt_type = 0;
								else if(getIDType(Ptr2->NAME) != INT_TYPE)
									crt_type = 0;
							}
							if(!crt_type){printf("%d ERROR : Type Mismatch in WRITE\n",yylineno);exit(0);}
							else return 1;	
						    }				
			}break;
}}
#endif
