
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
    /* read */ 
    if (mm->peep == EOF) { break; } else { readChar(mm); }
    if (workspaceInClass(mm, "alpha")) {
      whilePeepInClass(mm, "alpha");
      put(mm);
      if ((strcmp(mm->buffer.workspace, "the") == 0) || (strcmp(mm->buffer.workspace, "a") == 0) || (strcmp(mm->buffer.workspace, "one") == 0) || (strcmp(mm->buffer.workspace, "some") == 0) ) { 
        mm->buffer.workspace[0] = '\0';
        add(mm, "article*");
        push(mm);
        goto parse;
      }
      if ((strcmp(mm->buffer.workspace, "big") == 0) || (strcmp(mm->buffer.workspace, "blue") == 0) || (strcmp(mm->buffer.workspace, "beautiful") == 0) || (strcmp(mm->buffer.workspace, "small") == 0) ) { 
        mm->buffer.workspace[0] = '\0';
        add(mm, "adjective*");
        push(mm);
        goto parse;
      }
      if ((strcmp(mm->buffer.workspace, "dog") == 0) || (strcmp(mm->buffer.workspace, "house") == 0) || (strcmp(mm->buffer.workspace, "horse") == 0) || (strcmp(mm->buffer.workspace, "girl") == 0) || (strcmp(mm->buffer.workspace, "fish") == 0) ) { 
        mm->buffer.workspace[0] = '\0';
        add(mm, "noun*");
        push(mm);
        goto parse;
      }
      if ((strcmp(mm->buffer.workspace, "runs") == 0) || (strcmp(mm->buffer.workspace, "eats") == 0) || (strcmp(mm->buffer.workspace, "sleeps") == 0) || (strcmp(mm->buffer.workspace, "is") == 0) ) { 
        mm->buffer.workspace[0] = '\0';
        add(mm, "verb*");
        push(mm);
        goto parse;
      }
      put(mm);
      mm->buffer.workspace[0] = '\0';
      add(mm, "<");
      get(mm);
      add(mm, ">");
      add(mm, " Sorry, don't understand that word! \n");
      printf("%s", mm->buffer.workspace);
      mm->buffer.workspace[0] = '\0';
      exit(EXECQUIT); // quit
    }
    mm->buffer.workspace[0] = '\0';
    parse:;
    pop(mm);
    pop(mm);
    if (strcmp(mm->buffer.workspace, "article*noun*") == 0) {
      mm->buffer.workspace[0] = '\0';
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      put(mm);
      mm->buffer.workspace[0] = '\0';
      add(mm, "nounphrase*");
      push(mm);
      goto parse;
    } 
    pop(mm);
    if (strcmp(mm->buffer.workspace, "article*adjective*noun*") == 0) {
      mm->buffer.workspace[0] = '\0';
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      put(mm);
      mm->buffer.workspace[0] = '\0';
      add(mm, "nounphrase*");
      push(mm);
      goto parse;
    } 
    if (strcmp(mm->buffer.workspace, "nounphrase*verb*noun*") == 0) {
      mm->buffer.workspace[0] = '\0';
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      put(mm);
      mm->buffer.workspace[0] = '\0';
      add(mm, "sentence*");
      push(mm);
      goto parse;
    } 
    if (strcmp(mm->buffer.workspace, "noun*verb*noun*") == 0) {
      mm->buffer.workspace[0] = '\0';
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      add(mm, " ");
      increment(mm);
      get(mm);
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      /* -- */ 
      if (mm->tape.currentCell > 0) mm->tape.currentCell--; 
      put(mm);
      mm->buffer.workspace[0] = '\0';
      add(mm, "sentence*");
      push(mm);
      goto parse;
    } 
    push(mm);
    push(mm);
    push(mm);
    if (mm->peep == EOF) {
      pop(mm);
      if (strcmp(mm->buffer.workspace, "sentence*") == 0) {
        mm->buffer.workspace[0] = '\0';
        add(mm, "its a english sentence! (");
        get(mm);
        add(mm, ") \n");
        printf("%s", mm->buffer.workspace);
        mm->buffer.workspace[0] = '\0';
        exit(EXECQUIT); // quit
      } 
      if (strcmp(mm->buffer.workspace, "nounphrase*") == 0) {
        mm->buffer.workspace[0] = '\0';
        add(mm, "its a noun-phrase! (");
        get(mm);
        add(mm, ") \n");
        printf("%s", mm->buffer.workspace);
        mm->buffer.workspace[0] = '\0';
        exit(EXECQUIT); // quit
      } 
      push(mm);
      add(mm, "nope, not a sentence. \n");
      printf("%s", mm->buffer.workspace);
      mm->buffer.workspace[0] = '\0';
      exit(EXECQUIT); // quit
    }
  } 
} // main 
