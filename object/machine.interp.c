
/* 

  Code used by the machine when interpreting scripts (but 
  not when running compiled scripts).

HISTORY

  1 sept 2025
    The script 'add "a*"; push;' caused a segmentation fault in 
    the pep interpreter because the script 
    push the current tape cell beyond allocated memory in the tape. (by 8 
    or 16 bytes) It would probably be sensible to have an upper limit
    for the tape.
    
  28 aug 2025
    Seem to have fixed a (big) memory leak which was caused by not 
    freeing a current tape cell pointer in the 'swap' code. The 
    until and untiltape code seems to have been made better and avoids
    some seg faults, but valgrind still reports unassigned values being
    used, and some pointer corruption may still occur. This needs to be 
    debugged properly.
  23 aug 2025
    adding the 'system' command here. trying to make appending the 
    output of the command to the workspace.
  20 may 2025
    made a modification to escape and unescape code so that the escape 
    char itself will be properly escaped. I didnt have to rewrite
    the existing code after all.
  24 april 2025
    starting to add an 'echar' command which changes the 
    escape char in the machine.
  7 sept 2022
    Adding commands to write workspace to a particular filename and append
    to a file.
  31 aug 2022
    Adding an "until-tape" command which reads until the 
    workspace ends with the current tape cell (unless escaped).
    What should this do if the tape-cell is empty? At the 
    moment reads 1 char.

  16 June 2021
    Added some new commands like upper, lower, capital and also
    tried to fix a bug in 'until' which didn't like eg: add "\\" or add "\\\"ab"
    Also, a gotcha!!
      >> printf(mm->buffer.workspace);
    gave segmentation faults! The answer was 
      >> printf("%s", mm->buffer.workspace);

  13 september 2019

    trying to add tape pointer adjustments to unstack/stack.
    adding "marks" to this file. a duplicate mark is deleted. 

*/

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include "colours.h"
#include "tapecell.h"
#include "tape.h"
#include "buffer.h"
#include "command.h"
#include "parameter.h"
#include "instruction.h"
#include "labeltable.h"
#include "program.h"
#include "machine.h"
#include "machine.interp.h"
#include "exitcode.h"

enum ExitCode execute(struct Machine * mm, struct Instruction * ii) {

  struct TapeCell * thisCell;
  int kk;
  long newCapacity;
  char * fileName;  // name of file
  FILE * saveFile;  // where workspace is written by 'write' command
  char * temp;      // a temporary string for x swaps
  char acc[100];    // a text version of the accumulator
  char * bufferstart;  // need to save buffer pos to do a free() later 
  char * buffer;    // store the workspace when escaping (needs to be malloc)
  size_t len;
  int count;       // count escapable chars for malloc
  long nn;         // just a counting variable.
  char * where;    // find substrings 
  char * lastc;    // points to last char in workspace
  char * lastw;    // points to last char in workspace
  int (* fn)(int); // a function pointer for the ctype.h functions
  size_t cellLength;  // how long tapecell text is
  int difference = 0;  // substring size difference for "replace" 
  size_t worklen;      // workspace length counter
  char * suffix;       // current workspace suffix
  char * cellText;     // text of the current tape-cell 

  // for the system command 
  FILE * fp;
  char buff[1024];
  char * res = NULL;
  size_t total_size = 0;

  switch (ii->command) {
    case ADD:
      if (strlen(mm->buffer.stack) + strlen(ii->a.text) >= 
        mm->buffer.capacity) {
        growBuffer(&mm->buffer, strlen(ii->a.text) + 50);
      }
      strcat(mm->buffer.workspace, ii->a.text);
      break;
    case CLIP:
      if (*mm->buffer.workspace == 0) break;
      mm->buffer.workspace[strlen(mm->buffer.workspace)-1] = '\0';
      break;
    case CLOP:
      if (*mm->buffer.workspace == 0) break;
      len = strlen(mm->buffer.workspace);
      memmove(mm->buffer.workspace, mm->buffer.workspace+1, len-1);
      mm->buffer.workspace[len-1] = 0;
      break;
    case CLEAR:
      mm->buffer.workspace[0] = '\0';
      break;
    /*
    case TAPEREPLACE:
      similar implementation as for replace. replaces given text with
      the contents of the current tape cell. This command will allow
      us to make a much better compilation for quotesets* tokens since
      we will be able to generate a unique 'true-jump' label based
      on the character count or line count etc.
    */
    case REPLACE:
      // !! need to multiply by number of occurrences.
      // maybe write an occurrences() function to wrap up this
      // logic.
      len = strlen(ii->a.text);
      count = 0;
      where = mm->buffer.workspace; 

      if (len) {
        while ((where = strstr(where, ii->a.text))) {
          where += len;
          count++;
        }
      }
      // substring does not occur in workspace, so nothing else to do. 
      if (count == 0) { break; }

      difference = count * (strlen(ii->b.text) - strlen(ii->a.text));
      // but growBuffer takes an increase, not a minimum size
      size_t newSize = strlen(mm->buffer.workspace) + difference;
      char * result = malloc((newSize + 100) * sizeof(char));

      *result = 0;
      replaceString(result, mm->buffer.workspace, ii->a.text, ii->b.text);

      if (newSize >= workspaceCapacity(&mm->buffer)) {
        growBuffer(&mm->buffer, difference + 100);
      }
      strcpy(mm->buffer.workspace, result);
      free(result);
      break;
    case UPPERC: 
      temp = mm->buffer.workspace;
      while (*temp) {
        *temp = toupper((unsigned char) *temp);
        temp++;
      }
      break;
    case LOWERC: 
      temp = mm->buffer.workspace;
      while (*temp) {
        *temp = tolower((unsigned char) *temp);
        temp++;
      }
      break;
    case CAPITALC: 
      temp = mm->buffer.workspace;
      if (*temp) {
        *temp = toupper((unsigned char) *temp);
        temp++;
      }
      while (*temp) {
        *temp = tolower((unsigned char) *temp);
        temp++;
      }
      break;
    case PRINT:
      printf("%s", mm->buffer.workspace);
      break;
    case POP:
      // pop a token from the stack, so skip the first delim * and
      // read back to the next delim * in the stack buffer.
      // 
      // this pop routine seems unnecessary complicated.
      // basically given s:a*b* w:  
      // pop should give s:a* w:b*
      //
      if (mm->buffer.workspace == mm->buffer.stack) break;
      mm->buffer.workspace--;
      if (mm->buffer.workspace == mm->buffer.stack) {
        if (mm->tape.currentCell > 0)
          mm->tape.currentCell--;
        break;
      }
      while ((*(mm->buffer.workspace-1) != mm->delimiter) && 
             (mm->buffer.workspace-1 != mm->buffer.stack))
        mm->buffer.workspace--; 

      if (mm->buffer.workspace == mm->buffer.stack) {
        if (mm->tape.currentCell > 0)
          mm->tape.currentCell--;
        break;
      }
      if (*(mm->buffer.workspace-1) != mm->delimiter) 
        mm->buffer.workspace--; 

      // dec current tape cell
      if (mm->tape.currentCell > 0)
        mm->tape.currentCell--;
      break;
    case PUSH:
      // could use strchr instead, or better strchrnul
      // but strchrnul is not standard C.
      if (mm->buffer.workspace[0] == '\0') break;
      while ((*mm->buffer.workspace != '\0') && 
             (*mm->buffer.workspace != mm->delimiter))
         mm->buffer.workspace++;
      if (mm->buffer.workspace[0] == mm->delimiter) 
        mm->buffer.workspace++;
      // increment current tape cell
      // star at end of token - not beginning
      // look for limits !!
      if (mm->tape.currentCell < mm->tape.capacity - 2)
        mm->tape.currentCell++;
      else {
        printf("Push: Out of tape bounds. \n");
        exit(1);
      }
      break;
    case POPALL:
      // wind back the tape pointer? yes
      // the "unstack" command 
      // untested!!
      temp = mm->buffer.workspace;
      while (temp >= mm->buffer.stack) {
        if ((*temp == mm->delimiter) && (mm->tape.currentCell > 0)) {
          mm->tape.currentCell--;
        }
        temp--;
      }
      mm->buffer.workspace = mm->buffer.stack;
      break;
    case PUSHALL:
      // the "stack" command
      // count mm->delimiter chars in workspace and add to tape.currentCell
      // this assumes that workspace is null terminated
      for (kk = 0; mm->buffer.workspace[kk]; kk++) {
         if (mm->buffer.workspace[kk] == mm->delimiter) {
           mm->tape.currentCell++;
         }
      }
      mm->buffer.workspace = mm->buffer.stack + strlen(mm->buffer.stack);
      break;
    case PUT:
      // I could make this a function, but the only place the
      // tape cell can get resized is here in the PUT command

      // if not enough space in tape cell, malloc here
      thisCell = &mm->tape.cells[mm->tape.currentCell];
      // fix: segmentation fault here, because thisCell is pointing 
      // at invalid memory. Which is caused by multiple valid push;
      // commands pushing the currentCell beyond allocated memory in the 
      // tape. fixed in case PUSH but maybe memory should be allocated 
      // until an upper limit.(1 million cells?)
      if (strlen(mm->buffer.workspace) >= thisCell->capacity) {
        newCapacity = strlen(mm->buffer.workspace)+100;
        // free!!
        free(thisCell->text);
        thisCell->text = malloc(newCapacity * sizeof(char));
        if (thisCell->text == NULL) {
          fprintf(stderr, 
            "PUT: couldnt allocate memory for cell->text (execute) \n");
          exit(EXIT_FAILURE);
        }
        thisCell->capacity = newCapacity - 1;
        thisCell->resizings++;
      }
      strcpy(thisCell->text, mm->buffer.workspace);
      break;
    case GET:
      cellLength = strlen(mm->tape.cells[mm->tape.currentCell].text);
      if ((strlen(mm->buffer.stack) + cellLength) >= mm->buffer.capacity) {
        growBuffer(&mm->buffer, cellLength + 100);
      }
      strcat(mm->buffer.workspace, 
        mm->tape.cells[mm->tape.currentCell].text);
      break;
    case SWAP:
      temp = malloc((strlen(mm->buffer.workspace) + 10) * sizeof(char));
      // ... todo! implement this
      strcpy(temp, mm->buffer.workspace);
      cellLength = strlen(mm->tape.cells[mm->tape.currentCell].text);
      // this is a bug, we need a function mm.workspaceCapacity()
      // because some room in the buffer is taken up by the stack
      // and we dont know how long that is because the stack is 
      // not zero terminated (it is combined with the workspace). 
      if (cellLength >= workspaceCapacity(&mm->buffer)) {
        growBuffer(&mm->buffer, cellLength + 20);
      }
      strcpy(mm->buffer.workspace, 
        mm->tape.cells[mm->tape.currentCell].text);

      thisCell = &mm->tape.cells[mm->tape.currentCell];
      if (strlen(temp) > thisCell->capacity) {
        newCapacity = strlen(temp)+20;
        // free!! 
        free(thisCell->text);
        // fix: this should all be 'realloc' not malloc!! ??
        // dont need to strcpy data over because realloc does this!!
        thisCell->text = malloc(newCapacity * sizeof(char));
        if (thisCell->text == NULL) {
          fprintf(stderr, 
            "PUT: couldnt allocate memory for cell->text (execute) \n");
          exit(EXIT_FAILURE);
        }
        thisCell->capacity = newCapacity - 1;
        thisCell->resizings++;
      }
      strcpy(thisCell->text, temp);
      free(temp); 
      break;
    case INCREMENT:
      if (mm->tape.currentCell < mm->tape.capacity - 2)
        mm->tape.currentCell++;
      else {
        printf("++: Out of tape bounds. \n");
        exit(1);
      }
      break;
    case DECREMENT:
      if (mm->tape.currentCell > 0)
        mm->tape.currentCell--;
      break;
    case MARK:
      // delete duplicate marks on the tape.
      for (nn = 0; nn < mm->tape.capacity; nn++) {
        if (strcmp(mm->tape.cells[nn].mark, ii->a.text) == 0) {
          strcpy(mm->tape.cells[nn].mark, ""); 
        }
      }
      strcpy(mm->tape.cells[mm->tape.currentCell].mark, ii->a.text); 
      break;
    case MARKTAPE:
      // this marks the current tape cell with the text in the 
      // current tape cell. another way is to mark with the 
      // current text in the workspace which may be more useful.
      cellText = mm->tape.cells[mm->tape.currentCell].text;
      for (nn = 0; nn < mm->tape.capacity; nn++) {
        if (strcmp(mm->tape.cells[nn].mark, cellText) == 0) {
          strcpy(mm->tape.cells[nn].mark, ""); 
        }
      }
      strcpy(mm->tape.cells[mm->tape.currentCell].mark, cellText); 
      break;
    case GO:
      for (nn = 0; nn < mm->tape.capacity; nn++) {
        if (strcmp(mm->tape.cells[nn].mark, ii->a.text) == 0) {
          mm->tape.currentCell = nn;
        }
      }
      break;
    case GOTAPE:
      cellText = mm->tape.cells[mm->tape.currentCell].text;
      for (nn = 0; nn < mm->tape.capacity; nn++) {
        if (strcmp(mm->tape.cells[nn].mark, cellText) == 0) {
          mm->tape.currentCell = nn;
        }
      }
      break;
    case READ:
      if (mm->peep == EOF) { 
        return ENDOFSTREAM;   // end of file
      }
      readc(mm);
      break;
    case UNTIL:
      /* This is a little tricky for the following reason:
        given: add "\"abc"; then until should read until
        the second quote, after 'c'. But given 
        replace "\\" "."; Until should only read until the first
        quote after the \ char. This is because '\' is an escape 
        char, but '\\' is itself escaped!

        And what about: 
          >> add "\\\"abc" ? or 
          >> add "\\\\"
        So until actually has to count how many escape chars are 
        immediately before the current char!! And this logic
        needs to be transmitted to the translate scripts as well.
      */
      // until workspace ends with ii->a.text
      if (mm->peep == EOF) break; 
      // until reads at least one character, even if the workspace
      // already ends with the given text (that is it's behaviour to
      // make it useful).

      if (!readc(mm)) break;
     

      /* 
      int endsWith(const char *str, const char *suffix) {
        if (!str || !suffix) return 0;
        size_t lenstr = strlen(str);
        size_t lensuffix = strlen(suffix);
        if (lensuffix >  lenstr) return 0;
        return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
      }
      */
      // below is a general "endswith" function...
      // strcmp(mm->buffer.workspace+worklen-len, ii->a.text) != 0) {
      len = strlen(ii->a.text);
      worklen = strlen(mm->buffer.workspace);
      if (len > worklen ) { goto untilloop; }

      // bug!! use buffer.c/endsWith() instead? No, that doesnt look at \\\\ etc
      // after just one char,
      suffix = mm->buffer.workspace + worklen - len;
      // check if work finished already. 
      //if (strlen(mm->buffer.workspace) < strlen(ii->a.text)) 
      if (strcmp(suffix, ii->a.text) == 0) { break; }
 
      untilloop:
      while (readc(mm)) {
        worklen++; 
        if (len > worklen ) { continue; }
        suffix = mm->buffer.workspace+worklen-len;
        // if ((strcmp(suffix, ii->a.text) == 0) && (*(suffix-1) != '\\')) {
        // deal with escape character.

        
        // if ((strcmp(suffix, ii->a.text) == 0) && 
        //     (*(suffix-1) != mm->escape)) { break; }
        // this above doesnt work because until should not stop at "\\" see
        // the note above. So using this nn counter to track escape sequences.
        if (strcmp(suffix, ii->a.text) == 0) {
          // now count how many escape chars behind the suffix 
          if ((*(suffix-1) != mm->escape)) { break; }
          nn = 2;
          while (((suffix-nn) >= mm->buffer.workspace) && 
                  (*(suffix-nn) == mm->escape)) { nn++; }
          // printf("escape count = %d \n", nn);
          if (nn % 2 == 1) break;
        }
      }
      break;
    case UNTILTAPE:
      // see notes for until
      // until workspace ends with ii->a.text
      if (mm->peep == EOF) break; 
      // until reads at least one character
      if (!readc(mm)) break;
      //len = strlen(ii->a.text);
      len = strlen(mm->tape.cells[mm->tape.currentCell].text);
      cellText = mm->tape.cells[mm->tape.currentCell].text;
      worklen = strlen(mm->buffer.workspace);
      if (len > worklen ) { goto untiltapeloop; }

      suffix = mm->buffer.workspace + worklen - len;
      if (strcmp(suffix, cellText) == 0) { break; }
 
      untiltapeloop:
      while (readc(mm)) {
        worklen++; 
        if (len > worklen ) { continue; }
        suffix = mm->buffer.workspace + worklen - len;
        
        // So using this nn counter to track escape sequences.
        if (strcmp(suffix, cellText) == 0) {
          // now count how many escape chars behind the suffix 
          if ((*(suffix-1) != mm->escape)) { break; }
          nn = 2;
          while (((suffix-nn) >= mm->buffer.workspace) && 
                 (*(suffix-nn) == mm->escape)) { nn++; }
          // printf("escape count = %d \n", nn);
          if (nn % 2 == 1) break;
        }
      }
      break;
    case WHILE:
      if (mm->peep == EOF) break;
      // while and whilenot handle classes eg :space: ranges eg [a-z]
      // and lists eg [abxy] [.] etc
      // a function pointer: fn = &isblank; int res = (*fn)('1');

      if (ii->a.datatype == CLASS) {
        // get character class function pointer from the instruction
        fn = ii->a.classFn;
        while ((*fn)(mm->peep)) {
          if (!readc(mm)) break;
        }
      }
      else if (ii->a.datatype == RANGE) {
        // compare peep to a range of characters eg a-z
        while ((mm->peep >= ii->a.range[0]) && (mm->peep <= ii->a.range[1])) {
          if (!readc(mm)) break;
        }
      }
      else if (ii->a.datatype == LIST) {
        // read input while peep is in a list of chars 
        while (strchr(ii->a.list, mm->peep) != NULL) {
          if (!readc(mm)) break;
        }
      }
      break;
    case WHILENOT:
      // do we really need a whilenot. We could just write
      // while ![:space:] etc

      // why not use a switch here??? Its a switch within a switch...
      /*
       switch (ii->a.datatype) {
         case CLASS:
            break;
         case RANGE:
            break;
       }
      */

      if (ii->a.datatype == CLASS) {
        // get character class function pointer from the instruction
        fn = ii->a.classFn;
        while (!(*fn)(mm->peep)) {
          if (!readc(mm)) break;
        }

      }
      else if (ii->a.datatype == RANGE) {
        // read input while peep is not in a range (eg b-f) 
        while ((mm->peep < ii->a.range[0]) || (mm->peep > ii->a.range[1])) {
          if (!readc(mm)) break;
        }
      }
      else if (ii->a.datatype == LIST) {
        // read input while peep is not in a char list eg "abxy"
        while (strchr(ii->a.list, mm->peep) == NULL) {
          if (!readc(mm)) break;
        }
      }
      break;
    case JUMP:
      // update program counter. non-relative jump
      mm->program.ip = ii->a.number;
      break;
    case JUMPTRUE:
      if (mm->flag == TRUE) 
        // relative jump. easier to assemble code
        // mm->program.ip = ii->a.number;
        mm->program.ip = mm->program.ip + ii->a.number;
      else mm->program.ip++;
      break;
    case JUMPFALSE:
      if (mm->flag == FALSE) 
        // relative jump.
        mm->program.ip = mm->program.ip + ii->a.number;
      else mm->program.ip++;
      break;
    case TESTIS:
      // fix: valgrind complains that there is an uninitialised value
      // in the line below.
      if (strcmp(mm->buffer.workspace, ii->a.text) == 0) {
        mm->flag = TRUE;
      } else { mm->flag = FALSE; }
      break;
    /*
    case TESTHAS:
      test if the workspace currently contains the text of the 
      current tape cell. This will allow us to parse strings of the 
      same letter (and will help with the palindrome.pss script).
      strings of letters, eg: aaa bbbbbb, will be tokenised as 
      string* not as pal* 
      break;
    case TESTENDSTAPE:
      maybe....
    */
    case TESTCLASS:
      // handle class, range, text, etc
      // depending on the parameter type.
      if (strlen(mm->buffer.workspace) == 0) { 
        mm->flag = FALSE; break;
      }
      if (ii->a.datatype == CLASS) {
        // get character class function pointer from the instruction
        fn = ii->a.classFn;
        lastc = mm->buffer.workspace; 
        //while ((*fn)(mm->peep)) {
        mm->flag = TRUE;
        while (*lastc != 0) {
          if (!fn(*lastc)) { 
            mm->flag = FALSE; break;
          }
          lastc++;
        }
      }
      else if (ii->a.datatype == RANGE) {
        // compare ws to a range of characters eg a-z
        mm->flag = TRUE; 
        lastc = mm->buffer.workspace; 
        while (*lastc != 0) {
          if ((*lastc < ii->a.range[0]) || (*lastc > ii->a.range[1])) {
            mm->flag = FALSE; break;
          }
          lastc++;
        }
      }
      else if (ii->a.datatype == LIST) {
        // compare ws to a list of chars 
        //while (strchr(ii->a.list, mm->peep) != NULL) {
        mm->flag = TRUE; 
        lastc = mm->buffer.workspace; 
        while (*lastc != 0) {
          if (strchr(ii->a.list, *lastc) == NULL) {
            mm->flag = FALSE; break;
          }
          lastc++;
        }
      }
      break;
    case TESTBEGINS:
      if (strncmp(mm->buffer.workspace, ii->a.text, strlen(ii->a.text)) == 0) {
        mm->flag = TRUE;
      } else { mm->flag = FALSE; }
      break;
    case TESTENDS:
      if (strlen(mm->buffer.workspace) < strlen(ii->a.text)) {
        mm->flag = FALSE; break;
      }
      if (strcmp(mm->buffer.workspace + strlen(mm->buffer.workspace)
           - strlen(ii->a.text), ii->a.text) == 0) 
        mm->flag = TRUE;
      else mm->flag = FALSE;
      break;
    case TESTEOF:
      if (mm->peep == EOF) { mm->flag = TRUE; }
      else { mm->flag = FALSE; }
      break;
    case TESTTAPE:
      if (strcmp(mm->buffer.workspace, 
        mm->tape.cells[mm->tape.currentCell].text) == 0)
        { mm->flag = TRUE; }
      else { mm->flag = FALSE; }
      break;
    case COUNT:
      sprintf(acc, "%d", mm->accumulator);
      if (strlen(mm->buffer.stack) + strlen(acc) >= mm->buffer.capacity) {
        growBuffer(&mm->buffer, strlen(acc) + 50);
      }
      strcat(mm->buffer.workspace, acc);
      break;
    case INCC:
      mm->accumulator++;
      break;
    case DECC:
      mm->accumulator--;
      break;
    case ZERO:
      mm->accumulator = 0;
      break;
    case CHARS:
      sprintf(acc, "%ld", mm->charsRead);
      if (strlen(mm->buffer.stack) + strlen(acc) >= mm->buffer.capacity) {
        growBuffer(&mm->buffer, strlen(acc) + 50);
      }
      strcat(mm->buffer.workspace, acc);
      break;
    case LINES:
      sprintf(acc, "%ld", mm->lines);
      if (strlen(mm->buffer.stack) + strlen(acc) >= mm->buffer.capacity) {
        growBuffer(&mm->buffer, strlen(acc) + 50);
      }
      strcat(mm->buffer.workspace, acc);
      break;
    case NOCHARS:
      mm->charsRead = 0; break;
    case NOLINES:
      mm->lines = 0; break;
    case ESCAPE:
      /*
       count escapable
       but if the escapable is already preceded with a 
       backslash I should not reescape it. But if the escapable is 
       the same as the escape char then odd sequences of escape chars
       should be escaped. Getting this code right is important, especially
       for second generation scripts.
      */
      count=0;
      lastc = strchr(mm->buffer.workspace, ii->a.text[0]);
      while (lastc != NULL) {
        count++;
        lastc = strchr(lastc+1, ii->a.text[0]);
      }
      
      buffer = malloc((strlen(mm->buffer.workspace)+count+10) * sizeof(char));
      bufferstart = buffer;
      // also grow workspace if needed.
      strcpy(buffer, mm->buffer.workspace);
      lastw = mm->buffer.workspace;
      // now use count to count escape chars preceding escapable
      // char. Eg donot escape \\\c but do escape \\\\c
      count = 0;
      while (*buffer != 0) {
        if ((*buffer == ii->a.text[0]) && (ii->a.text[0] != mm->escape) && 
            (count % 2 == 0)) {
          *lastw = mm->escape;
          lastw++;
        }
        if (*buffer == mm->escape) { count++; }
        else { 
          if ((ii->a.text[0] == mm->escape) && (count > 0) && (count % 2 == 1)) {
            *lastw = mm->escape; lastw++;
          }
          count = 0;
        }

        *lastw = *buffer;   
        buffer++; lastw++;
      }
      *lastw = 0;   
      free(bufferstart);
      break;

    case UNESCAPE:
      /* modify this as per code above */
      lastc = mm->buffer.workspace;
      lastw = mm->buffer.workspace;

      // use count to count number of escape chars before 
      // escapable.
      count = 0;
      while (*lastc != 0) {
        if ((*lastc == mm->escape) && (*(lastc+1)==ii->a.text[0]) && 
            (ii->a.text[0] != mm->escape ) && (count % 2 == 0)) {
          lastc++; 
        }
        if (*lastc == mm->escape) { count++; }
        else { 
          // here remove the last escape char if even sequence
          // see escape code
          if ((ii->a.text[0] == mm->escape) && (count > 0) && (count % 2 == 0)) {
            lastw--;
          }
          count = 0;
        }
        *lastw = *lastc;
        lastc++; lastw++;
      }
      *lastw = 0;   
      // ...
      break;
    case ECHAR:
      mm->escape = ii->a.text[0];
      break;
    case DELIM:
      mm->delimiter = ii->a.text[0];
      break;
    case STATE:
      showMachineTapeProgram(mm, 3);
      break;
    case QUIT:  //
      return EXECQUIT;  // script must now exit
      break;
    case BAIL:  //
      return BADQUIT;  // script must now exit with error code
      break;
    case WRITE:
      // I may get rid of this command soon, since WRITEFILE
      // is better.
      // write workspace to a default file 'sav.pp'
      if ((saveFile = fopen("sav.pp", "w")) == NULL) {
        printf ("Cannot open file %s'sav.pp'%s for writing\n", 
            YELLOW, NORMAL);
        return WRITESAVERROR;
      }
      fputs(mm->buffer.workspace, saveFile);
      fclose(saveFile);
      break;
    case WRITEFILE:
      // write workspace to given file name (file is overwritten)
      fileName = ii->a.text;
      if ((saveFile = fopen(fileName, "w")) == NULL) {
        printf ("Cannot open file '%s' for writing\n", fileName);
        return WRITESAVERROR;
      }
      fputs(mm->buffer.workspace, saveFile);
      fclose(saveFile);
      break;

    case WRITEFILEAPPEND:
      // append workspace to given file name (file is not overwritten)
      fileName = ii->a.text;
      if ((saveFile = fopen(fileName, "a")) == NULL) {
        printf ("Cannot open file '%s' for writing\n", fileName);
        return WRITESAVERROR;
      }
      fputs(mm->buffer.workspace, saveFile);
      fclose(saveFile);
      break;
    case SYSTEM:
      // execute the workspace as a system command.
      // and read results to workspace. (The contents of the workspace
      // are replaced. 

      fp = popen(mm->buffer.workspace, "r");
      if (fp == NULL) {
        perror("Pep/nom: bad error, failed to run command!"); 
        return 0;
      }
      mm->buffer.workspace[0] = '\0';

      // Read the output in chunks and append to the workspace.
      while (fgets(buff, sizeof(buff), fp) != NULL) {
        size_t len = strlen(buff);
        // printf("%s", buff);
        // grow the workspace if required.
        if (strlen(mm->buffer.stack) + len >= mm->buffer.capacity) {
          growBuffer(&mm->buffer, len+100);
        }
        strcat(mm->buffer.workspace, buff);
      }
      pclose(fp); 
      break;
    case NOP:
      break;
    case UNDEFINED:
      fprintf(stderr, 
           "Executing undefined command! "
           "at instruction: %d \n ", mm->program.ip);
      return EXECUNDEFINED;  // error code
      break;
  }
  // if a jump command, dont increment the instruction pointer 
  if (strncmp(info[ii->command].name, "jump", 4) != 0) {
    mm->program.ip++;
  }
  return SUCCESS;
}

/*
this code is for the system command.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* get_command_output(const char* command) {
    FILE* fp;
    char buffer[1024];
    char* result = NULL;
    size_t total_size = 0;

    // Open the command for reading.
    fp = popen(command, "r");
    if (fp == NULL) {
      perror("Failed to run command"); return NULL;
    }

    // Read the output in chunks and append to the result string.
    while (fgets(buffer, sizeof(buffer), fp) != NULL) {
      size_t buffer_len = strlen(buffer);
      // Dynamically resize the result string to fit the new chunk.
      char* temp = realloc(result, total_size + buffer_len + 1);
      if (temp == NULL) {
        // Handle realloc failure
        free(result); pclose(fp); return NULL;
      }
      result = temp;
      // Append the new chunk to the result string.
      memcpy(result + total_size, buffer, buffer_len + 1);
      total_size += buffer_len;
    }

    // Close the pipe.
    pclose(fp);

    return result;
}

int main() {
    char* output_string = get_command_output("ls -l");

    if (output_string != NULL) {
        printf("--- Command Output ---\n");
        printf("%s", output_string);
        printf("----------------------\n");

        // Don't forget to free the dynamically allocated memory!
        free(output_string);
    } else {
        fprintf(stderr, "Failed to capture command output.\n");
        return 1;
    }

    return 0;
}
*/

