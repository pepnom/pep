#ifndef MACHINE_H
#define MACHINE_H

 #define TRUE 0
 #define FALSE 1

 typedef struct 
 {
   /** a counter for counting */
   int accumulator;

   /** the next char on the input stream */
   wint_t peep;   

   wchar_t * workspace;  

   wchar_t * stack;  

   /* the maximum length of the tape */
   int LENGTH;

   /* the tape where attributes are stored */
   wchar_t * tape[100];

   /* pointer to the current tape element */
   int pointer;

   /* the text input stream */
   FILE * input; 

   /* whether the end of the file has been reached */
   bool eof;    

   /* the result of the last test instruction */
   bool flag;

   /* the character which 'escapes' with until */
   wchar_t escape[20];
   
 } Machine;

 Machine * init(Machine *);
 wchar_t * read(Machine *);
 wchar_t * visiblePeep(wchar_t *, Machine *);
 void printState(Machine *);

#endif

