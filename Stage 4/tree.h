#ifndef TREE_H
#define TREE_H
#include<stdio.h>
#include<stdlib.h>
int sym[26];

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
#define MUL_NODETYPE	8
#define ASG_NODETYPE	9
#define LT_NODETYPE	10
#define GT_NODETYPE	11
#define EQ_NODETYPE	12

#define TRUE_NODETYPE	13
#define FALSE_NODETYPE  14
/** Sample Expression Tree Node Structure **/
struct Tnode {
int TYPE; // Integer, Boolean or Void (for statements)
int NODETYPE;/* Must point to the type expression tree for user defined types */
		/* this field should carry following information:
		* a) operator : (+,*,/ etc.) for expressions
		* b) statement Type : (WHILE, READ etc.) for statements */
int VALUE; // for constants
char* NAME; // For Identifiers/Functions

//struct Tnode *ArgList; // List of arguments for functions
struct Tnode *Ptr1, *Ptr2, *Ptr3; /* Maximum of three subtrees (3 required for IF THEN ELSE */
struct Gsymbol *Gentry; // For global identifiers/functions
struct Lsymbol *Lentry; // For Local variables
};

struct Tnode* 
TreeCreate(int TYPE, int NODETYPE, int VALUE, char* NAME, struct Tnode* Ptr1, struct Tnode* Ptr2, struct Tnode* Ptr3, struct Gsymbol* Gentry, struct Lsymbol* Lentry){

	struct Tnode *ptr = malloc(sizeof(struct Tnode));
	ptr->TYPE = TYPE;
	ptr->NODETYPE = NODETYPE;
	ptr->VALUE = VALUE;
	ptr->NAME = NAME;
	ptr->Ptr1 = Ptr1;
	ptr->Ptr2 = Ptr2;
	ptr->Ptr3 = Ptr3;
	ptr->Gentry = Gentry;
	ptr->Lentry = Lentry; 	
	return ptr;
}

int Evaluate(struct Tnode* Node){
	if(Node!=NULL){
		switch(Node->TYPE){
			case DUMMY_TYPE: 
					Evaluate(Node->Ptr1); 
					Evaluate(Node->Ptr2); 
					break;
			case INT_TYPE:
			     switch(Node->NODETYPE){				
				case NUM_NODETYPE: return Node->VALUE;
				case PLUS_NODETYPE: return(Evaluate(Node->Ptr1) + Evaluate(Node->Ptr2)); 
				case MUL_NODETYPE: return(Evaluate(Node->Ptr1) * Evaluate(Node->Ptr2));
				case ASG_NODETYPE: sym[*Node->Ptr1->NAME-'a'] = Evaluate(Node->Ptr2); break;
			     }break;
			case BOOL_TYPE: 	
		             switch(Node->NODETYPE){
				case LT_NODETYPE: return(Evaluate(Node->Ptr1) < Evaluate(Node->Ptr2));
				case GT_NODETYPE: return(Evaluate(Node->Ptr1) > Evaluate(Node->Ptr2));
				case EQ_NODETYPE: return(Evaluate(Node->Ptr1) == Evaluate(Node->Ptr2));
			     }break;
			case VOID_TYPE:
			     switch(Node->NODETYPE){
				case READ_NODETYPE: scanf("%d",&sym[*Node->Ptr1->NAME - 'a']); break;
				case WRITE_NODETYPE: printf("%d",Evaluate(Node->Ptr1)); break;
				case IF_NODETYPE: if(Evaluate(Node->Ptr1))
						  	Evaluate(Node->Ptr2);						
				case WHILE_NODETYPE: while(Evaluate(Node->Ptr1))
						     	Evaluate(Node->Ptr2);
				case ID_NODETYPE: return sym[*Node->NAME - 'a'];
			    }break;
		}
	}
}
#endif
