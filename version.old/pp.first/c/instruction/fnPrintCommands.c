
#include <stdio.h>
#include <wchar.h>
#include "command.h"

/* -------------------------------------------*/
void fnPrintCommands(int iWidth)
{
  wchar_t sCommand[100];
  int iCommand;
  wstrcpy(sCommand, "");

  wprintf("legal commands: \n   ");

  for (iCommand = 1; iCommand < UNDEFINED; iCommand++)
  {
    fnCommandToDisplayString(sCommand, iCommand);   
    wprintf("%ls ", sCommand);
    if (iCommand % iWidth == 0) 
     { wprintf("\n   "); }
  }

  printf("\n");
  //printf("* All commands except tests and braces must end with ';' \n");
  //printf("* All statement blocks must be enclosed in {} \n");
}
