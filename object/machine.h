
#ifndef MACHINEH 
#define MACHINEH
/* 
The buffer object, which holds the stack and the workspace.
pushing and popping the stack just involves shifting the 
workspace pointer left or right.
*/


// the virtual machine which parses
struct Machine {
  FILE * inputstream;   //source of characters
  int peep;             // next char in the stream, may have EOF
  struct Buffer buffer; //workspace & stack
  struct Tape tape;     
  int accumulator;      // used for counting
  long charsRead;       // how many characters read from input stream
  long lines;           // how many lines already read from input stream 
  enum Bool flag;     // used for tests
  char delimiter;     // eg *, to separate tokens on the stack
  char escape;             // escape character
  struct Program program;  // compiled instructions + ip counter
  char version[64];        // machine version string (eg: "0.1 campania" etc) 
};


// initialise the machine with an input stream 
void newMachine(struct Machine * machine, FILE * input, 
               int tapeCells, int cellSize);

// reset the machine without destroying program 
void resetMachine(struct Machine * machine);

// free all memory associated with the machine.
void freeMachine(struct Machine * mm);

void showStackWorkPeep(struct Machine * mm, enum Bool escape);

// read one character from the input stream and update
// the peep and workspace and other machine registers
// this fuction is used in commands while, whilenot, until, read etc
// returns 0 if end of stream is reached
int readc(struct Machine * mm);

/* display some meta-information about the machine such as
   version, capacites etc 
*/
void printMachineMeta(struct Machine * machine);

void printBufferAndPeep(struct Machine * mm);

void showBufferAndPeep(struct Machine * mm);

/* show core registers of the parsing machine: the stack, the "workspace"
  (like a text accumulator), and the "peep" (the next character in the
  input stream */
void showStackWorkPeep(struct Machine * mm, enum Bool escape);

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
void showMachine(struct Machine * mm, enum Bool escape);

// show state of machine buffers with tape cells
void showMachineWithTape(struct Machine * mm);

// show state of machine buffers with tape cells
void showMachineTapeProgram(struct Machine * mm, int tapeContext);

/* this is mainly for debugging. It shows the capacity of the 
   buffer and its string length */
void printBufferCapacity(struct Machine * mm);

#endif

