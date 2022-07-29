
/* -------------------------------------------*/
void fnPrintInstruction(Instruction instruction)
{
  char sCommandName[50] = "";
  fnCommandToString(sCommandName, instruction.command);
  printf("%s '%s' '%s' (True=%d, False=%d, NOT=%d)", 
          sCommandName, instruction.argument1, instruction.argument2, 
	  instruction.trueJump, instruction.falseJump, instruction.isNegated);
  
}