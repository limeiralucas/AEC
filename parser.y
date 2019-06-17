%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "headers/structures.h"

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

%type <strVal> statement
%type <strVal> statement_list
%type <strVal> coumpound_statement_list
%type <strVal> function_definition
%type <strVal> primary_statement
%type <strVal> primary_statement_list
%type <strVal> declaration
%type <strVal> assignment

%type <instruction> number
%type <instruction> expression
%type <instruction> function_call

%type <instruction> c_parameter
%type <instruction> parameter
%type <instruction> parameter_list

%type <instruction> c_id
%type <instruction> id_list

%%

assignment
    : ID EQUALS expression {
        char* idDataType = getIdentifierDataType($1);
        if(strcmp(idDataType, $3->dataType)) {
            printf("INVALID MIX EXPRESSION on line %d: \nCan't mix <%s> and <%s> types\n", yylineno, idDataType, $3->dataType);
            exit(0);
        }
        int size = snprintf(NULL, 0, "%s = %s;", $1, $3->value.strValue);
        char* aux = malloc(sizeof(char) * size);
        sprintf(aux, "%s = %s;", $1, $3->value.strValue);
        $$ = aux;
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
    : number { $$ = $1; }
    | function_call {
        $$->value.strValue = $1->value.strValue;
    }
    | ID {
        $$->dataType = getIdentifierDataType($1);
        $$->value.strValue = strdup($1);
    }
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
        if($4->dataType == "int") {
            int size = snprintf(NULL, 0, "%s %s = %d", $1, $2, $4->value.intValue);
            char* aux = malloc(sizeof(char) * size);
            sprintf(aux, "%s %s = %d;", $1, $2, $4->value.intValue);
            $$ = aux;
        } else if ($4->dataType == "float") {
            int size = snprintf(NULL, 0, "%s %s = %f", $1, $2, $4->value.floatValue);
            char* aux = malloc(sizeof(char) * size);
            sprintf(aux, "%s %s = %f;", $1, $2, $4->value.floatValue);
            $$ = aux;
        } else {
            int size = snprintf(NULL, 0, "%s %s = %s", $1, $2, $4->value.strValue);
            char* aux = malloc(sizeof(char) * size);
            sprintf(aux, "%s %s = %s;", $1, $2, $4->value.strValue);
            $$ = aux;
        }
    }
    | DATA_TYPE ID {;}
    ;

c_id
    : COMMA ID {
        $$->dataType = getIdentifierDataType($2);
        $$->value.strValue = $2;
    }
    ;

id_list
    : ID {
        $$ = malloc(sizeof(struct Instruction*));
        $$->dataType = getIdentifierDataType($1);
        $$->value.strValue = strdup($1);
    }
    | id_list c_id {
        $$ = malloc(sizeof(struct Instruction*));
        char* aux = malloc(sizeof(char) * (strlen($1->dataType) + strlen($2->dataType) + 2));
        strcpy(aux, $1->dataType);
        strcat(aux, ",");
        strcat(aux, $2->dataType); 
        $$->dataType = aux;

        int size = snprintf(NULL, 0, "%s, %s", $1->value.strValue, $2->value.strValue);
        char* aux2 = malloc(sizeof(char) * size);
        sprintf(aux2, "%s, %s", $1->value.strValue, $2->value.strValue);
        $$->value.strValue = aux2;
    }
    ;

function_call
    : ID LEFT_PARENTHESIS id_list RIGHT_PARENTHESIS {
        validateFunctionParams($1, $3->dataType);
        $$ = malloc(sizeof(struct Instruction*));
        $$->dataType = getFunctionDataType($1);

        int size = snprintf(NULL, 0, "%s(%s)", $1, $3->value.strValue);
        char* aux = malloc(sizeof(char) * size);
        sprintf(aux, "%s(%s)", $1, $3->value.strValue);
        $$->value.strValue = aux;
    }
    | ID LEFT_PARENTHESIS RIGHT_PARENTHESIS {
        validateFunctionParams($1, "");
        $$ = malloc(sizeof(struct Instruction*));
        $$->dataType = getFunctionDataType($1);
    }
    ;

statement
    : declaration END { $$ = strdup($1); }
    | assignment END { $$ = strdup($1); }
    | function_call END {;}
    ;

statement_list
    : statement {
        $$ = strdup($1);
    }
    | statement_list statement
    ;

coumpound_statement_list
    : LEFT_BRACKET statement_list RIGHT_BRACKET {
        int size = snprintf(NULL, 0, "{%s}", $2);
        char* aux = malloc(sizeof(char) * size);
        sprintf(aux, "{%s}", $2);
        $$ = aux;
    }
    | LEFT_BRACKET RIGHT_BRACKET
    | END
    ;

c_parameter
    : COMMA parameter {
        $$->dataType = $2->dataType;

        char* aux = malloc(sizeof(char) * (strlen($2->dataType) + strlen($2->value.strValue) + 3));
        strcpy(aux, $2->dataType);
        strcat(aux, " ");
        strcat(aux, $2->value.strValue);

        $$->value.strValue = aux;

        free($2);
    }
    ;

parameter
    : DATA_TYPE ID {
        $$->dataType = strdup($1);
        $$->value.strValue = strdup($2);
    }
    ;

parameter_list
    : parameter {
        $$ = malloc(sizeof(struct Instruction*));

        $$->dataType = $1->dataType;
        char* aux = malloc(sizeof(char) * (strlen($1->dataType) + strlen($1->value.strValue) + 3));
        strcpy(aux, $1->dataType);
        strcat(aux, " ");
        strcat(aux, $1->value.strValue);
        
        $$->value.strValue = aux;
    }
    | parameter_list c_parameter {
        $$ = malloc(sizeof(struct Instruction*));
    
        char* aux = malloc(sizeof(char) * (strlen($1->dataType) + strlen($2->dataType) + 2));
        strcpy(aux, $1->dataType);
        strcat(aux, ",");
        strcat(aux, $2->dataType);
        $$->dataType = aux;

        int size = strlen($1->value.strValue) + strlen($2->value.strValue) + 4;
        char* aux2 = malloc(sizeof(char) * size);
        strcpy(aux2, $1->value.strValue);
        strcat(aux2, ",");
        strcat(aux2, $2->value.strValue);
        $$->value.strValue = aux2;
    }
    | {
        $$ = malloc(sizeof(struct Instruction*));
        $$->dataType = "";
        $$->value.strValue = "";
    }
    ;


function_definition
    : DATA_TYPE ID LEFT_PARENTHESIS parameter_list RIGHT_PARENTHESIS coumpound_statement_list {
        storeFunction($2, $1);
        storeParams($2, $4->dataType);

        int size = snprintf(NULL, 0, "%s %s(%s)", $1, $2, $4->value.strValue);
        char* aux = malloc(sizeof(char) * size);
        sprintf(aux, "%s %s(%s)%s", $1, $2, $4->value.strValue, $6);
        
        $$ = aux;
    }
    ;

primary_statement
    : declaration END {
        $$ = $1;
    }
    | function_definition {
        $$ = $1;
    }
    ;

primary_statement_list
    : primary_statement {
        $$ = $1;
    }
    | primary_statement_list primary_statement {
        sprintf($$, "%s\n%s", $1, $2);
    }
    ;

program
    : primary_statement_list {
        freeTables();
        printf("%s\n", $1);
    }
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