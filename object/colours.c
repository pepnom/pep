 /* show a table of colours and their names and numbers
 */

# include <stdio.h>
# include <string.h>
# include "colours.h"


struct oneColour colourInfo[] = { 
  { GREYc, "grey", "\x1B[1;30m"},
  { REDc, "red",  "\x1B[0;31m"},
  { PALEREDc, "palered", "\x1B[1;31m"},
  { GREENc, "green", "\x1B[0;32m"},
  { PALEGREENc, "palegreen", "\x1B[1;32m"},
  { BROWNc, "brown", "\x1B[0;33m"},
  { YELLOWc, "yellow", "\x1B[1;33m"},
  { PALEBLUEc, "paleblue", "\x1B[0;34m"},
  { BLUEc, "blue", "\x1B[1;34m"},
  { PURPLEc, "purple",  "\x1B[0;35m"},
  { PINKc, "pink", "\x1B[1;35m"},
  { AQUAc, "aqua", "\x1B[0;36m"},
  { CYANc, "cyan", "\x1B[1;36m"},
  { WHITEc, "white", "\x1B[37m"},
  { BLACKc, "black", "\x1B[0;30m"},
  { NORMALc, "normal", "\x1B[0m"}
};

 void showColours() {
   int ii;
   printf("Colours and colour values: \n");
   for (ii = 0; ii <= NORMALc; ii++) {
     printf("%s%2d: %s%9s [%s%s%s]\n", 
       GREEN, ii,
       WHITE, colourInfo[ii].name,
       colourInfo[ii].ansi, colourInfo[ii].name, WHITE);
   }
   printf("\n");
 }

 
// convert special characters in a string to their escaped
// equivalent eg \n \r \v \f \t \? etc
// also escapes the given delimiter eg " or ]
//
// this has to be done char by char and is used in the 
// saveAssembledProgram() function, writeInstruction() function etc
void escapeText(FILE * file, char * text) {

  char * cc = text;
  while (*cc != '\0') {
    switch (*cc) {
      case '"':
        fprintf(file, "\\\""); 
        break;
      case ']':
        fprintf(file, "\\]"); 
        break;
      case '\\':
        fprintf(file, "\\\\"); 
        break;
      case '\n':
        fprintf(file, "\\n"); 
        break;
      case '\t':
        fprintf(file, "\\t"); 
        break; 
      case '\r':
        fprintf(file, "\\r"); 
        break;
      case '\f':
        fprintf(file, "\\f"); 
        break;
      default:
        fprintf(file, "%c", *cc); 
        break;
    } // switch cc
    cc++;
  } // while
} // fn 

// this escapes special chars such as \n \r \\ and colours
// them differently and displays on stdout. This will be used
// by the printInstruction() function. This does not escape delimiter
// chars such as " and ]
void escapeSpecial(char * text, char * colour) {

  char * cc = text;
  // dont need this line, since normal characters
  // are handled below in the switch
  printf("%s", colour); 
  while (*cc != '\0') {
    switch (*cc) {
      case '\n':
        printf("%s\\n%s", YELLOW, colour); 
        break;
      case '\t':
        printf("%s\\t%s", YELLOW, colour); 
        break; 
      case '\r':
        printf("%s\\r%s", YELLOW, colour); 
        break;
      case '\f':
        printf("%s\\f%s", YELLOW, colour); 
        break;
      case '\v':
        printf("%s\\v%s", YELLOW, colour); 
        break;
      default:
        printf("%s%c", colour, *cc); 
        break;
    } // switch cc
    cc++;
  } // while
  printf("%s", NORMAL); 
}


 /* just displays some text at the bottom of the screen when
    the output needs to be 'paged' (one screen at a time)
 */
 void pagePrompt() {
   printf("\n%s<enter>%s for more (%sq%s = exit):", 
     AQUA, NORMAL, AQUA, NORMAL);
 }

 // print text in lots of colours! ....
 void colourPrint(char * text) {
   int ii;
   int length = strlen(text);
   for (ii = 0; ii < length; ii++) {
     printf("%s%c", colourInfo[ii%13 + 1].ansi, *text); 
     text++;
   }
   printf(NORMAL); 
 }

 //  Print the text as a row in various colours
 void colourRow(char * text) {
   int ii;
   int length = strlen(text);
   for (ii = 0; ii < (46/length); ii++) {
     printf("%s%s", colourInfo[ii%13 + 1].ansi, text); 
   }
   printf("\n");
   printf(NORMAL); 
   
 }

 //  print a banner 
 void banner() {
   printf("\n");
   colourRow("== ");
   printf("%s pep/nom:%s A Pattern Parsing Machine and Language%s\n", 
      PINK, GREEN, NORMAL);
   colourRow("== ");
   printf("\n");
 }

//---------------------------------
// unit test code
// compile with gcc -DUNITTEST

  #ifdef UNITTEST
  int main(int argc, char **argv)
  {
  }
  #endif

