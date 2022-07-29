

/*

 Parameters within a compiled instruction within a program. The parameter is
 defined as a union because they may have various data types; text numeric
 etc (eg: a jump to another instruction) hence the need for a union
 structure.
 
*/

#include <stdio.h>
#include <ctype.h>
#include "colours.h"
#include "charclass.h"
#include "parameter.h"

/* this prints a compact display of the parameter suitable
   for including as part of printInstruction(). See showParameter()
   for a longer format */
int printParameter(struct Parameter parameter) {
  // if the parameter is not used, dont print it
  printf(" %s[%s", GREY, CYAN);

  switch (parameter.datatype) {
    case INT:
      printf("%sint:%s%d", BROWN, CYAN, parameter.number);
      break;
    case TEXT:
      printf("%stext:%s", BROWN, CYAN);
      escapeSpecial(parameter.list, CYAN);
      break;
    case CLASS:
      printf("%sclass:%s%s", 
        BROWN, CYAN, classInfo[fnToClass(parameter.classFn)].name);
      break;
    case RANGE:
      printf("%srange:%s%c-%c", BROWN, CYAN, 
        parameter.range[0], parameter.range[1]);
      break;
    case LIST:
      printf("%slist:%s", BROWN, CYAN);
      escapeSpecial(parameter.list, CYAN);
      break;
    case UNSET:
      printf("%sunset:%s", BROWN, CYAN);
      break;
    default:
      printf("%s??error:%s", BROWN, CYAN);
      break;
  }
  printf("%s]%s ", GREY, NORMAL);
  return parameter.datatype;
}


/*
  scans an instruction parameter and stops at the delimiter
  also converts escape sequences such as \n \r to their 
  actual character. The unescaped sequence is stored starting
  at pointer param.
  return the new position in the scan stream. The datatype of 
  the parameter is set by the instructionFromText() function
*/
char * scanParameter(char * param, char * text, int line) { 
  char * nextChar;
  char delimiter;
  char * arg = text;

  if (*arg == 0) return arg;

  // lets skip leading spaces here.
  while(isspace((unsigned char)*arg)) arg++;
  if (*arg == 0) return arg;

  switch (* arg) {
    case '[':
      delimiter = ']';
      break;
    case '{':
      delimiter = '}';
      break;
    case '\'':
      delimiter = '\'';
      break;
    case '"':
      delimiter = '"';
      break;
    default:
      return arg;
      break;
  }

  nextChar = arg+1;
  while ((*nextChar != '\0') && (*nextChar != delimiter)) {
    if (*nextChar == '\\') {
      nextChar++;
        // check \n \t \] \\ etc
      switch (*nextChar) {
        case 'n':
          *param = '\n'; 
          break;
        case 't':
          *param = '\t'; 
          break;
        case 'r':
          *param = '\r'; 
          break;
        case 'f':
          *param = '\f'; 
          break;
        case 'v':
          *param = '\v'; 
          break;
        default:
          // handle all other \\ slash escapes eg \\ \] \"
          *param = *nextChar; 
          break;
      } // switch
    } 
    else {
      *param = *nextChar; 
    }
    *(param+1) = 0;
    nextChar++;
    param++;
  } // while not delimiter

  if (*nextChar != delimiter) {
    printf("%s Warning: %s on line %s%d%s. \n",
      PURPLE, NORMAL, YELLOW, line, NORMAL);
    printf("%s >> %s%s %s\n", BLUE, GREEN, arg, NORMAL);
    printf("  No terminating %s%c%s character for parameter \n",
      YELLOW, delimiter, NORMAL);
  }
  if (*nextChar != '\0') { nextChar++; }
  return nextChar;
} // scanParameter

//----------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

