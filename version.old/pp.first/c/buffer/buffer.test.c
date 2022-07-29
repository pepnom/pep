 #include <stdio.h>
 #include <wchar.h>
 #include <locale.h>
 #include <string.h>
 #include <stdlib.h>
 #include "buffer.h"

 void printHelp();

 int main()
 {
   wchar_t input[200];
   wchar_t command[100];
   wchar_t arg[100];
   buffer bb; 
   wchar_t * sDisplay;
   command[0] = arg[0] = L'\0'; 

   setlocale(LC_ALL, "");
   wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
   wprintf(L"Test program for the 'buffer' type\n"
           L"The buffer is like a stack, holding tokens\n"
           L"in the form 'op*name*op*'\n"
           L"Notice the postfixed '*' character\n");

   printHelp();
   createBuffer(&bb);

   while(1)
   {
     wprintf(L">");

     command[0] = arg[0] = L'\0';

     fgetws(input, 200, stdin);
     swscanf(input, L"%ls %100l[^\n]", command, arg);
     //wprintf(L"command=%ls, arg=%ls \n", command, arg);
     if (wcscmp(command, L"q") == 0)
       { exit(0); }
     else if (wcscmp(command, L"h") == 0)
       { printHelp(); }
     else if (wcscmp(command, L"d") == 0)
     {
       clearWorkspace(&bb); 
       wprintf(L"%ls\n", printBuffer(sDisplay, &bb));
     }
     else if (wcscmp(command, L"s") == 0)
     { 
       wprintf(L"%ls\n", printBuffer(sDisplay, &bb));
     }
     else if (wcscmp(command, L"S") == 0)
     {
       wprintf(L"%ls\n", dumpBuffer(sDisplay, &bb));
     }
     else if (wcscmp(command, L"a") == TRUE)
     {
       if (arg[0] == L'\0')
       { 
         wprintf(L"missing argument\n" "eg: a token*\n");
         continue;
       }

       appendText(&bb, arg);
       wprintf(L"%ls\n", printBuffer(sDisplay, &bb));
     }
     else if (wcscmp(command, L"k") == TRUE)
     {
       appendText(&bb, L"雨");
       wprintf(L"%ls\n", printBuffer(sDisplay, &bb));
     }
     else if (wcscmp(command, L"p") == TRUE)
     {
       popBuffer(&bb);
       sDisplay = printBuffer(sDisplay, &bb);
       wprintf(L"%ls\n", printBuffer(sDisplay, &bb));
     }
     else if (wcscmp(command, L"P") == TRUE)
     {
       pushBuffer(&bb);
       sDisplay = printBuffer(sDisplay, &bb);
       wprintf(L"%ls\n", sDisplay);
     }
     else
     { 
       wprintf(L"?? unknown command '%ls'\n", command);
       printHelp();
     }
   }

   free(sDisplay);
   free(&bb);
   return 0;
 }

 void printHelp()
 {
   wprintf(
     L" Commands for the 'buffer' test program: \n"
     L" h - print this help message \n"
     L" d - clearWorkspace()        [deletes text in the workspace] \n"
     L" a stuff - appendText(stuff) [adds to the workspace] \n"
     L" k - append a kanji (雨) character to the buffer \n"
     L" p - popBuffer()   [pops one token from the stack ] \n"
     L" P - pushBuffer()  [pushes one token onto the stack ] \n"
     L" s - printBuffer() [prints a concise summary of the buffer ]\n"
     L" S - dumpBuffer()  [print more verbose buffer information ]\n"
     L" q - exit \n");
 }

