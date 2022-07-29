   #include <wchar.h>
   #include <locale.h>
   int main () {
     long name[100] = {1,3,5,7};
     setlocale (LC_ALL, ""); 
     wprintf(L"size (bytes):%d\n", sizeof(name));
     wprintf(L"size (elements):%d\n", sizeof(name)/sizeof(long));
     return(0);
   }
