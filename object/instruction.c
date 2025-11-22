
/* 
  One instruction in a compiled program
*/


#include <stdio.h>
#include <string.h>
#include "colours.h"
#include "command.h"
#include "charclass.h"
#include "parameter.h"
#include "instruction.h"

//struct Instruction * newInstruction(struct Instruction * ii, enum Command cc) {
void newInstruction(struct Instruction * ii, enum Command cc) {
  ii->command = cc;
  ii->a.datatype = UNSET;
  ii->b.datatype = UNSET;
}

// probably a memcpy of old and new would do the trick
// struct Instruction * copyInstruction(

void copyInstruction(
  struct Instruction * new, struct Instruction * old) {
  //memcpy(new, old, sizeof(new));
  new->command = old->command;
  memcpy(&new->a, &old->a, sizeof(struct Parameter));
  memcpy(&new->b, &old->b, sizeof(struct Parameter));
}


/*
display the instruction with parameters and parameter types.
*/
void debugInstruction(struct Instruction * ii) {

  printf("%s%9s", AQUA, info[ii->command].name);
  printParameter(ii->a);
  printParameter(ii->b);
}
 
/*
 show the instruction in a format suitable for program listings

 Use the escapeSpecial() function below to 
 to display special chars (eg \n \r ...) as escaped sequences
 in a different colour to the rest of the text.
 
 todo:!! 
  write function printParameter() to display a parameter
  with its datatype
*/
void printInstruction(struct Instruction * ii) {
  printf("%s%9s", AQUA, info[ii->command].name);
  if (ii->a.datatype != UNSET) { 
    printParameter(ii->a);
  }
  if (ii->b.datatype != UNSET) { 
    printParameter(ii->b);
  }
} // printInstruction
 
// show the instruction in a format suitable for program listings
// with special chars \n \r etc shown escaped in different colour
void printEscapedInstruction(struct Instruction * ii) {
  printf(" %s%s %s[%s", BLUE, info[ii->command].name, GREY, CYAN);
  if (ii->a.datatype == INT) 
    printf("%d", ii->a.number);
  else if (ii->a.datatype == TEXT) 
    escapeSpecial(ii->a.text, CYAN);
  else if (ii->a.datatype == CLASS) 
    printf("%sclass:%s%s", BROWN, CYAN, classInfo[fnToClass(ii->a.classFn)].name);
  else if (ii->a.datatype == RANGE) 
    printf("%srange:%s%c-%c", BROWN, CYAN, ii->a.range[0], ii->a.range[1]);
  else if (ii->a.datatype == LIST) {
    printf("%slist:", BROWN);
    escapeSpecial(ii->a.list, CYAN);
  }
  // else printf("");
  printf("%s]%s ", GREY, NORMAL);
  // deal with 2nd parameter ii->b ??
}
 
// this is used by saveAssembledProgram() or writeAssembledProgram()
// special and delim chars are escaped, eg: \n \r \] \"
// 
void writeInstruction(struct Instruction * ii, FILE * file) {
  fprintf(file, "%s ", info[ii->command].name);
  switch (ii->a.datatype) {
    case INT:
      fprintf(file, "%d", ii->a.number);
      break;
    case TEXT:
      // special chars \n \r \t \\ and " need to be escaped
      fprintf(file, "\"");
      escapeText(file, ii->a.text);
      fprintf(file, "\"");
      break;
    case CLASS:
      fprintf(file, "[:%s:]", classInfo[fnToClass(ii->a.classFn)].name);
      break;
    case RANGE:
      // todo: check range arguments (escaped characters???)
      // no I dont think ranges should have escaped characters
      fprintf(file, "[%c-%c]", ii->a.range[0], ii->a.range[1]);
      break;
    case LIST:
      // special chars \n \r \t \\ etc and ] need to be escaped
      fprintf(file, "[");
      escapeText(file, ii->a.list);
      fprintf(file, "]");
      break;
    default:
      // no parameter
      // fprintf(file, "");
      break;
  }
  // deal with 2nd parameter, but this is not currently used ....

}
 
// print to file the instruction with a line number and colours 
// this function is used in the validateProgram function to display
// or log program errors. We also need something like this in
// saveAssembledProgram()
// 
void numberedInstruction(
  struct Instruction * instruction, int lineNumber, FILE * file) {
  fprintf(file, "%d: %s ", lineNumber, info[instruction->command].name);
  if (instruction->a.datatype == INT) 
    fprintf(file, "[%d] ", instruction->a.number);
  else if (instruction->a.datatype == TEXT) 
    fprintf(file, "[%s] ", instruction->a.text);
  else printf("[] ");

  if (instruction->b.datatype == INT) 
    fprintf(file, "[%d] ", instruction->b.number);
  else if (instruction->b.datatype == TEXT) 
    fprintf(file, "[%s] ", instruction->b.text);
  else printf("[] ");
  printf("\n");
}
 

