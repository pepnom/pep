
/* -------------------------------------------*/
/* represents a compiled instruction */
typedef struct
{
  enum commandtypes command;
  char argument1[MAXARGUMENTLENGTH];
  char argument2[MAXARGUMENTLENGTH];
  int trueJump;
  int falseJump;
  int isNegated;
} Instruction;

/* prints legal class names in class tests such as [:alpha:]
void fnPrintClasses();


