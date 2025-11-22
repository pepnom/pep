
#ifndef CHARCLASSH 
#define CHARCLASSH

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

enum Class {
  ALNUM=0, ALPHA, BLANK, CNTRL, DIGIT, GRAPH, LOWER, PRINTABLE,
  PUNCT, SPACE, UPPER, XDIGIT, NOCLASS };

// contain information about different character classes
struct ClassInformation {
  enum Class class;
  char * name;
  char * description;
  int (* classFn)(int);  // a function pointer for the ctype.h functions
};

extern struct ClassInformation classInfo[];

// given a character class text return the enumerated constant 
enum Class textToClass(const char * text);

// given a pointer to a class function return the class 
// a bit tricky ....
// a func pointer as argument to a function.

//int add2to3(int (*functionPtr)(int, int)) {

enum Class fnToClass(void * func);

// display all valid character classes
void showClasses();

// display help for all character classes, one per line 
void printClasses();

#endif

