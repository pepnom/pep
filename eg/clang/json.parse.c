

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
    // Unlike Crockfords grammar, I will just completely ignore whitespace,
    // but this may not be acceptable in a rigorous application. Also, I
    // am just using the ctype.h definition of whitespace, whatever that 
    // may be.
    if (workspaceInClassType(mm, "[:space:]")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      goto parse;
    }
    if (workspaceInClassType(mm, "[0-9]")) {
      while (((mm->peep >= '0') && ('9' >= mm->peep)) && readc(mm)) {} /* while */
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "number*"); 
      push(mm);
      goto parse;
    }
    if (workspaceInClassType(mm, "[a-z]")) {
      while (((mm->peep >= 'a') && ('z' >= mm->peep)) && readc(mm)) {} /* while */
      if (0 != strcmp(mm->buffer.workspace, "true") && 0 != strcmp(mm->buffer.workspace, "false") && 0 != strcmp(mm->buffer.workspace, "null")) {
        // handle error
        put(mm);
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "Unknown value '"); 
        get(mm);
        add(mm, "' at line "); 
        lines(mm);
        add(mm, " (character "); 
        chars(mm);
        add(mm, ").\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        exit(0);
      }
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "value*"); 
      push(mm);
      goto parse;
    }
    if (0 == strcmp(mm->buffer.workspace, "\"")) {
      // save line number for error message
      mm->buffer.workspace[0] = '\0';      /* clear */
      lines(mm);
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      until(mm, "\"");
      if (mm->peep == EOF) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "Unterminated \" char, at line "); 
        get(mm);
        add(mm, "\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        exit(0);
      }
      /* clip */ 
      if (*mm->buffer.workspace != 0)  
        { mm->buffer.workspace[strlen(mm->buffer.workspace)-1] = '\0'; }
      put(mm);
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "string*"); 
      push(mm);
      goto parse;
    }
    // literal tokens
    if (0 == strcmp(mm->buffer.workspace, ",") || 0 == strcmp(mm->buffer.workspace, ":") || 0 == strcmp(mm->buffer.workspace, "-") || 0 == strcmp(mm->buffer.workspace, "+") || 0 == strcmp(mm->buffer.workspace, "[") || 0 == strcmp(mm->buffer.workspace, "]") || 0 == strcmp(mm->buffer.workspace, "{") || 0 == strcmp(mm->buffer.workspace, "}")) {
      put(mm);
      add(mm, "*"); 
      push(mm);
      goto parse;
    }
    parse: 
    // The parse/compile phase
    // --------------
    // 2 tokens
    pop(mm);
    pop(mm);
    // comma errors 
    if (0 == strcmp(mm->buffer.workspace, "{*,*") || 0 == strcmp(mm->buffer.workspace, ",*}*") || 0 == strcmp(mm->buffer.workspace, "[*,*") || 0 == strcmp(mm->buffer.workspace, ",*,*") || 0 == strcmp(mm->buffer.workspace, ",*]*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "Misplaced , at line "); 
      lines(mm);
      add(mm, " ?(char "); 
      chars(mm);
      add(mm, ")\n"); 
      printf("%s", mm->buffer.workspace);  /* print */
      exit(0);
    }
    // catch object member errors 
    // also need to check that not only 1 token in on the stack
    // hence the !"member*" construct
    if (strncmp(mm->buffer.workspace, "member*", strlen("member*")) == 0 || strncmp(mm->buffer.workspace, "members*", strlen("members*")) == 0) {
      if (0 != strcmp(mm->buffer.workspace, "member*") && 0 != strcmp(mm->buffer.workspace, "members*") && !endsWith(mm->buffer.workspace, ",*") && !endsWith(mm->buffer.workspace, "}*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "Error after object member near line "); 
        lines(mm);
        add(mm, " (char "); 
        chars(mm);
        add(mm, ")\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        exit(0);
      }
    }
    // catch array errors 
    if (strncmp(mm->buffer.workspace, "items*", strlen("items*")) == 0) {
      if (0 != strcmp(mm->buffer.workspace, "items*") && !endsWith(mm->buffer.workspace, ",*") && !endsWith(mm->buffer.workspace, "]*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "Error after an array item near line "); 
        lines(mm);
        add(mm, " (char "); 
        chars(mm);
        add(mm, ")\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        exit(0);
      }
    }
    if (strncmp(mm->buffer.workspace, "array*", strlen("array*")) == 0 || strncmp(mm->buffer.workspace, "object*", strlen("object*")) == 0) {
      if (0 != strcmp(mm->buffer.workspace, "array*") && 0 != strcmp(mm->buffer.workspace, "object*") && !endsWith(mm->buffer.workspace, ",*") && !endsWith(mm->buffer.workspace, "}*") && !endsWith(mm->buffer.workspace, "]*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "Error after array or object near line "); 
        lines(mm);
        add(mm, " (char "); 
        chars(mm);
        add(mm, ")\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        exit(0);
      }
    }
    // invalid string sequence
    if (strncmp(mm->buffer.workspace, "string*", strlen("string*")) == 0) {
      if (0 != strcmp(mm->buffer.workspace, "string*") && !endsWith(mm->buffer.workspace, ",*") && !endsWith(mm->buffer.workspace, "]*") && !endsWith(mm->buffer.workspace, "}*") && !endsWith(mm->buffer.workspace, ":*")) {
        mm->buffer.workspace[0] = '\0';      /* clear */
        add(mm, "Error after a string near line "); 
        lines(mm);
        add(mm, " (char "); 
        chars(mm);
        add(mm, ")\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        exit(0);
      }
    }
    // transmogrify into array item, start array
    if (0 == strcmp(mm->buffer.workspace, "[*number*") || 0 == strcmp(mm->buffer.workspace, "[*string*") || 0 == strcmp(mm->buffer.workspace, "[*value*") || 0 == strcmp(mm->buffer.workspace, "[*array*") || 0 == strcmp(mm->buffer.workspace, "[*object*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "[*items*"); 
      push(mm);
      push(mm);
      goto parse;
    }
    // signed numbers
    if (0 == strcmp(mm->buffer.workspace, "-*number*")) {
      /* nop: eliminated */
    }
    // empty arrays are legal json
    if (0 == strcmp(mm->buffer.workspace, "[*]*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "array*"); 
      push(mm);
      goto parse;
    }
    // empty objects are legal json
    if (0 == strcmp(mm->buffer.workspace, "{*}*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "object*"); 
      push(mm);
      goto parse;
    }
    // --------------
    // 3 tokens
    pop(mm);
    // arrays, 
    if (0 == strcmp(mm->buffer.workspace, "[*items*]*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "array*"); 
      push(mm);
      goto parse;
    }
    // 
    if (0 == strcmp(mm->buffer.workspace, "items*,*number*") || 0 == strcmp(mm->buffer.workspace, "items*,*string*") || 0 == strcmp(mm->buffer.workspace, "items*,*value*") || 0 == strcmp(mm->buffer.workspace, "items*,*array*") || 0 == strcmp(mm->buffer.workspace, "items*,*object*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "items*"); 
      push(mm);
      goto parse;
    }
    // object members
    if (0 == strcmp(mm->buffer.workspace, "string*:*number*") || 0 == strcmp(mm->buffer.workspace, "string*:*string*") || 0 == strcmp(mm->buffer.workspace, "string*:*value*") || 0 == strcmp(mm->buffer.workspace, "string*:*object*") || 0 == strcmp(mm->buffer.workspace, "string*:*array*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "member*"); 
      push(mm);
      goto parse;
    }
    // multiple elements of an object
    if (0 == strcmp(mm->buffer.workspace, "member*,*member*") || 0 == strcmp(mm->buffer.workspace, "members*,*member*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "members*"); 
      push(mm);
      goto parse;
    }
    //  
    if (0 == strcmp(mm->buffer.workspace, "{*members*}*") || 0 == strcmp(mm->buffer.workspace, "{*member*}*")) {
      mm->buffer.workspace[0] = '\0';      /* clear */
      add(mm, "object*"); 
      push(mm);
      goto parse;
    }
    push(mm);
    push(mm);
    push(mm);
    if (mm->peep == EOF) {
      while (pop(mm)) {}          /* unstack */
      if (0 == strcmp(mm->buffer.workspace, "object*") || 0 == strcmp(mm->buffer.workspace, "array*") || 0 == strcmp(mm->buffer.workspace, "value*") || 0 == strcmp(mm->buffer.workspace, "string*") || 0 == strcmp(mm->buffer.workspace, "number*")) {
        while (push(mm)) {}          /* stack */
        add(mm, "Valid json! Top level item was '"); 
        printf("%s", mm->buffer.workspace);  /* print */
        mm->buffer.workspace[0] = '\0';      /* clear */
        pop(mm);
        /* clip */ 
        if (*mm->buffer.workspace != 0)  
          { mm->buffer.workspace[strlen(mm->buffer.workspace)-1] = '\0'; }
        add(mm, "'\n"); 
        printf("%s", mm->buffer.workspace);  /* print */
        mm->buffer.workspace[0] = '\0';      /* clear */
        exit(0);
      }
      while (push(mm)) {}          /* stack */
      add(mm, "Maybe not valid json.\n"); 
      add(mm, "The parse stack was \n"); 
      printf("%s", mm->buffer.workspace);  /* print */
      mm->buffer.workspace[0] = '\0';      /* clear */
      while (pop(mm)) {}          /* unstack */
      add(mm, "\n"); 
      printf("%s", mm->buffer.workspace);  /* print */
    }
  }
}
