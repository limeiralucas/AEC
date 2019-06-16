%{
    #include <string.h>
    #include <stdlib.h>
    #include "y.tab.h"

    void extern yyerror(char*);
    void InvalidToken();
%}
%%
[ \t]               ;
[\n]                {yylineno++;};
(";")               {yylval.dataType = strdup(yytext); return(END);}

("if")              {yylval.dataType = strdup(yytext); return(IF);}
("else")            {yylval.dataType = strdup(yytext); return(ELSE); }
("for")             {yylval.dataType = strdup(yytext); return(FOR); }
("while")           {yylval.dataType = strdup(yytext); return(WHILE); }
("switch")          {yylval.dataType = strdup(yytext); return(SWITCH); }
("return")          {yylval.dataType = strdup(yytext); return(RETURN); }
("case")            {yylval.dataType = strdup(yytext); return(CASE); }
("default")         {yylval.dataType = strdup(yytext); return(DEFAULT); }
("break")           {yylval.dataType = strdup(yytext); return(BREAK); }

"void"      |
"int"       |
"float"     |
"bool"      |
"string"    |
"char"              {yylval.dataType = strdup(yytext); return DATA_TYPE;}

("true")            return(BOOLEAN_LITERAL);
("false")           return(BOOLEAN_LITERAL);

("+")               return(PLUS);
("-")               return(MINUS);
("*")               return(TIMES);
("**")              return(POW);
("\/")              return(DIVIDE);
("(")               return(LEFT_PARENTHESIS);
(")")               return(RIGHT_PARENTHESIS);
("{")               return(LEFT_BRACKET);
("}")               return(RIGHT_BRACKET);
("=")               return(EQUALS);
("%")               return(MOD);
("++")              return(UNARY_PLUS);
("--")              return(UNARY_MINUS);

("<")               return(LESS_THAN);
(">")               return(GREATER_THAN);
("==")              return(EQUALS_THAN);

(":")               return(COLON);
(",")               return(COMMA);
("and")             return(AND);
("or")              return(OR);
("&")               return(BITWISE_AND);
("|")               return(BITWISE_OR);
[-+]?[0-9]+         {yylval.intVal = atoi(yytext); return INTEGER_LITERAL; }
[-+]?[0-9]*\.?[0-9]+ return(FLOAT_LITERAL);

\"(\\.|[^"])*\"     return(STRING_VALUE);

[a-zA-Z]+           {yylval.dataType = strdup(yytext); return ID;}

.                   {InvalidToken();}
%%

int yywrap(void) {
    return 1;
}

void yyerror(char *s) {
    fprintf(stderr, "\nERROR ON LINE %d : \n %s\n", yylineno, s);
    exit(0);
}

void InvalidToken() {
    printf("ERROR ON LINE %d : \n Invalid Token %s\n", yylineno, yytext);
    exit(0);
}
