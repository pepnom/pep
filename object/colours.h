
#ifndef COLOURSH 
#define COLOURSH 

// the wrong way around
//enum Bool {TRUE=0, FALSE};
enum Bool {FALSE=0, TRUE};

enum Colour {
  GREYc=0, REDc, PALEREDc, GREENc, PALEGREENc, BROWNc, YELLOWc, 
  PALEBLUEc, BLUEc, PURPLEc, PINKc, AQUAc, CYANc, 
  WHITEc, BLACKc, NORMALc
};

struct oneColour {
  enum Colour colour;
  char * name;
  char * ansi;
};
extern struct oneColour colourInfo[];

#define BLACK "\x1B[0;30m"
#define PALERED "\x1B[0;31m"
#define RED  "\x1B[1;31m"
#define PALEGREEN  "\x1B[0;32m"
#define GREEN "\x1B[1;32m"
#define BROWN "\x1B[0;33m"
#define YELLOW "\x1B[1;33m"
#define PALEBLUE  "\x1B[0;34m"
#define BLUE "\x1B[1;34m"
#define PALEMAGENTA "\x1B[0;35m"
#define PURPLE "\x1B[0;35m"
#define PINK "\x1B[1;35m"
#define PALECYAN "\x1B[0;36m"
#define AQUA "\x1B[0;36m"
#define CYAN "\x1B[1;36m"
#define WHITE "\x1B[37m"
// on BSD (Mac OSX, this grey seems to be black)
// define GREY "\x1B[1;30m"
#define GREY "\x1B[37m"
#define NORMAL "\x1B[0m"

 //strcpy(GREY, colourInfo[GREYc].name);
 //char *  = colourInfo[c].ansi;
 //char * Colours[] = 
  // {RED, GREEN, YELLOW, BLUE, PURPLE, CYAN, WHITE, NORMAL};

 /* show a table of colours and their names and numbers
 */
 void showColours();

 // convert special characters in a string to their escaped
 // equivalent eg \n \r \v \f \t \? etc
 // also escapes the given delimiter eg " or ]
 //
 // this has to be done char by char and is used in the 
 // saveAssembledProgram() function, writeInstruction() function etc
 void escapeText(FILE * file, char * text);

 // this escapes special chars such as \n \r \\ and colours
 // them differently and displays on stdout. This will be used
 // by the printInstruction() function. This does not escape delimiter
 // chars such as " and ]
 void escapeSpecial(char * text, char * colour);


 /* just displays some text at the bottom of the screen when
    the output needs to be 'paged' (one screen at a time)
 */
 void pagePrompt();

 // print text in lots of colours! ....
 void colourPrint(char * text);

 //  Print the text as a row in various colours
 void colourRow(char * text);

 //  print a banner 
 void banner();

#endif
