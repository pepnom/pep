
/*

  http://bumble.sourceforge.net/books/pars/object/ompp.c

OVERVIEW

  ompp.c 

  This is the viewer and debugger for the pp script engine.
  See the file /books/pars/object/gh.c for comprehensive comments
  and developement history.

SEE ALSO
   
   compile.pss
     A script which can compile parse-scripts into an assembler format.
     This does just the same job as 'asm.pp' but is more readable
     and compact.

   compilable.c.pss
     A script which produces compilable c code for any given script. 
     The c code is linked against the libmachine.a library to produce
     an executable parser/translator. see the ghcl bash function in
     helpers.gh.sh for the exact gcc compiling code. This is only
     hampered by a segmentation fault currently (august 2019)

   eg/exp.tolisp.pss
     a solution to the elementary parsing problem of parsing and 
     transforming arithmetic expressions (eg "a+b*c*(d+e)") with 
     operator precedence. The script transforms the input into 
     a lisp-like prefix-bracket syntax. Test with:
       >> pp -f eg/exp.tolisp.pss -i "a+b*c*(d+e)"

   eg/natural.language.pss
     a very limited example of a natural language recogniser. Test with:
       >> pp -f eg/natural.language.pss -i "a big dog eats meat"

   object/machine.methods.c
     a set of functions which correspond to each instruction of the 
     machine.

   object folder
     The object folder contains a set of 'objects' (c structures
     and related functions) which form the components of the 
     virtual parsing machine.

   asm.pp
     a parse machine 'assembler' program which compiles scripts to an
     intermediate format (which I call an 'assembler' format because of its
     similarities to real assembler languages on real chips). This
     intermediate assembler format can be, and is loaded and run directly by
     the virtual parse machine, to transform the input stream.

   test.commands.pss
     contains a set of valid syntax patterns for the parse
     script language and can be used as a kind of syntax 
     reference

   pars-book.txt
     The beginnings of a booklet describing the parse machine
     and engine. 

   ompp -Ie "read; print; clear;" -i "otto"
     explore the machine interactively (view registers and step
     through programs and input) using the simplest possible 
     program and input.

   helpers.pars.sh
     A set of bash functions to make compiling the code easier 
     among other things.

FIXED BUGS

BUGS 
   
    * using pp -Ii "abc" -e "r;U;d;" caused a malloc segfault.
      (U is unimplemented). Any "misplaced" character appears to
      cause the segfault.
    * having an unterminated " quote character in a script may
      cause a segfault....
    * the escape command does not check for sufficient memory
      in the workspace buffer. Need to fix execute() and also
      the escape method in machine.methods.c
    * saveAssembledProgram will not deal with the second 
      parameter currently (aug 2019) and so will not save 
      the "replace" command correctly. This is not so important
      because saveAssembledProgram is not being used for anything 
      significant, currently (august 2019).  

    * when program grows, it often creates a segmentation fault.
      Also, the first instruction of the program becomes 'undefined'

    * some label error while loading asm.pp ".token" label
      not found. This was after writing parameterFromText().  Basically after
      the first call to parameterFromText() the scan position was not updated
      properly to the end of the text. So the system thought there was a
      second label (for the same jump instruction) which it attempted to
      resolve into a line number. Obviously jumps cannot have two target
      address for the same jump. I ignored the bug by ignoring the 
      second parameter for any jump instruction, but this may rear its head
      up later.

    * eg: b interactively, requires argument, then 'n', segmentation fault.
    * segmentation fault when growing the program.
    * if labels have trailing space, they dont work.
    * all scripts need (still?) an extra space at the end, other wise
      asm.pp cant read the final character. 

HISTORY

 13 sept 2019
   
   Separating this file ompp.c from gh.c and deleting duplicated
   comments. I would like to add a "tape truncation" parameter to 
   the showSomeTapeInfo() function, so that I can see what is 
   happening with machine even when the tapecells get very big.

*/

// <code> 

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include <unistd.h>

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
#include "exitcode.h" 
#include "machine.h" 
#include "machine.interp.h" 

/*
 execute a compiled instruction. Possible return values might be
        0: success no problems
        1: end of stream reached (tried to read eof)
        2: trying to execute undefined instruction
        3: quit/crash command executed (exit script)
        4: could not open 'sav.pp' for writing (from write command) 
        5: tried to execute unimplemented command
 */

// commands to test and analyse the machine
// these enumerations are in the same order as the informational 
// array below for convenience
enum TestCommand { 
  HELP=0, COMMANDHELP, SEARCHHELP, SEARCHCOMMAND, LISTMACHINECOMMANDS,
  DESCRIBEMACHINECOMMANDS, MACHINECOMMANDDOC, LISTCLASSES, LISTCOLOURS,
  MACHINEPROGRAM, MACHINESTATE, MACHINETAPESTATE, MACHINEMETA, BUFFERSTATE,
  STACKSTATE, TAPESTATE, TAPEINFO, TAPECONTEXTLESS, TAPECONTEXTMORE,
  RESETINPUT, RESETMACHINE,
  STEPMODE, PROGRAMMODE, MACHINEMODE, COMPILEMODE,
  IPCOMPILEMODE, ENDCOMPILEMODE, INTERPRETMODE, LISTPROGRAM, LISTSOMEPROGRAM, 
  LISTPROGRAMWITHLABELS, PROGRAMMETA, SAVEPROGRAM, 
  SHOWJUMPTABLE, LOADPROGRAM, LOADASM,
  LOADLAST, LOADSAVED, LISTSAVFILE, SAVELAST, CHECKPROGRAM, 
  CLEARPROGRAM, CLEARLAST, INSERTINSTRUCTION, 
  EXECUTEINSTRUCTION, PARSEINSTRUCTION, TESTWRITEINSTRUCTION, 
  STEPCODE, RUNCODE, RUNZERO, RUNCHARSLESSTHAN, RUNTOLINE, RUNTOTRUE, 
  RUNTOWORK, RUNTOENDSWITH,
  IPZERO, IPEND, IPGO, IPPLUS, IPMINUS,
  SHOWSTREAM,
  EXIT, UNKNOWN
};

// stepcode and executeinstruction below seem to be the 
// same exactly
struct {
  enum TestCommand c;
  char * names[2];
  char * argText;   // eg <command>
  char * description;
} testInfo[] = { 
  { HELP, {"hh", ""}, "",
     "list all interactive commands" },
  { COMMANDHELP, {"H", ""}, "<command>", 
     "show help for a given machine command" },
  { SEARCHHELP, {"/", "h/"}, "<search term>", 
     "searches help system for an interpreter command containing search term" },
  { SEARCHCOMMAND, {"//", "//"}, "<command search term>", 
     "searches help for a machine command containing search term" },
  { LISTMACHINECOMMANDS, {"com", ""}, "", 
     "list all machine commands" },
  { DESCRIBEMACHINECOMMANDS, {"Com", ""}, "", 
     "list and describe machine commands" },
  { MACHINECOMMANDDOC, {"doc", ""}, "", 
     "output machine commands in a documentation style format." },
  { LISTCLASSES, {"class", "cl"}, "", 
     "list all valid character classes for testclass and while" },
  { LISTCOLOURS, {"col", "colours"}, "", 
     "list all ansi colours" },
  { MACHINEPROGRAM, {"m", ""}, "", 
     "show state of machine, tape and current program instructions" },
  { MACHINESTATE, {"M", ""}, "", 
     "show the state of the machine" },
  { MACHINETAPESTATE, {"s", ""}, "", 
     "show state of the machine buffers with some tape cells" },
  { MACHINEMETA, {"Mm", ""}, "", 
     "show some meta information about the machine" },
  { BUFFERSTATE, {"bu", ""}, "", 
     "show the state of the machine buffer (stack/workspace)" },
  { STACKSTATE, {"Ss", "showstack"}, "", 
     "show the state of the machine stack" },
  { TAPESTATE, {"T", "t.."}, "", 
     "show the state of the machine tape" },
  { TAPEINFO, {"TT", "tapeinfo"}, "", 
     "show detailed info of the state of the machine tape" },
  { TAPECONTEXTLESS, {"tcl", "lesstape"}, "", 
     "reduce ammount of tape that will be displayed by printSomeTapeInfo()" },
  { TAPECONTEXTMORE, {"tcm", "moretape"}, "", 
     "increase ammount of tape to be displayed by printSomeTapeInfo()" },
  { RESETINPUT, {"i.r", ""}, "", 
     "reset the input stream" },
  { RESETMACHINE, {"M.r", ""}, "", 
     "reset the machine to original state" },
  { STEPMODE, {"m.s", ""}, "", 
     "make <enter> step through instructions" },
  { PROGRAMMODE, {"m.p", ""}, "", 
     "make <enter> display program state" },
  { MACHINEMODE, {"m.m", ""}, "", 
     "make <enter> display machine state" },
  { COMPILEMODE, {"m.c", ""}, "", 
     "set mode: entered instructions are compiled but "
     "not executed" },
  { IPCOMPILEMODE, {"m.ipc", ""}, "", 
     "set mode: entered instructions are compiled at current ip position" },
  { ENDCOMPILEMODE, {"m.ec", ""}, "", 
     "set mode: entered instructions are compiled at end of program" },
  { INTERPRETMODE, {"m.int", "interpret"}, "", 
     "set mode: entered instructions are executed but not compiled" },
  { LISTPROGRAM, {"ls", "p.ls"}, "", 
     "list all instructions in the machines current program" },
  { LISTSOMEPROGRAM, {"l", "list"}, "", 
     "list current instructions in the machines program" },
  { LISTPROGRAMWITHLABELS, {"pl", "p.ll"}, "", 
     "list all instructions in program with labels (and jump labels)" },
  { PROGRAMMETA, {"pm", "pi"}, "", 
     "show some meta information about the current program" },
  { SAVEPROGRAM, {"wa", "p.w"}, "<file>", 
     "save the current program as 'assembler'" },
  { SHOWJUMPTABLE, {"jj", "showjumps"}, "", 
     "Show the jumptable generated by buildJumpTable()" },
  { LOADPROGRAM, {"l.asm", "l.a"}, "<file>", 
     "load machine assembler commands from text file" },
  { LOADASM, {"asm", "as"}, "", 
     "load 'asm.pp' (the script parser) and reset the machine" },
  { LOADLAST, {"last", "p.ll"}, "", 
     "load 'last.pp' (the program automatically saved on exit)" },
  { LOADSAVED, {"sav", "l.sav"}, "", 
     "load 'sav.pp' (output of the 'write' command.)" },
  { LISTSAVFILE, {"lss", "ls.sav"}, "", 
     "list the contents of 'sav.pp' (output of the 'write' command.)" },
  { SAVELAST, {"ww", "p.ww"}, "", 
     "save 'last.pp' (the program automatically saved on exit)" },
  { CHECKPROGRAM, {"p.v", ""}, "", 
     "validate or check the machines compiled program " },
  { CLEARPROGRAM, {"p.dd", "dd"}, "", 
     "delete the machines compiled program " },
  { CLEARLAST, {"p.dl", "pdl"}, "", 
     "delete the last instruction in the compiled program " },
  { INSERTINSTRUCTION, {"pi", "p.i"}, "", 
     "insert an instruction at the current program ip " },
  { EXECUTEINSTRUCTION, {"n", "."}, "", 
     "execute the next (current) compiled instruction in program" },
  { PARSEINSTRUCTION, {"pi:", "pi"}, "<test instruction text>", 
     "parse some example text into a compiled instruction" },
  { TESTWRITEINSTRUCTION, {"twi", "twi"}, "", 
     "shows how the current instruction will be written by writeInstruction()" },
  { STEPCODE, {"p.s", "ps"}, "", 
     "step through the next instruction in compiled program" },
  { RUNCODE, {"rr", "p.r"}, "", 
     "run the whole compiled program from the current instruction" },
  { RUNZERO, {"r0", "p.r0"}, "", 
     "run the whole compiled program from instruction zero" },
  { RUNCHARSLESSTHAN, {"rrc", "runchars"}, "<number>", 
     "run program while characters read less than <number>" },
  { RUNTOLINE, {"rrl", "p.rl"}, "<number>", 
     "run the compiled program until given input stream line number" },
  { RUNTOTRUE, {"rrt", "p.rt"}, "", 
     "run the compiled program until flag is set to true" },
  { RUNTOWORK, {"rrw", "runwork"}, "<text>", 
     "run program until the workspace is exactly the given text" },
  { RUNTOENDSWITH, {"rre", "runworkendswith"}, "<text>", 
     "run program until the workspace ends with the given text" },
  { IPZERO, {"p<<", "p0"}, "", 
     "set the instruction pointer to zero" },
  { IPEND, {"p>>", "p.e"}, "", 
     "set the instruction pointer to the end of the program" },
  { IPGO, {"pg", "p.g"}, "", 
     "set the instruction pointer to the given instruction" },
  { IPPLUS, {"p>", "p.>"}, "", 
     "increment the instruction pointer without executing" },
  { IPMINUS, {"p<", "p.<"}, "", 
     "decrement the instruction pointer without executing" },
  { SHOWSTREAM, {"ss", "ss"}, "", 
     "shows the next few characters from the input stream" },
  { EXIT, {"X", "exit"}, "", 
     "exit the maching testing program" },
  { UNKNOWN, {"", ""}, "", ""}
};

/* display help for one interactive help command
   (not a machine command. which may be should be referred to 
   as instructions to avoid confusion) */
void printHelpCommand(int command, int comColour, int helpColour) {
  int ii = command;
  printf("%s%4s: %s%s%s ", 
     colourInfo[comColour].ansi, testInfo[ii].names[0], 
     colourInfo[helpColour].ansi,
     testInfo[ii].description, NORMAL);
}

/* Display help just for core help commands to assist the 
   user to start to use the interactive system */
void printUsefulCommands() {
  int commands[] = {
    HELP, MACHINEPROGRAM, LISTMACHINECOMMANDS, EXECUTEINSTRUCTION,
    LISTPROGRAM, RUNCODE};

  printf("\nUseful interactive commands: \n"
           "---------------  \n");
  int nn; 
  for (nn = 0; nn < 6; nn++) {
    printHelpCommand(commands[nn], YELLOWc, WHITEc); printf("\n");
  }
}

// check datatype of instruction etc
int checkInstruction(struct Instruction * ii, FILE * file) {
 
  if ((info[ii->command].args > 0) && (ii->a.datatype == UNSET))  {
    fprintf(file, "error: missing argument for command \n");
  }
  if ((commandType(ii->command) == JUMPS) && (ii->a.datatype != INT))  {
    //printf(file, "error: non integer \n");
  }
  if ((info[ii->command].args == 0) && (ii->a.datatype != UNSET))  {
    fprintf(file, "warning: superfluous argument for command %s%s%s \n",
        YELLOW, info[ii->command].name, NORMAL);
  }

  switch (ii->command) {
    case ADD:
      if (ii->a.datatype != TEXT) {
        fprintf(file, "Error: ADD requires 'text' datatype \n");
      }
      if (*ii->a.text == 0) {
        fprintf(file, "No text parameter for ADD \n");
      }
      break;
    case CLIP:
      break;
    case CLOP:
      break;
    case CLEAR:
      break;
    case PRINT:
      break;
    case POP:
      break;
    case PUSH:
      break;
    case PUT:
      break;
    case GET:
      break;
    case SWAP:
      break;
    case INCREMENT:
      break;
    case DECREMENT:
      break;
    case READ:
      break;
    case UNTIL:
    case WHILE:
    case WHILENOT:
      break;
    case JUMP:
      // validate all jump targets... is target undefined, in 
      // range of program etc etc.
      if (ii->a.datatype != INT) {
        fprintf(file, "error: Non integer target for jump instruction");
      } 
      break;
    case JUMPTRUE:
      if (ii->a.datatype != INT) {
        fprintf(file, "error: Non integer target for jump instruction");
      } 
      break;
    case JUMPFALSE:
      if (ii->a.datatype != INT) {
        fprintf(file, "error: Non integer target for jump instruction");
      } 
      break;
    case TESTIS:
      if (ii->a.datatype != TEXT) {
        fprintf(file, 
          "wrong datatype for parameter for TESTIS \n");
      }
      break;
    case TESTBEGINS:
      if (ii->a.datatype != TEXT) {
        fprintf(file, 
          "wrong datatype for parameter for TESTBEGINS \n");
      }
      break;
    case TESTENDS:
      if (ii->a.datatype != TEXT) {
        fprintf(file, 
          "wrong datatype for parameter for TESTENDS \n");
      }
      break;
    case TESTEOF:
      break;
    case TESTTAPE:
      break;
    case COUNT:
      break;
    case INCC:
      break;
    case DECC:
      break;
    case ZERO:
      break;
    case CHARS:
      break;
    case STATE:
      break;
    case QUIT:
      break;
    case WRITE:
      break;
    case NOP:
      break;
    case UNDEFINED:
      break;
    default:
      break;
  } // switch

  return -1;
} // checkInstruction

// steps through one instruction of the machines program
void step(struct Machine * mm) {
  //int result = 
  execute(mm, &mm->program.listing[mm->program.ip]);
}


/*
 runs the compiled program in the machine
 but this will exit when the last read is performed...
 execute() has the following exit codes which we might need to 
 handle:
  0: success no problems
  1: end of stream reached (tried to read eof)
  2: trying to execute undefined instruction
  3: quit/crash command executed (exit script)

*/

enum ExitCode run(struct Machine * mm) {
  int result;
  for (;;) { 
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
  return result;
}

void runDebug(struct Machine * mm) {
  int result;
  long ii = 0;  // a counter
  for (;;) { 
    printf("%6ld: ip=%3d T(n)=%3d", ii, mm->program.ip, mm->tape.currentCell);
    printInstruction(&mm->program.listing[mm->program.ip]);
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    printf("\n");
    if (result != 0) {
      printf("execute() returned error code (%d)\n", result);
      break;
    }
    ii++;
  }
}

/* another debugging tool: run while the number of characters read
   by the machine is less than maximum. This actually has a bug, 
   namely that we need to execute script commands even when the 
   peep is EOF. should exit when readc on EOF is executed.

   */ 
void runWhileCharsLessThan(struct Machine * mm, long maximum) {
  int result;
  while ((mm->peep != EOF) && (mm->charsRead < maximum)) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

/* another debugging tool: run until the input stream line number 
   is equal to the number */ 
void runToLine(struct Machine * mm, long maximum) {
  int result;
  while ((mm->peep != EOF) && (mm->lines < maximum)) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

// runs the compiled program in the machine until the 
// flag register is set to true 
void runUntilTrue(struct Machine * mm) {
  int result;  
  while (mm->flag == FALSE) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

/*
  runs the compiled program in the machine until the workspace
  is exactly the specified text */

void runUntilWorkspaceIs(struct Machine * mm, char * text) {
  int result;
  while ((mm->peep != EOF) && (strcmp(mm->buffer.workspace, text) != 0)) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

/*
int endsWith(const char *str, const char *suffix) {
  if (!str || !suffix) return 0;
  size_t lenstr = strlen(str);
  size_t lensuffix = strlen(suffix);
  if (lensuffix >  lenstr) return 0;
  return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}
*/

int startsWith(const char * text, const char * prefix)
{
  return strncmp(text, prefix, strlen(prefix));
}


/*
  runs the compiled program until the workspace
  is ends with the specified text */
void runUntilWorkspaceEndsWith(struct Machine * mm, char * text) {
  int result;
  while ((mm->peep != EOF) && (!endsWith(mm->buffer.workspace, text))) {
    result = execute(mm, &mm->program.listing[mm->program.ip]);
    if (result != 0) break;
  }
}

// given user input text return the test command
enum TestCommand textToTestCommand(const char * text) {
  int ii;
  if (*text == 0) return UNKNOWN;
  for (ii = 0; ii < UNKNOWN; ii++) {
    if ((strcmp(text, testInfo[ii].names[0]) == 0) ||
        (strcmp(text, testInfo[ii].names[1]) == 0)) {
       return (enum TestCommand)ii;
    }
  }
  return UNKNOWN;
}

void showTestHelp() {
  int ii;
  int key;
  printf("%s[ALL HELP COMMANDS]%s:\n", YELLOW, NORMAL);
  for (ii = 0; ii < UNKNOWN; ii++) {
    printf("%s%5s%s %s %s-%s %s%s \n",
      GREEN, testInfo[ii].names[0], PALEGREEN, testInfo[ii].argText,
      NORMAL, WHITE, testInfo[ii].description, NORMAL); 
    if ( (ii+1) % 14 == 0 ) {
      pagePrompt();
      key = getc(stdin);
      if (key == 'q') { return; }
    }
  }
}

// information about different modes the test program can be in
// eg step where enter steps through the next instruction.
// Or maybe 2 mode variables enterMode and programMode. enterMode
// determines what the <enter> key does, and programMode determines
// whether instructions are compiled or executed or both
enum TestMode {
  COMPILE=0, IPCOMPILE, ENDCOMPILE, INTERPRET, 
  MACHINE, PROGRAM, STEP, RUN } mode; 
// contain information about all commands
struct {
  enum TestMode mode;
  char * name;
  char * description;
} modeInfo[] = { 
  { COMPILE, "compile", 
    "enter displays the compiled program. Instructions entered are \n"
    "compiled into the machines program listing, but are not executed "},
  { IPCOMPILE, "ipcompile", 
    "Instructions are compiled into the machines program listing \n"
    "at the current instruction pointer position instead of at  \n"
    "the end of the program. This is a slightly clunky way of \n"
    "modifying the in-memory program, but possibly easier than trying \n"
    "to manually modify the text assembler listing. "},
  { ENDCOMPILE, "endcompile", 
    "Instructions are compiled into the machines program listing \n"
    "at the end of the program  \n" },
  { INTERPRET, "interpret", 
    "Instructions entered are executed but not compiled into the \n"
    "machine's program.  \n" },
  { MACHINE, "machine", "enter displays the state of the machine"},
  { PROGRAM, "", ""},
  { STEP, "step", 
    "When enter is pressed the next instruction is executed and "
    "the state of the machine is displayed "},
  { RUN, "run", 
    "When enter is pressed the current program is run. "}
};

// searches testInfo array for commands matching a search term
void searchHelp(char * text) {
  int ii; int jj = 0;
  char key;
  printf("%s[Searching help commands]%s:\n", YELLOW, NORMAL);
  for (ii = 0; ii < UNKNOWN; ii++) {
    if ((strstr(testInfo[ii].description, text) != NULL) || 
        (strstr(testInfo[ii].names[1], text) != NULL) || 
        (strstr(testInfo[ii].names[0], text) != NULL))  {
      jj++; 
      printf("%s%5s%s %s %s-%s %s%s \n",
        PURPLE, testInfo[ii].names[0], YELLOW, testInfo[ii].argText,
        NORMAL, BROWN, testInfo[ii].description, NORMAL); 
      if ( (jj+1) % 14 == 0 ) {
        pagePrompt();
        key = getc(stdin);
        if (key == 'q') { return; }
      }
    } // if search term found
  } // for

  if (jj == 0) {
    printf("No results found for '%s'\n", text); 
  }
}

/* load a script from file and install in the machines program at
   instruction number "position". This allows us to append one
   script at the end of another which may be useful. */
enum ExitCode loadScript(
   struct Program * program, FILE * scriptFile, int position) {

    /* the procedure is:
      load asm.pp, run it on the script-file (assembly is saved to sav.pp)
      load sav.pp, run it on the input stream. */
    FILE * asmFile;
    if ((asmFile = fopen("asm.pp", "r")) == NULL) {
      printf("Could not open assembler %sasm.pp%s \n", 
        YELLOW, NORMAL);
      return 1;
    } 
    FILE * savFile;
    // first delete contents of the sav.pp file to avoid confusion
    // later.
    if ((savFile = fopen("sav.pp", "w")) == NULL) {
      printf("Could not open script file %s'sav.pp'%s for writing \n", 
        YELLOW, NORMAL);
      return(1);
    } 

    fputs("add \"no script\" \n", savFile);
    fputs("quit \n", savFile);
    fclose(savFile);

    struct Machine new;
    newMachine(&new, scriptFile, TAPESTARTSIZE, 10);
    loadAssembledProgram(&new.program, asmFile, 0);

    int result = 0;
    result = run(&new);

    /*
     check if the compilation was successful. (which means 
     ExitCode SUCCESS of EXECQUIT) If not successful, do not proceed.
     because the script file was not properly compiled by asm.pp
    */

    if (result > EXECQUIT) {
      // try to give a more informative error message here
      // showMachineTapeProgram(&new, 3);
    }

    //runDebug(&m);
    fclose(asmFile);
    freeMachine(&new);

    if (result > EXECQUIT) {
      return result;
    }

    // asm.pp has created a new sav.pp file, which is the 
    // script in a "compiled" form (a type of assembly language
    // for the parse virtual machine. We can now open, load  
    // it and run it. 
    if ((savFile = fopen("sav.pp", "r")) == NULL) {
      printf("Could not open script file %s'sav.pp'%s for reading. \n", 
        YELLOW, NORMAL);
      return READSAVERROR;
    } 
    loadAssembledProgram(program, savFile, 0);
    fclose(savFile);
    //freeMachine(&new);
    return SUCCESS;
}

void printUsageHelp() {
  fprintf(stdout, "'pp' a pattern parsing machine \n"
    "Usage: pp [-shI] [-i 'text'] [-e 'snippet'] [-f script-file] [-a file] [inputfile] \n"
    " \n"
    "  -f script-file   text input file \n"
    "  -e expression    add inline script commands to script \n"
    "  -i text          use 'text' as input for the script \n"
    "  -h               print this help \n"
    "  -s               run in unix filter mode (the default).\n"
    "  -a [file]        load script-assembly source file \n"
    "  -I               run in interactive mode (with shell) \n");
    //"  -M               print the state of the machine after compiling \n"
    //"                   a script. This option is useful for debugging. \n"
}

// The main testing loop for the machine. This accepts interactive 
// commands and executes them, among other things. Allows the state
// of the machine to be observed, including the compiled program.
int main (int argc, char *argv[]) {

  int c;
  // name of the file with script assembly commands
  char * asmFileName = NULL;
  // name of file to serve as input stream
  char * inputFile = NULL;
  // name of the file with parse script commands
  char * scriptFileName = NULL;
  // script commands on the command line with the -e switch
  char * inlineScript = NULL;
  // inline input (instead of an input file) 
  char * inlineInput = NULL;

  char source[64] = "input.txt";
  // if asm.pp generate an error, then the machine parse state will
  // be printed.
  enum Bool printState = FALSE;
  /* filtermode means the program is used as a unix filter, like sed, grep etc
     intermode means the program starts an interactive shell, so that 
     the user can debug scripts and learn about the machine */
  enum { FILTERMODE, INTERMODE } progmode = FILTERMODE;
  // determines how much of the tape will be shown by printSomeTapeInfo()
  // and showMachineTapeProgram()
  int tapeContext = 3;
  // (initial) number of tapecells
  int tapeSize = 500;

  opterr = 0;

  while ((c = getopt (argc, argv, "i:f:e:IsMha:")) != -1) {
    switch (c) {
      // a text input file, but this should be a non-option argument
      // (just the file name).
      case 'f':
        scriptFileName = optarg;
        break;
      case 'e':
        inlineScript = optarg;
        break;
      case 'i':
        inlineInput = optarg;
        break;
      case 'I':
        progmode = INTERMODE; 
        break;
      case 's':
        progmode = FILTERMODE; 
        break;
      case 'M':
        printState = TRUE; 
        break;
      case 'h':
        printUsageHelp();
        break;
      case 'a':
        asmFileName = optarg;
        break;
      case '?':
        switch (optopt) {
          case 'a':
            fprintf (stderr, "Option -%c requires an argument.\n", optopt);
            fprintf (stderr, " -a scriptAssemblyFile \n");
            break;
          case 'f': 
            fprintf (
              stderr, "%s: option -%c requires an argument.\n", 
              argv[0], optopt);
            break;
          case 'e': 
          case 'i': 
            fprintf (
              stderr, "%s: option -%c requires an argument.\n", 
              argv[0], optopt);
            break;
          default:
            fprintf (stderr, "%s: unknown option -- %c \n", argv[0], optopt);
            break;
        }
        printUsageHelp(); 
        exit(1);
      default:
        abort ();

    }
  } // while

  if (argv[optind] != NULL) 
    { inputFile = argv[optind]; }

  if ((asmFileName != NULL) && (scriptFileName != NULL)) {
    printf("cannot load assembly and script at the same time (-a and -f)");
    printUsageHelp();
    exit(1);
  }

  char version[64] = "v31415";

  if (progmode != FILTERMODE) {
    banner() ;
    printf("Compiled: %s%s%s \n", YELLOW, version, NORMAL);
  }

  struct Machine m; 

  //struct Instruction i;

  if (inputFile != NULL) { 
    strcpy(source, inputFile);
  }


  if ((inlineInput == NULL) && (inputFile == NULL)) {
    fprintf(stdout, "No input given to script (use -i or inputFile)\n");
    printUsageHelp();
    exit(1);
  }

  if ((inlineInput != NULL) && (inputFile != NULL)) {
    fprintf(stdout, "cannot use -i switch and inputFile together\n");
    printUsageHelp();
    exit(1);
  }

  /* use input given to the -i switch. This is a convenience for 
     testing scripts */
  if (inlineInput != NULL) {
    FILE * temp = NULL;
    if ((temp = fopen("tempInput.txt", "w")) == NULL) {
      printf("Could not open temporary file %stempInput.txt%s for writing \n", 
        YELLOW, NORMAL);
      exit(1);
    } 
    fputs(inlineInput, temp);
    fclose(temp);

    strcpy(source, "tempInput.txt");
  }

  // mode determines how the enter key behaves. Also, in compile mode
  // instructions are compiled into the machines program but not automatically
  // executed
  enum TestMode mode = INTERPRET;
  enum TestCommand testCom;

  FILE * inputStream;

  if((inputStream = fopen (source, "r")) == NULL) {
    printf ("Cannot open file %s%s%s \n", YELLOW, source, NORMAL);
    printf ("Try %s%s -i <inputfile>%s \n", CYAN, argv[0], NORMAL);
    exit (1);
  }
  //else { inputStream = stdin; }

  if (progmode != FILTERMODE) {
    printf("Using source file %s%s%s as input stream \n", 
      YELLOW, source, NORMAL);
    printUsefulCommands();

  }

  FILE * asmFile;
  FILE * scriptFile;

  // machine, input stream, tape cells, tape cells size, and program listing
  newMachine(&m, inputStream, tapeSize, 10);
  // now we can use the machine to parse etc
  if (asmFileName != NULL) {
    if ((asmFile = fopen(asmFileName, "r")) == NULL) {
      printf("Could not open script-assembler file %s%s%s \n", 
        YELLOW, asmFileName, NORMAL);
      freeMachine(&m);
      exit(1);
    } 
    if (progmode != FILTERMODE) {
      printf("\n");
      printf("Loading assembler file %s%s%s \n", YELLOW, asmFileName, NORMAL);
    }
    strcpy(m.program.source, "asm.pp"); 
    loadAssembledProgram(&m.program, asmFile, 0);

    if (progmode != FILTERMODE) {

      printf("Compiled %s%d%s instructions "
             "from '%s%s%s' in about %s%ld%s milliseconds \n",
        CYAN, m.program.count, NORMAL, 
        CYAN, m.program.source, NORMAL,
        CYAN, m.program.compileTime, NORMAL);
    }
    fclose(asmFile);
  }

  if (scriptFileName != NULL) {
    if ((scriptFile = fopen(scriptFileName, "r")) == NULL) {
      printf("Could not open script file %s%s%s \n", 
        YELLOW, scriptFileName, NORMAL);
      freeMachine(&m);
      exit(1);
    } 
    if (progmode != FILTERMODE) {
      printf("\n");
      printf("Loading script file %s%s%s \n", YELLOW, scriptFileName, NORMAL);
    }
    /* the procedure is:
      load asm.pp, run it on the script-file (assembly is saved to sav.pp)
      load sav.pp, run it on the input stream. */
    int result = loadScript(&m.program, scriptFile, 0);
    fclose(scriptFile);
    /*
    if (printState == TRUE) {
      showMachineTapeProgram(&m, 3);
    } */

    if (result > EXECQUIT) {
      fprintf(stderr, 
        "The script file '%s' could not be compiled. \n", scriptFileName); 
      printExitCode(result);
      freeMachine(&m);
      exit(result);
    }
  }
  /* add commands given to the -e switch to the current program */
  if (inlineScript != NULL) {
    /* the procedure is:
      save the -e script commands to a temporary file
      compile the commands to sav.pp with asm.pp 
      load sav.pp, run it on the input stream. */
    FILE * temp = NULL;
    if ((temp = fopen("temp.pp", "w")) == NULL) {
      printf("Could not open temporary file %stemp.pp%s for writing \n", 
        YELLOW, NORMAL);
      freeMachine(&m);
      exit(1);
    } 

    fputs(inlineScript, temp);
    // this is a cludge because asm.pp doesnt deal with
    // the last character of input. 
    fputs(" ", temp);
    fclose(temp);

    if ((temp = fopen("temp.pp", "r")) == NULL) {
      printf("Could not open temporary file %stemp.pp%s for reading \n", 
        YELLOW, NORMAL);
      freeMachine(&m);
      exit(1);
    } 

    if ((asmFile = fopen("asm.pp", "r")) == NULL) {
      printf("Could not open assembler %sasm.pp%s \n", 
        YELLOW, NORMAL);
      exit(1);
    } 

    if (progmode != FILTERMODE) {
      printf("Loading assembler %sasm.pp%s \n", YELLOW, NORMAL);
    }

    // need a parameter to loadScript if we want to show machine
    // state after a compilation error
    int result = loadScript(&m.program, temp, m.program.count);
    fclose(temp);
    if (result > EXECQUIT) {
      fprintf(stderr, 
        "The inline script in -e '%s' "
        "was not compiled. \n", inlineScript); 
      printExitCode(result);
      freeMachine(&m);
      if (inputStream != NULL) fclose(inputStream);
      inputStream = NULL;
      exit(result);
    }
  }

  if (progmode == FILTERMODE) {
    //or runDebug(&m);
    run(&m);
    freeMachine(&m);
    if (inputStream != NULL) fclose(inputStream);
    inputStream = NULL;
    exit(0);
  }

  char line[401];
  char command[201];
  char argA[201];
  char argB[201];
  char args[300];

  while (1) {
    printf(">");
    fgets(line, 400, stdin);
    // remove newline
    line[strlen(line) - 1] = '\0';
    //printf("input[%s]\n", line);
      
    command[0] = args[0] = argA[0] = argB[0] = '\0';
    // int result;
    sscanf(line, "%200s %200[^\n]", command, args);

    // we also need to deal with quoted arguments such as
    //  a "many words"
    //  eg ranges [a-z] character classes :alpha: etc.

   /*
   A good example of sscanf with different cases
    res = sscanf(buf, 
      " \"%5[^\"]\" \"%19[^\"]\" \"%29[^\"]\" %lf %d", 
      p->number, p->name, p->description, &p->price, &p->qty);

   if (res < 5) {
     static const char *where[] = {
        "number", "name", "description", "price", "quantity"};
    if (res < 0) res = 0;
    fprintf(stderr, 
      "Error while reading %s in line %d.\n", where[res], nline);
       break;
   }
   */

    // eg sscanf(line, "%200s '%200[^']'", command, argA)
    // printf("c=%s, argA=%s, argB=%s \n", command, argA, argB);

    testCom = textToTestCommand(command);
    //printf("testcom= %s \n", testInfo[testCom].description);

    if (testCom == HELP) {
      showTestHelp();
    }
    else if (testCom == SEARCHCOMMAND) {
      if (strlen(args) == 0) {
        printf("No command seach term specified. \n");
        printf("Try: // <search-term> \n");
        continue;
      }
      searchCommandHelp(args);
    }
    else if (testCom == SEARCHHELP) {
      if (strlen(args) == 0) {
        printf("No seach term specified. \n");
        printf("Try: / <search-term> \n");
        continue;
      }
      searchHelp(args);
    }
    else if (testCom == COMMANDHELP) {
      if (strlen(args) == 0) {
        printf("No machine command specified. \n");
        continue;
      }
      if (textToCommand(args) == UNDEFINED) {
        printf("Not a valid machine command %s%s%s \n", YELLOW, args, NORMAL);
        continue;
      }
      enum Command thisCom = textToCommand(args);
      printf("name: %s %s(%s%c%s)%s \n", 
        info[thisCom].name, GREY, GREEN, info[thisCom].abbreviation, 
        GREY, NORMAL);
      printf("   %s \n", info[thisCom].shortDesc);
      printf("   %s \n", info[thisCom].longDesc);
      printf("example: %s \n", info[thisCom].example);
      printf("takes %s%d%s argument(s) \n", YELLOW, info[thisCom].args, NORMAL);
    }
    else if (testCom == LISTMACHINECOMMANDS) {
      showCommandNames();
    }
    else if (testCom == DESCRIBEMACHINECOMMANDS) {
      machineCommandHelp();
    }
    else if (testCom == MACHINECOMMANDDOC) {
      machineCommandAsciiDoc(stdout);
    }
    else if (testCom == LISTCLASSES) {
      printClasses();
    }
    else if (testCom == LISTCOLOURS) {
      showColours();
    }
    else if (testCom == MACHINEPROGRAM) {
      showMachineTapeProgram(&m, tapeContext);
    }
    else if (testCom == MACHINESTATE) {
      showMachine(&m, TRUE);
    }
    else if (testCom == MACHINETAPESTATE) {
      showMachineWithTape(&m);
    }
    else if (testCom == MACHINEMETA) {
      printMachineMeta(&m);
    }
    else if (testCom == BUFFERSTATE) {
      showBufferInfo(&m.buffer);
    }
    else if (testCom == STACKSTATE) {
      showStackWorkPeep(&m, TRUE);
    }
    else if (testCom == TAPESTATE) {
      printSomeTape(&m.tape, TRUE);
    }
    else if (testCom == TAPEINFO) {
      printTapeInfo(&m.tape);
    }
    else if (testCom == TAPECONTEXTLESS) {
      if (tapeContext > 0) tapeContext--;
      printf("Tape display variable set to %d\n", tapeContext);
    }
    else if (testCom == TAPECONTEXTMORE) {
      tapeContext++;
      printf("Tape display variable set to %d\n", tapeContext);
    }
    else if (testCom == RESETINPUT) {
      rewind(inputStream);
      printf ("%s Rewound the input stream %s \n", YELLOW, NORMAL);
    }
    else if (testCom == RESETMACHINE) {
      colourPrint("reinitializing machine ...\n");
      resetMachine(&m);
    }
    else if (testCom == STEPMODE) {
      mode = STEP;
      printf(
        "%sSTEP%s mode (<enter> steps next instruction)\n", 
        YELLOW, NORMAL);
    }
    else if (testCom == PROGRAMMODE) {
      mode = PROGRAM;
      printf(
        "%sPROGRAM%s mode (<enter> displays program listing)\n", 
         YELLOW, NORMAL);
    }
    else if (testCom == MACHINEMODE) {
      mode = MACHINE;
      printf(
        "%sMACHINE%s mode (<enter> displays machine state)\n", 
        YELLOW, NORMAL);
    }
    else if (testCom == COMPILEMODE) {
      printf ("Not implemented ... \n");
    }
    else if (testCom == IPCOMPILEMODE) {
      mode = IPCOMPILE;
      printf ("Mode set to %sIPCOMPILE%s \n", YELLOW, NORMAL);
      printf (
        "  Instructions will be compiled into the program \n"
        "  at the current instruction pointer position, instead \n"
        "  of at the end of the program. \n");
    }
    else if (testCom == ENDCOMPILEMODE) {
      mode = ENDCOMPILE;
      printf ("Mode set to %sENDCOMPILE%s \n", YELLOW, NORMAL);
    }
    else if (testCom == INTERPRETMODE) {
      mode = INTERPRET;
      printf("Mode set to %sINTERPRET%s \n", YELLOW, NORMAL);
      printf("  %smachine commands will be executed but not compiled \n"
             "  to the internal program.%s \n",
             WHITE, NORMAL);
    }
    // ENTER key pressed ....
    else if (strcmp(command, "") == 0) {
      if (mode == MACHINE) {
        // to do: show the stream with ftell and fseek
        showMachine(&m, TRUE);
      }
      else if (mode == STEP) {
        step(&m);
        printSomeProgram(&m.program, 5);
        showMachine(&m, TRUE);
      }
      else if (mode == PROGRAM) {
        printSomeProgram(&m.program, 5);
      }
    }
    else if (strcmp(command, "BB") == 0) {
      showBufferAndPeep(&m);
    }
    else if (testCom == LISTPROGRAM) {
      printProgram(&m.program);
    }
    else if (testCom == LISTSOMEPROGRAM) {
      printSomeProgram(&m.program, 7);
    }
    else if (testCom == LISTPROGRAMWITHLABELS) {
      printProgramWithLabels(&m.program);
    }
    else if (testCom == PROGRAMMETA) {
      printProgramMeta(&m.program);
    }
    else if (testCom == SAVEPROGRAM) {
      FILE * savefile;
      if (strlen(args) == 0) {
        printf ("%s No save file given! %s \n", CYAN, NORMAL);
        printf ("%s Try %sP.wa <filename> %s \n", GREEN, YELLOW, NORMAL);
        continue;
      }
      if ((savefile = fopen (args, "w")) == NULL) {
        printf ("Could not open file %s%s%s for writing \n", 
          YELLOW, args, NORMAL);
        continue;
      }
      saveAssembledProgram(&m.program, savefile);
      fclose(savefile);
    }
    else if (testCom == SHOWJUMPTABLE) {
      printJumpTable(m.program.labelTable);
    }
    else if (testCom == LOADPROGRAM) {
      FILE * loadfile;
      if (strlen(args) == 0) {
        printf ("%s No assembly text file given to load %s \n", GREEN, NORMAL);
        continue;
      }
      if ((loadfile = fopen (args, "r")) == NULL) {
        printf ("Could not open file %s%s%s for reading\n", YELLOW, args, NORMAL);
        continue;
      }
      loadAssembledProgram(&m.program, loadfile, 0);
      strcpy(m.program.source, args); 
      fclose(loadfile);
    }
    else if (testCom == LOADASM) {
      FILE * loadfile;
      if ((loadfile = fopen ("asm.pp", "r")) == NULL) {
        printf ("Could not open file %sasm.pp%s for reading\n", 
           YELLOW, NORMAL);
        continue;
      }
      printf("%sresetting machine and loading '%sasm.pp%s'... \n",
        BROWN, PINK, NORMAL);
      rewind(inputStream);
      resetMachine(&m);
      clearProgram(&m.program);
      strcpy(m.program.source, "asm.pp"); 
      loadAssembledProgram(&m.program, loadfile, 0);
      fclose(loadfile);
    }
    else if (testCom == LOADLAST) {
      FILE * loadfile;
      if ((loadfile = fopen ("last.pp", "r")) == NULL) {
        printf ("Could not open file %slast.pp%s for reading\n", 
          YELLOW, NORMAL);
        continue;
      }
      strcpy(m.program.source, "last.pp"); 
      loadAssembledProgram(&m.program, loadfile, 0);
      fclose(loadfile);
    }
    else if (testCom == LOADSAVED) {
      FILE * loadfile;
      if ((loadfile = fopen ("sav.pp", "r")) == NULL) {
        printf ("Could not open file %ssav.pp%s for reading\n", 
          YELLOW, NORMAL);
        continue;
      }
      strcpy(m.program.source, "sav.pp"); 
      loadAssembledProgram(&m.program, loadfile, 0);
      fclose(loadfile);
    }
    else if (testCom == LISTSAVFILE) {
      FILE * loadfile;
      char line[200];
      char key;
      int ii = 0;

      if ((loadfile = fopen("sav.pp", "r")) == NULL) {
        printf ("Could not open file %ssav.pp%s for reading\n", 
          YELLOW, NORMAL);
        continue;
      }
      while (fgets(line, sizeof(line), loadfile)) {
        printf("%s", line);
        if ((ii+1) % 14 == 0) {
          pagePrompt();
          key = getc(stdin);
          if (key == 'q') { break; }
        }
      }
      fclose(loadfile);
    }
    else if (testCom == SAVELAST) {
      FILE * savefile;
      if ((savefile = fopen ("last.pp", "w")) == NULL) {
        printf ("Could not open file %slast.pp%s for writing \n", 
          YELLOW, NORMAL);
        continue;
      }
      saveAssembledProgram(&m.program, savefile);
      fclose(savefile);
    }
    else if (testCom == CHECKPROGRAM) {
      printf("Not implemented \n");
    }
    else if (testCom == CLEARPROGRAM) {
      clearProgram(&m.program);
    }
    else if (testCom == CLEARLAST) {
      // need to set last instruction to undefined 
      newInstruction(&m.program.listing[m.program.count-1], UNDEFINED);
      m.program.count--;
      printSomeProgram(&m.program, 7);
    }
    else if (testCom == INSERTINSTRUCTION) {
      // insert an instruction at the current program ip
      // need to recalculate jump address (add 1)
      printf ("Inserting instruction at %s%d%s \n",
        YELLOW, m.program.ip, NORMAL);
      insertInstruction(&m.program);
      printProgram(&m.program);
    }
    else if (testCom == EXECUTEINSTRUCTION) {
      execute(&m, &m.program.listing[m.program.ip]);
      showMachineTapeProgram(&m, tapeContext);
      /*
      printSomeProgram(&m.program, 6);
      printf("%s--------- Machine State ----------%s \n", 
         YELLOW, NORMAL);
      showMachine(&m);
      */
    }
    else if (testCom == PARSEINSTRUCTION) {
      struct Instruction * ii;
      struct Label table[100];  // void jumptable
      printf("testing instructionFromText()...\n");
      if (strlen(args) == 0) {
        printf ("%s No example instruction given... %s \n"
                " Try %spi: add {this}%s \n", GREEN, NORMAL, YELLOW, NORMAL);
        continue;
      }
      newInstruction(ii, UNDEFINED);
      instructionFromText(stdout, ii, args, -1, table);
      printEscapedInstruction(ii);
      printf("\n");
    }
    else if (testCom == TESTWRITEINSTRUCTION) {
      printf("Testing writeInstruction()... \n");
      writeInstruction(&m.program.listing[m.program.ip], stdout);  
    }
    else if (testCom == STEPCODE) {
      printf("step through next compiled instruction:\n");
      step(&m);
      printSomeProgram(&m.program, 6);
    }
    else if (testCom == RUNCODE) {
      printf("%sRunning program from instruction %s%d%s...%s\n", 
        GREEN, CYAN, m.program.ip, GREEN, NORMAL);
      run(&m);
      printf("\n%s--------- Machine State ----------%s \n", 
         YELLOW, NORMAL);
      showMachine(&m, TRUE);
    }
    else if (testCom == RUNZERO) {
      printf("%sRunning program from ip 0%s\n", GREEN, NORMAL);
      m.program.ip = 0;
      run(&m);
    }
    else if (testCom == RUNCHARSLESSTHAN) {
      int maximum;
      if (!sscanf(args, "%d", &maximum) ||  (strlen(args) == 0)) {
        printf ("%sNo number argument given%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrc %s<number>%s \n", GREEN, YELLOW, NORMAL);
        continue;
      }
      printf("%sRunning while characters less than %d%s\n", 
         GREEN, maximum, NORMAL);
      runWhileCharsLessThan(&m, maximum);
      showMachineTapeProgram(&m, 2);
    }
    else if (testCom == RUNTOLINE) {
      int maximum;
      if (!sscanf(args, "%d", &maximum) ||  (strlen(args) == 0)) {
        printf ("%sNo line number argument given%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrc %s<number>%s \n", GREEN, YELLOW, NORMAL);
        continue;
      }
      printf("%sRunning until input line number is %d%s\n", 
         GREEN, maximum, NORMAL);
      runToLine(&m, maximum);
      showMachineTapeProgram(&m, 2);
    }
    else if (testCom == RUNTOTRUE) {
      printf("run program until the flag is set to true\n");
      runUntilTrue(&m);
      showMachineTapeProgram(&m, 2);
    }
    else if (testCom == RUNTOWORK) {
      if (strlen(args) == 0) {
        printf ("%sNo text given to compare%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrw %s<text>%s \n", GREEN, YELLOW, NORMAL);
        printf ("   runs the current program until workspace is <text> \n");
        continue;
      }
      printf("Running program until workspace is \"%s%s%s\" \n", 
         YELLOW, args, NORMAL);
      runUntilWorkspaceIs(&m, args);
      // printf("%s--------- Machine State ----------%s \n", 
      //   YELLOW, NORMAL);
      showMachineWithTape(&m);
    }
    else if (testCom == RUNTOENDSWITH) {
      if (strlen(args) == 0) {
        printf ("%sNo text given to compare%s \n", GREEN, NORMAL);
        printf ("%sUsage: rrw %s<text>%s \n", GREEN, YELLOW, NORMAL);
        printf ("   runs the program until workspace ends with <text> \n");
        continue;
      }
      printf("Running program until workspace ends with \"%s%s%s\" \n", 
         YELLOW, args, NORMAL);
      runUntilWorkspaceEndsWith(&m, args);
      showMachineTapeProgram(&m, tapeContext);
    }
    else if (testCom == IPZERO) {
      m.program.ip = 0;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPEND) {
      m.program.ip = m.program.count-1;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPGO) {
      if (strlen(args) == 0) {
        printf ("%s No number given to jump to %s \n", GREEN, NORMAL);
        continue;
      }
      int ipnumber = 0;
      int res = sscanf(args, " %d", &ipnumber);
      if (res < 1) {
        printf ("%s Couldnt parse number %s \n", GREEN, NORMAL);
        continue;
      }
      m.program.ip = ipnumber; 
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPPLUS) {
      m.program.ip++;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == IPMINUS) {
      m.program.ip--;
      printSomeProgram(&m.program, 4);
    }
    else if (testCom == SHOWSTREAM) {
      // show some upcoming chars from stream and then
      // reset stream position
      long pos = ftell(m.inputstream);
      int num = 40;
      char c;
      int ii = 0;
      printf ("%sNext %s%d%s chars in input stream...%s\n", 
        GREEN, YELLOW, num, GREEN, BLUE);
      while (((c = fgetc(m.inputstream)) != EOF) && (ii < num)) {
        printf("%c", c);
        ii++;
      }
      printf("%s\n", NORMAL);
      fseek(m.inputstream, pos, SEEK_SET);
    }
    // deal with pure machine commands (not testing commands)
    else if (textToCommand(command) != UNDEFINED) {
      void * p = NULL; // no jump table here
      if (mode == IPCOMPILE) {
        compile(&m.program, line, m.program.ip, p);
      }
      else if (mode == INTERPRET) {
        // execute the entered command but dont insert it 
        // in the program.
        struct Instruction ii;
        instructionFromText(stdout, &ii, line, 0, p);
        execute(&m, &ii);
        // execute automatically advances ip pointer, which we
        // dont want in this case. Jumps will probably not be entered
        // interactively so, should not cause trouble here.
        m.program.ip--;
        showMachineTapeProgram(&m, tapeContext);
        continue;
      }
      else {
        compile(&m.program, line, m.program.count, p);
      }
      // check if the instruction is ok
      // checkInstruction(&m.program.listing[m.program.count-1], stdout);

      if (mode == COMPILE) {
        showMachineTapeProgram(&m, tapeContext);
      } else step(&m);

      m.program.ip = m.program.count;
      showMachineTapeProgram(&m, tapeContext);
    }
    else if (testCom == EXIT) {
      printf("%sSaving program to '%slast.pp%s'...\n", 
        GREEN, YELLOW, GREEN);
      FILE * savefile;
      if ((savefile = fopen ("last.pp", "w")) == NULL) {
        printf ("Could not open file %slast.pp%s for writing \n", 
          YELLOW, NORMAL);
        continue;
      }
      saveAssembledProgram(&m.program, savefile);

      fclose(savefile);
      fclose(inputStream);
      colourPrint("Freeing Machine memory...\n");
      freeMachine(&m);
      colourPrint("Goodbye !!\n");
      exit(1);
    }
    else {
      printf("%sUnrecognised command:%s %s %s \n", 
        BROWN, command, GREEN, NORMAL);
    }

  }

  fclose(inputStream);
  return(0);
}
// </code>

/*
*/
