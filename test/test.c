
/* 
 created with the script 'compile.ccode.pss' 
 running on the parse-machine. 
 see http://bumble.sf.net/books/gh/gh.c 
 Compile with something like: 
   gcc -o test somefile.c  
*/ 
#include <stdio.h> 
#include "machine.methods.c" 
// called Main because there is main() in gh.c which 
// I need to clean up/ convert to machine.c 
int Main() { 
  struct Machine * mm; 
  newMachine(mm, stdin, 100, 10); 
start:;
  readChar(mm);
  print(mm);
  print(mm);
  clear(mm);
goto start; 
}
