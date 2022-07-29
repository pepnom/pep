
/* -------------------------------------------*/
void fnInitializeInstruction(Instruction * instruction)
{
  
  instruction->command = UNDEFINED;
  strcpy(instruction->argument1, "");
  strcpy(instruction->argument2, "");
  instruction->trueJump = -1;
  instruction->falseJump = -1;
  instruction->isNegated = FALSE;
  
} 