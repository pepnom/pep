
enum commandtypes
{ ADD = 1,              /* adds a given text to the workbuffer */
  CLEAR,                /* clears the workspace */
  PRINT,                /* prints the workspace to stdout */
  DUMP,                 /* prints the current state of the machine */
  TAPE,                 /* prints all tape elements and stack */
  BURP,                 /* prints a very detailed dump of the machine */           
  ESCAPE,               /* turns escape sequences in the workspace to chars */
  REPLACE,              /* todo: reconsider */
  INDENT,               /* indents each line of the workspace */
  CLIP,                 /* removes the last character of the workspace */
  CLOP,                 /* removes the first character of the workspace */
  NEWLINE,                      /* adds a newline to the  workspace */
  PUSH,                         /* pushes part/all of the workspace to the stack */
  POP,                          /* pops the stack to the workspace */
  PUT,
  GET,
  INCREMENT,
  DECREMENT,
  READ,                         /* read a character from the input stream */
  UNTIL,
  WHILE,
  WHILENOT,
  TESTIS,
  TESTBEGINS,
  TESTCLASS,
  TESTENDS,
  TESTLIST,
  TESTEOF,
  TESTTAPE,
  TIME,                         /* adds the amount of time the machine has run */
  COUNT,
  INCC,                         /* increment the accumulator or counter */
  DECC,                         /* decrement the accumulator or counter */
  CRASH,                        /* exits the script immediately */
  OPENBRACE,
  CLOSEBRACE,
  ZERO,                         /* sets the accumulator to zero */
  JUMP,                         /* an unconditional jump */
  CHECK,                        /* a shift reduce jump, todo: reassess */
  LABEL,                        /* todo: reassess this */
  NOP,                          /* no operation */
  UNDEFINED,                    /* the default */
  UNKNOWN
};

void fnPrintCommands(int iWidth);
wchar_t * fnCommandToDisplayString(wchar_t * sReturn, int iCommand);

