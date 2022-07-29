
#include <stdio.h>
#include <locale.h>
#include <wchar.h>
#include "command.h"


int main()
{
  wprintf(L"Testing the commands \n");
  wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));
  setlocale(LC_ALL, "");
  wprintf(L"Locale is: %s\n", setlocale(LC_ALL,NULL));

  fnPrintCommands(3);

  wchar_t sInput[1000] = L"This is unicode 雨";
  wchar_t sCommand[1000] = L"雨";
  wchar_t sParam1[1000] = L"雨";
  wchar_t sParam2[1000] = L"雨";

  wprintf(L">");
  wscanf(L"%ls %ls %ls", sCommand, sParam1, sParam2);
  wprintf(L"sCommand=%ls \n", sCommand);
  wprintf(L"sParam1=%ls \n", sParam1);
  wprintf(L"sParam2=%ls \n", sParam2);

}
