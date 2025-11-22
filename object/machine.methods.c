/*

 /object/machine.methods.c

ABOUT

  This file contains:
    functions which are equivalent to the operation of each
    instruction on the parsing virtual machine. These will just 
    be extracted from the execute() method. These functions or 
    methods will allow parsing scripts to be compiled!

  The code below has basically been copied from the execute() 
  function in machine.interp.c changing breaks to returns
  and removing references to any instruction. These methods
  should be kept in sync with the execute() code.

  These methods, along with the virtual parsing machine implemented
  in machine.c can be used by translate.c.pss (or similar scripts)
  to create compilable c code (and therefore, stand-alone executables)
  for any parsing script.

NOTES

  Some commands can be translated "in-line" so dont require a 
  function here (eg nom://delim  or nom://echar )

SYNTAX

SEE ALSO

   /tr/translate.c.pss
     a nom script that generates compilable c code from a 
     nom script. 

   /object/machine.c
     An implementation of the virtual machine. This may contain
     just the machine structure and helper functions, or else 
     methods as well.

   /object/machine.interp.c
     The same as this code but for the interpreter.

HISTORY

  20 may 2025
    modify escape and unescape methods to allow properly escaping and
    unescaping the 'escape characcter' (by default it is '\\' but 
    can be changed with the echar nom command). This is an important
    piece of code because some languages and compilers will crash 
    or refuse to compile if an 'unrecognised escape sequence' is 
    given in the text of the program. This code here is untested
    but is very similar to the code in machine.interp.c which has been
    lightly tested.

  24 april 2025
    fixed escape and unescape so that those command will count
    the number of escape chars preceding
    starting to add 'echar' code to change the escape character 

  28 august 2019
    starting to add a workspaceInClassType() function
    
  13 august 2019
    moved to object folder. created machine.methods.h

  8 august 2019
    continued working on this in conjuction with the 
    script compile.ccode.pss

  28 july 2019
    had the idea to reorganise gh.c into distinct files
    I dont think that these functions or methods will take an
    struct Instruction argument.

    I will try to name each method the same as the machine 
    instruction.

  */

// this should become include machine.c or machine.h


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

  /* some helper functions */

  /** this function provides the same functionality as the 
      "testclass" instruction of the machine. This allows us to
      translate scripts directly into c code without parameters 
      or other tricks. Currently (28 august 2019)
      the compilable.c.pss code parses
      a script into 3 different character tests ie: list,class,range
      but this means that the compilable.c.pss script has a different
      structure to compile.c.pss which is inconvenient for maintainance. */
  int workspaceInClassType(struct Machine * mm, const char * class) { 
    int result = FALSE;
    char range[4]; 
    char classGroup[64];
    char list[256];
 
    // all chars in plain c are ascii, so just return true
    if (strcmp(class, "[:ascii:]") == 0) { return TRUE; }

    // format "[:space:]
    if ((class[0] == '[') && (class[1] == ':')) {
      // convert "[:space:]" to "space"
      strncpy(classGroup, class+2, strlen(class)-4);
      classGroup[strlen(class)-3] = '\0';
      result = workspaceInClass(mm, classGroup);  
      if (result == TRUE) return result;
    }
    // format "whilenot [a-z]"
    else if ((class[0] == '[') && (class[2] == '-')) {
      // convert "[a-z]" to "a-z"
      strncpy(range, class+1, 3);
      range[3] = '\0';
      result = workspaceInRange(mm, range);
      if (result == TRUE) return result;
    }
    // format "[abcdef]"
    else if (class[0] == '[') {
      // convert "[ab\n\rc]" to "ab\n\rc"
      scanParameter(list, class, 0);
      result = workspaceInList(mm, list);
      if (result == TRUE) return result;
    }
    else {
      printf("not valid class. \n");
      exit;
    }
    return FALSE;
  }

  /* return true if all characters in the workspace are in
     the give (ctype.h) class. class is a string in the format
     'alnum', 'space' etc */
  int workspaceInClass(struct Machine * mm, const char * charclass) { 
    char * lastc;
    int (* fn)(int); // a function pointer for the ctype.h functions
    int result = TRUE;
    if (strlen(mm->buffer.workspace) == 0) { return FALSE; }
    fn = classInfo[textToClass(charclass)].classFn;
    lastc = mm->buffer.workspace;
    mm->flag = TRUE;
    while (*lastc != 0) {
      if (!fn(*lastc)) {
        result = FALSE; break;
      }
      lastc++;
    }
    return result;
  }

  /* return true if all the characters in the workspace
     are in the given list (array of characters) */
  int workspaceInList(struct Machine * mm, const char * list) { 
    char * lastc;
    int result = TRUE;
    if (strlen(mm->buffer.workspace) == 0) { return FALSE; }
    lastc = mm->buffer.workspace;
    while (*lastc != 0) {
      if (strchr(list, *lastc) == NULL) {
        result = FALSE; break;
      }
      lastc++;
    }
    return result;
  }

  /* return true if all the characters in the workspace
     are in the given range */
  /* range is in the format "a-z", so range[0] is the start
     of the range and range[2] is the end of the range */
  int workspaceInRange(struct Machine * mm, const char * range) { 
    char * lastc;
    int result = TRUE;
    lastc = mm->buffer.workspace;
    if (strlen(mm->buffer.workspace) == 0) { return FALSE; }
    while (*lastc != 0) {
      if ((*lastc < range[0]) || (*lastc > range[2])) {
        result = FALSE; break;
      }
      lastc++;
    }
    return result;
  }

  /* functions which correspond to instructions on the 
     machine */

  /* append text to the workspace */
  void add(struct Machine * mm, const char * text) {
    if (strlen(mm->buffer.stack) + strlen(text) > 
      mm->buffer.capacity) {
      growBuffer(&mm->buffer, strlen(text) + 50);
    }
    strcat(mm->buffer.workspace, text);
  }
 
  void clip(struct Machine * mm) {
    if (*mm->buffer.workspace == 0) return;
    mm->buffer.workspace[strlen(mm->buffer.workspace)-1] = '\0';
  }

  void clop(struct Machine * mm) {
    size_t len;
    if (*mm->buffer.workspace == 0) return;
    len = strlen(mm->buffer.workspace);
    memmove(mm->buffer.workspace, mm->buffer.workspace+1, len-1);
    mm->buffer.workspace[len-1] = 0;
  }

  void clear(struct Machine * mm) {
    mm->buffer.workspace[0] = '\0';
  }

  void replace(struct Machine * mm, const char * old, const char * new) {
    int difference = 0;  
    difference = strlen(new) - strlen(old);
    // but growBuffer takes an increase, not a minimum size
    size_t newSize = strlen(mm->buffer.workspace) + difference;
    char * result = malloc((newSize + 100) * sizeof(char));
    *result = 0;
    replaceString(result, mm->buffer.workspace, old, new);
    if (newSize > workspaceCapacity(&mm->buffer)) {
      growBuffer(&mm->buffer, difference + 100);
    }
    strcpy(mm->buffer.workspace, result);
    free(result);
  }

  void print(struct Machine * mm) {
    printf("%s", mm->buffer.workspace);
  }

  /* this shold return a value, to use in stack/unstack etc */
  int pop(struct Machine * mm) {
    // pop a token from the stack, so skip the first delim * and
    // read back to the next delim * in the stack buffer.
    // 
    // this pop routine seems unnecessary complicated.
    // basically given s:a*b* w:  
    // pop should give s:a* w:b*
    //
    if (mm->buffer.workspace == mm->buffer.stack) return 0;
    mm->buffer.workspace--;
    if (mm->buffer.workspace == mm->buffer.stack) {
      if (mm->tape.currentCell > 0) mm->tape.currentCell--;
      return 0;
      //return 1;
    }
    while ((*(mm->buffer.workspace-1) != mm->delimiter) && 
           (mm->buffer.workspace-1 != mm->buffer.stack))
      mm->buffer.workspace--; 

    if (mm->buffer.workspace == mm->buffer.stack) {
      if (mm->tape.currentCell > 0)
        mm->tape.currentCell--;
      //return 1;
      return 0;
    }
    if (*(mm->buffer.workspace-1) != mm->delimiter) 
      mm->buffer.workspace--; 
    // dec current tape cell
    if (mm->tape.currentCell > 0)
      mm->tape.currentCell--;
    return 1;
  }

  int push(struct Machine * mm) {
    if (mm->buffer.workspace[0] == '\0') return 0;
    while ((*mm->buffer.workspace != '\0') && 
           (*mm->buffer.workspace != mm->delimiter))
       mm->buffer.workspace++;
    if (mm->buffer.workspace[0] == mm->delimiter) 
      mm->buffer.workspace++;
    // increment current tape cell
    // star at end of token - not beginning
    // look for limits !!
    if (mm->tape.currentCell < mm->tape.capacity)
      mm->tape.currentCell++;
    else {
      printf("Push: Out of tape bounds");
      exit(1);
    }
    return 1;
  }

  void put(struct Machine * mm) {
    // I could make this resize  a function, but the only place the
    // tape cell can get resized is here in the PUT command
    // if not enough space in tape cell, malloc here
    long newCapacity;
    struct TapeCell * thisCell;
    thisCell = &mm->tape.cells[mm->tape.currentCell];
    if (strlen(mm->buffer.workspace) > thisCell->capacity) {
      newCapacity = strlen(mm->buffer.workspace)+100;
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
    return;
  }

  void get(struct Machine * mm) {
    size_t cellLength;  // how long tapecell text is
    cellLength = strlen(mm->tape.cells[mm->tape.currentCell].text);
    if ((strlen(mm->buffer.stack) + cellLength) > mm->buffer.capacity) {
      growBuffer(&mm->buffer, cellLength + 100);
    }
    strcat(mm->buffer.workspace, 
      mm->tape.cells[mm->tape.currentCell].text);
  }

  void swap(struct Machine * mm) {
    size_t cellLength;  // how long tapecell text is
    struct TapeCell * thisCell;
    char * temp;    // a temporary string for x swaps
    long newCapacity;
    temp = malloc(strlen(mm->buffer.workspace + 10) * sizeof(char));
    strcpy(temp, mm->buffer.workspace);
    cellLength = strlen(mm->tape.cells[mm->tape.currentCell].text);

    // we need a function mm.workspaceCapacity()
    // because some room in the buffer is taken up by the stack
    // and we dont know how long that is because the stack is 
    // not zero terminated (it is combined with the workspace). 
    if (cellLength > workspaceCapacity(&mm->buffer)) {
      growBuffer(&mm->buffer, cellLength + 20);
    }
    strcpy(mm->buffer.workspace, 
      mm->tape.cells[mm->tape.currentCell].text);

    thisCell = &mm->tape.cells[mm->tape.currentCell];
    if (strlen(temp) > thisCell->capacity) {
      newCapacity = strlen(temp)+20;
      thisCell->text = malloc(newCapacity * sizeof(char));
      if (thisCell->text == NULL) {
        fprintf(stderr, 
          "SWAP: couldnt allocate memory for cell->text (execute) \n");
        exit(EXIT_FAILURE);
      }
      thisCell->capacity = newCapacity - 1;
      thisCell->resizings++;
    }
    strcpy(thisCell->text, temp);
    free(temp); 
  }

  void increment(struct Machine * mm) {
    if (mm->tape.currentCell < mm->tape.capacity)
      mm->tape.currentCell++;
    else {
      printf("++: Out of tape bounds");
      exit(1);
    }
  }

  // in compile.ccode.pss we could generate the contents of 
  // this function (and others) directly for the sake of 
  // speed of execution. But the generated code would be less 
  // readable.
  void decrement(struct Machine * mm) {
    if (mm->tape.currentCell > 0)
      mm->tape.currentCell--;
  }
  
  // avoid name clash with read(). I think readc also has
  // EOF protection, so this is duplicate eof testing.
  // infact dont need this function, just use readc()
  void readChar(struct Machine * mm) {
    // very inefficient to be checking for eof on every read!!
    if (mm->peep == EOF) { exit(ENDOFSTREAM); }
    readc(mm);
  }

  void until(struct Machine * mm, const char * text) {
    int nn = 0;
    size_t len;
    if (mm->peep == EOF) return; 
    // read atleast 1 char if not eof
    if (!readc(mm)) return;
    len = strlen(text);
    size_t worklen = strlen(mm->buffer.workspace);
    char * suffix = mm->buffer.workspace+worklen-len;
    if (strcmp(suffix, text) == 0) { return; }
    while (readc(mm)) {
      worklen++; 
      suffix = mm->buffer.workspace+worklen-len;
      if (strcmp(suffix, text) == 0) {
        // now count how many escape chars behind the suffix 
        if ((*(suffix-1) != mm->escape)) { break; }
        nn = 1;
        while (((suffix-nn-1) >= mm->buffer.workspace) && 
               (*(suffix-nn-1) == mm->escape)) { nn++; }
        // printf("escape count = %d \n", nn);
        if (nn % 2 == 0) break;
      }
    }
    return;
  } // until

  // see the parameterFromText() function
  // maybe split this function into 3. whilePeepIsClass()
  // whilePeepIsRange() and whilePeepIsList().
  void whilePeep(struct Machine * mm, struct Parameter param) {

    int (* fn)(int); // a function pointer for the ctype.h functions
    if (mm->peep == EOF) return;
    // while and whilenot handle classes eg :space: ranges eg [a-z]
    // and lists eg [abxy] [.] etc
    // a function pointer: fn = &isblank; int res = (*fn)('1');

    switch (param.datatype) {
      case CLASS:
        // get character class function pointer from the instruction
        fn = param.classFn;
        while ((*fn)(mm->peep)) {
          if (!readc(mm)) break;
        }
        break;
      case RANGE:
        // compare peep to a range of characters eg a-z
        while ((mm->peep >= param.range[0]) && (mm->peep <= param.range[1])) {
          if (!readc(mm)) return;
        }
        break;
      case LIST:
        // read input while peep is in a list of chars 
        while (strchr(param.list, mm->peep) != NULL) {
          if (!readc(mm)) return;
        }
        break;
      default: break;
    }
    return;
  }


  // todo!! convert text to function pointer.
  void whilePeepInClass(struct Machine * mm, const char * charclass) {
    int (* fn)(int); 
    // a function pointer for the ctype.h functions
    // get character class function pointer from the instruction
    // convert text to class function
    fn = classInfo[textToClass(charclass)].classFn;
    while ((*fn)(mm->peep)) {
      if (!readc(mm)) break;
    }
  }

  // todo!! convert text to function pointer.
  void whileNotPeepInClass(struct Machine * mm, const char * charclass) {
    int (* fn)(int); 
    // a function pointer for the ctype.h functions
    // get character class function pointer from the instruction
    // convert text to class function
    fn = classInfo[textToClass(charclass)].classFn;
    while (!(*fn)(mm->peep)) {
      if (!readc(mm)) break;
    }
  }

  
  // "range" is a string in the format "a-z" , so range[0] is the 
  // start of the range and range[2] is the end of the range
  void whilePeepInRange(struct Machine * mm, char * range) {
    while ((mm->peep >= range[0]) && (mm->peep <= range[2])) {
      if (!readc(mm)) return;
    }
  }

  void whileNotPeepInRange(struct Machine * mm, char * range) {
    while ((mm->peep < range[0]) || (mm->peep > range[2])) {
      if (!readc(mm)) return;
    }
  }

  void whilePeepInList(struct Machine * mm, const char * list) {
    while (strchr(list, mm->peep) != NULL) {
      if (!readc(mm)) return;
    }
  }

  void whileNotPeepInList(struct Machine * mm, const char * list) {
    while (strchr(list, mm->peep) == NULL) {
      if (!readc(mm)) return;
    }
  }

  // maybe split this function into 3. whilePeepIsClass()
  // whilePeepIsRange() and whilePeepIsList().
  void whileNotPeep(struct Machine * mm, struct Parameter param) {

    int (* fn)(int); // a function pointer for the ctype.h functions
    switch (param.datatype) {
      case CLASS:
        // get character class function pointer from the instruction
        fn = param.classFn;
        while (!(*fn)(mm->peep)) {
          if (!readc(mm)) return;
        }
        break;
      case RANGE:
        // read input while peep is not in a range (eg b-f) 
        while ((mm->peep < param.range[0]) || (mm->peep > param.range[1])) {
          if (!readc(mm)) return;
        }
        break;
      case LIST:
        // read input while peep is not in a char list eg "abxy"
        while (strchr(param.list, mm->peep) == NULL) {
          if (!readc(mm)) return;
        }
        break;
      default:
        break;
    }
    return;
  }

  // I will/may convert these instructions to c "goto:" instructions
  // that would avoid having to have a reference to a program
  // within the compiled program
  void jump(struct Machine * mm) {
    // update program counter. non-relative jump
    //mm->program.ip = ii->a.number;
  }

  // jumptrue and jumpfalse are relative jumps (unlike "jump")
  void jumpTrue(struct Machine * mm) {
    /*
    if (mm->flag == TRUE) 
      mm->program.ip = mm->program.ip + ii->a.number;
    else mm->program.ip++;
    */
  }

  void jumpFalse(struct Machine * mm) {
    /*
    if (mm->flag == FALSE) 
      mm->program.ip = mm->program.ip + ii->a.number;
    else mm->program.ip++;
    */
  }  

  /* also, all these tests below, may be recoded so as to 
     alter the control flow in the compiled program, rather than
     updating the machine "flag" register. It should become clearer
     how to handle these tests and jumps one the script has been
     written.
     
     */

  void testIs(struct Machine * mm) {
    // the contents are commented out because the implementation
    // will change when compiling scripts
    /*
    if (strcmp(mm->buffer.workspace, ii->a.text) == 0) {
      mm->flag = TRUE;
    } else { mm->flag = FALSE; }
    */
  }

  void testClass(struct Machine * mm) {
    // handle class, range, text, etc
    // depending on the parameter type.
    /*
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
    */
  }

  void testBegins(struct Machine * mm) {
    /*
    if (strncmp(mm->buffer.workspace, ii->a.text, strlen(ii->a.text)) == 0) {
      mm->flag = TRUE;
    } else { mm->flag = FALSE; }
    */
  }

  void testEnds(struct Machine * mm) {
    /*
    if (strcmp(mm->buffer.workspace + strlen(mm->buffer.workspace)
         - strlen(ii->a.text), ii->a.text) == 0) 
      mm->flag = TRUE;
    else mm->flag = FALSE;
    */
  }
  void testEof(struct Machine * mm) {
    /*
    if (mm->peep == EOF) { mm->flag = TRUE; }
    else { mm->flag = FALSE; }
    */
  }
  void testTape(struct Machine * mm) {
    /*
    if (strcmp(mm->buffer.workspace, 
      mm->tape.cells[mm->tape.currentCell].text) == 0)
      { mm->flag = TRUE; }
    else { mm->flag = FALSE; }
    */
  }

  void count(struct Machine * mm) {
    char acc[100];    // a text version of the accumulator
    sprintf(acc, "%d", mm->accumulator);
    if (strlen(mm->buffer.stack) + strlen(acc) > mm->buffer.capacity) {
      growBuffer(&mm->buffer, strlen(acc) + 50);
    }
    strcat(mm->buffer.workspace, acc);
  }

  void incCounter(struct Machine * mm) {
    mm->accumulator++;
  }

  void decCounter(struct Machine * mm) {
    mm->accumulator--;
  }

  void zeroCounter(struct Machine * mm) {
    mm->accumulator = 0;
  }

  void chars(struct Machine * mm) {
    char acc[100];    // a text version of the accumulator
    sprintf(acc, "%ld", mm->charsRead);
    if (strlen(mm->buffer.stack) + strlen(acc) > mm->buffer.capacity) {
      growBuffer(&mm->buffer, strlen(acc) + 50);
    }
    strcat(mm->buffer.workspace, acc);
  }

  void lines(struct Machine * mm) {
    char acc[100];    
    sprintf(acc, "%ld", mm->lines);
    if (strlen(mm->buffer.stack) + strlen(acc) > mm->buffer.capacity) {
      growBuffer(&mm->buffer, strlen(acc) + 50);
    }
    strcat(mm->buffer.workspace, acc);
  }

  // bug! doesnt check for sufficient room in the workspace 
  // buffer.
  void escape(struct Machine * mm, struct Parameter param) {
    // count escapable
    // if the escapable is already preceded with a 
    // backslash should we reescape it? No, should not, this is why
    // I need to count the escape chars
    char * lastc;    // points to last escape char in workspace
    char * lastw;    // points to last char in workspace
    char * buffer;   // store the workspace when escaping (needs to be malloc)
    int count;       // count escapable chars for malloc
    count=0;
    lastc = strchr(mm->buffer.workspace, param.text[0]);
    while (lastc != NULL) {
      count++;
      lastc = strchr(lastc+1, param.text[0]);
    }
    buffer = malloc((strlen(mm->buffer.workspace)+count+10) * sizeof(char));
    // also grow workspace if needed.
    strcpy(buffer, mm->buffer.workspace);
    lastw = mm->buffer.workspace;

    // now use count to count escape chars preceding escapable
    // char. Eg do not escape \\\c but do escape \\\\c
    count = 0;
    while (*buffer != 0) {
      if ((*buffer == param.text[0]) && (param.text[0] != mm->escape) && 
          (count % 2 == 0)) {
        *lastw = mm->escape;
        lastw++;
      }
      if (*buffer == mm->escape) { count++; }
      else { 
        if ((param.text[0] == mm->escape) && (count > 0) && (count % 2 == 1)) {
          *lastw = mm->escape; lastw++;
        }
        count = 0;
      }

      *lastw = *buffer;   
      buffer++; lastw++;
    }
    *lastw = 0;   
  }
  
  /* a helper to be used by translate.c.pss, escapes a particular
     character in the machine workspace */
  void escapeChar(struct Machine * mm, char c) {
    struct Parameter param;
    param.datatype = TEXT;
    param.text[0] = c; param.text[1] = 0;
    escape(mm, param);
  }

  void unescape(struct Machine * mm, struct Parameter param) {
    char * lastc;    // points to last char in workspace
    char * lastw;    // points to last char in workspace
    // count escape chars before escapable.
    int count = 0;
    lastc = mm->buffer.workspace;
    lastw = mm->buffer.workspace;
    while (*lastc != 0) {
      if ((*lastc == mm->escape) && (*(lastc+1)==param.text[0]) && 
          (param.text[0] != mm->escape) && (count % 2 == 0)) {
        lastc++; 
      }
      if (*lastc == mm->escape) { count++; }
      else { 
        // remove the last escape char (by default '\\') if there is an 
        // even sequence. Untested code 
        if ((param.text[0] == mm->escape) && (count > 0) && (count % 2 == 0)) {
          lastw--;
        }
        count = 0;
      }
      *lastw = *lastc;
      lastc++; lastw++;
    }
    *lastw = 0;   
  }

  void state(struct Machine * mm) {
    //showMachineTapeProgram(mm, 3);
    showMachine(mm, TRUE);
  }

  void quit(struct Machine * mm) {
    exit(EXECQUIT);  // script must now exit
  }

  void bail(struct Machine * mm) {
    exit(BADQUIT);  // script must now exit with error code
  }
  
  void writeToFile(struct Machine * mm) {
    // write workspace to file 'sav.pp'
    FILE * saveFile;  // where workspace is written by 'write' command
    if ((saveFile = fopen("sav.pp", "w")) == NULL) {
      printf ("Cannot open file %s'sav.pp'%s for writing\n", 
          YELLOW, NORMAL);
      exit(WRITESAVERROR);
    }
    fputs(mm->buffer.workspace, saveFile);
    fclose(saveFile);
  }
  
  void nop(struct Machine * mm) {
  }

  void undefined(struct Machine * mm) {
    fprintf(stderr, 
         "Executing undefined command! "
         "at instruction: %d \n ", mm->program.ip);
    exit(EXECUNDEFINED);  // error code
  }

