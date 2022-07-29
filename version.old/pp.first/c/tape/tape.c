
  #include <stdio.h>
  #include <stdlib.h>
  #include "element.h"
  #include "tape.h"


  tape * createTape(tape * tt)
  {
    element * ee;
    tt->first = (element *) malloc(sizeof(element) * TAPESIZE);
    if (tt->first == NULL)
    {
      fwprintf(L"error allocating memory in createTape()\n", stderr);
      exit(EXIT_FAILURE);
    }

    tt->current = tt->first;
    tt->last = tt->first + TAPESIZE - 1;
    for (ee = tt->first; ee <= tt->last; ee++)
    {
      createElement(ee);  
    }
    tt->size = TAPESIZE;   
    tt->resizings = 0;
  }

  void freeTape(tape * tt)
  {
    tt->current = tt->first; 
    int ii;
    for (ii = 0; ii < TAPESIZE; ii++)
    {
      freeElement(tt->current);  
      tt->current++;
    }
    free(tt); 
  }

  element * incrementTape(tape * tt)
  {
    int iNewSize = 0;
    element * test = NULL;
    element * ee = NULL;
    if (tt->current >= tt->last) 
    {
      iNewSize = tt->size + TAPEGROW;
      //--
      //-- will the pointers to the element.text be preserved???
      test = (element *) realloc((void *) tt->first, sizeof(element) * iNewSize);
      if (test == NULL)
      {
        fwprintf(L"error allocating memory in incrementTape()\n", stderr);
        exit(EXIT_FAILURE);
      }
      //wprintf(L"size:%ld", iNewSize);
      tt->first = test;
      tt->last = tt->first + iNewSize - 1;
      tt->current = tt->first + tt->size - 1;
      ee = tt->first + tt->size;
      int ii;
      for (ii = tt->size; ii < iNewSize; ii++)
      {
        createElement(ee);
        ee++;
      }
      tt->size = iNewSize;
      tt->resizings++;
    } /* if */

    tt->current++;
    return tt->current;
  }

  element * decrementTape(tape * tt)
  {
    if (tt->current == tt->first)
    {
      return tt->first;
    }
    tt->current--;
    return tt->current;
  }

  wchar_t * setCurrentElement(tape * tt, wchar_t * sNewText)
  {
    setElement(tt->current, sNewText);
  }

  wchar_t * printTape(wchar_t * sReturn, tape * tt)
  {
    long int iSpaceNeeded = 1000;
    wchar_t * sDisplay = NULL;
    int ii;
    element * ee = tt->first;
    wchar_t sLineNumber[10] = L"\0";

    for (ii = 0; ii < tt->size; ii++)
    {
      iSpaceNeeded += wcslen(ee->text) + 50;
      ee++; 
    }
    sReturn = (wchar_t *) malloc(sizeof(wchar_t) * iSpaceNeeded);
    if (sReturn == NULL)
    {
      fwprintf(L"error allocating memory in printTape()\n", stderr);
      exit(EXIT_FAILURE);
    }
    int iCurrentElement = tt->current - tt->first;
    sReturn[0] = L'\0';
    swprintf(sReturn, 1000, 
      L"size:%ld, resizings:%d, initial size:%d, grow factor:%d \n"
      L"current element:%d \n",
      tt->size, tt->resizings, TAPESIZE, TAPEGROW, iCurrentElement);

    ee = tt->first;
    for (ii = 0; ii < tt->size; ii++)
    {
      if (ee == tt->current)
       { wcscat(sReturn, L">>"); }
      else
       { wcscat(sReturn, L"  "); }
      swprintf(sLineNumber, 9, L"%d ", ii);
      wcscat(sReturn, sLineNumber);
      
      sDisplay = printElement(sDisplay, ee);
      wcscat(sReturn, sDisplay);
      wcscat(sReturn, L"\n");
      ee++; 
    }
    free(sDisplay);
    return sReturn;
  }
  

  wchar_t * dumpTape(wchar_t * sReturn, tape * tape)
  {
  }

  void showTape(tape * tape)
  {
  }
  

