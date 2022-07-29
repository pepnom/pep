#ifndef COMMAND_H
#define COMMAND_H

  #define TRUE 0
  #define FALSE 1

   enum commandtype
   { ADD = 1,          /* adds a given text to the workbuffer */
     CLEAR,            /* clears the workspace */
     PRINT,            /* prints the workspace to stdout */
     DUMP,             /* prints the current state of the machine */
     TAPE,             /* prints all tape elements and stack */
     BURP,             /* prints a very detailed dump of the machine */ 
     ESCAPE,           /* turns escape sequences in the workspace to chars */
     REPLACE,     /* ??? unimplemened ???  */
     INDENT,      /* indents each line of the workspace */
     CLIP,        /* removes the last character of the workspace */
     CLOP,        /* removes the first character of the workspace */
     NEWLINE,     /* adds a newline to the  workspace */
     PUSH,        /* pushes the next token in the  workspace onto the stack */
     POP,         /* pops the next token onto the workspace */
     PUT,         /* put the contents of the workspace in the tape */
     GET,         /* adds the current tape element to the workspace */
     SWAP,        /* swaps the current tape element with the workspace */
     INCREMENT,   /* increases the tape pointer by one */
     DECREMENT,   /* decreases the tape pointer by one */
     READ,      /* read one (wide) character from the input stream */
     UNTIL,     /* read the input stream until the workspace ends with ... */
     WHILE,     /* read the input stream while the 'peep' is ... */
     WHILENOT,    /* ??? unimplemented ??? */
     TIME,           /* adds the amount of time the machine has run */
     COUNT,      
     INCC,           /* increment the accumulator or counter */
     DECC,           /* decrement the accumulator or counter */
     CRASH,          /* exits the script immediately */
     ZERO,           /* sets the accumulator to zero */
     JUMP,           /* an unconditional jump to a line number */
     LABEL,          /* todo: reassess this */
     CHECK,          /* ??? a shift reduce jump, remove ??? */
     NOP,                          /* no operation */
     TESTIS,
     TESTBEGINS,
     TESTCLASS,
     TESTENDS,
     TESTLIST,
     TESTEOF,
     TESTTAPE,
     OPENBRACE,      /* does nothing, for calculating jumps */
     CLOSEBRACE,     /* does nothing, for calculating jumps */
     UNDEFINED,                    /* the default */
     UNKNOWN
   };

   struct command
   {
     enum commandtype type;
     int arguments;
     wchar_t shortform[5];
     wchar_t longform[50];
     wchar_t help[200];
     wchar_t notes[200];
     wchar_t example[200];
   };
   
   static struct command commands[] = {
   {},  
   {
     .type = ADD, 
     .arguments = 1,
     .shortform = L"a", 
     .longform = L"add",
     .help = L"adds the given text to the workspace",
     .notes = L"the argument should be quoted",
     .example = L"add 'op*';"
   },
   {
     .type = CLEAR, 
     .arguments = 0,
     .shortform = L"d", 
     .longform = L"clear",
     .help = L"clears the workspace",
     .notes = L"",
     .example = L"clear;"
   },
   {
     .type = PRINT, 
     .arguments = 0,
     .shortform = L"p", 
     .longform = L"print",
     .help = L"prints the workspace to the standard output",
     .notes = L"",
     .example = L"print;"
   },
   {
     .type = DUMP, 
     .arguments = 0,
     .shortform = L"P", 
     .longform = L"dump",
     .help = L"prints the current state of the machine",
     .notes = L"",
     .example = L"dump;"
   },
   {
     .type = TAPE, 
     .arguments = 0,
     .shortform = L"t", 
     .longform = L"tape",
     .help = L"prints all tape elements and stack",
     .notes = L"",
     .example = L"tape;"
   },
   {
     .type = BURP, 
     .arguments = 0,
     .shortform = L"d", 
     .longform = L"burp",
     .help = L"prints a very detailed dump of the machine",
     .notes = L"",
     .example = L"burp;"
   },
   {
     .type = ESCAPE, 
     .arguments = 0,
     .shortform = L"e", 
     .longform = L"escape",
     .help = L"escapes characters in the workspace",
     .notes = L"",
     .example = L"escape;"
   },
   {
     .type = REPLACE, 
     .arguments = 2,
     .shortform = L"d", 
     .longform = L"replace",
     .help = L"replace one string in the workspace with another",
     .notes = L"unimplemented ?",
     .example = L"replace 'a' 'b';"
   },
   {
     .type = INDENT, 
     .arguments = 0,
     .shortform = L"i", 
     .longform = L"indent",
     .help = L"indents each line of the workspace",
     .notes = L"",
     .example = L";"
   },
   {
     .type = CLIP, 
     .arguments = 0,
     .shortform = L"c", 
     .longform = L"clip",
     .help = L"removes the last character of the workspace",
     .notes = L"",
     .example = L"c;"
   },
   {
     .type = CLOP, 
     .arguments = 0,
     .shortform = L"C", 
     .longform = L"clop",
     .help = L"removes the first character of the workspace",
     .notes = L"",
     .example = L"C;"
   },
   {
     .type = NEWLINE, 
     .arguments = 0,
     .shortform = L"nn", 
     .longform = L"newline",
     .help = L"appends a newline to the workspace",
     .notes = L"is this really necessary",
     .example = L"newline;"
   },
   {
     .type = PUSH, 
     .arguments = 0,
     .shortform = L"p", 
     .longform = L"push",
     .help = L"pushes a token onto the stack",
     .notes = L"",
     .example = L"push;"
   },
   {
     .type = POP, 
     .arguments = 0,
     .shortform = L"P", 
     .longform = L"pop",
     .help = L"pops the next token onto the workspace",
     .notes = L"tokens are delimited by a postfixed '*'",
     .example = L"pop;"
   },
   {
     .type = PUT, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"put",
     .help = L"put the workspace in the current tape element",
     .notes = L"the previous tape contents are overwritten",
     .example = L";"
   },
   {
     .type = GET, 
     .arguments = 0,
     .shortform = L"g", 
     .longform = L"get",
     .help = L"adds the current tape element to the workspace",
     .notes = L"",
     .example = L";"
   },
   {
     .type = SWAP, 
     .arguments = 0,
     .shortform = L"x", 
     .longform = L"swap",
     .help = L"swaps the current tape element with the workspace",
     .notes = L"",
     .example = L"swap;"
   },
   {
     .type = INCREMENT, 
     .arguments = 0,
     .shortform = L"++", 
     .longform = L"++",
     .help = L"increments the tape pointer by one",
     .notes = L"",
     .example = L"++;"
   },
   {
     .type = DECREMENT, 
     .arguments = 0,
     .shortform = L"--", 
     .longform = L"--",
     .help = L"decrements the tape pointer by one",
     .notes = L"",
     .example = L"--;"
   },
   {
     .type = READ, 
     .arguments = 0,
     .shortform = L"r", 
     .longform = L"read",
     .help = L"read one character from the input stream",
     .notes = L"",
     .example = L"read;"
   },
   {
     .type = UNTIL, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"",
     .help = L"",
     .notes = L"",
     .example = L";"
   },
   {
     .type = WHILE, 
     .arguments = 0,
     .shortform = L"x", 
     .longform = L"swap",
     .help = L"swaps the current tape element with the workspace",
     .notes = L"",
     .example = L"swap;"
   },
   { .type = WHILENOT },
   {
     .type = TIME, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"time",
     .help = L"appends the machine run time to the workspace",
     .notes = L"",
     .example = L"time;"
   },
   {
     .type = COUNT, 
     .arguments = 0,
     .shortform = L"n", 
     .longform = L"count",
     .help = L"appends the accumulator value to the workspace",
     .notes = L"",
     .example = L"count;"
   },
   {
     .type = INCC, 
     .arguments = 0,
     .shortform = L"+", 
     .longform = L"plus",
     .help = L"adds one to the accumulator",
     .notes = L"",
     .example = L"plus;"
   },
   {
     .type = DECC, 
     .arguments = 0,
     .shortform = L"-", 
     .longform = L"minus",
     .help = L"decrements the accumulator by one",
     .notes = L"",
     .example = L"minus;"
   },
   {
     .type = CRASH, 
     .arguments = 0,
     .shortform = L"!!", 
     .longform = L"crash",
     .help = L"immediately exits",
     .notes = L"",
     .example = L"!!;"
   },
   {
     .type = ZERO, 
     .arguments = 0,
     .shortform = L"00", 
     .longform = L"zero",
     .help = L"sets the accumulator to zero",
     .notes = L"",
     .example = L"zero;"
   },
   {
     .type = JUMP, 
     .arguments = 1,
     .shortform = L"", 
     .longform = L"jump",
     .help = L"an unconditional jump",
     .notes = L"",
     .example = L"jump;"
   },
   {
     .type = LABEL, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"",
     .help = L"",
     .notes = L"is this necessary ??",
     .example = L""
   },
   {
     .type = CHECK, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"",
     .help = L"",
     .notes = L"this is related to shift reductions",
     .example = L""
   },
   {
     .type = NOP, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"",
     .help = L"no operation, does nothing",
     .notes = L"not sure what for",
     .example = L""
   },
   { .type = TESTIS },
   { .type = TESTBEGINS },
   { .type = TESTCLASS },
   { .type = TESTENDS },
   { .type = TESTLIST },
   { .type = TESTEOF },
   { .type = TESTTAPE },
   { .type = OPENBRACE },
   { .type = CLOSEBRACE },
   {
     .type = UNDEFINED, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"",
     .help = L"",
     .notes = L"",
     .example = L""
   },
   {
     .type = UNKNOWN, 
     .arguments = 0,
     .shortform = L"", 
     .longform = L"",
     .help = L"an unknown command",
     .notes = L"",
     .example = L""
   }};

   // this is like a lookup table for the commands
   //command commands[100];
   
   //static command here = {1, L"f", L"feel"};
   //commands[ADD] = {ADD, L"f", L"feel"};

   //static command here = {1, L"f", L"feel"};
   //commands[1].type = 2;
   //commands[ADD].shortform = "a";

   void printcommand(enum commandtype);
   void printcommandslist(void);
   void dumpcommand(enum commandtype);
   void dumpcommands(void);


#endif
