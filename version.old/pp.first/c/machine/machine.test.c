 #include <stdio.h>
 #include <wchar.h>
 #include <locale.h>
 #include <string.h>
 #include <stdlib.h>
 #include "buffer.h"
 #include "element.h"
 #include "tape.h"
 #include "machine.h"

 void printHelp();

 int main()
 {
   wchar_t input[200];
   wchar_t command[100];
   wchar_t arg[100];
   machine mm; 
   wchar_t * sDisplay = NULL;

   command[0] = L'\0'; 
   arg[0] = L'\0'; 

   setlocale(LC_ALL, "");
   wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
   wprintf(L"Test program for the 'machine' type\n");
   printHelp();
   createMachine(&mm);

   while(1)
   {
     wprintf(L">");
     command[0] = L'\0'; 
     arg[0] = L'\0'; 

     fgetws(input, 200, stdin);
     swscanf(input, L"%ls %ls", command, arg);
     //wprintf(L"command=%ls, arg=%ls \n", command, arg);
     if (wcscmp(command, L"q") == 0)
     { 
       exit(0);
     }
     else if (wcscmp(command, L"h") == 0)
     { 
       printHelp();
     }
     else if (wcscmp(command, L"p") == 0)
     {
       sDisplay = printMachine(sDisplay, &mm);
       wprintf(L"%ls\n", sDisplay);
     }
     else if (wcscmp(command, L"s") == 0)
     {
       if (arg[0] == L'\0')
        { wprintf(L"missing argument\n"); continue; }
     }
     else
     { 
       int iCommand = 0;
       switch (iCommand)
       {
        /*-------------------*/
        case 0:
        break;
        /*-------------------*/
        case 1:
        break;
        /*-------------------*/
        default:
        break;
       }

       wprintf(L"unknown command '%ls'\n", command);
       printHelp();
     }
   }

   freeMachine(&mm);
   free(sDisplay);
   return 0;
 }

 void printHelp()
 {
   wprintf(
     L" Commands for the 'machine' type test program: \n"
     L" h - print this help message \n"
     L" p - printMachine() \n"
     L" q - exit \n");
 }
