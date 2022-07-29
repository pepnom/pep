  #include <stdio.h>
  #include <stdlib.h>
  #include "buffer.h"

  /*---------------------------------------------------- */
  /* initialize memory and member fields for the buffer. */

  buffer * createBuffer(buffer * bb)
  {
     bb->stack = (wchar_t *)malloc(sizeof(wchar_t) * BUFFERSIZE); 
     if (bb->stack == NULL)
     {
       fwprintf(L"error allocating memory in createBuffer()\n", stderr);
       exit(EXIT_FAILURE);
     }

     bb->end = bb->stack + BUFFERSIZE - 1;
     bb->last = bb->stack;
     bb->workspace = bb->stack;
     bb->stack[0] = L'\0';
     bb->size = BUFFERSIZE;
     bb->resizings = 0;
     return bb;
  }

  /*---------------------------------------------------- */
  void * freeBuffer(buffer * bb)
  {
    free(bb->stack);
    free(bb);
  }

  /*---------------------------------------------------- */
  wchar_t * printBuffer(wchar_t * sReturn, const buffer * bb)
  {
    long int iSpaceNeeded = 
      sizeof(wchar_t) * (wcslen(bb->stack) + 500) * 2;

    sReturn = (wchar_t *) malloc(iSpaceNeeded);
    if (sReturn == NULL)
    {
      fwprintf(L"error allocating memory in printBuffer() \n", stderr);
      exit(EXIT_FAILURE);
    }

    sReturn[0] = L'\0';  
    swprintf(sReturn, iSpaceNeeded, 
      L"[%ld/%ld] characters in stack: %ld\n"
      L"%ls\n", 
      wcslen(bb->stack), bb->size, bb->workspace-bb->stack, bb->stack);

    long int ii = 0;
    for (ii = 0; ii <= wcslen(bb->stack) + 1; ii++)
    {
      wcscat(sReturn, (bb->stack + ii == bb->workspace) ? L"^" : L" "); 
    }
    wcscat(sReturn, L"\n"); 
    return sReturn;
  }

  /*---------------------------------------------------- */
  wchar_t * dumpBuffer(wchar_t * sReturn, const buffer * bb)
  {
    long int iSpaceNeeded = sizeof(wchar_t) * (500 + wcslen(bb->stack));
    sReturn = (wchar_t *) malloc(iSpaceNeeded);
    if (sReturn == NULL)
    {
      fwprintf(L"error allocating memory in dumpBuffer() \n", stderr);
      exit(EXIT_FAILURE);
    }
    
    sReturn[0] = L'\0';  
    swprintf(sReturn, iSpaceNeeded, 
      L"buffer length:%ld\n"
      L"capacity     :%ld\n"
      L"resizings    :%ld\n"
      L"initial size :%ld\n"
      L"grow factor  :%ld\n"
      L"stack        :%ls\n"
      L"workspace    :%ls\n"
      L"offset       :%ld\n"
      L"text (hex)   :",
      wcslen(bb->stack), bb->size, bb->resizings, 
      BUFFERSIZE, BUFFERGROW, bb->stack, bb->workspace, 
      bb->workspace - bb->stack);
      // todo: a hex listing of the values
      //for (int i = 0; i < wcslen(bb->text); i++)
      // swprintf(sReturn+2*i, "%02x", (unsigned int) bb->text[i]);
    
    return sReturn;
  }

  wchar_t * appendText(buffer * bb, wchar_t * sText)
  {
    int iNewSize = 0; 
    wchar_t * test = NULL;
    int iOffset = 0;

    if (wcslen(bb->stack) + wcslen(sText) + 1 > bb->size) 
    {
      iNewSize = bb->size + wcslen(sText) + 1 + BUFFERGROW;
      test = (wchar_t *)realloc((void *) bb->stack, iNewSize * sizeof(wchar_t));  
      if (test == NULL)
      {
        fwprintf(L"error allocating memory in appendText() \n", stderr);
        exit(EXIT_FAILURE);
      }
      iOffset = bb->workspace - bb->stack; 
      bb->stack = test;
      bb->workspace = bb->stack + iOffset;
      bb->end = bb->stack + iNewSize - 1;
      bb->last = bb->workspace + wcslen(bb->workspace);
      bb->resizings++;
      bb->size = iNewSize;
    }
    wcscat(bb->workspace, sText);
    return sText;
  }

  wchar_t * appendCharacter(buffer * bb, wchar_t cCharacter)
  {}
  wchar_t * appendInteger(buffer * bb, long int ii)
  {}

  /* if the stack was popped (was not empty) returns true, if not false */
  int popBuffer(buffer * bb)
  {
    if (bb->workspace == bb->stack) return FALSE;
    bb->workspace--;
    if (bb->workspace == bb->stack) return FALSE;
    bb->workspace--;
    for (;bb->workspace[0] != L'*' && bb->workspace != bb->stack; bb->workspace--);
    if (bb->workspace[0] == L'*') bb->workspace++;
    //bb->stacksize--; ??
    return TRUE;
  }

  int pushBuffer(buffer * bb)
  {
    if (bb->workspace[0] == L'\0') return FALSE;
    for (;bb->workspace[0] != L'\0' && bb->workspace[0] != L'*'; bb->workspace++);
    if (bb->workspace[0] == L'*') bb->workspace++;
    //bb->stacksize--; ??
    return TRUE;
  }
  
  /* for the sake of efficiency this method should not be used
   * or should be a macro */
  wchar_t * clearWorkspace(buffer * bb)
  {
    bb->workspace[0] = L'\0'; 
  }


