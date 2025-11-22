#ifndef BUFFERH 
#define BUFFERH
/* 
The buffer object, which holds the stack and the workspace.
pushing and popping the stack just involves shifting the 
workspace pointer left or right.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "colours.h"

struct Buffer {
  int resizings;
  size_t capacity;
  char * workspace;  
  char * stack;
};

/* returns the current capacity of the workspace buffer.
This is important during virtual machine instructions such
as "get" and "put" because it allows us to know if we need to
do a malloc etc. */
size_t workspaceCapacity(struct Buffer * buffer);

int endsWith(const char *str, const char *suffix);

/* replace one substring with other text in a string. store the result
   in result. The "result" buffer needs to be big enough, otherwise
   bad things will happen */
void replaceString(
  char * result, char * target, const char *needle, const char *replacement);
  
#define BUFFERSTARTSIZE 1000 

void newBuffer(struct Buffer * buffer, int size);

void clearBuffer(struct Buffer * buffer);

/* just like clearBuffer but also sets buffer size to
   original */
void resetBuffer(struct Buffer * buffer);

// make the workspace/stack buffer bigger in the machine
void growBuffer(struct Buffer * buffer, int increase);

// show the state of the buffer for debugging
void showBufferInfo(struct Buffer * buffer);

// display buffer   
void showBuffer(struct Buffer * buffer);

#endif
