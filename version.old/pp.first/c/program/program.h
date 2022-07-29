#define MAXPROGRAMLENGTH 1500
/* -------------------------------------------*/
typedef struct
{
  Instruction instructionSet[MAXPROGRAMLENGTH + 1];
  int size;
  int braceStack[MAXNESTING + 1];
  int instructionPointer;
  int compileTime;
  int executionTime;
  char listFile[MAXARGUMENTLENGTH];
  int fileError;
} Program;
