/*Stage 7*/
%{
#include<stdlib.h>
#include<stdio.h>
#include "symboltable7.h"
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
"true"			{yylval.ptr = TreeCreate(BOOL_TYPE, TRUE_NODETYPE, 1 , NULL, NULL, NULL, NULL, NULL); return TRUE;}
"false"			{yylval.ptr = TreeCreate(BOOL_TYPE, FALSE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return FALSE;}
"read" 			{yylval.ptr = TreeCreate(VOID_TYPE, READ_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return READ;}
"write"			{yylval.ptr = TreeCreate(VOID_TYPE, WRITE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return WRITE;}
"if" 			{yylval.ptr = TreeCreate(VOID_TYPE, IF_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return IF;}
"then"			return THEN;
"else"			return ELSE;
"endif" 		return ENDIF;
"while" 		{yylval.ptr = TreeCreate(VOID_TYPE, WHILE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return WHILE;}
"do" 			return DO;
"endwhile" 		return ENDWHILE;
"<="			{yylval.ptr = TreeCreate(BOOL_TYPE, LE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return LE;}
">="			{yylval.ptr = TreeCreate(BOOL_TYPE, GE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return GE;}
"=="			{yylval.ptr = TreeCreate(BOOL_TYPE, EQ_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return EQ;}
"!="			{yylval.ptr = TreeCreate(BOOL_TYPE, NE_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return NE;}
"<"			{yylval.ptr = TreeCreate(BOOL_TYPE, LT_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return LT;}
">"			{yylval.ptr = TreeCreate(BOOL_TYPE, GT_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return GT;}
"&&"			{yylval.ptr = TreeCreate(BOOL_TYPE, AND_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return AND;}	
"||"			{yylval.ptr = TreeCreate(BOOL_TYPE, OR_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return OR;}
"!"			{yylval.ptr = TreeCreate(BOOL_TYPE, NOT_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return NOT;}
[-+*=/%]		{
			switch(*yytext){
			    case '-': yylval.ptr = TreeCreate(INT_TYPE, MINUS_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return MINUS;
			    case '+': yylval.ptr = TreeCreate(INT_TYPE, PLUS_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return PLUS;
			    case '*': yylval.ptr = TreeCreate(INT_TYPE, MUL_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return MUL;
		            case '/': yylval.ptr = TreeCreate(INT_TYPE, DIV_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return DIV;
		            case '%': yylval.ptr = TreeCreate(INT_TYPE, MOD_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return MOD;
                 	    case '=': yylval.ptr = TreeCreate(INT_TYPE, ASG_NODETYPE, 0 , NULL, NULL, NULL, NULL, NULL); return ASG; 			
			}}
"]"			|
"["			|
[;(){},]		return *yytext; 	
[a-zA-Z][a-zA-Z0-9]*	{yylval.ptr = TreeCreate(VOID_TYPE, ID_NODETYPE, 0, strdup(yytext), NULL, NULL, NULL, NULL); return ID;}
[0-9]+	 		{yylval.ptr = TreeCreate(INT_TYPE, NUM_NODETYPE, atoi(yytext),NULL, NULL, NULL, NULL, NULL); return NUM;}
[\n]	 		{++yylineno;}
[ \t]			{}
. 			{}
%%

