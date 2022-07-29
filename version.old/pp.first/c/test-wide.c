#include <stdio.h>
#include <locale.h>
#include <string.h>

struct machine
{
  wchar_t workspace[100];
};

  int main()
  { 
    struct machine m;

     char locale[100];
           strcpy(locale, setlocale(LC_ALL, NULL));

    setlocale(LC_ALL, "");
    wcscpy(m.workspace, L"雨が降りそう hello\n");
    wprintf(L"雨が降り size of wchar: %d\n", sizeof(wchar_t));
    wprintf(L"length: %d\n", wcslen(m.workspace));
    wprintf(m.workspace);

    size_t s;
    s = wcstombs(NULL, m.workspace, 0);
    wprintf(L"size need: %d\n", s);
    return 0;
  }
