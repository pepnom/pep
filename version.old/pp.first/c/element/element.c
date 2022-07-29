  #include <stdio.h>
  #include <stdlib.h>
  #include "element.h"

  /*---------------------------------------------------- */
  /* initialize memory and member fields for the element. The
   * function assumes that the element pointer has already points
   * to a valid 'element' structure. This is because the 'element'
   * will form part of a dynamic array in the 'tape' structure and 
   * memory for the array will be assigned in the createTape method */

  element * createElement(element * ee)
  {
     ee->text = (wchar_t *)malloc(sizeof(wchar_t) * ELEMENTSIZE); 
     if (ee->text == NULL)
     {
       fwprintf(L"error allocating memory in createElement()\n", stderr);
       exit(EXIT_FAILURE);
     }

     ee->text[0] = L'\0';
     ee->size = ELEMENTSIZE;
     ee->resizings = 0;
     return ee;
  }

  /*---------------------------------------------------- */
  /* this doesnt free the element pointer because the memory
   * for the pointer was probably allocated in the createTape method 
   */

  void * freeElement(element * ee)
  {
    free(ee->text);
  }

  /*---------------------------------------------------- */
  wchar_t * printElement(wchar_t * sReturn, element * ee)
  {
    long int iSpaceNeeded = sizeof(wchar_t) * (wcslen(ee->text) + 50);
    sReturn = (wchar_t *) malloc(iSpaceNeeded);
    if (sReturn == NULL)
    {
      fwprintf(L"error allocating memory in printElement() \n", stderr);
      exit(EXIT_FAILURE);
    }

    sReturn[0] = L'\0';  
    swprintf(sReturn, iSpaceNeeded, 
      L"[%ld/%ld] '%ls'", wcslen(ee->text), ee->size, ee->text);
    return sReturn;
  }

  /*---------------------------------------------------- */
  wchar_t * dumpElement(wchar_t * sReturn, element * ee)
  {
    long int iSpaceNeeded = sizeof(wchar_t) * (300 + wcslen(ee->text));
    sReturn = (wchar_t *) malloc(iSpaceNeeded);
    if (sReturn == NULL)
    {
      fwprintf(L"error allocating memory in dumpElement() \n", stderr);
      exit(EXIT_FAILURE);
    }
    
    sReturn[0] = L'\0';  
    swprintf(sReturn, iSpaceNeeded, 
      L"string length:%ld\n"
      L"capacity     :%ld\n"
      L"resizings    :%ld\n"
      L"initial size :%ld\n"
      L"grow factor  :%ld\n"
      L"text         :%ls\n"
      L"text (hex)   :",
      wcslen(ee->text), ee->size, ee->resizings, 
      ELEMENTSIZE, ELEMENTGROW, ee->text);
      // todo: a hex listing of the values
      //for (int i = 0; i < wcslen(ee->text); i++)
      // swprintf(sReturn+2*i, "%02x", (unsigned int) ee->text[i]);
    
    return sReturn;
  }


  /*---------------------------------------------------- */
  wchar_t * setElement(element * ee, wchar_t * sNewText)
  {
    int iNewSize; 
    if (wcslen(sNewText) >= ee->size - 2)
    {
      iNewSize = wcslen(sNewText) + ELEMENTGROW + 1; 
      ee->text = (wchar_t *) malloc(sizeof(wchar_t) * iNewSize);
      if (ee->text == NULL)
      {
        fwprintf(L"error allocating memory in setElement() \n", stderr);
        exit(EXIT_FAILURE);
      }

      ee->size = iNewSize;
      ee->resizings++;
    }

    wcscpy(ee->text, sNewText);
    return ee->text;

  } /* setElement */


