
/*

 The compiled program, which is a set or array of instructions.

 Currently the struct Program is a member variable of the Machine
 structure, but this should be the other way around. (a program needs
 a machine to execute on, but a machine does not necessarily need
 a program).

BUGS

  There appears to be a segmentation fault when growing the program.

HISTORY
 
  12 august 2019

    reorganised/separated the code from an "all-in-one" gh.c

*/

/* a prototype declaration, just to stop a gcc compiler 
   warning, because I am using compile() before I define it.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include "colours.h"
#include "command.h"
#include "charclass.h"
#include "parameter.h"
#include "instruction.h"
#include "labeltable.h"
#include "program.h"

//int compile(struct Program *, char *, int, struct Label[]);

void newProgram(struct Program * program, size_t capacity) {
  program->resizings = 0;
  program->count = 0;
  program->ip = 0;
  program->compileTime = -1;
  program->compileDate = -1;
  program->startExecute = -1;
  program->endExecute = -1;
  program->listing = malloc(capacity * sizeof(struct Instruction));
  if(program->listing == NULL) {
    fprintf(stderr, 
      "couldnt allocate memory for program listing newProgram()\n");
    exit(EXIT_FAILURE);
  }
  program->capacity = capacity;
  int ii;
  for (ii = 0; ii < capacity; ii++) {
    newInstruction(&program->listing[ii], UNDEFINED);
  }
  strcpy(program->source, "?");
  memset(program->labelTable, 0, sizeof(program->labelTable));
}

void freeProgram(struct Program * pp) {
  int ii;
  for (ii = 0; ii < pp->capacity; ii++) {
    // If instruction parameters are malloced, as they
    // should be, then we will have to free the associated
    // memory. But at the moment it is static memory allocation.
    //freeInstruction(&program->listing[ii]);
  }
  free(pp->listing);
}

// increase program capacity
// there is a bug in the capacity arithmetic so that 
// on the second realloc 2 instructions are wiped.
// also segmentation fault !!!
void growProgram(struct Program * program, size_t increase) {
  printf("Program listing is growing!!\n");
  program->capacity = program->capacity + increase;
  program->listing = realloc(program->listing, 
    program->capacity * sizeof(struct Instruction));
  if(program->listing == NULL) {
    fprintf(stderr, 
      "couldnt allocate more memory for program listing in growProgram()\n");
    exit(EXIT_FAILURE);
  }
  int ii;
  for (ii = program->count; ii < program->capacity; ii++) {
    newInstruction(&program->listing[ii], UNDEFINED);
  }
}

// insert an instruction at the current ip position 
void insertInstruction(struct Program * program) {
  int ii;
  struct Instruction * thisInstruction;
  if (program->count == program->capacity) {
    printf("no more room in program... \n");
    return;
  }
  for (ii = program->count-1; ii >= program->ip; ii--) {
    thisInstruction = &program->listing[ii]; 
    if (commandType(thisInstruction->command) == JUMPS) {
       // bug!! actually we only increment jumps if 
       // the jump target is after the instruction
       if (thisInstruction->a.number > program->ip) {
         thisInstruction->a.number++;
       }
    }
    //printInstruction(thisInstruction); printf(" \n");
    copyInstruction(&program->listing[ii+1], thisInstruction);   
  }
  newInstruction(&program->listing[program->ip], NOP);
  program->count++;
}

/* print meta information about the program
   This information is part of the Program structure, so
   it is not really meta information, technically.
*/  
void printProgramMeta(struct Program * program) {
  char Colour[30]; 
  char date[30];
  char time[30];
  strcpy(date, "?");
  strcpy(time, "?");
  strcpy(Colour, BROWN);
  printf("%s         Program source:%s %s \n", 
    Colour, NORMAL, program->source);
  printf("%sCapacity (Instructions):%s %ld \n", 
    Colour, NORMAL, program->capacity);
  printf("%s    Memory reallocation:%s %d \n", 
    Colour, NORMAL, program->resizings);
  printf("%s  How many instructions:%s %d \n", 
    Colour, NORMAL, program->count);
  printf("%s    Current instruction:%s %d  instruction:", 
    Colour, NORMAL, program->ip);
  printInstruction(&program->listing[program->ip]);
  printf("\n");
  if (program->compileDate != -1) {
    strcpy(date, ctime(&program->compileDate));
  }
  if (program->compileTime != -1) {
    sprintf(time, "%ld", program->compileTime); 
  }
  printf("%s            Compiled at:%s %s \n", Colour, NORMAL, date);
  printf("%s           Compile time:%s %s milliseconds \n", 
    Colour, NORMAL, time);
}


// print the instructions in a program 
void printProgram(struct Program * program) {
  int ii;
  char key;
  struct Instruction * thisInstruction;
  printf("%sFull Program Listing %s", CYAN, NORMAL);
  printf(" %s(%ssize:%s%d%s ip:%s%d%s cap:%s%lu%s)%s \n", 
    GREY, GREEN, NORMAL, program->count, GREEN, NORMAL,
    program->ip, GREEN, NORMAL, program->capacity, GREY, NORMAL);
  for (ii = 0; ii < program->count; ii++) {
    // page the listing
    if ( (ii+1) % 16 == 0 ) {
      printf("\n%s<enter>%s for more (%sq%s = exit):", 
        AQUA, NORMAL, AQUA, NORMAL);
      key = getc(stdin);
      if (key == 'q') { return; }
      // go back a page? lets not worry about it
      // if (key == 'b') { ii = (((ii-16)>(0))?(ii-16):(0)); } 
    }
    thisInstruction = &program->listing[ii]; 
    if (ii == program->ip) {
      printf("%s%3d> ", YELLOW, ii);
      printInstruction(thisInstruction);
      printf("%s\n", NORMAL);
    }
    else {
      printf("%s%3d:%s ", WHITE, ii, NORMAL);
      printInstruction(thisInstruction);
      printf("%s\n", NORMAL);
    }
  }
}


/* print all the instructions in a compiled program along
   with the labels which were parse from the assembly listing
   This may be handy for debugging jump target problems.
   Some jump targets may be relative, no?? */
void printProgramWithLabels(struct Program * program) {
  int ii;
  char key;
  char * label;
  struct Instruction * thisInstruction;
  printf("%s[Full Program Listing] %s", YELLOW, NORMAL);

  printf(" %s(%ssize:%s%d%s ip:%s%d%s cap:%s%lu%s)%s \n", 
    GREY, GREEN, NORMAL, program->count, GREEN, NORMAL,
    program->ip, GREEN, NORMAL, program->capacity, GREY, NORMAL);

  /* to do better paging, we can change this to a while loop
     and increment ii or set ii=0 (g) ii=max (G) etc */
  for (ii = 0; ii < program->count; ii++) {
    // page the listing
    if ( (ii+1) % 16 == 0 ) {
      printf("\n%s<enter>%s for more (%sq%s = exit) ...", 
        AQUA, NORMAL, AQUA, NORMAL);
      key = getc(stdin);
      // make 'g' go to top, 'G' go to bottom etc
      if (key == 'q') { return; }
      // go back a page here, but how to do it?
      // if (key == 'b') { ii = (((ii-16)>(0))?(ii-16):(0)); } 
    }
    thisInstruction = &program->listing[ii]; 
    // check if there is a label
    
    label = getLabel(ii, program->labelTable);
    if (strlen(label) > 0) {
      printf("%s:\n", label);
    }
    if (ii == program->ip) {
      printf("%s%3d> ", YELLOW, ii);
      printInstruction(thisInstruction);
      printf("%s\n", NORMAL);
    }
    else {
      printf("%s%3d:%s ", WHITE, ii, NORMAL);
      printInstruction(thisInstruction);
      printf("%s\n", NORMAL);
    }
  }
}

// show the program around the ip instruction pointer 
void printSomeProgram(struct Program * program, int context) {
  int ii;
  struct Instruction * thisInstruction;
  int start = program->ip - context;
  int end = program->ip + context;
  if (start < 0) start = 0;
  if (end > program->capacity) end = program->capacity;
  //if (program->ip > end) end = program->ip + 2;
  printf("%sPartial Program Listing%s", CYAN, NORMAL);
  printf(" %s(%ssize:%s%d%s ip:%s%d%s cap:%s%lu%s)%s \n", 
    GREY, GREEN, YELLOW, program->count, GREEN, YELLOW,
    program->ip, GREEN, YELLOW, program->capacity, GREY, NORMAL);
  for (ii = start; ii < end; ii++) {
    thisInstruction = &program->listing[ii]; 
    if (ii == program->ip) {
      printf(" %s%d> ", YELLOW, ii);
      printInstruction(thisInstruction);
      printf("%s\n", NORMAL);
    }
    else {
      printf(" %s%d%s: ", CYAN, ii, NORMAL);
      printInstruction(thisInstruction);
      printf("%s\n", NORMAL);
    }
  }
}

// save the compiled program as assembler to a text file
// we need to escape quotes in arguments !! 
// also need to handle other parameter datatypes such as class,
// range, list etc.

// Line numbers may make modifying the assembly laborious.
void saveAssembledProgram(struct Program * program, FILE * file) {
  int ii;
  fprintf(file, "# Assembly listing \n");
  for (ii = 0; ii < program->count; ii++) {
    //fprintf(file, "%d: ", ii);
    writeInstruction(&program->listing[ii], file);
    fprintf(file, "\n");
  }
  fprintf(file, "# End of program. \n");
  printf("%s%d%s instructions written to file. \n", BLUE, ii, NORMAL);
}

// in some cases it may be useful to have a numbered code listing
void saveNumberedProgram(struct Program * program, FILE * file) {
  int ii;
  fprintf(file, "# Numbered Assembly listing \n");
  for (ii = 0; ii < program->count; ii++) {
    fprintf(file, "%d: ", ii);
    writeInstruction(&program->listing[ii], file);
    fprintf(file, "\n");
  }
  fprintf(file, "# End of program. \n");
  printf("%s%d%s instructions written to file. \n", BLUE, ii, NORMAL);
}

// clear the machines compiled program 
void clearProgram(struct Program * program) {
  int ii;
  for (ii = 0; ii < program->count + 50; ii++) {
    program->listing[ii].command = UNDEFINED;
    program->listing[ii].a.number = 0;
    program->listing[ii].a.datatype = UNSET;
    program->listing[ii].b.number = 0;
    program->listing[ii].b.datatype = UNSET;
  }
  program->count = 0;
  program->ip = 0;
  program->compileTime = -1;
  program->compileDate = 0;
}


/*
 load a program from an assembler listing in a text file 
 uses compile() >> instructionFromText() or parseInstruction() 
 maybe change this to ...(struct Machine * mm, ...) ??.
 The compiled instructions are inserted in the program at position
 "start".
*/
void loadAssembledProgram(struct Program * program, FILE * file, int start) {
  clearProgram(program);
  // this is not robust, we need to deal with very long 
  // instructions using malloc (eg "add <lots of text>")
  char buffer[1000];
  char * line;
  int lineNumber;
  char text[2001];
  clock_t startTime = 0;
  clock_t endTime = 0;

  //int ii = 0;
  int ii = start;
  // build a table of label line numbers
  // printf("Put %s%d%s labels into the jump table. \n", YELLOW, ll, NORMAL);
  // this returns the number of labels found 
  buildJumpTable(program->labelTable, file);

  // printJumpTable(program->labelTable);

  rewind(file);

  //struct Instruction * instruction;

  while (fgets(buffer, 999, file) != NULL) {
    // printf("%s", line);
    line = buffer;
    line[strlen(line) - 1] = '\0';
    text[0] = '\0';
    lineNumber = -1;
    // Trim leading space
    while (isspace((unsigned char)*line)) line++;
    // skip blank lines
    if (*line == 0) continue; 

    // lines starting with # are 1 line comments
    // lines starting with #* are multiline comments (to *#) 
    if (line[0] == '#') {
      if (strlen(line) == 1) continue;
      if (line[1] == '*') {
        
        line = line + 2;
        //printf("multiline comment! %s", line);
        // multiline comment #* ... need to search for next *#
        if(strstr(line, "*#") != NULL) {
          line = strstr(line, "*#") + 2;
        } else {
          // search next lines for *#
          while (fgets(buffer, 999, file) != NULL) {
            line = buffer;
            line[strlen(line) - 1] = '\0';
            if (strstr(line, "*#") != NULL) {
              line = strstr(line, "*#") + 2;
              break;
            }
          }
        }
      } else continue;
    }

    // skip label lines. improve this to trim spaces
    if (line[strlen(line)-1] == ':') continue;

    sscanf(line, "%d: %2000[^\n]", &lineNumber, text);
    //debug: check that the arguments are getting parsed properly
    //printf("parsed - lineNumber=%d, text=%s \n", lineNumber, text);

    if (lineNumber == -1) {
      // if no line number, parse anyway
      sscanf(line, "%s", text);
      // only whitespace on line, so skip it 
      if (text[0] == '\0') { continue; }
      sscanf(line, "%2000[^\n]", text);
    }

    // empty line or just line number, just skip it
    if (*text == 0) continue;
    compile(program, text, ii, program->labelTable);
    ii++;
  } // while
  program->ip = 0;
  endTime = clock();
  program->compileTime = (double)((endTime - startTime)*1000) / CLOCKS_PER_SEC;
  program->compileDate = time(NULL); 

  /*
  printf("Compiled %s%d%s instructions from '%s%s%s' in about %s%ld%s milliseconds \n",
    CYAN, program->count, NORMAL, 
    CYAN, program->source, NORMAL,
    CYAN, program->compileTime, NORMAL);
  */

}



/* extracts the correct values for a parameter from a text argument 
   it returns a pointer to the last character scanned in "args" or 
   else NULL if there is no parameter. */
char * parameterFromText(
  FILE * file, struct Instruction * instruction, struct Parameter * param,
  char * text, int lineNumber, struct Label table[]) {
  char label[64] = "";       // possible jump label
  char charclass[20] = "";   // eg space, alnum, print
  int position;     // calculate how many chars were scanned
  char * next;    
  char * args = text;

  // here check if instruction is a jump (ie jumptrue/false/jump)
  // now check if it already has an integer argument. If not
  // check if 1st argument is a label. If so, convert to line number
  // using jumpTable[] and then convert to offset (line number - current 
  // line/instruction number)

  if (*args == '\0') { return args; }
  while(isspace((unsigned char)*args)) args++;

  // jumps only have one jump parameter. But this is a cludge
  // to suppress an error.
  if ((commandType(instruction->command) == JUMPS)  &&
      (instruction->a.datatype != INT)) {
    // format "jump 32"
    if (1 == sscanf(args, "%d%n", &param->number, &position)) {
      param->datatype = INT;
      return args + position;
    } 
    // format "jump label"
    else if (1 == sscanf(args, "%s%n", label, &position)) {
      // for debugging see the label jump table
      // printJumpTable(table);
      // find the label, 
      int jump = -1;
      jump = getJump(label, table);
      // printf("<label: %s, jump: %d> \n", label, jump);
      if (jump == -1) {
        fprintf(file, "%s Parse Error: %s at instruction %s%d%s. \n",
          PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
        fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, args, NORMAL);
        fprintf(file, " Label '%s%s%s' not found. \n",
          YELLOW, label, NORMAL);
        fprintf(file, 
          " Labels should start line and end with a \n"
          " colon (:). They are case sensitive. Jump targets should\n"
          " not include the colon. Labels cannot start with a number \n"
          " (because it is parsed as a line number).\n"
          " Type '%sjj%s' in interactive mode to see the label table\n",
             GREEN, NORMAL);

        return NULL;
      } else {
        //printf("command: %s \n", info[instruction->command].name);
        //printf("jump target=%d, linenumber=%d\n", jump, lineNumber);

        param->datatype = INT;
        if (instruction->command == JUMP) {
          param->number = jump;
        } else {
          param->number = jump - lineNumber;
        }
      }
      return args + position;
    } 
  }

  // format "jump 32"
  // we need to use this position variable and return it
  // this is because we will call parameterFromText() again, to see
  // there are any more parameters.
  //int pos
  //(1 == sscanf(expression, "%lf%n", &value, &pos))
  if (1 == sscanf(args, "%d%n", &param->number, &position)) {
    param->datatype = INT;
    return args + position;
  } 

  // format "while [:space:]
  else if ((args[0] == '[') && (args[1] == ':')) {
    if (sscanf(args+2, "%20[^:]%n", charclass, &position) == 1) {

      if (textToClass(charclass) == NOCLASS) {
        fprintf(file, "%s Error: %s on line %s%d%s of source file. \n",
          PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
        fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, args, NORMAL);
        fprintf(file, "  The character class %s%s%s is not valid \n",
          YELLOW, charclass, NORMAL);
        return NULL;
      } 

      param->datatype = CLASS;
      param->classFn = classInfo[textToClass(charclass)].classFn;
      // advance scan position past [:text:] format
      return args + position + 4;
    } else {

      fprintf(file, "%s Error: %s on line %s%d%s. \n",
        PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
      fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, args, NORMAL);
      fprintf(file, "  In argument %s%s%s, no character class given \n",
        YELLOW, args, NORMAL);
      return NULL;
    }

  }

  // format "whilenot  [a-z]
  else if ((args[0] == '[') && (args[2] == '-')) {
    param->datatype = RANGE; 
    param->range[0] = args[1];
    param->range[1] = args[3];
    return args+5;
  }
  else if (args[0] == '[') {
    // bracket delimited parameter
    param->datatype = LIST; 
    next = scanParameter(param->list, args, lineNumber);
    return next;
  }
  else if (args[0] == '"') {
    // quote delimited parameter
    param->datatype = TEXT;
    next = scanParameter(param->text, args, lineNumber);
    return next;
  } 
  else if (args[0] == '{') {
    // brace delimited parameter
    param->datatype = TEXT;
    next = scanParameter(param->text, args, lineNumber);
    return next;
  } // what sort of argument

  // print warnings if, for example, jump does not have an integer target
  // checkInstruction(instruction, stdout);
  return args;
}


/*
   fills out an instruction given valid text. Also handles unescaping
   of special characters and delimiter characters
     eg:  add " this \r \t \" \: \\ "
     eg:  while [ghi \];;\\ ]
     
   the line/instruction number parameter is for error messages
   returns -1 when an error occurs
   add struct label table[] jumptable parameter. 
*/
int instructionFromText(
  FILE * file, struct Instruction * instruction, 
  char * text, int lineNumber, struct Label table[]) {
  char command[1001] = "";
  char args[1001] = "";
  //char label[64] = "";       // possible jump label
  //char charclass[20] = "";   // eg space, alnum, print

  sscanf(text, "%1000s %2000[^\n]", command, args);
  //printf("parsed - command=%s, args=%s \n", command, args);

  if (command[0] == '\0') {
    fprintf(file, "%s Parse Error: %s on line %s%d%s \n",
      PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
    fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, text, NORMAL);
    fprintf(file, " Instruction command missing \n");
    return -1;
  }

  if (textToCommand(command) == UNDEFINED) {
    fprintf(file, "%s Parse Error: %s on line %s%d%s. \n",
      PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
    fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, text, NORMAL);
    fprintf(file, " Command %s%s%s is not a valid instruction command \n",
      YELLOW, command, NORMAL);
    return -1;
  }

  instruction->command = textToCommand(command);

  if ((info[instruction->command].args > 0) && (args[0] == '\0')) {
    fprintf(file, "%s Error: %s on line %s%d%s of source file. \n",
      PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
    fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, text, NORMAL);
    fprintf(file, "  Command %s%s%s requires %s%d%s argument(s) but none \n"
           "  is given in the assembly file \n",
      YELLOW, command, NORMAL, 
      YELLOW, info[instruction->command].args, NORMAL);
  }

  char * remainder = parameterFromText(
    file, instruction, &instruction->a, args, lineNumber, table);

  // also check here if the command/instruction actually needs
  // a second parameter. That should save time while compiling.  
  if (instruction->a.datatype != UNSET) {
    //printf("args:%s \n", args);
    //printf("remainder args:%s \n", remainder);
    remainder = parameterFromText(
      file, instruction, &instruction->b, remainder, lineNumber, table);
  }

  if ((info[instruction->command].args == 2) && 
      (instruction->b.datatype == UNSET)) {
    fprintf(file, "%s Error: %s on line %s%d%s of source file. \n",
      PURPLE, NORMAL, YELLOW, lineNumber, NORMAL);
    fprintf(file, "%s >> %s%s %s\n", BLUE, GREEN, text, NORMAL);
    fprintf(file, "  Command %s%s%s requires %s%d%s argument(s) but none \n"
           "  is given in the assembly file \n",
      YELLOW, command, NORMAL, 
      YELLOW, info[instruction->command].args, NORMAL);
    return 1;
  }

  /*
  */
  return 0;
}

// given some instruction text (eg: add "this") compile an instruction into
// the machines program listing. Returns zero on success or a positive integer
// if arguments are invalid.  maybe this should return a pointer to an
// instruction upon success the job of compile is to housekeep the machine.
// the job of instructionFromText() is actually to parse the text into an
// instruction
// change this to struct Program * pp ?? or change 
// loadAssembledProgram to take a machine
int compile(struct Program * program, char * text,
            int pos, struct Label table[]) {
  struct Instruction * ii;
  char command[200];
  char args[1000];
  // pos is where in the program list to put the compiled instruction
  ii = &program->listing[pos];

  if (program->capacity == program->count - 1) {
    growProgram(program, 50);
  }

  // int result = 
  sscanf(text, "%200s %200[^\n]", command, args);

  enum Command com = textToCommand(command);
  if (com == UNDEFINED) {
    printf("Unknown command name %s%s%s \n", BROWN, command, NORMAL);
    printf("on line: %s%s%s at program position %d \n", 
      BROWN, text, NORMAL, pos);
    return 1;
  }
  instructionFromText(stdout, ii, text, pos, table);
  program->count++;

  return 0;
  // 2 argument compilation... to do
} // compile

//---------------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

