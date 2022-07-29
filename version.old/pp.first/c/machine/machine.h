#ifndef MACHINE_H
#define MACHINE_H

  #define TRUE 0
  #define FALSE 1
  #define STACKSIZE 10
  #define STACKGROW 10

  /* -------------------------------------------*/
  typedef struct 
  {
    wint_t peep;          /* the next input character, may contain WEOF */
    buffer buffer;        /* contain the stack and workspace */
    tape tape;            /* an infinite array of strings */
    int counter;          /* an accumulator for counting things */
    //instruction * lastoperation;
  } machine;

    machine * createMachine(machine *);
    void freeMachine(machine *);
    wchar_t * pop(machine *);
    wchar_t * push(machine *);
    wchar_t * put(machine *);
    wchar_t * printMachine(wchar_t *, machine *);
    wchar_t * dumpMachine(wchar_t *, machine *);


#endif

