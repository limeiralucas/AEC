#include "hash.h"

extern int yylineno;
HashTable* symbolTable;
HashTable* functionTable;
HashTable* paramsTable;

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
        functionTable = newHashTable();
        paramsTable = newHashTable();
    }
}

int isDuplicate(char* identifier, HashTable* hashtable) {
    HashNode* item = hashSearch(&hashtable, identifier);
    if(item != NULL) {
        return 1;
    }
    return 0;
}

char* getDataType(char* identifier, HashTable* hashtable) {
    HashNode* item = hashSearch(&hashtable, identifier);
    if(item != NULL) {
        return item->data;
    }
    printf("UNDECLARED VARIABLE %s on line %d\n", identifier, yylineno);
    exit(0);
}

char* getIdentifierDataType(char* identifier) {
    return getDataType(identifier, symbolTable);
}

char* getFunctionDataType(char* identifier) {
    return getDataType(identifier, functionTable);
}

void store(char* identifier, char* identifier_data_type, HashTable* hashtable) {
     if(isDuplicate(identifier, hashtable)) {
        printf("REDECLARATION of identifier %s on line %d\n", identifier, yylineno);
        exit(0);
    }
    HashNode* item = newHashNode(identifier, identifier_data_type);
    hashInsert(&hashtable, &item);
}

void storeIdentifier(char* identifier, char* identifier_data_type) {
    store(identifier, identifier_data_type, symbolTable);
}

void storeFunction(char* identifier, char* identifier_data_type) {
    store(identifier, identifier_data_type, functionTable);
}

void storeParams(char* identifier, char* params) {
    store(identifier, params, paramsTable);
}

void validateFunctionParams(char* identifier, char* params) {
    char* functionParams = getDataType(identifier, paramsTable);
    if(strcmp(functionParams, params)) {
        printf("INVALID PARAMETERS on line %d:\nExpected (%s), encoutered (%s)\n", yylineno, functionParams, params);
        exit(0);
    }
}

void freeTables() {
    freeHashMemory(&symbolTable);
    freeHashMemory(&functionTable);
    freeHashMemory(&paramsTable);
}