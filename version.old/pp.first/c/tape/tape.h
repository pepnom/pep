#ifndef TAPE_H
#define TAPE_H

  #define TAPESIZE 10
  #define TAPEGROW 10

  typedef struct
  {
    element * first;      /* the first element in the tape */
    element * last;       /* the last element */
    element * current;    /* the current element */
    long int size;        /* how many elements in the tape */
    int resizings;        /* how many times the tape has been resized */
  } tape;

  tape * createTape(tape *);
  void freeTape(tape *);
  element * incrementTape(tape *);
  element * decrementTape(tape *);
  wchar_t * setCurrentElement(tape *, wchar_t *);
  wchar_t * printTape(wchar_t *, tape *);
  wchar_t * dumpTape(wchar_t *, tape *);
  void showTape(tape *);

#endif
