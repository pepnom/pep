
/* -------------------------------------------*/
void fnPrintScriptInstruction(Instruction instruction)
{
  char sCommandName[50] = "";
  char sDisplay[3 * MAXARGUMENTLENGTH];
  strcpy(sDisplay, "");

  fnCommandToDisplayString(sCommandName, instruction.command);
  switch (instruction.command)
  {
    case ADD:
    case CLEAR:
    case PRINT:
    case STATE:
    case INDENT:
    case CLIP:
    case CLOP:
    case NEWLINE:
    case PUSH:
    case POP:
    case PUT:
    case GET: 
    case COUNT:
    case INCREMENT:
    case DECREMENT:
    case INCC:   
    case DECC:
    case CRASH:
    case UNDEFINED: /* the default */
    case CHECK:
    case LABEL:
    case NOP:     /* no operation */
    case ZERO:     /*  */
    case READ:   
      strcpy(sDisplay, sCommandName);
      strcpy(sDisplay, ";");
      break;
    case JUMP:
      if (instruction.trueJump != 0)
      {
        
      }
      break;

    case OPENBRACE:
    case CLOSEBRACE:
      strcpy(sDisplay, sCommandName);
      break;
    case REPLACE:
      break;
    case UNTIL:
      sprintf(sDisplay, "%s '%s' '%s';",
         sCommandName, instruction.argument1, instruction.argument2);

      break;
    case WHILENOT:
      break;
    case WHILE:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "%s !'%s';",
           sCommandName, instruction.argument1);
      }
      else 
      {
        sprintf(sDisplay, "%s '%s';",
           sCommandName, instruction.argument1);
      }

     break;
    case TESTIS:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "!/%s/ {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "/%s/ {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }

      break;

    case TESTBEGINS:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "!<%s> {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "<%s> {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }

      break;
    case TESTENDS:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "!(%s) {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "(%s) {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }

      break;

    case TESTCLASS:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "![%s] {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "[%s] {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }

      break;

    case TESTLIST:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "!=%s= {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "=%s= {=%d }=%d",
           instruction.argument1, instruction.trueJump, instruction.falseJump);
      }

      break;

    case TESTEOF:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "!<> {=%d }=%d",
           instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "/%s/ {=%d }=%d",
           instruction.trueJump, instruction.falseJump);
      }

      break;
    case TESTTAPE:
      if (instruction.isNegated)
      {
         sprintf(sDisplay, "!== {=%d }=%d",
           instruction.trueJump, instruction.falseJump);
      }
      else 
      {
         sprintf(sDisplay, "== {=%d }=%d",
           instruction.trueJump, instruction.falseJump);
      }

      break;
    default:
      break;

  } //-- switch

  printf("%s", sDisplay);
  
}



