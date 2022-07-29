
#include <stdio.h>
#include <locale.h>
#include <wchar.h>
#include "command.h"

  /*---------------------------------------------------- */
  void printcommand(enum commandtype type)
  {
     struct command c = commands[type];
     wprintf(
       L"%ls - %ls (short: %ls) \n",
       c.longform, c.help, c.shortform);
  }

  /*---------------------------------------------------- */
  void printcommandlist(void)
  {
    int ii;
    for (ii = 1; ii <= UNDEFINED; ii++)
    {
      printcommand(commands[ii].type); 
    }
  }

  /*---------------------------------------------------- */
  void dumpcommand(enum commandtype type)
  {
     struct command c = commands[type];
     wprintf(
       L"type        : %ld \n"
       L"arguments   : %ld \n"
       L"short form  : %ls \n"
       L"long form   : %ls \n"
       L"help        : %ls \n"
       L"notes       : %ls \n"
       L"example     : %ls \n",
       c.type, c.arguments, c.shortform, c.longform,
       c.help, c.notes, c.example
       );
  }

  void dumpcommands()
  {
    int ii;
    for (ii = 0; ii < UNKNOWN; ii++)
    {
      wprintf(L"\n");
      dumpcommand(ii); 
    }
  }

  wchar_t * commandTypeToString(enum commandtype type)
  {
    return commands[type].longform;
  }

  enum commandtype commandTextToType(wchar_t * text)
  {
    int ii;
    for (ii = 0; ii <= UNDEFINED; ii++)
    {
      if (wcscmp(commands[ii].longform, text) == 0)
       { return ii; }
      if (wcscmp(commands[ii].shortform, text) == 0)
       { return ii; }
    }
    return UNDEFINED;
  }

  // checks the validity of the lookup table. If the 
  // table is valid then returns 0, if not returns the 
  // first command type which is not good
  int checkInfoTable(void)
  {
    int ii;
    for (ii = 0; ii <= UNDEFINED; ii++)
    {
      if (commands[ii].type != ii)
       { return ii; }
    }
    return 0;
  }


