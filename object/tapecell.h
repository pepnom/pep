
#ifndef TAPECELLH
#define TAPECELLH
/*

 One cell in the 'tape' or array of strings. The cells of the 
 tape have a 1-to-1 correspondance to the cells of the stack
 show capacity be characters or bytes??? for new 'bytes' because
 its easier to program

HISTORY

  13 sept 2019
    starting to add "marks" to tape cells.
  10 august 2019
    separated this 'object' from the file gh.c

*/

#define TAPECELLSIZE 50
struct TapeCell {
  int resizings;      // how many mallocs, for performance issues
  size_t capacity;    // how many characters in this cell? 
  char * text;        // the text content of the cell
  char mark[32];      // "marks" are used to jump to a tapecell 
};

// functions relating to TapeCells
// the sizeof(char) below is unnecessary but will be important
// if this is rewritten for wchar_t

/*
 initialise and allocate text memory for a tape cell
 this function could also allocate memory for the TapeCell
 itself, but should it? eg cell = malloc(sizeof(struct TapeCell))
 Well... if the Tape is not dynamically resized, then it is
 not necessary.
   eg: struct Tape { int capacity; struct TapeCell cells[1000]; }
   will allocate the required memory for the tapecells
*/
void newCell(struct TapeCell * cell, int cellSize);

// make the tape cell bigger, preserving text (realloc not malloc)
// bug! this function should have a 'minimum' parameter because
// cells contents are set, not added to.
// another bug: the capacity should not be multiplied by
// sizeof char or wchar because cell-capacity should indicate
// how many chars it can hold, not bytes. (but for realloc its ok)
#define TAPECELLGROWFACTOR 50
void growCell(struct TapeCell * cell);

void printTapeCellInfo(struct TapeCell * tc);

void printTapeCellLongInfo(struct TapeCell * tc);

#endif
