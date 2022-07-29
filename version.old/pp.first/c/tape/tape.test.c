 #include <stdio.h>
 #include <wchar.h>
 #include <locale.h>
 #include <string.h>
 #include <stdlib.h>
 #include "element.h"
 #include "tape.h"

 void printHelp();

 int main()
 {
   //wchar_t input[200], command[100],  wchar_t arg[100];
   wchar_t input[200], command[100], arg[100];
   tape tt; 
   wchar_t * sDisplay = NULL;

   command[0] = arg[0] = L'\0'; 

   setlocale(LC_ALL, "");
   wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
   wprintf(L"Test program for the 'tape' type\n");
   printHelp();
   createTape(&tt);

   while(1)
   {
     wprintf(L">");

     *command = L'\0'; *arg = L'\0';
     fgetws(input, 200, stdin);
     swscanf(input, L"%ls %l[^\n]", command, arg);

     //fwscanf(stdin, L"%ls %ls", command, arg);
     //wprintf(L"command=%ls, arg=%ls \n", command, arg);
     if (wcscmp(command, L"q") == 0)
     {
       exit(0);
     }

     else if (wcscmp(command, L"h") == 0)
     { 
       printHelp();
     }
     else if (wcscmp(command, L"i") == 0)
     {
       incrementTape(&tt); 
       wprintf(L"current element: %d\n", tt.current-tt.first);
     }
     else if (wcscmp(command, L"I") == 0)
     { 
       decrementTape(&tt);
       wprintf(L"current element: %d\n", tt.current-tt.first);
     }
     else if (wcscmp(command, L"sh") == 0)
     {
       showTape(&tt);
     }
     else if (wcscmp(command, L"p") == 0)
     {
       sDisplay = printTape(sDisplay, &tt);
       wprintf(L"%ls\n", sDisplay);
     }
     else if (wcscmp(command, L"d") == 0)
     {
       sDisplay = dumpTape(sDisplay, &tt);
       wprintf(L"%ls\n", sDisplay);
     }
     else if (wcscmp(command, L"de") == 0)
     {
       sDisplay = dumpElement(sDisplay, tt.current);
       wprintf(L"%ls\n", sDisplay);
     }
     else if (wcscmp(command, L"s") == 0)
     {
       if (arg[0] == L'\0')
        { wprintf(L"missing argument\n"); continue; }

       setCurrentElement(&tt, arg);
       sDisplay = printTape(sDisplay, &tt);
       wprintf(L"%ls\n", sDisplay);
     }
     else
     { 
       wprintf(L"unknown command '%ls'\n", command);
       printHelp();
     }
   }

   freeTape(&tt);
   free(sDisplay);
   return 0;
 }

 void printHelp()
 {
   wprintf(
     L" h  - print this help message \n"
     L" i  - incrementTape() \n"
     L" I  - decrementTape() \n"
     L" s text - setCurrentElement('text') \n"
     L" p  - printTape() \n"
     L" d  - dumpTape() \n"
     L" de - show the current element \n"
     L" sh - showTape() \n"
     L" q  - exit \n");
 }
