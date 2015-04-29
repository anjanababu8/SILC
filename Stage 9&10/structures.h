#ifndef STRUCTURES_H
#define STRUCTURES_H
#include <stdio.h>
#include <stdlib.h>

struct Arg { /** ARGUMENT STRUCTURE **/
	char* NAME;
	int TYPE;
	int ISREF;
	int BINDING;
	struct Arg *NEXT;
	struct Arg *PREV;
};
struct Arg *argHead = NULL;
struct Arg *argTail = NULL; 

struct Tnode { /** EXPRESSION TREE NODE STRUCTURE **/
int TYPE; // Integer, Boolean or Void (for statements)
int NODETYPE;/* Must point to the type expression tree for user defined types */
		/* this field should carry following information:
		* a) operator : (+,*,/ etc.) for expressions
		* b) statement Type : (WHILE, READ etc.) for statements */
char* NAME; // For Identifiers/Functions
int VALUE; // for constants
struct Arg *ArgList; // Argument List for functions.Argstruct must store the name and type of each argument ***/
struct Tnode *Ptr1, *Ptr2, *Ptr3; /* Maximum of three subtrees (3 required for IF THEN ELSE */
struct Gsymbol *Gentry; // For global identifiers/functions
struct Lsymbol *Lentry; // For Local variables
struct Tnode* NEXT;
struct Tnode* PREV;
};

struct Gsymbol { /** GLOBAL SYMBOL TABLE STRUCTURE **/
char *NAME; // Name of the Identifier
int TYPE; // TYPE can be INTEGER or BOOLEAN. The TYPE field must be a TypeStruct if user defined types are allowed***/
int SIZE; // Size field for arrays
int BINDING; // Address of the Identifier in Memory
int ISARRAY;
struct Arg *ARGLIST; // Argument List for functions. Argstruct must store the name and type of each argument ***/
struct Gsymbol *NEXT; // Pointer to next Symbol Table Entry */
};
struct Gsymbol *ghead = NULL;
struct Gsymbol *gtail = NULL;

struct Lsymbol { /** LOCAL SYMBOL TABLE - For each function **/
	char *NAME;
	int TYPE;
	int BINDING;
	struct Lsymbol *NEXT;
};
struct Lsymbol *lhead = NULL;
struct Lsymbol *ltail = NULL;
#endif
