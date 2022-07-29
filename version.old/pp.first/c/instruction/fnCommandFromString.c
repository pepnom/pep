/* -------------------------------------------*/
int fnCommandFromString(char * sCommand)
{
  if (strcmp(sCommand, "add") == 0) { return ADD; }
  else if (strcmp(sCommand, "clear") == 0) { return CLEAR; }
  else if (strcmp(sCommand, "crash") == 0) { return CRASH; }
  else if (strcmp(sCommand, "print") == 0) { return PRINT; }
  else if (strcmp(sCommand, "dump") == 0) { return DUMP; }
  else if (strcmp(sCommand, "burp") == 0) { return BURP; }
  else if (strcmp(sCommand, "tape") == 0) { return TAPE; }
  else if (strcmp(sCommand, "escape") == 0) { return ESCAPE; }
  else if (strcmp(sCommand, "time") == 0) { return TIME; }
  else if (strcmp(sCommand, "replace") == 0) { return REPLACE; }
  else if (strcmp(sCommand, "indent") == 0) { return INDENT; }
  else if (strcmp(sCommand, "clip") == 0) { return CLIP; }
  else if (strcmp(sCommand, "clop") == 0) { return CLOP; }
  else if (strcmp(sCommand, "newline") == 0) { return NEWLINE; }
  else if (strcmp(sCommand, "push") == 0) { return PUSH; }
  else if (strcmp(sCommand, "pop") == 0) { return POP; }
  else if (strcmp(sCommand, "put") == 0) { return PUT; }
  else if (strcmp(sCommand, "get") == 0) { return GET; }
  else if (strcmp(sCommand, "++") == 0) { return INCREMENT; }
  else if (strcmp(sCommand, "--") == 0) { return DECREMENT; }
  else if (strcmp(sCommand, "read") == 0) { return READ; }
  else if (strcmp(sCommand, "until") == 0) { return UNTIL; }
  else if (strcmp(sCommand, "while") == 0) { return WHILE; }
  else if (strcmp(sCommand, "whilenot") == 0) { return WHILENOT; }
  else if (strcmp(sCommand, "count") == 0) { return COUNT; }
  else if (strcmp(sCommand, "plus") == 0) { return INCC; }
  else if (strcmp(sCommand, "minus") == 0) { return DECC; }
  else if (strcmp(sCommand, "jump") == 0) { return JUMP; }
  else if (strcmp(sCommand, "check") == 0) { return CHECK; }
  else if (strcmp(sCommand, "@@@") == 0) { return LABEL; }
  else if (strcmp(sCommand, "zero") == 0) { return ZERO; }
  else if (strcmp(sCommand, "nop") == 0) { return NOP; }
  else { return UNKNOWN; }
}
