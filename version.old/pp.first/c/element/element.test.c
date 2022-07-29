 #include <stdio.h>
 #include <wchar.h>
 #include <locale.h>
 #include <string.h>
 #include <stdlib.h>
 #include "element.h"

 void printHelp();

 int main()
 {
   wchar_t input[200];
   wchar_t command[100];
   wchar_t arg[100];
   element ee; 
   wchar_t * sDisplay = NULL;

   *command = L'\0'; 
   *arg = L'\0'; 

   setlocale(LC_ALL, "");
   wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
   wprintf(L"Test program for the 'element' type\n");
   printHelp();
   createElement(&ee);

   while(1)
   {
     wprintf(L">");

     *command = L'\0'; *arg = L'\0'; 
     //*command, *arg = L'\0'; 

     fgetws(input, 200, stdin);
     swscanf(input, L"%ls %ls", command, arg);
     // wprintf(L"command=%ls, arg=%ls \n", command, arg);

     if (wcscmp(command, L"q") == 0)
       { exit(0); }
     else if (wcscmp(command, L"h") == 0)
       { printHelp(); }
     else if (wcscmp(command, L"d") == 0) {
       ee.text[0] = L'\0';
       wprintf(L"%ls\n", dumpElement(sDisplay, &ee));
     }
     else if (wcscmp(command, L"p") == 0)
     { 
       wprintf(L"%ls\n", printElement(sDisplay, &ee));
     }
     else if (wcscmp(command, L"P") == 0)
     {
       wprintf(L"%ls\n", dumpElement(sDisplay, &ee));
     }
     else if (wcscmp(command, L"s") == 0)
     {
       if (arg[0] == L'\0')
        { wprintf(L"missing argument\n"); continue; }

       setElement(&ee, arg);
       wprintf(L"%ls\n", dumpElement(sDisplay, &ee));
     }
     else
     { 
       wprintf(L"?? unknown command '%ls'\n", command);
       printHelp();
     }
   }
   return 0;
 }

 void printHelp()
 {
   wprintf(L" h - print this help message \n");
   wprintf(L" d - clear the element \n");
   wprintf(L" p - printElement() \n");
   wprintf(L" P - dumpElement() \n");
   wprintf(L" s text - setElement('text') \n");
   wprintf(L" q - exit \n");
 }
