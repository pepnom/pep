
#ifndef TAPEH
#define TAPEH

/*

 This object represents the "tape" data structure in the 
 parsing virtual machine. A "tape" in this context means an 
 array of character pointers (with memory allocated dynamically).
 Any of the tape cells can be accessed using the "tape pointer"
 (which is also called the "current tape cell"). The tape pointer is
 incremented and decremented with the "++" and "--" machine commands
 as well as the "pop" and "push" stack commands.

HISTORY

  10 august 2019
    separated this 'object' from the file gh.c

*/

// tape capacity refers to number of tape cells not bytes
#define TAPESTARTSIZE 1000 
struct Tape {
  int resizings;  //how many times re-malloced this tape?
  long capacity;  //how many cells in the tape
  struct TapeCell * cells;   // dynamic allocation
  //struct TapeCell cells[TAPESTARTSIZE];   //non dynamic allocation
  int currentCell;
};

// functions relating to tapes

// initialise a tape and initialise each tapecell
// but we dont really need a pointer to a tape to be 
// returned from this function, since there will only be 
// one tape per machine.
void newTape(struct Tape * tape, int cells, int cellSize);

void freeTape(struct Tape * tape);

// if the tape can get more cells, this has to be implemented
//struct Tape * growTape();

// set all cells in the tape to empty 
void clearTape(struct Tape * tape);

// show the contents of the tape, cells, with > showing current cell
void printTape(struct Tape * tape);

// show the contents of the tape around current cell
// add a "context" variable, to see more or less of the tape
void printSomeTape(struct Tape * tape, enum Bool escape);

// same as above, but shows cell capacity. 
void printSomeTapeInfo(struct Tape * tape, enum Bool escape, int context);

// show a detailed display of the tape
void printTapeInfo(struct Tape * tape);

#endif


