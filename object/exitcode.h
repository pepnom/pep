

/* the enum, array of structures, and associated functions are 
   to provide readable exit and error codes for functions such as
   execute(), run(), compile(), loadScript(), etc 
   EXECQUIT is actually a success code, where as BADQUIT (returned
   by the "bail" command, is an error.
   */
enum ExitCode { 
  SUCCESS=0, EXECQUIT, ENDOFSTREAM, EXECUNDEFINED, BADQUIT, 
  READSAVERROR, WRITESAVERROR, UNIMPLEMENTED };

struct Code {
  enum ExitCode error;
  char * description;   
};

extern struct Code exitCodes[];

// print the description for an error
void printExitCode(enum ExitCode error);

