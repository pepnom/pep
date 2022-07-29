#ifndef BUFFER_H
#define BUFFER_H 

  #define TRUE 0
  #define FALSE 1
  #define BUFFERSIZE 10
  #define BUFFERGROW 10

  /* This type is a string buffer within a 'machine' type. 
   * Its purpose is to manage a string stack and a workspace
   * which overlap. */

  typedef struct 
  {
    wchar_t * stack;
    wchar_t * workspace;
    wchar_t * last;      /* pointer to the null termination of the buffer */
    wchar_t * end;       /* pointer to the last available memory location */
    long int size;       /* the amount of allocated memory */
    int resizings;       /* the number of times the memory was changed */
  } buffer;

  buffer * createBuffer(buffer *);
  void * freeBuffer(buffer *);
  int popBuffer(buffer *);
  int pushBuffer(buffer *);
  wchar_t * appendText(buffer *, wchar_t *);
  wchar_t * appendCharacter(buffer *, wchar_t);
  wchar_t * appendInteger(buffer *, long int);
  wchar_t * clearWorkspace(buffer *);
  wchar_t * printBuffer(wchar_t *, const buffer *);
  wchar_t * dumpBuffer(wchar_t *, const buffer *);


#endif
