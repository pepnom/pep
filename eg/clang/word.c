

 /* c code generated by "tr/translate.c.pss" */
 /* note: this c engine cannot handle unicode! */
#include <stdio.h> 
#include <string.h>
#include <time.h> 
#include <ctype.h> 
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

  script: 
  while (!mm->peep != EOF) {
    if (mm->peep == EOF) { break; } else { readChar(mm); }  /* read */
    // ignore \r
    if (workspaceInClassType(mm, "[\r]")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      if (mm->peep == EOF) {
        goto parse;
      }
      continue;
    }
    // dont tokenize non-leading space. One space will be printed
    // between each word.
    if (workspaceInClassType(mm, "[ \t\f]")) {
      while ((strchr(" \t\f", mm->peep) != NULL) && readc(mm)) {}  /* while */
      mm->buffer.workspace[0] = '\0';      /* clear */
      if (mm->peep == EOF) {
        goto parse;
      }
      continue;
    }
    if (workspaceInClassType(mm, "[\n]")) {
      // make character count relative to line.
      mm->charsRead = 0; /* nochars */
      // save the leading space in the nl* token 
      while (isspace(mm->peep) && readc(mm)) {}  /* while */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "nl*"); 
      push(mm);
      goto parse;
    }
    // everything else is a word
    if (0 != strcmp(mm->buffer.workspace, "")) {
      while (!isspace(mm->peep) && readc(mm)) {}  /* while */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "word*"); 
      push(mm);
      goto parse;
    }
    parse: 
    // to visualise parse token reductions
    add(mm, "line "); 
    lines(mm);
    add(mm, " char "); 
    chars(mm);
    add(mm, ": "); 
    printf("%s", mm->buffer.workspace);  /* print */
    mm->buffer.workspace[0] = '\0';      /* clear */
    while (pop(mm)) {}          /* unstack */
    add(mm, "\n"); 
    printf("%s", mm->buffer.workspace);  /* print */
    /* clip */ 
    if (*mm->buffer.workspace != 0)  
      { mm->buffer.workspace[strlen(mm->buffer.workspace)-1] = '\0'; }
    while (push(mm)) {}          /* stack */
    //-------
    // 1 token
    pop(mm);
    //-------
    // 2 tokens
    pop(mm);
    // I want to recognise 2 word structures, so need to separate
    // the text*word* reduction from the word*word* rule. 
    // is there any need for a file* token, link token etc? 
    if (0 == strcmp(mm->buffer.workspace, "word*word*") || 0 == strcmp(mm->buffer.workspace, "text*word*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "text*"); 
      push(mm);
      goto parse;
    }
    if (0 == strcmp(mm->buffer.workspace, "word*nl*") || 0 == strcmp(mm->buffer.workspace, "text*nl*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "line*"); 
      push(mm);
      goto parse;
    }
    if (0 == strcmp(mm->buffer.workspace, "line*line*") || 0 == strcmp(mm->buffer.workspace, "lineset*line*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "lineset*"); 
      push(mm);
      goto parse;
    }
    push(mm);
    push(mm);
    if (mm->peep == EOF) {
      pop(mm);
      if (0 == strcmp(mm->buffer.workspace, "word*") || 0 == strcmp(mm->buffer.workspace, "text*") || 0 == strcmp(mm->buffer.workspace, "line*") || 0 == strcmp(mm->buffer.workspace, "lineset*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        get(mm);
        add(mm, "\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        mm->buffer.workspace[0] = '\0';      /* clear */
        exit(0);
      }
    }
  }
}
