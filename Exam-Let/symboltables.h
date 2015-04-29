#ifndef SYMBOLTABLES_H
#define SYMBOLTABLES_H
#include <stdio.h>
#include <stdlib.h>
#include "structures.h"

int symIndex = 0;
int globalVCount = 0;
int globalFCount = 0;
int argCount = 0;
int lVariables = 1;

int allow;
int isLet;
struct Lsymbol *currentTable = NULL;
struct Lsymbol* letHead = NULL;
struct Lsymbol* myHead = NULL;
struct Lsymbol* myTail = NULL;

struct Tnode* TreeCreate(int TYPE, int NODETYPE, int VALUE, char* NAME, struct Tnode* Ptr1, struct Tnode* Ptr2, struct Tnode* Ptr3,struct Lsymbol* leth);
void Ginstall(char* NAME, int TYPE, int SIZE, struct Arg *ARGLIST, int ISARRAY);
void Linstall(char* NAME, int TYPE,int BINDING,int SIZE);
struct Gsymbol* Glookup(char* NAME);
struct Lsymbol* Llookup(struct Lsymbol* currentTable, char* NAME);
int typecheck(struct Tnode* Ptr1, struct Tnode* Ptr2,struct Tnode* Ptr3);
void setArgListBinding(struct Arg* head, int count);
void MakeArgList(char* NAME, int type,int isRef);
void ArgLinstall(struct Arg* head,int count);

void setArgListBinding(struct Arg* head, int count){
	while(head != NULL){
		head->BINDING = -1*count-- - 2;
		head = head->NEXT;
	}
}


void MakeArgList(char* name, int type, int isRef){
	struct Arg* arg = malloc(sizeof(struct Arg));
	arg->NAME 	= name;	
	arg->TYPE 	= type;
	arg->ISREF	= isRef;
	if(argHead==NULL){
		argHead = arg;
		arg->PREV = NULL;
	}
	else{
		arg->PREV = argTail; 
		argTail->NEXT = arg;
	}
	arg->NEXT = NULL;
	argTail = arg;	
}

void ArgLinstall(struct Arg* head, int count){
	while(head != NULL){
		Linstall(head->NAME,head->TYPE,-1*count-- -2,1); 	
		head = head->NEXT;
	}
}


struct Tnode* TreeCreate(int TYPE, int NODETYPE, int VALUE, char* NAME, struct Tnode* Ptr1, struct Tnode* Ptr2, struct Tnode* Ptr3,struct Lsymbol* leth){
	struct Tnode *ptr = malloc(sizeof(struct Tnode));
	ptr->TYPE = TYPE;
	ptr->NODETYPE = NODETYPE;
	ptr->VALUE = VALUE;
	ptr->NAME = NAME;
	ptr->Ptr1 = Ptr1;
	ptr->Ptr2 = Ptr2;
	ptr->Ptr3 = Ptr3;	
	ptr->leth = leth;	
	return ptr;
}


/** Symbol Table Entry is required for variables, arrays and functions**/
void Ginstall(char* NAME, int TYPE, int SIZE,struct Arg* ARGLIST,int ISARRAY){
	struct Gsymbol* id = Glookup(NAME);
	if(id != NULL){
		printf("%d ERROR : Re-declaration of \"%s\"  is impossible\n",yylineno,NAME);
		exit(0);
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
		Entry->ISARRAY = ISARRAY;
		Entry->ARGLIST = ARGLIST;
		Entry->NEXT = NULL;
		if(Entry->SIZE == 10000){
			Entry->BINDING = getLabel();
			symIndex++;
			globalFCount++;		
		}else{
			Entry->BINDING = globalVCount;
			symIndex += SIZE;
			globalVCount += SIZE;
		}return ;
	}
	else{
		printf("%d ERROR : Array \"%s\" Size should be > 0\n",yylineno,NAME); exit(0);
	}
	
}

void Linstall(char* NAME, int TYPE, int BINDING,int SIZE){
	if(currentTable != NULL){
		struct Lsymbol* id = Llookup(currentTable,NAME);
		if(id != NULL && !allow){
			printf("%d ERROR : Re-declaration of \"%s\"  is impossible\n",yylineno,NAME);
			exit(0);
		} 
	}
	struct Lsymbol *Entry = malloc(sizeof(struct Lsymbol));
	if (lhead == NULL)
		lhead = Entry;
	else
		ltail->NEXT = Entry;
	ltail = Entry;
	Entry->NAME 	= NAME;
	Entry->TYPE 	= TYPE;
	Entry->BINDING 	= BINDING; 
	Entry->NEXT 	= NULL;
	Entry->SIZE	= SIZE;
	if(Entry->SIZE == 20000){         /*** Added **/
			
			if(myHead==NULL){
				myHead = Entry;
				Entry->PREV = NULL;
			}
			else{
				Entry->PREV = myTail;
				myTail->NEXT = Entry;
			}
			Entry->NEXT = NULL;
			myTail = Entry;
			letHead=Entry;
	}

	currentTable = lhead;
	return ;	
}

struct Gsymbol* Glookup(char* NAME){ 
	struct Gsymbol *var = ghead;
	while(var!=NULL && strcmp(var->NAME,NAME)!=0)
		var = var->NEXT;
	return var;	
}

struct Lsymbol *Llookup(struct Lsymbol* currentTable, char* NAME){
	struct Lsymbol *var = currentTable;
	while(var!=NULL && strcmp(var->NAME,NAME)!=0)
		var = var->NEXT;
	return var;
}

#endif
