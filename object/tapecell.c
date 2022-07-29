/*

 One cell in the 'tape' or array of strings. The cells of the 
 tape have a 1-to-1 correspondance to the cells of the stack
 show capacity be characters or bytes??? for new 'bytes' because
 its easier to program

*/

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

#include <stdio.h>
#include <stdlib.h>
#include "tapecell.h"

void newCell(struct TapeCell * cell, int cellSize) {
  cell->text = malloc(cellSize * sizeof(char));
  if(cell->text == NULL) {
    fprintf(stderr, 
      "couldnt allocate memory for cell->text in newCell()\n");
    exit(EXIT_FAILURE);
  }
  cell->text[0] = 0; 
  cell->mark[0] = 0; 
  cell->capacity = cellSize;
  cell->resizings = 0;
}

// not really necessary this func
/*
void freeCell(struct TapeCell * cell) {
  free(cell);
}
*/

// make the tape cell bigger, preserving text (realloc not malloc)
// bug! this function should have a 'minimum' parameter because
// cells contents are set, not added to.
// another bug: the capacity should not be multiplied by
// sizeof char or wchar because cell-capacity should indicate
// how many chars it can hold, not bytes. (but for realloc its ok)
#define TAPECELLGROWFACTOR 50

void growCell(struct TapeCell * cell) {
  long newCapacity = 
    cell->capacity + TAPECELLGROWFACTOR*sizeof(char);
  cell->text = realloc(cell->text, newCapacity);
  if(cell->text == NULL) {
    fprintf(stderr, 
      "couldnt allocate more memory for cell->text in growCell()\n");
    exit(EXIT_FAILURE);
  }
  cell->capacity = newCapacity;
  cell->resizings++;
}

void printTapeCellInfo(struct TapeCell * tc) {
  printf("%s, %ld ", tc->text, tc->capacity); 
}

void printTapeCellLongInfo(struct TapeCell * tc) {
  printf("%s ( capacity=%ld, resizings=%d )", 
    tc->text, tc->capacity, tc->resizings); 
}



