/* 

  This file along with machine.h implements the virtual parsing 
  machine which is the core of the script language and parsing system.

  The machine consists of a set of component parts which, in some
  cases are implemented in separate files such as buffer.c and 
  tape.c.

  The file machine.interp.c contains functions which are mainly 
  used while using the machine to interpret a script (especially)
  interactively.

SEE ALSO

   machine.h 
     contains the actually structure which represents the virtual machine

   machine.methods.c
     A file which contains functions which correspond to each
     command which can be executed on the virtual parsing machine.
     These functions are not used when interpreting a script, because
     the machine execute(...) command is implemented as a big 
     switch statement. I chose this design with the idea of not slowing
     down the interpreter with unnecessary function calls, but an
     alternative design has advantages; namely that we could use 
     function pointers instead of the switch statement.
     But the functions or 'methods' can be used when
     generating compilable c code with the compile.ccode.pss script.

   machine.interp.c
     machine functions which are required when interpreting a script
     (such as "execute(..)") but which are not required when generating
     compilable c code. The idea of separating these files is to be 
     able to create very small executable programs which parse 
     and compile/transform/translate.

HISTORY

  12 august 2019
    began this file by separating code from the main pep.c file

*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include "colours.h"
#include "tapecell.h"
#include "tape.h"
#include "buffer.h"
#include "command.h"
#include "parameter.h"
#include "instruction.h"
#include "labeltable.h"
#include "program.h"
#include "machine.h"

// initialise the machine with an input stream 
void newMachine(struct Machine * machine, FILE * input, 
               int tapeCells, int cellSize) {
  // set the input stream
  // read the first character into peep??
  machine->inputstream = input; 
  machine->charsRead = 0;
  machine->lines = 0;
  machine->accumulator = 0;
  newTape(&machine->tape, tapeCells, cellSize);  
  newBuffer(&machine->buffer, 40);
  newProgram(&machine->program, 20000);
  machine->peep = fgetc(machine->inputstream); 
  machine->flag = FALSE;
  machine->escape = '\\';
  machine->delimiter = '*';
  strcpy(machine->version, "0.1 campania");
}

// reset the machine without destroying program 
void resetMachine(struct Machine * machine) {
  // rewind the input stream
  rewind(machine->inputstream);
  machine->charsRead = 0;
  machine->lines = 0;
  machine->accumulator = 0;
  clearTape(&machine->tape);
  resetBuffer(&machine->buffer);
  // read the first character into peep
  machine->peep = fgetc(machine->inputstream); 
  machine->flag = FALSE;
  machine->escape = '\\';
  machine->delimiter = '*';
  machine->program.ip = 0;
}

// free all memory associated with the machine.
void freeMachine(struct Machine * mm) {
  freeTape(&mm->tape);
  freeProgram(&mm->program);
  free(mm->buffer.stack);
  return;
}

// read one character from the input stream and update
// the peep and workspace and other machine registers
// this fuction is used in commands while, whilenot, until, read etc
// returns 0 if end of stream is reached, otherwise return the 
// char read no? the until command might need it.

//void showStackWorkPeep(struct Machine * mm, enum Bool escape);

int readc(struct Machine * mm) {
   if (mm->peep == EOF) return 0;
   // not the problem
   //if (feof(mm->inputstream)) return 0;
   //if (ferror(mm->inputstream)) return 0;

   if (strlen(mm->buffer.stack) == mm->buffer.capacity - 2) {
     growBuffer(&mm->buffer, 100);
   }
   // this was a bug when it was placed before growBuffer()
   char * lastc = mm->buffer.workspace + strlen(mm->buffer.workspace);
   *lastc = mm->peep; *(lastc + 1) = '\0';
   
   mm->peep = fgetc(mm->inputstream); 
   mm->charsRead++;
   // start line counting at 1, because that is what is expected
   if (mm->lines == 0) { mm->lines = 1; }
   if (mm->peep == '\n') { mm->lines++; }
   return 1;
}

/* display some meta-information about the machine such as
   version, capacites etc 
*/
void printMachineMeta(struct Machine * machine) {
  char Colour[30]; 
  char date[30];
  char time[30];
  strcpy(Colour, BROWN);
  strcpy(date, "?");
  strcpy(time, "?");
  printf("%s        Machine Version:%s %s \n", 
    Colour, NORMAL, machine->version);
  printf("%s         Character read:%s %ld \n", 
    Colour, NORMAL, machine->charsRead);
  printf("%s       Escape character:%s %c \n", 
    Colour, NORMAL, machine->escape);

  printf("%s         Peep character: %c %s \n", 
    Colour, machine->peep, NORMAL);
  // cant really use escapeSpecial here, because it converts text, not
  // one character...
  // escapeSpecial(, PINK);
  printf("\n");
  printf("%s  Stack token delimiter:%s %c \n", 
    Colour, NORMAL, machine->delimiter);

  /*
  printf("%s                 Flag:%s %d \n", 
    Colour, NORMAL, machine->flag);
  if (machine->flag == FALSE) {
    //strcpy(date, ctime(&machine->compileDate));
  }
  */
}

void printBufferAndPeep(struct Machine * mm) {
  printf("[%ld] Buff:%s Peep:%c \n", 
    mm->buffer.capacity, mm->buffer.stack, mm->peep );
}

void showBufferAndPeep(struct Machine * mm) {
  char peep[20];
  if (mm->peep == EOF) { strcpy(peep, "EOF"); }
  else if (mm->peep == '\n') { strcpy(peep, "\\n"); }
  else if (mm->peep == '\r') { strcpy(peep, "\\r"); }
  else {
    peep[0] = mm->peep; peep[1] = '\0'; 
  }
  printf("[%s%ld%s] Buff[%s%s%s] P[%s%s%s] \n", 
    GREEN, mm->buffer.capacity, NORMAL, 
    YELLOW, mm->buffer.stack, NORMAL, BLUE, peep, NORMAL );
}

/* show core registers of the parsing machine: the stack, the "workspace"
  (like a text accumulator), and the "peep" (the next character in the
  input stream */

void showStackWorkPeep(struct Machine * mm, enum Bool escape) {
  char peep[20];
  if (mm->peep == EOF) { strcpy(peep, "EOF"); }
  else if (mm->peep == '\n') { strcpy(peep, "\\n"); }
  else if (mm->peep == '\r') { strcpy(peep, "\\r"); }
  else {
    peep[0] = mm->peep; peep[1] = '\0'; 
  }

  // uses the %.*s, len, buffer trick to print the stack
  int stackwidth = mm->buffer.workspace - mm->buffer.stack;
  if (escape == TRUE) {

    printf("%s(Buff:%s%ld/%ld +r:%d%s)%s Stack[%s%.*s%s] Work[%s", 
      WHITE, BROWN, 
      strlen(mm->buffer.stack), mm->buffer.capacity, 
      mm->buffer.resizings,
      WHITE, NORMAL, 
      YELLOW, stackwidth, mm->buffer.stack, NORMAL, PURPLE);

    escapeSpecial(mm->buffer.workspace, CYAN);
    printf("%s] Peep[%s%s%s] \n", 
      NORMAL, BLUE, peep, NORMAL );
  } else {
    // uses the %.*s, len, buffer trick to print the stack
    printf("%s(Buff:%s%ld%s)%s Stack[%s%.*s%s] Work[%s%s%s] Peep[%s%s%s] \n", 
      WHITE, BROWN, mm->buffer.capacity, WHITE, NORMAL, 
      YELLOW, stackwidth, mm->buffer.stack, NORMAL, 
      PURPLE, mm->buffer.workspace, NORMAL, 
      BLUE, peep, NORMAL );
  }
}

/*
 display the state of registers of the machine using colours
 This does not show the tape (which is part of the machine) or 
 the program which is also part of the machine. See 
 showMachineTapeProgram() or showMachineWithTape() for that.

 The "escape" parameter determines if whitespace (newlines,
 carriage returns, tabs etc) will be displayed in the format
 "\n \r \t" etc, or just printed normally.  If there are newlines
 in the workspace then the display gets messy. So its just a matter of 
 aesthetics.
*/
void showMachine(struct Machine * mm, enum Bool escape) {
  showStackWorkPeep(mm, escape);
  printf("Acc:%s%d%s Flag:%s%s%s Esc:%s%c%s "
         "Delim:%s%c%s Chars:%s%ld%s Lines:%s%ld%s  \n", 
    GREEN, mm->accumulator, NORMAL, 
    YELLOW, (mm->flag==TRUE?"TRUE":"FALSE"), NORMAL, 
    YELLOW, mm->escape, NORMAL,
    YELLOW, mm->delimiter, NORMAL,
    BLUE, mm->charsRead, NORMAL,
    BLUE, mm->lines, NORMAL);
}

// show state of machine buffers with tape cells
void showMachineWithTape(struct Machine * mm) {
  printf("%s--------- Machine State -----------%s \n", 
    BROWN, NORMAL);
  showMachine(mm, TRUE);
  printf("%s--------- Tape --------------------%s \n", 
    BROWN, NORMAL);
  // true means: escape special character (newlines mainly)
  printSomeTapeInfo(&mm->tape, TRUE, 2);
}

// show state of machine buffers with tape cells
void showMachineTapeProgram(struct Machine * mm, int tapeContext) {
  printSomeProgram(&mm->program, 3);
  printf("%s--------- Machine State -----------%s \n", 
    PURPLE, NORMAL);
  showMachine(mm, TRUE);
  printf("%s--------- Tape --------------------%s \n", 
    PURPLE, NORMAL);
  printSomeTapeInfo(&mm->tape, TRUE, tapeContext);
}

/* this is mainly for debugging. It shows the capacity of the 
   buffer and its string length */
void printBufferCapacity(struct Machine * mm) {
   //incomplete
   printf("buff cap:");
}

//----------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

