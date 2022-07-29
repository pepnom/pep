

   /* c code generated by "tr/translate.c.pss" */
   /* note: the translation script has not been debugged
            expect unusual results! */
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
  add(mm, ""); 
  add(mm, "\n    An attempt at basic natural language parsing. "); 
  add(mm, "\n    Use the following words in simple sentences: "); 
  add(mm, "\n"); 
  add(mm, "\n     articles: the, this, her, his, a, one, some, "); 
  add(mm, "\n     preposition: up, in, at, on, with, under, to"); 
  add(mm, "\n     adjectives: simple, big, small, blue, beautiful, small,"); 
  add(mm, "\n     nouns: flower, tree, dog, house, horse, girl, fish, meat,"); 
  add(mm, "\n     verbs: runs, eats, sleeps, is, grows, digs, sings"); 
  add(mm, "\n"); 
  add(mm, "\n    End the sentence with a full stop \".\""); 
  add(mm, "\n      eg: the small dog eats fish."); 
  add(mm, "\n      eg: the simple horse runs on the house ."); 
  add(mm, "\n   .\n"); 
  printf("%s", mm->buffer.workspace);  /* print */
  mm->buffer.workspace[0] = '\0';      /* clear */
  script: 
  while (!mm->peep != EOF) {
    if (mm->peep == EOF) { break; } else { readChar(mm); }  /* read */
    if (workspaceInClassType(mm, "[:alpha:]")) {
      while (isalpha(mm->peep) && readc(mm)) {}  /* while */
      put(mm);
      if (0 == strcmp(mm->buffer.workspace, "the") || 0 == strcmp(mm->buffer.workspace, "this") || 0 == strcmp(mm->buffer.workspace, "her") || 0 == strcmp(mm->buffer.workspace, "his") || 0 == strcmp(mm->buffer.workspace, "a") || 0 == strcmp(mm->buffer.workspace, "one") || 0 == strcmp(mm->buffer.workspace, "some")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "article*"); 
        push(mm);
        goto parse;
      }
      if (0 == strcmp(mm->buffer.workspace, "up") || 0 == strcmp(mm->buffer.workspace, "in") || 0 == strcmp(mm->buffer.workspace, "at") || 0 == strcmp(mm->buffer.workspace, "on") || 0 == strcmp(mm->buffer.workspace, "with") || 0 == strcmp(mm->buffer.workspace, "under") || 0 == strcmp(mm->buffer.workspace, "to")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "preposition*"); 
        push(mm);
        goto parse;
      }
      if (0 == strcmp(mm->buffer.workspace, "simple") || 0 == strcmp(mm->buffer.workspace, "big") || 0 == strcmp(mm->buffer.workspace, "small") || 0 == strcmp(mm->buffer.workspace, "blue") || 0 == strcmp(mm->buffer.workspace, "beautiful") || 0 == strcmp(mm->buffer.workspace, "small")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "adjective*"); 
        push(mm);
        goto parse;
      }
      if (0 == strcmp(mm->buffer.workspace, "flower") || 0 == strcmp(mm->buffer.workspace, "tree") || 0 == strcmp(mm->buffer.workspace, "dog") || 0 == strcmp(mm->buffer.workspace, "house") || 0 == strcmp(mm->buffer.workspace, "horse") || 0 == strcmp(mm->buffer.workspace, "girl") || 0 == strcmp(mm->buffer.workspace, "fish") || 0 == strcmp(mm->buffer.workspace, "meat")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "noun*"); 
        push(mm);
        goto parse;
      }
      if (0 == strcmp(mm->buffer.workspace, "runs") || 0 == strcmp(mm->buffer.workspace, "eats") || 0 == strcmp(mm->buffer.workspace, "sleeps") || 0 == strcmp(mm->buffer.workspace, "is") || 0 == strcmp(mm->buffer.workspace, "grows") || 0 == strcmp(mm->buffer.workspace, "digs") || 0 == strcmp(mm->buffer.workspace, "sings")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "verb*"); 
        push(mm);
        goto parse;
      }
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "<"); 
      get(mm);
      add(mm, ">"); 
      add(mm, " Sorry, don't understand that word! \n"); 
      printf("%s", mm->buffer.workspace);  /* print */
      mm->buffer.workspace[0] = '\0';      /* clear */
      exit(0);
    }
    // use a full-stop to complete sentence
    if (0 == strcmp(mm->buffer.workspace, ".")) {
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "dot*"); 
      push(mm);
    }
    // ignore every thing else
    mm->buffer.workspace[0] = '\0';      /* clear */
    parse: 
    // 2 tokens
    pop(mm);
    pop(mm);
    if (0 == strcmp(mm->buffer.workspace, "article*noun*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "nounphrase*"); 
      push(mm);
      goto parse;
    }
    if (0 == strcmp(mm->buffer.workspace, "verb*preposition*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "verbphrase*"); 
      push(mm);
      goto parse;
    }
    // 3 tokens
    pop(mm);
    if (0 == strcmp(mm->buffer.workspace, "noun*verb*dot*") || 0 == strcmp(mm->buffer.workspace, "nounphrase*verb*dot*") || 0 == strcmp(mm->buffer.workspace, "noun*verbphrase*dot*") || 0 == strcmp(mm->buffer.workspace, "nounphrase*verbphrase*dot*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "sentence*"); 
      push(mm);
      goto parse;
    }
    if (0 == strcmp(mm->buffer.workspace, "article*adjective*noun*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "nounphrase*"); 
      push(mm);
      goto parse;
    }
    // 4 tokens
    pop(mm);
    if (0 == strcmp(mm->buffer.workspace, "nounphrase*verb*noun*dot*") || 0 == strcmp(mm->buffer.workspace, "noun*verb*noun*dot*") || 0 == strcmp(mm->buffer.workspace, "nounphrase*verb*nounphrase*dot*") || 0 == strcmp(mm->buffer.workspace, "noun*verb*nounphrase*dot*") || 0 == strcmp(mm->buffer.workspace, "nounphrase*verbphrase*nounphrase*dot*") || 0 == strcmp(mm->buffer.workspace, "noun*verbphrase*nounphrase*dot*") || 0 == strcmp(mm->buffer.workspace, "nounphrase*verbphrase*noun*dot*") || 0 == strcmp(mm->buffer.workspace, "noun*verbphrase*noun*dot*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      add(mm, " "); 
      increment(mm);  /* ++ */ 
      get(mm);
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "sentence*"); 
      push(mm);
      goto parse;
    }
    push(mm);
    push(mm);
    push(mm);
    push(mm);
    if (mm->peep == EOF) {
      pop(mm);
      pop(mm);
      if (0 == strcmp(mm->buffer.workspace, "sentence*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "It's an english sentence! \n("); 
        get(mm);
        add(mm, ") \n"); 
        add(mm, "But it may not make sense! \n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        mm->buffer.workspace[0] = '\0';      /* clear */
        exit(0);
      }
      if (0 == strcmp(mm->buffer.workspace, "nounphrase*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "its a noun-phrase! ("); 
        get(mm);
        add(mm, ") \n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        mm->buffer.workspace[0] = '\0';      /* clear */
        exit(0);
      }
      if (0 == strcmp(mm->buffer.workspace, "verbphrase*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "its a verb-phrase! ("); 
        get(mm);
        add(mm, ") \n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        mm->buffer.workspace[0] = '\0';      /* clear */
        exit(0);
      }
      push(mm);
      push(mm);
      add(mm, "nope, not a sentence. \n"); 
      printf("%s", mm->buffer.workspace);  /* print */
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "The parse stack was: \n  "); 
      printf("%s", mm->buffer.workspace);  /* print */
      mm->buffer.workspace[0] = '\0';      /* clear */
      while (pop(mm));          /* unstack */
      add(mm, "\n"); 
      printf("%s", mm->buffer.workspace);  /* print */
      exit(0);
    }
  }
}
