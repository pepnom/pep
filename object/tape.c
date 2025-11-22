/*

 the tape: 

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "colours.h"
#include "tapecell.h"
#include "tape.h"

// functions relating to tapes

// initialise a tape and initialise each tapecell
// but we dont really need a pointer to a tape to be 
// returned from this function, since there will only be 
// one tape per machine.
void newTape(struct Tape * tape, int cells, int cellSize) {
  tape->capacity = cells;
  tape->resizings = 0;
  tape->cells = malloc(tape->capacity * sizeof(struct TapeCell));
  if(tape->cells == NULL) {
    fprintf(stderr, 
      "couldnt allocate memory for cells in tape in newTape()\n");
    exit(EXIT_FAILURE);
  }
  int ii;
  for (ii = 0; ii < tape->capacity; ii++) {
    newCell(&tape->cells[ii], cellSize);
  }
  tape->currentCell = 0;
}

void freeTape(struct Tape * tape) {
  //printf("freeing tape....\n");
  int ii;
  for (ii = 0; ii < tape->capacity; ii++) {
    free(tape->cells[ii].text);
  }
  free(tape->cells);
}

/*
// if the tape can get more cells, this has to be implemented
struct Tape * growTape() {
}
*/

// set all cells in the tape to empty 
void clearTape(struct Tape * tape) {
  int ii;
  tape->currentCell = 0;
  for (ii = 0; ii < tape->capacity; ii++) {
     tape->cells[ii].text[0] = '\0';
  }
}

// show the contents of the tape, cells, with > showing current cell
void printTape(struct Tape * tape) {
  int ii;
  for (ii = 0; ii < tape->capacity; ii++) {
    if (ii == tape->currentCell)
      printf("%4d> %s\n", ii, tape->cells[ii].text);
    else 
      printf("%4d: %s\n", ii, tape->cells[ii].text);
  }
}

// show the contents of the tape around current cell
// add a "context" variable, to see more or less of the tape
void printSomeTape(struct Tape * tape, enum Bool escape) {
  int ii;

  int start = tape->currentCell - 3;
  int end = tape->currentCell + 3;
  if (start < 0) start = 0;
  if (end > tape->capacity) end = tape->capacity;

  printf("Tape Size: %ld \n", tape->capacity);
  for (ii = start; ii < end; ii++) {
    if (escape == TRUE) {
      if (ii == tape->currentCell) {
        printf(" %s%3d> [", YELLOW, ii);
        escapeSpecial(tape->cells[ii].text, CYAN);
        printf("%s]%s\n", YELLOW, NORMAL);
      } else { 
        printf(" %s%3d%s  [", BLUE, ii, NORMAL);
        escapeSpecial(tape->cells[ii].text, CYAN);
        printf("%s]\n", NORMAL);
      }
    } else {
      if (ii == tape->currentCell) {
        printf(" %s%3d> [%s]%s\n", 
          YELLOW, ii, tape->cells[ii].text, NORMAL);
      } else { 
        printf(" %s%3d%s  [%s]%s\n", 
          BLUE, ii, NORMAL, tape->cells[ii].text, NORMAL);
      }

    }
  }
}

// same as above, but shows cell capacity. 
void printSomeTapeInfo(struct Tape * tape, enum Bool escape, int context) {
  int ii;

  // use context
  int start = tape->currentCell - context;
  int end = tape->currentCell + context;
  if (start < 0) { end = end - start; start = 0; }
  if (end > tape->capacity) end = tape->capacity;

  printf("Tape Size: %ld \n", tape->capacity);
  for (ii = start; ii < end; ii++) {
    if (escape == TRUE) {
      if (ii == tape->currentCell) {
        printf(" %s%3ld/%-3ld%s)%s%3d> [", 
          BROWN, strlen(tape->cells[ii].text), tape->cells[ii].capacity, 
          GREY, YELLOW, ii);
        escapeSpecial(tape->cells[ii].text, CYAN);
        printf("%s] %s%s\n", YELLOW, tape->cells[ii].mark, NORMAL);
      } else { 
        printf(" %s%3ld/%-3ld%s)%s%3d%s  [", 
          BROWN, strlen(tape->cells[ii].text), tape->cells[ii].capacity, 
          GREY, BLUE, ii, GREEN);
        escapeSpecial(tape->cells[ii].text, CYAN);
        printf("%s] %s\n", NORMAL, tape->cells[ii].mark);
      }
    } else {
      if (ii == tape->currentCell) {
        printf(" %s%3ld/%-3ld%s)%s%3d> [%s] %s%s\n", 
          BROWN, strlen(tape->cells[ii].text), tape->cells[ii].capacity, 
          GREY, YELLOW, ii, tape->cells[ii].text, 
          tape->cells[ii].mark, NORMAL);
      } else { 
        printf(" %s%3ld/%-3ld%s)%s%3d%s  [%s] %s\n", 
          BROWN, strlen(tape->cells[ii].text), tape->cells[ii].capacity, 
          GREY, BLUE, ii, NORMAL, tape->cells[ii].text,
          tape->cells[ii].mark);
      }
    }
  }
}

// show a detailed display of the tape
void printTapeInfo(struct Tape * tape) {
  int ii;
  char key;
  printf("Tape Size: %ld \n", tape->capacity);
  for (ii = 0; ii < tape->capacity; ii++) {
    if (ii == tape->currentCell)
      printf(" %s%ld%s) %s%3d> [%s]%s\n", 
        BROWN, tape->cells[ii].capacity, GREY, 
        YELLOW, ii, tape->cells[ii].text, NORMAL);
    else 
      printf(" %s%ld%s) %s%3d%s  [%s]\n", 
        BROWN, tape->cells[ii].capacity, GREY, 
        BLUE, ii, NORMAL, tape->cells[ii].text);
    if ( (ii+1) % 14 == 0 ) {
      pagePrompt();
      key = getc(stdin);
      if (key == 'q') { return; }
    }
  }
}


//----------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

