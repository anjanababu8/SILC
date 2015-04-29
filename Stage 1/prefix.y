%{
#include "lex.yy.c"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char s[100];

char *make_expression (char op, const char *left, const char *right)
{
    char buffer[100];   
    sprintf (buffer, "%c %s %s", op, left, right);
    return strdup(buffer);
}

void yyerror(char *str){ fprintf(stderr, "ERROR : %s\n", str);}
int main(){ return yyparse();}
%}

%union{
char *str;
int val;
};

%token <val> NUM
%type <str> expr 
%left '+' '-'
%left '*' '/' '%'

%%
pgm : expr '\n' {printf("\nComplete Answer %s\n",$1);exit(0);};

expr : expr '+' expr {$$ = make_expression ('+', $1, $3);}
     | expr '*' expr {$$ = make_expression ('*', $1, $3);}
     | expr '-' expr {$$ = make_expression ('-', $1, $3);}
     | expr '/' expr {$$ = make_expression ('/', $1, $3);}
     | expr '%' expr {$$ = make_expression ('%', $1, $3);}
     | '('expr')' {$$ = $2;}
     | NUM {sprintf(s, "%d", $1); $$ = strdup(s); };
%%
