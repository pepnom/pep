

   /* -------------------------------------------*/
   wchar_t * fnCommandToString(wchar_t * sReturn, int iCommand)
   {
     switch (iCommand)
     {
       case ADD:
         strcpy(sReturn, "add");
         break;
       case CLEAR:
         strcpy(sReturn, "clear");
         break;
       case PRINT:
         strcpy(sReturn, "print");
         break;
       case DUMP:
         strcpy(sReturn, "dump");
         break;
       case TAPE:
         strcpy(sReturn, "tape");
         break;
       case BURP:
         strcpy(sReturn, "burp");
         break;
       case ESCAPE:
         strcpy(sReturn, "escape");
         break;
       case TIME:
         strcpy(sReturn, "time");
         break;
       case REPLACE:
         strcpy(sReturn, "replace");
         break;
       case INDENT:
         strcpy(sReturn, "indent");
         break;
       case CLIP:
         strcpy(sReturn, "clip");
         break;
       case CLOP:
         strcpy(sReturn, "clop");
         break;
       case NEWLINE:
         strcpy(sReturn, "newline");
         break;
       case PUSH:
         strcpy(sReturn, "push");
         break;
       case POP:
         strcpy(sReturn, "pop");
         break;
       case PUT:
         strcpy(sReturn, "put");
         break;
       case GET: 
         strcpy(sReturn, "get");
         break;
       case COUNT:
         strcpy(sReturn, "count");
         break;
       case INCREMENT:
         strcpy(sReturn, "++");
         break;
       case DECREMENT:
         strcpy(sReturn, "--");
         break;
       case READ:   
         strcpy(sReturn, "read");
         break;
       case UNTIL:
         strcpy(sReturn, "until");
         break;
       case WHILE:
         strcpy(sReturn, "while");
         break;
       case WHILENOT:
         strcpy(sReturn, "while-not");
         break;
       case TESTIS:
         strcpy(sReturn, "testis");
         break;
       case TESTBEGINS:
         strcpy(sReturn, "testbeginswith");
         break;
       case TESTENDS:
         strcpy(sReturn, "testendswith");
         break;
       case TESTCLASS:
         strcpy(sReturn, "testclass");
         break;
       case TESTLIST:
         strcpy(sReturn, "testlist");
         break;
       case TESTEOF:
         strcpy(sReturn, "testeof");
         break;
       case TESTTAPE:
         strcpy(sReturn, "testtape");
         break;
       case INCC:   
         strcpy(sReturn, "plus");
         break;
       case DECC:
         strcpy(sReturn, "minus");
         break;
       case CRASH:
         strcpy(sReturn, "crash");
         break;
       case UNDEFINED: /* the default */
         strcpy(sReturn, "undefined");
         break;
       case JUMP:
         strcpy(sReturn, "jump");
         break;
       case CHECK:
         strcpy(sReturn, "check");
         break;
       case LABEL:
         strcpy(sReturn, "label");
         break;
       case NOP:     /* no operation */
         strcpy(sReturn, "nop");
         break;
       case ZERO:     /*  */
         strcpy(sReturn, "zero");
         break;
       case OPENBRACE:
         strcpy(sReturn, "open-brace");
         break;
       case CLOSEBRACE:
         strcpy(sReturn, "close-brace");
         break;
       default:
         strcpy(sReturn, "unknown command");
         break;

     } /* switch */
     return sReturn;

   }

