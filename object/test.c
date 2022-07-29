
/* 
 created with the script 'compile.ccode.pss' 
 running on the parse-machine. 
 see http://bumble.sf.net/books/gh/object/gh.c 
*/ 
#include <stdio.h> 
#include <string.h> 
#include <time.h> 
#include "colours.h" 
#include "tapecell.h" 
#include "tape.h"  
#include "buffer.h" 
#include "charclass.h" 
#include "command.h" 
#include "parameter.h" 
#include "instruction.h" 
#include "labeltable.h" 
#include "program.h" 
#include "machine.h" 
#include "exitcode.h" 
#include "machine.methods.h" 
int main() { 
  struct Machine machine; 
  struct Machine * mm = &machine; 
  newMachine(mm, stdin, 100, 10); 
  for (;;) { 
    if (mm->peep == EOF) { break; } else { readChar(mm); }
    nop(mm);
    print(mm);
    print(mm);
    clear(mm);
  } 
} // main 
