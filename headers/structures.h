#include "hash.h"

extern int yylineno;
HashTable* symbolTable;

union ValueUnion {
    int intValue;
    float floatValue;
    char* strValue;
};

struct Instruction {
    char* dataType;
    union ValueUnion value;
};

void initSymbolTable() {
    if(symbolTable == NULL) {
        printf("INIT SYMBOL TABLE\n");
        symbolTable = newHashTable();
    }
}

int isDuplicate(char* identifier) {
    HashNode* item = hashSearch(&symbolTable, identifier);
    if(item != NULL) {
        return 1;
    }
    return 0;
}

char* getIdentifierDataType(char* identifier) {
    HashNode* item = hashSearch(&symbolTable, identifier);
    if(item != NULL) {
        return item->data;
    }
    printf("UNDECLARED VARIABLE %s on line %d\n", identifier, yylineno);
    exit(0);
}

void storeIdentifier(char* identifier, char* identifier_data_type) {
    if(isDuplicate(identifier)) {
        printf("REDECLARATION of identifier %s on line %d\n", identifier, yylineno);
        exit(0);
    }
    HashNode* item = newHashNode(identifier, identifier_data_type);
    hashInsert(&symbolTable, &item);
}