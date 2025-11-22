

/*
 the following enumeration and structure provide information
 about the standard c character classes, defined in ctype.h
 these classes will be used with the TESTCLASS command and
 also with the WHILE command. Parameters for Instructions will
 have a function pointer to the correct class function compiled
 into them, to speed up execution.

 each class corresponds to a "isUpper, isLower etc" function.

*/
      //  fn = &isalnum;

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "colours.h"
#include "charclass.h"

struct ClassInformation classInfo[] = { 
  { ALNUM, "alnum", "alphanumeric like [0-9a-zA-Z]", isalnum},
  { ALPHA, "alpha", "alphabetic like [a-zA-Z]", isalpha},
  { BLANK, "blank", "blank chars, space and tab", isblank},
  { CNTRL, "cntrl", "control chars, ascii 000 to 037 and 177 (del)", iscntrl},
  { DIGIT, "digit", "digits 0-9", isdigit},
  { GRAPH, "graph", "graphical chars same as :alnum: and :punct:", isgraph},
  { LOWER, "lower", "lower case letters [a-z]", islower},
  { PRINTABLE, "print", "printable chars ie :graph: + space", isprint},
  { PUNCT, "punct", "punctuation ie !\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~.", ispunct},
  { SPACE, "space", "all whitespace, eg \\n\\r\\t vert tab, space, \\f", isspace},
  { UPPER, "upper", "upper case letters [A-Z]", isupper},
  { XDIGIT, "xdigit", "hexadecimal digit ie [0-9a-fA-F]", isxdigit,},
  { NOCLASS, "noclass", "", NULL},
};

// given a character class text return the enumerated constant 
enum Class textToClass(const char * text) {
  int ii;
  for (ii = 0; ii < NOCLASS; ii++) {
    if (strncmp(text, classInfo[ii].name, strlen(classInfo[ii].name)) == 0) 
      return ii;
  }
  return NOCLASS;
} 

// given a pointer to a class function return the class 
// a bit tricky ....
// a func pointer as argument to a function.

//int add2to3(int (*functionPtr)(int, int)) {

enum Class fnToClass(void * func) {
  int ii;
  for (ii = 0; ii < NOCLASS; ii++) {
    if (func == classInfo[ii].classFn) return ii;
  }
  return NOCLASS;
} 

// display all valid character classes
void showClasses() {
  printf("%sValid classes are: \n%s", CYAN, NORMAL);
  int ii;
  for (ii = 0; ii < NOCLASS; ii++) {
    if ( ii % 4 == 0 ) printf("\n  ");
    printf("%s%s%s - ", GREEN, classInfo[ii].name, GREY);
  }
  printf("\n");
  printf("%sClasses are used by the commands : \n%s", AQUA, NORMAL);
  printf("%s  while, whilenot and testclass \n%s", AQUA, NORMAL);
  printf("%seg: %s w [:space:] \n%s", BLUE, CYAN, NORMAL);
  printf("  reads the input stream while the peek register \n");
  printf("  is a whitespace character (space, tab, newline etc) \n");
} 

// display help for all character classes, one per line 
void printClasses() {
  printf("%sValid classes are: \n%s", CYAN, NORMAL);
  int ii;
  for (ii = 0; ii < NOCLASS; ii++) {
    printf(" %s%s%s - %s \n", 
      GREEN, classInfo[ii].name, NORMAL, classInfo[ii].description);
    if ( (ii+1) % 14 == 0 ) {
      printf("\n%spress <enter> to continue...%s", CYAN, NORMAL);
      getc(stdin);
    }
  }
  printf("\n");
  printf("%sClasses are used by the commands : \n%s", AQUA, NORMAL);
  printf("%s  while, whilenot and testclass \n%s", AQUA, NORMAL);
  printf("%seg: %s w :space: \n%s", BLUE, CYAN, NORMAL);
  printf("  reads the input stream while the peek register \n");
  printf("  is a whitespace character (space, tab, newline etc) \n");

} 

//-------------------------------
// unit test code

  // compile with gcc -DUNITTEST
  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

