 #include <stdio.h>
 #include <wchar.h>
 #include <locale.h>
 #include <string.h>
 #include <stdlib.h>
 #include "command.h"

 void printHelp();

 int main()
 {
   wchar_t input[200];    
   wchar_t command[100];
   wchar_t arg[100];
   enum commandtype c; 
   wchar_t * sDisplay;
   c = UNDEFINED; 
   command[0] = arg[0] = L'\0'; 

   setlocale(LC_ALL, "");
   wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
   wprintf(L"Test program for the 'command' enumerated type\n");
   printHelp();

   while(1)
   {
     wprintf(L">");
     command[0] = arg[0] = L'\0';

     fgetws(input, 200, stdin);
     swscanf(input, L"%ls %ls", command, arg);
     //wprintf(L"command=%ls, arg=%ls \n", command, arg);
     if (wcscmp(command, L"q") == 0)
       { exit(0); }
     else if (wcscmp(command, L"h") == 0)
     {  
       printHelp();
     }
     else if (wcscmp(command, L"p") == 0)
     { 
       printcommand(commandTextToType(arg));
     }
     else if (wcscmp(command, L"pl") == 0)
     { 
       wprintf(L"hh"); 
       printcommandlist();
     }
     else if (wcscmp(command, L"c") == 0)
     { 
       if (checkInfoTable() == 0)
         wprintf(L"the lookup table is ok \n");
       else
       {
         wprintf(L"something is wrong with the lookup table \n");
       }
     }
     else if (wcscmp(command, L"t") == 0)
     { 
       dumpcommand(commandTextToType(arg));
     }
     else if (wcscmp(command, L"dc") == 0)
     { 
       dumpcommands();
     }
     else
     { 
       wprintf(L"unknown command '%ls'\n", command);
       printHelp();
     }
   }

   free(sDisplay);
   return 0;
 }

 void printHelp()
 {
   wprintf(
     L" Commands for the 'command' test program: \n"
     L" h - print this help message \n"
     L" p text - printcommand(text) : prints the given command \n"
     L" pl     - printcommandlist() : prints all the legal commands \n"
     L" c      - checkInfoTable() : checks the validity of the table \n"
     L" t text - commandTextToType(arg) :  \n"
     L" dc - dumpcommands() \n"
     L" q - exit \n");
 }

