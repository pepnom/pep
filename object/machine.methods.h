
#ifndef MACHINEMETHODSH 
#define MACHINEMETHODSH
/*
   machine.methods.h

SEE ALSO

HISTORY

 31 aug 2022
   Looking at how to add and "untilTape()" method
 2015 - 2022
   development. 

  */

  /** accepts "[:space:]" or "[a-z]" or "[abcde]" */
  int workspaceInClassType(struct Machine * mm, const char * class);

  /* return true if all characters in the workspace are in
     the give (ctype.h) class. class is a string in the format
     'alnum', 'space' etc */
  int workspaceInClass(struct Machine * mm, const char * charclass);

  /* return true if all the characters in the workspace
     are in the given list (array of characters) */
  int workspaceInList(struct Machine * mm, const char * list);

  /* return true if all the characters in the workspace
     are in the given range */
  /* range is in the format "a-z", so range[0] is the start
     of the range and range[2] is the end of the range */
  int workspaceInRange(struct Machine * mm, const char * range);

  /* functions which correspond to instructions on the 
     machine */

  /* append text to the workspace */
  void add(struct Machine * mm, const char * text);

  void clip(struct Machine * mm);

  void clop(struct Machine * mm);

  void clear(struct Machine * mm);

  void replace(struct Machine * mm, const char * old, const char * new);

  void print(struct Machine * mm);

  int pop(struct Machine * mm);

  int push(struct Machine * mm);

  void put(struct Machine * mm);

  void get(struct Machine * mm);

  void swap(struct Machine * mm);

  void increment(struct Machine * mm);

  void decrement(struct Machine * mm);

  // avoid name clash with read()
  void readChar(struct Machine * mm);

  void until(struct Machine * mm, const char * text);

  // see the parameterFromText() function
  // maybe split this function into 3. whilePeepIsClass()
  // whilePeepIsRange() and whilePeepIsList().
  void whilePeep(struct Machine * mm, struct Parameter param);

  void whilePeepInClass(struct Machine * mm, const char * charclass);

  void whileNotPeepInClass(struct Machine * mm, const char * charclass);

  // "range" is a string in the format "a-z" , so range[0] is the 
  // start of the range and range[2] is the end of the range
  void whilePeepInRange(struct Machine * mm, char * range);

  void whileNotPeepInRange(struct Machine * mm, char * range);

  void whilePeepInList(struct Machine * mm, const char * list);

  void whileNotPeepInList(struct Machine * mm, const char * list);

  // split this function into 3. whilePeepIsClass()
  // whilePeepIsRange() and whilePeepIsList().
  void whileNotPeep(struct Machine * mm, struct Parameter param);

  // I will/may convert these instructions to c "goto:" instructions
  // that would avoid having to have a reference to a struct Program
  // within the compiled program
  void jump(struct Machine * mm);

  // jumptrue and jumpfalse are relative jumps (unlike "jump")
  void jumpTrue(struct Machine * mm);

  void jumpFalse(struct Machine * mm);

  /* also, all these tests below, may be recoded so as to 
     alter the control flow in the compiled program, rather than
     updating the machine "flag" register. It should become clearer
     how to handle these tests and jumps one the script has been
     written.
     
     */

  void testIs(struct Machine * mm);

  void testClass(struct Machine * mm);

  void testBegins(struct Machine * mm);

  void testEnds(struct Machine * mm);

  void testEof(struct Machine * mm);

  void testTape(struct Machine * mm);

  void count(struct Machine * mm);

  // these 3 dont need to be functions, in the compilable output
  // of compile.ccode.pss
  void incCounter(struct Machine * mm);

  void decCounter(struct Machine * mm);

  void zeroCounter(struct Machine * mm);

  void chars(struct Machine * mm);

  void lines(struct Machine * mm);

  // bug! doesnt check for sufficient room in the workspace 
  // buffer.
  void escape(struct Machine * mm, struct Parameter param);

  /* used in tr/translate.c.pss where there are no parameters */
  void escapeChar(struct Machine * mm, char c);

  void unescape(struct Machine * mm, struct Parameter param);

  void state(struct Machine * mm);

  void quit(struct Machine * mm);

  void bail(struct Machine * mm);

  void writeToFile(struct Machine * mm);

  void nop(struct Machine * mm);

  void undefined(struct Machine * mm);

#endif

