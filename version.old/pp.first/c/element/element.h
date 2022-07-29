#ifndef ELEMENT_H
#define ELEMENT_H 

  #define ELEMENTSIZE 10
  #define ELEMENTGROW 10

  /* represents an element in an infinite tape */
  typedef struct 
  {
    wchar_t * text;
    long int size;
    int resizings;
  } element;

  element * createElement(element *);
  void * freeElement(element *);
  wchar_t * printElement(wchar_t *, element *);
  wchar_t * dumpElement(wchar_t *, element *);
  wchar_t * setElement(element *, wchar_t *);


#endif
