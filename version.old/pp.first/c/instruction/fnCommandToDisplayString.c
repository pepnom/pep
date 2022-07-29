#include "command.h"

/* ------------------------------------------- */
wchar_t * fnCommandToDisplayString(wchar_t * sReturn, int iCommand)
{
  switch (iCommand)
  {
    case ADD:
      wstrcpy(sReturn, "add");
      break;
    case CLEAR:
      wstrcpy(sReturn, "clear");
      break;
    case PRINT:
      wstrcpy(sReturn, "print");
      break;
    case DUMP:
      wstrcpy(sReturn, "dump");
      break;
    case BURP:
      wstrcpy(sReturn, "burp");
      break;
    case TIME:
      wstrcpy(sReturn, "time");
      break;
    case REPLACE:
      //--unimplemented command
      //wstrcpy(sReturn, "replace");
      wstrcpy(sReturn, "");
      break;
    case INDENT:
      wstrcpy(sReturn, "indent");
      break;
    case CLIP:
      wstrcpy(sReturn, "clip");
      break;
    case CLOP:
      wstrcpy(sReturn, "clop");
      break;
    case NEWLINE:
      wstrcpy(sReturn, "newline");
      break;
    case PUSH:
      wstrcpy(sReturn, "push");
      break;
    case POP:
      wstrcpy(sReturn, "pop");
      break;
    case PUT:
      wstrcpy(sReturn, "put");
      break;
    case GET: 
      wstrcpy(sReturn, "get");
      break;
    case COUNT:
      wstrcpy(sReturn, "count");
      break;
    case INCREMENT:
      wstrcpy(sReturn, "++");
      break;
    case DECREMENT:
      wstrcpy(sReturn, "--");
      break;
    case READ:   
      wstrcpy(sReturn, "read");
      break;
    case UNTIL:
      wstrcpy(sReturn, "until");
      break;
    case WHILE:
      wstrcpy(sReturn, "while");
      break;
    case WHILENOT:
      //unimplemented command
      //wstrcpy(sReturn, "whilenot");
      wstrcpy(sReturn, "");
      break;
    case TESTIS:
      wstrcpy(sReturn, "/text/");
      break;
    case TESTBEGINS:
      wstrcpy(sReturn, "<text>");
      break;
    case TESTENDS:
      wstrcpy(sReturn, "(text)");
      break;
    case TESTCLASS:
      wstrcpy(sReturn, "[text]");
      break;
    case TESTLIST:
      wstrcpy(sReturn, "=text=");
      break;
    case TESTEOF:
      wstrcpy(sReturn, "<>");
      break;
    case TESTTAPE:
      wstrcpy(sReturn, "==");
      break;
    case INCC:   
      wstrcpy(sReturn, "plus");
      break;
    case DECC:
      wstrcpy(sReturn, "minus");
      break;
    case CRASH:
      wstrcpy(sReturn, "crash");
      break;
    case JUMP:
      wstrcpy(sReturn, "jump");
      break;
    case CHECK:
      wstrcpy(sReturn, "check");
      break;
    case LABEL:
      wstrcpy(sReturn, "@@@");
      break;
    case NOP:     /* no operation */
      wstrcpy(sReturn, "nop");
      break;
    case ZERO:     /*  */
      wstrcpy(sReturn, "zero");
      break;
    case OPENBRACE:
      wstrcpy(sReturn, "{");
      break;
    case CLOSEBRACE:
      wstrcpy(sReturn, "}");
      break;
    default:
      wstrcpy(sReturn, "unknown command");
      break;

  } /* switch */
  return sReturn;

}

