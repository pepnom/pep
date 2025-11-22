
/* 

 The buffer object, which holds the stack and the workspace.
 Pushing and popping the stack just involves shifting the 
 workspace pointer left or right to the next stack delimiter
 character (which is by default '*'). 

 The stack buffer is just the start of the buffer (and is not
 zero terminated). The workspace buffer immediately follows
 the stack buffer.

 The "peep" register (the next, unread, character in the input
 stream) is a separate variable.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "colours.h"
#include "buffer.h"

/* returns the current capacity of the workspace buffer.
This is important during virtual machine instructions such
as "get" and "put" because it allows us to know if we need to
do a malloc etc. */
size_t workspaceCapacity(struct Buffer * buffer) {
  size_t diff = buffer->workspace - buffer->stack;
  return buffer->capacity - diff - 1;
}

int endsWith(const char *str, const char *suffix) {
  if (!str || !suffix) return 0;
  size_t lenstr = strlen(str);
  size_t lensuffix = strlen(suffix);
  if (lensuffix >  lenstr) return 0;
  return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}

/* replace one substring with other text in a string. store the result
   in result. The "result" buffer needs to be big enough, otherwise
   bad things will happen */
void replaceString(
  char * result, char * target, const char *needle, const char *replacement) {
  //char buffer[1024] = { 0 };
  //char * insertPoint = &buffer[0];
  char * insertPoint = result;
  const char * temp = target;
  size_t lengthNeedle = strlen(needle);
  size_t lengthReplacement = strlen(replacement);

  while (1) {
    const char * p = strstr(temp, needle);
    // walked past last occurrence of needle; copy remaining part
    if (p == NULL) {
      strcpy(insertPoint, temp);
      break;
    }

    // copy part before needle
    memcpy(insertPoint, temp, p - temp);
    insertPoint += p - temp;

    // copy replacement string
    memcpy(insertPoint, replacement, lengthReplacement);
    insertPoint += lengthReplacement;
    // adjust pointers, move on
    temp = p + lengthNeedle;
  }
}

#define BUFFERSTARTSIZE 1000 
void newBuffer(struct Buffer * buffer, int size) {
  buffer->stack = malloc(size * sizeof(char));
  if(buffer->stack == NULL) {
    fprintf(stderr, 
      "couldnt allocate memory for stack/workspace in newBuffer()\n");
    exit(EXIT_FAILURE);
  }
  buffer->workspace = buffer->stack;
  buffer->stack[0] = '\0';
  buffer->workspace[0] = '\0';
  buffer->resizings = 0;
  buffer->capacity = size - 1;  // one less for \0
}

void clearBuffer(struct Buffer * buffer) {
  buffer->workspace = buffer->stack;
  buffer->stack[0] = '\0';
  buffer->resizings = 0;
}

/* just like clearBuffer but also sets buffer size to
   original */
void resetBuffer(struct Buffer * buffer) {
  newBuffer(buffer, 40);
}

// make the workspace/stack buffer bigger in the machine
void growBuffer(struct Buffer * buffer, int increase) {
  int offset = buffer->workspace - buffer->stack;
  long newCapacity = 
    buffer->capacity + increase + 1*sizeof(char);
  buffer->stack = realloc(buffer->stack, newCapacity);
  if(buffer->stack == NULL) {
    fprintf(stderr, 
      "couldnt allocate more memory for buffer in growBuffer()\n");
    exit(EXIT_FAILURE);
  }
  buffer->workspace = buffer->stack + offset;
  buffer->resizings++;
  buffer->capacity = newCapacity - 1;
}

// show the state of the buffer for debugging
void showBufferInfo(struct Buffer * buffer) {
  printf("%scapacity: %s%ld%s \n", 
    GREEN, PURPLE, buffer->capacity, NORMAL );
  printf("%sresizings: %s%d%s \n", 
    GREEN, PURPLE, buffer->resizings, NORMAL );
    //%.*s
    // not sure how to do this
  //printf("%sstack: %s%.*s%s \n", 
  //  GREEN, PURPLE, buffer.workspace - buffer.stack, NORMAL );
  printf("%sworkspace: %s%s%s \n", 
    GREEN, PURPLE, buffer->workspace, NORMAL );
  // show capacity, resizings, value of stack, of workspace
  // etc
}

// display buffer   
void showBuffer(struct Buffer * buffer) {
  printf("capacity: %ld \n", buffer->capacity);
  // show capacity, resizings, value of stack, of workspace
  // etc
}

//----------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

