// compile.c 

/*
  This file contains functions and data structures used to compile 
  source code (text) into a series of executable 'instructions'
  which run on the virtual machine. The virtual machine is 
  specified in gh.c and loop.c contains a testing program.
*/
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

// include gh.h

// given a text string such as 'push' or P, returns the corresponding
// enumerated constant for that command (or returns INVALID)
enum Command commandFromText(char * text) {
  printf("<dev>"); 
  int ii = ADD;
  while (ii < INVALID) {
    if (strcmp(text, info[ii].name))
      return ii;
    else if ((text[0] == info[ii].abbreviation) && (strlen(text)==1))
      return ii;
    ii++;
  }
  return INVALID;
}

int main() {
  printf("<main>");
  return(0);
}


/*
= Unions

Below... a good example of using a union within a structure 
with a tag. the enum Type could be within the structure like 
this

enum Type { INTS, FLOATS, DOUBLE };
struct S
{
  Type s_type;
  // or enum Type { INTS, FLOATS, DOUBLE } s_type;
  union
  {
    int s_ints[2];
    float s_floats[2];
    double s_double;
  };
};

void do_something(struct S *s)
{
  switch(s->s_type)
  {
    case INTS:  // do something with s->s_ints
      break;

    case FLOATS:  // do something with s->s_floats
      break;

    case DOUBLE:  // do something with s->s_double
      break;
  }
}

= Using function pointers

Some simple examples from stackoverflow

Let's start with a basic function which we will be pointing to:

int addInt(int n, int m) {
    return n+m;
}

First thing, lets define a pointer to a function which receives 2 ints and returns and int:

int (*functionPtr)(int,int);
Now we can safely point to our function:

functionPtr = &addInt;
Now that we have a pointer to the function, lets use it:

int sum = (*functionPtr)(2, 3); // sum == 5
Passing the pointer to another function is basically the same:

int add2to3(int (*functionPtr)(int, int)) {
    return (*functionPtr)(2, 3);
}

// define a function 'tricky' which takes parameter n and
// return a pointer to a function which takes 2 int parameters
int (*tricky(int n))(int, int) {
    printf("Got parameter %d", n);
        int (*functionPtr)(int,int) = &addInt;
            return functionPtr;
            }

use a typedef to simplify the syntax of returning function
pointers

But it's much nicer to use a typedef:

typedef void (*commandFn)(struct Machine *, struct Instruction *);

typedef int (*myFuncDef)(int, int);
// note that the typedef name is indeed myFuncDef

myFuncDef functionFactory(int n) {
    printf("Got parameter %d", n);
        myFuncDef functionPtr = &addInt;
            return functionPtr;
            }
*/
