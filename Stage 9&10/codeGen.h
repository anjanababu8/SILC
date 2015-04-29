#ifndef CODEGEN_H
#define CODEGEN_H
#include<stdio.h>
#include<stdlib.h>
#include "symboltables.h"
#include "structures.h"
#include "typecheck.h"
extern FILE* outfile;
int count = 0;		// number of reg used  (starts frm 0)
int label = 0;		// number of labels used (starts frm 1)

int getBind(char* varname);
int getReg();
void freeReg(int reg);
int getLabel();

int codeGen(struct Tnode* t);
int codeGenMainEntry(struct Tnode* ptr);
int codeGenFuncEntry(struct Tnode* ptr);

int codeGenMainEntry(struct Tnode* ptr){
	int i;

	fprintf(outfile,"START\n");
	fprintf(outfile,"MOV SP,0\n");			
	for(i = globalVCount; i > 0; --i)
		fprintf(outfile,"PUSH R0\n");

	fprintf(outfile,"PUSH BP\n");
        fprintf(outfile,"MOV BP,SP\n");		
	
	for(i = ptr->VALUE; i > 0; --i)	/** Pushing Local Variables**/
		fprintf(outfile,"PUSH R0\n");

	codeGen(ptr->Ptr1);			/** Code Generation of Body **/
	
	for(i = ptr->VALUE; i > 0; --i)
		fprintf(outfile,"POP R0\n");

	fprintf(outfile,"POP BP\n");		/** Pops the BP Back to BP*/

	for(i = globalVCount; i > 0; --i)
		fprintf(outfile,"POP R0\n");
	fprintf(outfile,"HALT\n");
}
/*SP POINTS TO TOP OF THE STACK(filled block)
  ON PUSH SP INCR BY 1	
*/

int codeGenFuncEntry(struct Tnode* ptr){
	int r,s,i,r1,r2;
	fprintf(outfile,"L%d:\n",ptr->Gentry->BINDING);
	fprintf(outfile,"PUSH BP\n");    /** BP of the caller...to go back to BP of caller stack**/	
	fprintf(outfile,"MOV BP,SP\n");	
		
	for(i=ptr->VALUE;i>0;--i)	/** Push Local Variables on to stack **/
		fprintf(outfile,"PUSH R0\n");

	codeGen(ptr->Ptr1);   /*Body*/
	s = codeGen(ptr->Ptr2);	  /*Return*/

	r1 = getReg(); r2 = getReg();
	fprintf(outfile,"MOV R%d,BP\n",r1);
	fprintf(outfile,"MOV R%d,2\n",r2);  
	fprintf(outfile,"SUB R%d,R%d\n",r1,r2); freeReg(r2);
	fprintf(outfile,"MOV [R%d],R%d\n",r1,s); freeReg(r1); freeReg(s);

	for(i=ptr->VALUE;i>0;--i)
		fprintf(outfile,"POP R0\n");
	fprintf(outfile,"POP BP\n");

	fprintf(outfile,"RET\n\n");

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
					freeReg(r2);
					return r1;}
				case MINUS_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"SUB R%d,R%d\n",r1,r2);
					freeReg(r2);
					return r1;}
				case MUL_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"MUL R%d,R%d\n",r1,r2);
					freeReg(r2);
					return r1;}
		                case DIV_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"DIV R%d,R%d\n",r1,r2);
					freeReg(r2);
					return r1;}
			        case MOD_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"MOD R%d,R%d\n",r1,r2);
					freeReg(r2);
					return r1;}
				case ASG_NODETYPE:{
					
					int loc = getBind(t->Ptr1->NAME);//Register # containing the location
					if(t->Ptr3 == NULL){
						int val   = codeGen(t->Ptr2);
						fprintf(outfile,"MOV [R%d],R%d\n",loc,val); freeReg(val); freeReg(loc);
					}else{
						int val = codeGen(t->Ptr3);
						int rl = codeGen(t->Ptr2);
											
						fprintf(outfile,"ADD R%d,R%d\n",loc,rl); freeReg(rl);
						fprintf(outfile,"MOV [R%d],R%d\n",loc,val); freeReg(val); freeReg(loc);
					}return;}
			}break;
		case BOOL_TYPE:
			 switch(t->NODETYPE){
				case LT_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"LT R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}
				case GT_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"GT R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}	 
				case LE_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"LE R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}
				case GE_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"GE R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}
				case EQ_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"EQ R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}
				case NE_NODETYPE:{ 
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"NE R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}
				case AND_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"MUL R%d,R%d\n",r1,r2); freeReg(r2);
					return r1;}	
				case OR_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r2 = codeGen(t->Ptr2);
					fprintf(outfile,"ADD R%d,R%d\n",r1,r2); freeReg(r2);

					int r = getReg();

					fprintf(outfile,"MOV R%d,%d\n",r,1);
					fprintf(outfile,"GE R%d,R%d\n",r1,r); freeReg(r);
					return r1;}
				case NOT_NODETYPE:{
					int r1 = codeGen(t->Ptr1);
					int r  = getReg();

					fprintf(outfile,"MOV R%d,%d\n",r,1);
					fprintf(outfile,"ADD R%d,R%d\n",r1,r);	
					fprintf(outfile,"MOV R%d,%d\n",r,2);
					fprintf(outfile,"MOD R%d,R%d\n",r1,r); freeReg(r);
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
					int loc = getBind(t->Ptr1->NAME); // Reg # containing the loc of ID
					int r   = getReg();

					fprintf(outfile,"IN R%d\n",r);					

					if(t->Ptr2 == NULL){
						fprintf(outfile,"MOV [R%d],R%d\n",loc,r); freeReg(r); freeReg(loc);
					}else{
						int off = codeGen(t->Ptr2);						
						fprintf(outfile,"ADD R%d,R%d\n",loc,off); freeReg(off);
						fprintf(outfile,"MOV [R%d],R%d\n",loc,r); freeReg(r); freeReg(loc);	
					}return;}
				case WRITE_NODETYPE:{
						int r = codeGen(t->Ptr1);
						fprintf(outfile,"OUT R%d\n",r); freeReg(r);
						return;} 
				case IF_NODETYPE: {
					int l1 = getLabel();
					int l2 = getLabel();

					int r1 = codeGen(t->Ptr1);					
					fprintf(outfile,"JZ R%d,L%d\n",r1,l1); freeReg(r1);

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
					fprintf(outfile,"JZ R%d,L%d\n",r,l2); freeReg(r);

					codeGen(t->Ptr2);
					fprintf(outfile,"JMP L%d\n",l1);
						
					fprintf(outfile,"L%d:\n",l2);
					break;}	 
				case ID_NODETYPE:{
					int r   = getReg();
					int loc = getBind(t->NAME);
					if(t->Ptr1 == NULL){										
						fprintf(outfile,"MOV R%d,[R%d]\n",r,loc); freeReg(loc);
						return r; 
					}else{
						int off = codeGen(t->Ptr1);						
						fprintf(outfile,"ADD R%d,R%d\n",loc,off); freeReg(off);
						fprintf(outfile,"MOV R%d,[R%d]\n",r,loc); freeReg(loc);
						return r;	
					}}
				case FUNCTION_NODETYPE:{  // Function Call
					int i,r,rstackval,rvarloc; i=0;
					
					struct Tnode* func = t;

					while(i<count) /** 1. Push the used Registers**/
						fprintf(outfile,"PUSH R%d\n",i++);				

					struct Tnode* arg = func->Ptr1;;	/* 2. Push the arguments*/
					if(arg != NULL){
						do{
							r = codeGen(arg);	
							fprintf(outfile,"PUSH R%d\n",r); freeReg(r);
							arg = arg->PREV; 		
						}while(arg != NULL);
					}

					int oldcount = count; count = 0;
					fprintf(outfile,"PUSH R0\n");			   /* 3. Push Space for return value */

					struct Lsymbol* oldTable = currentTable;
					currentTable = func->Lentry;
					fprintf(outfile,"CALL L%d\n",func->Gentry->BINDING); /* 4. Call Function */
					currentTable = oldTable;
					
					count = oldcount;
					r = getReg(); /* ON RETURN FROM FUNCTION */
					fprintf(outfile,"POP R%d\n",r);  		   /* 5. POP Return Value to a Register*/
	

					struct Arg* a = Glookup(func->NAME)->ARGLIST;/* 6. POP the arguments*/
					while(a != NULL && a->NEXT != NULL){
						a = a->NEXT;
					}
					struct Tnode* e = func->Ptr1;/* 6. POP the arguments*/
					while(e != NULL && e->PREV != NULL){
						e = e->PREV;
					}
							


					while(a != NULL){
						rstackval = getReg();
						fprintf(outfile,"POP R%d\n",rstackval);
						if(a->ISREF){
							rvarloc = getBind(e->NAME);
							if(e->Ptr1 == NULL){
								fprintf(outfile,"MOV [R%d],R%d\n",rvarloc,rstackval); 
							}else{
								int off = codeGen(e->Ptr1);						
								fprintf(outfile,"ADD R%d,R%d\n",rvarloc,off); freeReg(off);
								fprintf(outfile,"MOV [R%d],R%d\n",rvarloc,rstackval);
							}
							freeReg(rvarloc);
						}
						freeReg(rstackval);
						a = a->PREV;
						e = e->NEXT;
					}	
					i=count-2;
					while(i>=0)				/** 7. Pop the used Registers**/
						fprintf(outfile,"POP R%d\n",i--);

					return r;
					}
			     }break;
	}
}

int getBind(char* varname){//Returns the the reg which contains the location of variable
	struct Lsymbol* lptr = Llookup(currentTable,varname);
	if(lptr != NULL){
		int r = getReg(); int s = getReg();
		fprintf(outfile,"MOV R%d,BP\n",r);
		fprintf(outfile,"MOV R%d,%d\n",s,lptr->BINDING);
		fprintf(outfile,"ADD R%d,R%d\n",r,s); freeReg(s);
		return r;
	}
	struct Gsymbol* gptr = Glookup(varname);
	if(gptr != NULL){	
		int r = getReg();
		fprintf(outfile,"MOV R%d,%d\n",r,gptr->BINDING);
		return r;
	}
}
int getReg(){
	return count++;
}
void freeReg(int reg){
	--count;
}
int getLabel(){
	return ++label;
}
#endif
