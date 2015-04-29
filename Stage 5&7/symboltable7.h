#ifndef SYMBOLTABLE7_H
#define SYMBOLTABLE7_H
#include<stdio.h>
#include<stdlib.h>

#define INT_TYPE	1
#define BOOL_TYPE	2
#define VOID_TYPE	3

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

#define BOOL_VAR_TYPE	13
#define INT_VAR_TYPE	14

#define TRUE_NODETYPE   15
#define FALSE_NODETYPE  16

int symIndex = 0;

/** Sample Expression Tree Node Structure **/
struct Tnode {
int TYPE; // Integer, Boolean or Void (for statements)
int NODETYPE;/* Must point to the type expression tree for user defined types */
		/* this field should carry following information:
		* a) operator : (+,*,/ etc.) for expressions
		* b) statement Type : (WHILE, READ etc.) for statements */
char* NAME; // For Identifiers/Functions
int VALUE; // for constants
//struct Tnode *ArgList; // List of arguments for functions
struct Tnode *Ptr1, *Ptr2, *Ptr3; /* Maximum of three subtrees (3 required for IF THEN ELSE */
struct Gsymbol *Gentry; // For global identifiers/functions
//struct Lsymbol *Lentry; // For Local variables
};

int flag,r;
int error = 0;
struct Tnode*
TreeCreate(int TYPE, int NODETYPE, int VALUE, char* NAME, struct Tnode* Ptr1, struct Tnode* Ptr2, struct Tnode* Ptr3, struct Gsymbol *Gentry){
	struct Tnode *ptr = malloc(sizeof(struct Tnode));
	ptr->TYPE = TYPE;
	ptr->NODETYPE = NODETYPE;
	ptr->VALUE = VALUE;
	ptr->NAME = NAME;
	ptr->Ptr1 = Ptr1;
	ptr->Ptr2 = Ptr2;
	ptr->Ptr3 = Ptr3;	
	ptr->Gentry = Gentry;
	return ptr;
}
/* Sample Global and Local Symbol Table Structure */

/** Symbol Table Entry is required for variables, arrays and functions**/
struct Gsymbol {
char *NAME; // Name of the Identifier
int TYPE; // TYPE can be INTEGER or BOOLEAN
/***The TYPE field must be a TypeStruct if user defined types are allowed***/
int SIZE; // Size field for arrays
int BINDING; // Address of the Identifier in Memory
//ArgStruct *ARGLIST; // Argument List for functions
/***Argstruct must store the name and type of each argument ***/
struct Gsymbol *NEXT; // Pointer to next Symbol Table Entry */
};
struct Gsymbol *ghead = NULL;
struct Gsymbol *gtail = NULL;

struct Gsymbol *lhead = NULL;
struct Gsymbol *ltail = NULL;

struct Gsymbol* Glookup(char* NAME){ // Look up for a global identifier
	struct Gsymbol *var = ghead;
	while(var!=NULL && strcmp(var->NAME,NAME)!=0)
		var = var->NEXT;
	return var;	

}
void Ginstall(char* NAME, int TYPE, int SIZE){ // Installation       ... ARGLIST no need now
	struct Gsymbol* id = Glookup(NAME);
	if(id != NULL){
		error = 1;
		printf("%d ERROR : Re-declaration of \"%s\"  is impossible\n",yylineno,NAME);
		if(SIZE<=0){
			printf("%d ERROR : Array \"%s\" Size should be > 0\n",yylineno,NAME);
		}
		return;
	} 
	if(SIZE>0){
		struct Gsymbol *Entry = malloc(sizeof(struct Gsymbol));
		if (ghead == NULL)
			ghead = Entry;
		else
			gtail->NEXT = Entry;
	
		gtail = Entry;
	
        	Entry->NAME = NAME;
		Entry->TYPE = TYPE;
		Entry->SIZE = SIZE;
		Entry->BINDING = symIndex;symIndex += SIZE;
		Entry->NEXT = NULL;
		return ;
	}
	else{
		error = 1;
		printf("%d ERROR : Array \"%s\" Size should be > 0\n",yylineno,NAME);
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
						if(Ptr2->TYPE == BOOL_TYPE || Ptr3->TYPE == BOOL_TYPE)//Boolean
							crt_type = 0;
						else{ 
							if(Ptr2->TYPE == VOID_TYPE){//Identifier&Function
								if(Ptr2->NODETYPE!=ID_NODETYPE)
									crt_type=0;
								else{
									struct Gsymbol *entry = Ptr2->Gentry;
									if(entry != NULL && entry->TYPE != INT_VAR_TYPE)
										crt_type = 0;
							}}
							if(Ptr3->TYPE == VOID_TYPE){
								if(Ptr3->NODETYPE!=ID_NODETYPE)
									crt_type=0;
								else{
									struct Gsymbol *entry = Ptr3->Gentry;
									if(entry != NULL && entry->TYPE != INT_VAR_TYPE)
										crt_type = 0;
							}}
						}
						if(!crt_type){
							error = 1;
							printf("%d ERROR : Type Mismatch in ARITHMETIC OPERATOR\n",yylineno);return 0;	
						}else
							return 1;				
			case ASG_NODETYPE:
						if(Ptr2->TYPE != VOID_TYPE)
							crt_type = 0;
						else if(Ptr2->NODETYPE != ID_NODETYPE)
							crt_type = 0;
						else{
							struct Gsymbol *entry = Ptr2->Gentry;
							if(entry != NULL && entry->TYPE == INT_VAR_TYPE){
								if(Ptr3->TYPE == BOOL_TYPE)				
									crt_type=0;
								else if(Ptr3->TYPE == VOID_TYPE){
									struct Gsymbol *entry2 = Ptr3->Gentry;
									if(entry2 != NULL && entry2->TYPE == BOOL_VAR_TYPE)
										crt_type = 0;
							}}	
							else if(entry != NULL && entry->TYPE == BOOL_VAR_TYPE){
								if(Ptr3->TYPE == INT_TYPE)				
									crt_type=0;
								else if(Ptr3->TYPE == VOID_TYPE){
									struct Gsymbol *entry2 = Ptr3->Gentry;
									if(entry2 != NULL && entry2->TYPE == INT_VAR_TYPE)
										crt_type = 0;
								}
							}
							else{
								error = 1;
								printf("%d ERROR : %s is undeclared\n",yylineno,Ptr2->NAME);
							}
								
						}
						if(!crt_type){
							error = 1;
							printf("%d ERROR : Type Mismatch in '='\n",yylineno);return 0;
						}else
							return 1;
		}break;
	case BOOL_TYPE:
			switch(Ptr1->NODETYPE){
				case LT_NODETYPE:
				case GT_NODETYPE:
				case LE_NODETYPE:
				case GE_NODETYPE:
				case NE_NODETYPE:
				case EQ_NODETYPE:
							if(Ptr2->TYPE == BOOL_TYPE || Ptr3->TYPE == BOOL_TYPE)	
								crt_type = 0;
							else{ 
								if(Ptr2->TYPE == VOID_TYPE){
									if(Ptr2->NODETYPE != ID_NODETYPE)
										crt_type = 0;
									else{ 
										struct Gsymbol *entry = Ptr2->Gentry;
										if(entry != NULL && entry->TYPE != INT_VAR_TYPE)
											crt_type = 0;
									}
								}
								if(Ptr3->TYPE == VOID_TYPE){
									if(Ptr3->NODETYPE != ID_NODETYPE)
										crt_type = 0;
									else{
										struct Gsymbol *entry = Ptr3->Gentry;
										if(entry != NULL && entry->TYPE != INT_VAR_TYPE)
											crt_type = 0;
									}
							}}
							if(!crt_type){
								error = 1;
								printf("%d ERROR : Type Mismatch in LOGICAL OPERATOR\n",yylineno);return 0;
							}else
								return 1;
				case AND_NODETYPE:
				case OR_NODETYPE:
						if(Ptr2->TYPE == INT_TYPE || Ptr3->TYPE == INT_TYPE) crt_type = 0;
						else{ 
							if(Ptr2->TYPE == VOID_TYPE){
								if(Ptr2->NODETYPE != ID_NODETYPE)
									crt_type = 0;
								else{ 
									struct Gsymbol *entry = Ptr2->Gentry;
									if(entry != NULL && entry->TYPE != BOOL_VAR_TYPE)
										crt_type = 0;
								}
							}
							if(Ptr3->TYPE == VOID_TYPE){
								if(Ptr3->NODETYPE != ID_NODETYPE)
									crt_type = 0;
								else{
									struct Gsymbol *entry = Ptr3->Gentry;
									if(entry != NULL && entry->TYPE != BOOL_VAR_TYPE)
										crt_type = 0;
								}
						}}
						if(!crt_type){
							error = 1;
							printf("%d ERROR : Type Mismatch in RELATIONAL OPERATOR\n",yylineno);return 0;
						}else
							return 1;
				case NOT_NODETYPE:	
						if(Ptr2->TYPE == INT_TYPE)	
							crt_type = 0;
						else{ 
							if(Ptr2->TYPE == VOID_TYPE){
								if(Ptr2->NODETYPE != ID_NODETYPE)
									crt_type = 0;
								else{ 
									struct Gsymbol *entry = Ptr2->Gentry;
									if(entry != NULL && entry->TYPE != BOOL_VAR_TYPE)
										crt_type = 0;
								}
							}
						}
						if(!crt_type){
							error = 1;
							printf("%d ERROR : Type Mismatch in RELATIONAL OPERATOR\n",yylineno);return 0;
						}else
							return 1;				
			}break;
	case VOID_TYPE:
			switch(Ptr1->NODETYPE){
				case IF_NODETYPE:
				case WHILE_NODETYPE:
							if(Ptr2->TYPE == INT_TYPE)
								crt_type = 0;
							else if(Ptr2->TYPE == VOID_TYPE){
								if(Ptr2->NODETYPE != ID_NODETYPE)
									crt_type = 0;
								else{ 
									struct Gsymbol *entry = Ptr2->Gentry;
									if (entry != NULL && entry->TYPE != BOOL_VAR_TYPE)
										crt_type = 0;
								}
							}
							if(!crt_type){
								error = 1;
								if(Ptr1->NODETYPE == IF_NODETYPE)
									printf("%d ERROR : Type Mismatch in IF\n",yylineno);
								else
									printf("%d ERROR : Type Mismatch in WHILE\n",yylineno);
								return 0;
							}else
								return 1;
				case READ_NODETYPE:
							{struct Gsymbol *entry = Ptr2->Gentry;
							if(entry != NULL && entry->TYPE != INT_VAR_TYPE){
								error = 1;
								printf("%d ERROR : Type Mismatch in READ\n",yylineno);
								return 0;
							}else{
								if(entry == NULL){
									error = 1;
									printf("%d ERROR : %s is undeclared\n",yylineno,Ptr2->NAME);
								}
								return 1;
							}}	
				case WRITE_NODETYPE:	if(Ptr2->TYPE == BOOL_TYPE ){
								crt_type=0;
							}else if (Ptr2->TYPE == VOID_TYPE){
								if(Ptr2->NODETYPE != ID_NODETYPE){
									crt_type = 0;
								}else{
									struct Gsymbol *entry = Ptr2->Gentry;
									if (entry != NULL && entry->TYPE == BOOL_VAR_TYPE)
										crt_type=0;
								}
							}
							if(!crt_type){
								error = 1;
								printf("%d ERROR : Type Mismatch in WRITE\n",yylineno);return 0;
							}else
								return 1;
									
			}break;
}
}
#endif
