

/* the enum, array of structures, and associated functions are 
   to provide readable exit and error codes for functions such as
   execute(), run(), compile(), loadScript(), etc 
   EXECQUIT is actually a success code, where as BADQUIT (returned
   by the "bail" command, is an error.
   */

#include <stdio.h>
#include "exitcode.h"

struct Code exitCodes[] = { 
  { SUCCESS, "success, no errors" },
  { EXECQUIT, "quit was executed (exit script)" },
  { ENDOFSTREAM, "tried to read past end of stream (eof)" },
  { EXECUNDEFINED, "tried to execute undefined machine instruction" },
  { BADQUIT, "program exited with an error" },
  { READSAVERROR, "could not open 'sav.pp' for reading" },
  { WRITESAVERROR, "could not open 'sav.pp' for writing" },
  { UNIMPLEMENTED, "executed an unimplemented machine instruction" }
};

// print the description for an error
void printExitCode(enum ExitCode error) {
  printf("(%d) %s\n", exitCodes[error].error, exitCodes[error].description);
}

