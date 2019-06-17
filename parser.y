%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "headers/structures.h"

    extern char Data_Type[50];

    extern void yyerror();
    extern int yylex();
    extern char* yytext;
    extern int yylineno;
    extern FILE* yyin;
%}

%define parse.lac full
%define parse.error verbose

%union {
    int intVal;
    char* dataType;
    char* strVal;
    float floatVal;
    char charVal;
    struct Instruction* instruction;
}

%start program

%token <intVal> INTEGER_LITERAL
%token <floatVal> FLOAT_LITERAL
%token <strVal> STRING_VALUE
%token <strVal> BOOLEAN_LITERAL
            COMMA COLON
            PLUS MINUS TIMES DIVIDE MOD POW 
            ID
            UNARY_MINUS UNARY_PLUS
            AND OR EQUALS LESS_THAN GREATER_THAN EQUALS_THAN BITWISE_AND BITWISE_OR END
            LEFT_BRACKET RIGHT_BRACKET LEFT_PARENTHESIS RIGHT_PARENTHESIS
            IF ELSE FOR WHILE RETURN SWITCH CASE DEFAULT BREAK
%token <dataType> DATA_TYPE
%token <dataType> INT_TYPE FLOAT_TYPE BOOLEAN_TYPE CHAR_TYPE STRING_TYPE VOID_TYPE

%left	PLUS	MINUS
%left	TIMES	DIVIDE    MOD
%right	POW

%type <instruction> number
%type <instruction> expression
%type <instruction> function_call

%type <strVal> c_parameter
%type <strVal> parameter
%type <strVal> parameter_list

%type <strVal> c_id
%type <strVal> id_list

%%

assignment
    : ID EQUALS expression {
        char* idDataType = getIdentifierDataType($1);
        if(strcmp(idDataType, $3->dataType)) {
            printf("INVALID MIX EXPRESSION on line %d: \nCan't mix <%s> and <%s> types\n", yylineno, idDataType, $3->dataType);
            exit(0);
        }
    }
    ;

number:
    FLOAT_LITERAL {
        $$ = malloc(sizeof(struct Instruction*));
        $$->dataType = "float";
        $$->value.floatValue = $1;
    }
    | INTEGER_LITERAL {
        $$ = malloc(sizeof(struct Instruction*));
        $$->dataType = "int";
        $$->value.intValue = $1;
    }
    ;

operator
    : PLUS
    | MINUS
    | TIMES
    | DIVIDE
    | MOD
    | POW
    ;

expression
    : number {;}
    | function_call {;}
    | ID { $$->dataType = getIdentifierDataType($1); }
    | number operator expression {
        if(strcmp($1->dataType, $3->dataType)) {
            printf("INVALID MIX EXPRESSION on line %d: \nCan't mix <%s> and <%s> types\n", yylineno, $1->dataType, $3->dataType);
            exit(0);
        }
        $$->dataType = $1->dataType;
    }
    | ID operator expression {
        char* idDataType = getIdentifierDataType($1);
        if(strcmp(idDataType, $3->dataType)) {
            printf("INVALID MIX EXPRESSION on line %d: \nCan't mix <%s> and <%s> types\n", yylineno, idDataType, $3->dataType);
            exit(0);
        }
        $$->dataType = idDataType;
    }
    ;

declaration
    : DATA_TYPE ID EQUALS expression { 
        if (strcmp($1, $4->dataType)) {
            printf("INVALID TYPE on line %d: \nExpecting <%s>, encountered <%s>\n", yylineno, $1, $4->dataType);
            exit(0);
        }
        storeIdentifier($2, $1);
    }
    | DATA_TYPE ID
    ;

c_id
    : COMMA ID { $$ = getIdentifierDataType($2); }
    ;

id_list
    : ID { $$ = getIdentifierDataType($1); }
    | id_list c_id {
        char* aux = malloc(sizeof(char) * (strlen($1) + strlen($2) + 2));
        strcpy(aux, $1);
        strcat(aux, ",");
        strcat(aux, $2);
        $$ = aux;
    }
    ;

function_call
    : ID LEFT_PARENTHESIS id_list RIGHT_PARENTHESIS {
        validateFunctionParams($1, $3);
        $$->dataType = getFunctionDataType($1);
    }
    | ID LEFT_PARENTHESIS RIGHT_PARENTHESIS {
        validateFunctionParams($1, "");
        $$->dataType = getFunctionDataType($1);
    }
    ;

statement
    : declaration END
    | assignment END
    | function_call END
    ;

statement_list
    : statement
    | statement_list statement
    ;

coumpound_statement_list
    : LEFT_BRACKET statement_list RIGHT_BRACKET
    | LEFT_BRACKET RIGHT_BRACKET
    | END
    ;

c_parameter
    : COMMA parameter { $$ = $2; }
    ;

parameter
    : DATA_TYPE ID { $$ = $1; }
    ;

parameter_list
    : parameter { $$ = $1; }
    | parameter_list c_parameter {
        char* aux = malloc(sizeof(char) * (strlen($1) + strlen($2) + 2));
        strcpy(aux, $1);
        strcat(aux, ",");
        strcat(aux, $2);
        $$ = aux;
    }
    | {$$ = "";}
    ;


function_definition
    : DATA_TYPE ID LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS coumpound_statement_list {
        storeFunction($2, $1);
        storeParams($2, $4);
    }
    ;

primary_statement
    : declaration END
    | function_definition
    ;

primary_statement_list
    : primary_statement
    | primary_statement_list primary_statement
    ;

program
    : primary_statement_list
    |
    ;

%%

int main(int argc, char *argv[]) {
    initSymbolTable();
    yyin = fopen(argv[1], "r");
    
    yyparse();
    printf("No Errors\n");
    fclose(yyin);
    return 0;
}