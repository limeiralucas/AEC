/**
  @author: Nalbert Gabriel Melo Leal
  @Date: 14/05/2019
  @Last Update: 15/06/2019
  @brief: A hash table to be a simbol table of a compiler writem in C
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INITIAL_SIZE 20000

typedef enum {
  false,
  true
} bool;

typedef struct HashNode {
  char* key;
  char* data;
  struct HashNode* next;
} HashNode;

typedef struct HashTable {
  HashNode** table;
  unsigned int capacity;
} HashTable;

HashTable* newHashTable() {
  HashTable* hash = (HashTable*) malloc(sizeof(HashTable));
  hash->table = (HashNode**) malloc(sizeof(HashNode*) * INITIAL_SIZE);
  hash->capacity = INITIAL_SIZE;

  for(int itable = 0; itable < INITIAL_SIZE; itable++) {
    hash->table[itable] = NULL;
  }

  return hash;
}

HashNode* newHashNode(char* key, char* data) {
  HashNode* node;
  node = malloc(sizeof(HashNode));
  node->key = strdup(key);
  node->data = strdup(data);
  node->next = NULL;

  return node;
}

unsigned int hashChar(char* value) {
  int valueSize = strlen(value);
  unsigned int valueCharSum = 0;
  for(int ivalue = 0; ivalue < valueSize; ivalue++) {
    valueCharSum += value[ivalue];
  }
  return valueCharSum;
}

void hashInsert(HashTable** hashTable, HashNode** node) {
  unsigned int charHash = hashChar((*node)->key);
  unsigned int index = charHash % (*hashTable)->capacity;

  if((*hashTable)->table[index] == NULL) {
    (*hashTable)->table[index] = (*node);
    return;
  }

  HashNode* tempNode = (*hashTable)->table[index];
  for(; tempNode->next != NULL && strcmp((*node)->key, tempNode->key) != 0;) {
    tempNode = tempNode->next;
  }

  if(strcmp(tempNode->key, (*node)->key) == 0) {
    tempNode->data = (*node)->data;
  }
  else {
    tempNode->next = (*node);
  }
}

HashNode* hashSearch(HashTable** hashTable, char* key) {
  unsigned int charHash = hashChar(key);
  unsigned int index = charHash % (*hashTable)->capacity;

  if((*hashTable)->table[index] == NULL) {
    return NULL;
  }
  
  HashNode* nowNode = (*hashTable)->table[index];
  for(; nowNode != NULL && nowNode->key != NULL && strcmp(key, nowNode->key) != 0;) {
    nowNode = nowNode->next;
  }

  if(nowNode != NULL && nowNode->key != NULL && strcmp(nowNode->key, key) == 0) {
    return nowNode;
  }
  else {
    return NULL;
  }
}

HashNode* hashRemove(HashTable** hashTable, char* key) {
  unsigned int charHash = hashChar(key);
  unsigned int index = charHash % (*hashTable)->capacity;

  if((*hashTable)->table[index] == NULL) {
    return NULL;
  }
  
  HashNode* previousNode = NULL;
  HashNode* nowNode = (*hashTable)->table[index];
  for(; nowNode != NULL && nowNode->key != NULL && strcmp(key, nowNode->key) != 0;) {
    previousNode = nowNode;
    nowNode = nowNode->next;
  }

  if(nowNode != NULL && nowNode->key != NULL && strcmp(nowNode->key, key) == 0) {
    if(previousNode != NULL) {
      previousNode->next = nowNode->next;
    }
    else {
      (*hashTable)->table[index] = nowNode->next;
    }
    return nowNode;
  }
  else {
    return NULL;
  }
}

void freeHashMemory(HashTable** hashTable) {
  for(int itable = 0; itable < (*hashTable)->capacity; itable++) {
    if((*hashTable)->table[itable] != NULL) {
      HashNode* nowNode = (*hashTable)->table[itable];
      HashNode* nextNode = NULL;
      for(; nowNode != NULL ;) {
        nextNode = nowNode->next;
        free(nowNode->key);
        free(nowNode->data);
        free(nowNode);
        nowNode = nextNode;
      }
    }
  }
  free((*hashTable)->table);
  free((*hashTable));
}

void printHash(HashTable** hashTable) {
  printf("PRINTANDO HASH TABLE\n");
  for(int itable = 0; itable < (*hashTable)->capacity; itable++) {
    if((*hashTable)->table[itable] != NULL) {
      HashNode* tempNode = (*hashTable)->table[itable];
      for(; tempNode != NULL ;) {
        printf("%s  ->  %s\n", tempNode->key, tempNode->data);
        tempNode = tempNode->next;
      }
    }
  }
}