#ifndef PROGRAMH 
#define PROGRAMH 

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

#define PROGRAMCAPACITY 500
struct Program {
  // date and time when compiled 
  time_t compileDate; 
  // how long program took to compile (milliseconds), timed with clock() ?
  clock_t compileTime;
  // starting to execute
  int startExecute;  
  // time ended executing
  int endExecute;   
  // whether new compiled instructions are appended to the 
  // program (after count), inserted after IP or overwrite from ip
  // ??? necessary.
  enum CompileMode {APPEND, INSERT, OVERWRITE} compileMode; 
  // how much room for instructions
  size_t capacity;   
  // how many times has program memory been reallocated
  int resizings;
  //how many instructions are in the program
  int count;         
  //current instruction (next to be executed)
  int ip;            
  // the set of program instructions (dynamically allocated)
  struct Instruction * listing;  
  // if applicable, name of assembly file containing instructions  
  char source[128];

  // an array of line labels and line numbers from assembly listing
  struct Label labelTable[256];

  // static allocation of memory for instructions
  // struct Instruction listing[PROGRAMCAPACITY]; 
};

/* a prototype declaration, just to stop a gcc compiler 
   warning, because I am using compile() before I define it.
*/
int compile(struct Program *, char *, int, struct Label[]);

void newProgram(struct Program * program, size_t capacity);

void freeProgram(struct Program * pp);

// increase program capacity
// there is a bug in the capacity arithmetic so that 
// on the second realloc 2 instructions are wiped.
// also segmentation fault !!!
void growProgram(struct Program * program, size_t increase);

// insert an instruction at the current ip position 
void insertInstruction(struct Program * program);

/* print meta information about the program
   This information is part of the Program structure, so
   it is not really meta information, technically.
*/  
void printProgramMeta(struct Program * program);

// print the instructions in a program 
void printProgram(struct Program * program);

/* print all the instructions in a compiled program along
   with the labels which were parsed from the assembly listing
   This may be handy for debugging jump target problems.
   Some jump targets may be relative, no?? */
void printProgramWithLabels(struct Program * program);

// show the program around the ip instruction pointer 
void printSomeProgram(struct Program * program, int context);

// save the compiled program as assembler to a text file
// we need to escape quotes in arguments !! 
// also need to handle other parameter datatypes such as class,
// range, list etc.

// Line numbers may make modifying the assembly laborious.
void saveAssembledProgram(struct Program * program, FILE * file);

// in some cases it may be useful to have a numbered code listing
void saveNumberedProgram(struct Program * program, FILE * file);

// clear the machines compiled program 
void clearProgram(struct Program * program);

void loadAssembledProgram(struct Program * program, FILE * file, int start);

char * parameterFromText(
  FILE * file, struct Instruction * instruction, struct Parameter * param,
  char * text, int lineNumber, struct Label table[]);

int instructionFromText(
  FILE * file, struct Instruction * instruction, 
  char * text, int lineNumber, struct Label table[]);

int compile(struct Program * program, char * text,
            int pos, struct Label table[]);

#endif

