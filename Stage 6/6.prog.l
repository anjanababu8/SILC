/*Stage 4*/
%{
#include<stdlib.h>
#include<stdio.h>
#include "symboltable.h"
#include "y.tab.h"
%}

%option noyywrap  

%%
"decl"			return DECL;
"enddecl"		return ENDDECL;
"integer"		return INTEGER;
"boolean"		return BOOLEAN;
"main"			return MAIN;
"begin"			return BEGINS;
"end"			return END;
"true"			{yylval.ptr = TreeCreate(BOOL_TYPE, TRUE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return TRUE;}
"false"			{yylval.ptr = TreeCreate(BOOL_TYPE, FALSE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return FALSE;}
"read" 			{yylval.ptr = TreeCreate(VOID_TYPE, READ_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return READ;}
"write"			{yylval.ptr = TreeCreate(VOID_TYPE, WRITE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return WRITE;}
"if" 			{yylval.ptr = TreeCreate(VOID_TYPE, IF_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return IF;}
"then"			return THEN;
"endif" 		return ENDIF;
"while" 		{yylval.ptr = TreeCreate(VOID_TYPE, WHILE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return WHILE;}
"do" 			return DO;
"endwhile" 		return ENDWHILE;
"=="			{yylval.ptr = TreeCreate(BOOL_TYPE, EQ_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return EQ;}
"<"			{yylval.ptr = TreeCreate(BOOL_TYPE, LT_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return LT;}
">"			{yylval.ptr = TreeCreate(BOOL_TYPE, GT_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return GT;}
[+*=]			{
			switch(*yytext){
			    case '+': yylval.ptr = TreeCreate(INT_TYPE, PLUS_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return PLUS;
			    case '*': yylval.ptr = TreeCreate(INT_TYPE, MUL_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return MUL; 
                 	    case '=': yylval.ptr = TreeCreate(INT_TYPE, ASG_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL, NULL); return ASG; 			
			}}
"]"			|
"["			|
[;(){},]		return *yytext; 	
[a-z]+			{char *id =  (char *)malloc(sizeof(yytext));
			 strcpy(id,yytext);
			 yylval.ptr = TreeCreate(VOID_TYPE, ID_NODETYPE, 0, id, NULL, NULL, NULL, NULL, NULL); return ID;}
[0-9]+	 		{yylval.ptr = TreeCreate(INT_TYPE, NUM_NODETYPE, atoi(yytext),NULL, NULL, NULL, NULL, NULL, NULL); return NUM;}
[ \t\n]	 		{}
. 			{}
%%

