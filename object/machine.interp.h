
#ifndef MACHINEINTERPH 
#define MACHINEINTERPH
/* 

  code used by the machine when interpreting scripts (but 
  not when running compiled scripts).

*/

enum ExitCode execute(struct Machine * mm, struct Instruction * ii);

#endif

