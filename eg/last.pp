# Assembly listing 
read 
testclass [\n]
jumpfalse 2
nochars 
testclass [\n]
jumpfalse 6
put 
clear 
add ";*"
push 
jump 755
testclass [:space:]
jumpfalse 6
clear 
testeof 
jumpfalse 2
jump 755
jump 0
testis "#"
jumpfalse 10
clear 
add "/* "
until "\n"
testends "\n"
jumpfalse 2
clip 
add " */\n"
put 
clear 
testis "~"
jumptrue 12
testis ","
jumptrue 10
testis "{"
jumptrue 8
testis "}"
jumptrue 6
testis ";"
jumptrue 4
testis "!"
jumptrue 2
jump 46
put 
add "*"
push 
jump 755
testis "="
jumptrue 30
testis "p"
jumptrue 28
testis "P"
jumptrue 26
testis "l"
jumptrue 24
testis "d"
jumptrue 22
testis "D"
jumptrue 20
testis "F"
jumptrue 18
testis "g"
jumptrue 16
testis "G"
jumptrue 14
testis "h"
jumptrue 12
testis "H"
jumptrue 10
testis "n"
jumptrue 8
testis "N"
jumptrue 6
testis "x"
jumptrue 4
testis "z"
jumptrue 2
jump 156
testis "="
jumpfalse 4
clear 
add "this.output.write(String.valueOf(this.linesRead)+'\\n');\n"
add "this.output.flush(); /* '=' */"
testis "d"
jumpfalse 3
clear 
add "if (true) { this.patternSpace.setLength(0); continue; } /* 'd' */"
testis "D"
jumpfalse 6
clear 
add "if (this.patternSpace.indexOf(\"\\n\") > -1) {\n"
add "  this.patternSpace.delete(0, this.patternSpace.indexOf(\"\\n\"));\n"
add "  this.readNext = false; if (true) continue; \n"
add "} else { this.patternSpace.setLength(0); continue; } /* 'd' */"
testis "F"
jumpfalse 3
clear 
add "this.output.write(\"<unknown-file>\n\");  /* F */"
testis "g"
jumpfalse 4
clear 
add "this.patternSpace.setLength(0); \n"
add "this.patternSpace.append(this.holdSpace);  /* 'g' */"
testis "G"
jumpfalse 3
clear 
add "this.patternSpace.append(\"\\n\" + this.holdSpace);  /* 'G' */"
testis "h"
jumpfalse 4
clear 
add "this.holdSpace.setLength(0); \n"
add "this.holdSpace.append(this.patternSpace);  /* 'h' */"
testis "H"
jumpfalse 3
clear 
add "this.holdSpace.append(\"\\n\" + this.patternSpace);  /* 'H' */"
testis "l"
jumpfalse 3
clear 
add "this.output.write(this.patternSpace.toString()+'\\n'); /* 'l' */"
testis "n"
jumpfalse 6
clear 
add "if (this.autoPrint) { \n"
add "  this.output.write(this.patternSpace.toString()+'\\n');\n}\n"
add "this.patternSpace.setLength(0);\n"
add "this.readLine();   /* 'n' */"
testis "N"
jumpfalse 4
clear 
add "this.patternSpace.append('\\n'); "
add "this.readLine();  /* 'N' */"
testis "p"
jumpfalse 3
clear 
add "this.output.write(this.patternSpace.toString()+'\\n'); /* 'p' */"
testis "P"
jumpfalse 7
clear 
add "if (this.patternSpace.indexOf(\"\\n\") > -1) {\n"
add "  this.output.write(\n"
add "    this.patternSpace.substring(0, \n"
add "    this.patternSpace.indexOf(\"\\n\"))+'\\n');\n"
add "} else { this.output.write(this.patternSpace.toString()+'\\n'); }"
testis "x"
jumpfalse 3
clear 
add "this.swap();  /* x */"
testis "z"
jumpfalse 3
clear 
add "this.patternSpace.setLenth(0); /* z */"
put 
clear 
add "action*"
push 
jump 755
testclass [0-9]
jumpfalse 7
while [0-9]
put 
clear 
add "number*"
push 
jump 755
testis "$"
jumpfalse 6
put 
clear 
add "number*"
push 
jump 755
testis "/"
jumpfalse 37
clear 
add "near line/char "
ll 
add ":"
cc 
put 
clear 
until "/"
testends "/"
jumptrue 7
clear 
add "Missing '/' to terminate "
get 
add "?\n"
print 
quit 
clip 
testends "$"
jumptrue 2
add ".*$"
testbegins "^"
jumptrue 5
put 
clear 
add "^.*"
get 
put 
clear 
add "\""
get 
add "\""
put 
clear 
add "pattern*"
push 
jump 755
testis "y"
jumpfalse 80
clear 
add "near line "
ll 
add ", char "
cc 
put 
clear 
until "/"
testends "/"
jumpfalse 4
testclass [ /]
jumpfalse 2
jump 231
clear 
add "Missing '/' after 'y' transliterate command\n"
add "Or trailing characters "
get 
add "\n"
print 
quit 
clear 
add "near line "
ll 
add ", char "
cc 
put 
clear 
until "/"
testends "/"
jumptrue 7
clear 
add "Missing 2nd '/' after 'y' transliterate command "
get 
add "\n"
print 
quit 
testis "/"
jumpfalse 8
clear 
add "Sed syntax error? \n"
add "  Empty regex after 'y' transliterate command "
get 
add "\n"
print 
quit 
clip 
put 
clear 
add "this.transliterate(\""
get 
add "\", \""
put 
clear 
add "near line "
ll 
add ", char "
cc 
++ 
put 
-- 
clear 
until "/"
testends "/"
jumptrue 7
clear 
add "Missing 3rd '/' after 'y' transliterate command "
get 
add "\n"
print 
quit 
clip 
swap 
get 
add "\");   /* y */ "
put 
clear 
add "action*"
push 
jump 755
testbegins "a\\"
jumptrue 6
testbegins "c\\"
jumptrue 4
testbegins "i\\"
jumptrue 2
jump 347
testends "\\\n"
jumpfalse 5
clip 
clip 
add "\\n"
jump 0
testeof 
jumpfalse 2
add "\n"
testends "\n"
jumpfalse 3
testends "\\\n"
jumpfalse 2
jump 346
clip 
replace "\n"
testbegins "a\\"
jumpfalse 8
clop 
clop 
put 
clear 
add "this.patternSpace.append('\\n'+\""
get 
add "\");"
testbegins "c\\"
jumpfalse 9
clop 
clop 
put 
clear 
add "this.patternSpace.setLength(0);\n"
add "this.patternSpace.append(\""
get 
add "\");"
testbegins "i\\"
jumpfalse 8
clop 
clop 
put 
clear 
add "this.patternSpace.insert(0, \""
get 
add "\"+'\\n');"
put 
clear 
add "action*"
push 
jump 755
jump 0
testis "a"
jumptrue 6
testis "c"
jumptrue 4
testis "i"
jumptrue 2
jump 438
put 
clear 
while [ \t\f]
clear 
testeof 
jumpfalse 12
clear 
add "Sed syntax error? (near line:char "
ll 
add ":"
cc 
add ")\n"
add "  No argument for '"
get 
add "' command.\n"
print 
quit 
read 
testbegins "\\"
jumpfalse 4
swap 
get 
jump 0
testeof 
jumpfalse 3
testis "\n"
jumptrue 2
jump 393
clear 
add "[Sed syntax error?\] (near line:char "
ll 
add ":"
cc 
add ")\n"
add "  No argument for '"
get 
add "' command.\n"
print 
quit 
until "\n"
testeof 
jumpfalse 17
testends "\n"
jumpfalse 2
clip 
testis ""
jumpfalse 12
clear 
add "{Sed syntax error?\] (near line:char "
ll 
add ":"
cc 
add ")\n"
add "  No argument for '"
get 
add "' command.\n"
print 
quit 
replace "\n"
swap 
testis "a"
jumpfalse 5
clear 
add "this.patternSpace.append('\\n'+\""
get 
add "\");"
testis "c"
jumpfalse 6
clear 
add "this.patternSpace.setLength(0);\n"
add "this.patternSpace.append(\""
get 
add "\");"
testis "i"
jumpfalse 5
clear 
add "this.patternSpace.insert(0, \""
get 
add "\"+'\\n');"
put 
clear 
add "action*"
push 
jump 755
testis "b"
jumptrue 12
testis "e"
jumptrue 10
testis "q"
jumptrue 8
testis "Q"
jumptrue 6
testis "t"
jumptrue 4
testis "T"
jumptrue 2
jump 536
put 
clear 
while [ ]
clear 
whilenot [ ;}]
testis ""
jumptrue 4
swap 
add " "
swap 
swap 
get 
testbegins "b"
jumpfalse 5
clear 
add "this.unsupported(\"b -branch \");\n"
put 
clear 
testbegins "e "
jumpfalse 7
clear 
add "System.out.print(this.execute(\""
get 
add "\"));  /* \"e <cmd>\" */"
put 
clear 
testis "e"
jumpfalse 7
clear 
add "temp = this.patternSpace.toString();\n"
add "this.patternSpace.setLength(0);  /* 'e' */\n"
add "this.patternSpace.append(this.execute(temp)); "
put 
clear 
testis "q"
jumpfalse 6
clear 
add "this.output.write(this.patternSpace.toString()+'\\n');\n"
add "System.exit(0);"
put 
clear 
testbegins "q "
jumpfalse 11
clop 
clop 
put 
clear 
add "this.output.write(this.patternSpace.toString()+'\\n');\n"
add "System.exit("
get 
add ");"
put 
clear 
testis "Q"
jumpfalse 5
clear 
add "System.exit(0);"
put 
clear 
testbegins "Q "
jumpfalse 10
clop 
clop 
put 
clear 
add "System.exit("
get 
add ");"
put 
clear 
testbegins "t"
jumpfalse 5
clear 
add "this.unsupported(\"t - branch \");\n"
put 
clear 
testbegins "T"
jumpfalse 5
clear 
add "this.unsupported(\"T - branch \");\n"
put 
clear 
add "action*"
push 
jump 755
testis ":"
jumptrue 10
testis "r"
jumptrue 8
testis "R"
jumptrue 6
testis "w"
jumptrue 4
testis "W"
jumptrue 2
jump 621
put 
clear 
while [ ]
clear 
whilenot [ ;}]
testis ""
jumpfalse 10
clear 
add "Sed syntax error? (at line:char "
ll 
add ":"
cc 
add ")\n"
add "  no filename for read 'r' command. \n"
print 
quit 
swap 
add " "
get 
testbegins ": "
jumpfalse 5
clear 
add "this.unsupported(\": - branchlabel \");\n"
put 
clear 
testbegins "r "
jumpfalse 14
clear 
add "/* \"r\" */\n"
add "Path path = Path.of(\""
get 
add "\");\n"
add "File f = new File(\""
get 
add "\"); \n"
add "if (f.isFile()) { \n"
add "  this.patternSpace.append(Files.readString(path));\n"
add "}"
put 
clear 
testbegins "R "
jumpfalse 14
clear 
add "/* \"R\" */\n"
add "Path path = Path.of(\""
get 
add "\");\n"
add "File f = new File(\""
get 
add "\"); \n"
add "if (f.isFile()) { \n"
add "  this.output.write(Files.readString(path)+'\\n');\n"
add "}"
put 
clear 
testbegins "w "
jumpfalse 7
clear 
add "this.writeToFile(\""
get 
add "\");"
put 
clear 
testbegins "W "
jumpfalse 7
clear 
add "this.writeFirstToFile(\""
get 
add "\");"
put 
clear 
add "action*"
push 
jump 755
testis "s"
jumpfalse 100
clear 
add "near line/char "
ll 
add ":"
cc 
put 
clear 
until "/"
testends "/"
jumpfalse 4
testclass [ /]
jumpfalse 2
jump 643
clear 
add "Missing '/' after 's' substitute command\n"
add "Or trailing characters "
get 
add "\n"
print 
quit 
clear 
add "near line "
ll 
add ", char "
cc 
put 
clear 
until "/"
testends "/"
jumptrue 8
clear 
add "Sed syntax error? \n"
add "  Missing 2nd '/' after 's' substitute command "
get 
add "\n"
print 
quit 
testis "/"
jumpfalse 8
clear 
add "Sed syntax error? \n"
add "  Empty regex after 's' substitute command "
get 
add "\n"
print 
quit 
clip 
replace "\\("
replace "\\)"
replace "\\'"
put 
clear 
add "this.substitute(\""
get 
add "\", \""
put 
clear 
add "near line/char "
ll 
add ":"
cc 
++ 
put 
-- 
clear 
until "/"
testends "/"
jumptrue 7
clear 
add "Missing 3rd '/' after 's' substitute command "
get 
add "\n"
print 
quit 
clip 
replace "\\1"
replace "\\2"
replace "\\3"
replace "\\4"
replace "\\5"
replace "\\6"
replace "\\7"
replace "\\8"
replace "\\9"
swap 
get 
add "\", \""
while [emgip0123456789]
add "\", \""
while [w]
testends "w"
jumpfalse 2
whilenot [;\n]
add "\");   /* s */ "
put 
clear 
add "action*"
push 
jump 755
testis "a"
jumptrue 6
testis "c"
jumptrue 4
testis "i"
jumptrue 2
jump 741
put 
clear 
add "Unimplemented command (near line:char "
ll 
add ":"
cc 
add ")\n"
add "  The script does not recognise '"
get 
add "' yet.\n"
print 
quit 
testis ""
jumptrue 13
put 
clear 
add "Sed syntax error? (near line:char "
ll 
add ":"
cc 
add ")\n"
add "  unrecognised command '"
get 
add "'\n"
print 
quit 
add "// "
ll 
add ":"
cc 
add " "
print 
clear 
add "\n"
unstack 
print 
clip 
stack 
testeof 
jumpfalse 9
pop 
testis "action*"
jumpfalse 5
add ";*"
push 
push 
jump 755
push 
pop 
pop 
pop 
pop 
pop 
pop 
testis "pattern*,*pattern*{*commandset*}*"
jumptrue 10
testis "pattern*,*number*{*commandset*}*"
jumptrue 8
testis "number*,*number*{*commandset*}*"
jumptrue 6
testis "number*~*number*{*commandset*}*"
jumptrue 4
testis "number*,*pattern*{*commandset*}*"
jumptrue 2
jump 975
++ 
++ 
++ 
++ 
swap 
replace "\n"
-- 
put 
clear 
add " "
get 
++ 
swap 
-- 
-- 
-- 
-- 
testbegins "pattern*,*pattern*"
jumpfalse 37
clear 
add "if (this.line.toString().matches("
get 
add ") && (this.states["
count 
add "\] == false))\n  {"
add " this.states["
count 
add "\] = true; }\n"
add "if (this.states["
count 
add "\] == true) {\n"
++ 
++ 
++ 
++ 
get 
-- 
-- 
-- 
-- 
add "\n}\n"
add "if (this.line.toString().matches("
++ 
++ 
get 
-- 
-- 
add ") && (this.states["
count 
add "\] == true))\n  {"
add " this.states["
count 
add "\] = false; }\n"
put 
a+ 
testbegins "pattern*,*number*"
jumpfalse 37
clear 
add "if (this.line.toString()..matches("
get 
add ") && (this.states["
count 
add "\] == false))\n"
add "  { this.states["
count 
add "\] = true; }\n"
add "if (this.states["
count 
add "\] == true) {\n "
++ 
++ 
++ 
++ 
get 
-- 
-- 
-- 
-- 
add "\n}\n"
add "if ((this.linesRead > "
++ 
++ 
get 
-- 
-- 
add ") && (this.states["
count 
add "\] == true))\n"
add "  { this.states["
count 
add "\] = false; }\n"
put 
a+ 
testbegins "number*,*pattern*"
jumpfalse 37
clear 
add "if ((this.linesRead == "
get 
add ") && (this.states["
count 
add "\] == false))\n"
add "  { this.states["
count 
add "\] = true; }\n"
add "if (this.states["
count 
add "\] == true) {\n "
++ 
++ 
++ 
++ 
get 
-- 
-- 
-- 
-- 
add "\n}\n"
add "if (this.line.toString().matches("
++ 
++ 
get 
-- 
-- 
add ") && (this.states["
count 
add "\] == true))\n"
add "  { this.states["
count 
add "\] = false; }\n"
put 
a+ 
testbegins "number*,*number*"
jumpfalse 22
clear 
add "if ((this.linesRead >= "
get 
add ") && (this.linesRead <= "
++ 
++ 
get 
-- 
-- 
add ")) {\n"
++ 
++ 
++ 
++ 
get 
-- 
-- 
-- 
-- 
add "\n}"
put 
testbegins "number*~*number*"
jumpfalse 22
clear 
add "if ((this.linesRead % "
++ 
++ 
get 
-- 
-- 
add ") == "
get 
add ") {\n"
++ 
++ 
++ 
++ 
get 
-- 
-- 
-- 
-- 
add "\n}"
put 
clear 
add "command*"
push 
jump 755
push 
push 
push 
push 
push 
push 
pop 
pop 
pop 
pop 
testis "pattern*,*pattern*command*"
jumptrue 10
testis "pattern*,*number*command*"
jumptrue 8
testis "number*,*number*command*"
jumptrue 6
testis "number*~*number*command*"
jumptrue 4
testis "number*,*pattern*command*"
jumptrue 2
jump 1011
push 
push 
push 
clear 
get 
++ 
put 
-- 
clear 
put 
add "{*commandset*}*"
push 
push 
push 
jump 755
push 
push 
push 
push 
pop 
pop 
pop 
testis "range*action*;*"
jumptrue 6
testis "number*action*;*"
jumptrue 4
testis "pattern*action*;*"
jumptrue 2
jump 1037
push 
clear 
get 
++ 
put 
-- 
clear 
add "{*commandset*}*"
push 
push 
push 
jump 755
testis "range*{*}*"
jumptrue 6
testis "number*{*}*"
jumptrue 4
testis "pattern*{*}*"
jumptrue 2
jump 1054
push 
push 
clear 
add "  // warning: empty braces {} - does nothing!"
put 
clear 
add "commandset*}*"
push 
push 
jump 755
push 
push 
push 
pop 
pop 
testis "pattern*number*"
jumptrue 18
testis "pattern*pattern*"
jumptrue 16
testis "number*number*"
jumptrue 14
testis "number*pattern*"
jumptrue 12
testis "range*number*"
jumptrue 10
testis "range*pattern*"
jumptrue 8
testis "pattern*;*"
jumptrue 6
testis "number*;*"
jumptrue 4
testis "range*;*"
jumptrue 2
jump 1088
clear 
add "Sed syntax error? (near line:char "
ll 
add ":"
cc 
add ")\n"
add "  line selector/number/range with no action \n"
add "  (missing ',' or misplaced ';' ?) \n"
print 
quit 
testis "action*action*"
jumptrue 12
testis "action*command*"
jumptrue 10
testis "action*number*"
jumptrue 8
testis "action*pattern*"
jumptrue 6
testis "action*range*"
jumptrue 4
testis "action*{*"
jumptrue 2
jump 1110
clear 
add "Sed error (line "
ll 
add ", chars "
cc 
add "):\n"
add "  Missing ';' after command?\n"
print 
quit 
testis ",*}*"
jumptrue 14
testis ",*{*"
jumptrue 12
testis ",*;*"
jumptrue 10
testis ",*,*"
jumptrue 8
testis ";*,*"
jumptrue 6
testis ";*{*"
jumptrue 4
testis "range*,*"
jumptrue 2
jump 1140
clip 
clop 
clop 
put 
clear 
add "Sed error (line "
ll 
add ", chars "
cc 
add "):\n"
add "  Unexpected character '"
get 
add "' \n"
print 
quit 
testis "command*;*"
jumptrue 6
testis "commandset*;*"
jumptrue 4
testis ";*;*"
jumptrue 2
jump 1151
clip 
clip 
push 
jump 755
testis "action*;*"
jumpfalse 5
clear 
add "command*"
push 
jump 755
testis "number*!*"
jumpfalse 11
clear 
get 
++ 
get 
-- 
put 
clear 
add "number*"
push 
jump 755
testis "pattern*!*"
jumpfalse 11
clear 
get 
++ 
get 
-- 
put 
clear 
add "pattern*"
push 
jump 755
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2
jump 1197
clear 
get 
++ 
add "\n"
get 
-- 
put 
clear 
add "commandset*"
push 
jump 755
pop 
testis "command*command*}*"
jumptrue 8
testis "command*action*}*"
jumptrue 6
testis "commandset*action*}*"
jumptrue 4
testis "commandset*command*}*"
jumptrue 2
jump 1219
clear 
get 
++ 
add "\n"
get 
-- 
put 
clear 
add "commandset*}*"
push 
push 
jump 755
testis "range*action*}*"
jumptrue 6
testis "number*action*}*"
jumptrue 4
testis "pattern*action*}*"
jumptrue 2
jump 1239
clear 
get 
add "{\n  "
++ 
get 
add "\n}"
-- 
put 
clear 
add "command*}*"
push 
push 
jump 755
testis "{*action*}*"
jumpfalse 7
clear 
add "{*commandset*}*"
push 
push 
push 
jump 755
testis "{*command*}*"
jumpfalse 7
clear 
add "{*commandset*}*"
push 
push 
push 
jump 755
pop 
testis "pattern*{*commandset*}*"
jumptrue 4
testis "number*{*commandset*}*"
jumptrue 2
jump 1304
++ 
++ 
swap 
replace "\n"
-- 
put 
clear 
add "  "
get 
++ 
swap 
-- 
-- 
testis "pattern*{*commandset*}*"
jumpfalse 12
clear 
add "if (this.line.toString().matches("
get 
add ")) {\n"
++ 
++ 
get 
-- 
-- 
add "\n}"
put 
testis "number*{*commandset*}*"
jumpfalse 12
clear 
add "if (this.linesRead == "
get 
add ") {\n"
++ 
++ 
get 
-- 
-- 
add "\n}"
put 
clear 
add "command*"
push 
jump 755
pop 
pop 
push 
push 
push 
push 
push 
push 
testeof 
jumpfalse 301
add "/* The token parse-stack was: "
print 
clear 
unstack 
add " */\n"
print 
clip 
clip 
clip 
clip 
testis "commandset*"
jumptrue 3
testis "command*"
jumpfalse 2
jump 1336
clear 
add "# [error\] Sed syntax error? \n"
add "# ----------------- \n"
add "# Also, uncomment lines after parse> label in script\n"
add "# to see how the sed script is being parsed. \n"
print 
quit 
testis "commandset*"
jumptrue 4
testis "command*"
jumptrue 2
jump 1613
clear 
add "\n"
get 
replace "\n"
put 
clear 
add "\n"
add "\n"
add " /* [ok\] Sed syntax appears ok */\n"
add " /* ---------------------      */\n"
add " /* Java code generated by \"sed.tojava.pss\" */\n"
add " import java.io.*;\n"
add " import java.nio.file.*;\n"
add " import java.nio.charset.*;\n"
add " import java.util.regex.*;\n"
add " import java.util.*;   // contains stack\n"
add "\n"
add " public class javased {\n"
add "   public StringBuffer patternSpace;\n"
add "   public StringBuffer holdSpace;\n"
add "   public StringBuffer line;         /* current line unmodified */\n"
add "   public int linesRead;\n"
add "   private boolean[\] states;         /* pattern-seen state */\n"
add "   private Scanner input;            /* what script will read */\n"
add "   public Writer output;             /* where script will send output */\n"
add "   private boolean eof;              /* end of file reached? */\n"
add "   private boolean hasSubstituted;   /* a sub on this cycle? */\n"
add "   private boolean lastLine;         /* last line of input (for $) */\n"
add "   private boolean readNext;         /* read next line or not */\n"
add "   private boolean autoPrint;        /* autoprint pattern space? */\n"
add "\n"
add "   /** convenience: read stdin, write to stdout */\n"
add "   public javased() {\n"
add "     this(\n"
add "       new Scanner(System.in), \n"
add "       new BufferedWriter(new OutputStreamWriter(System.out)));\n"
add "   }\n"
add "\n"
add "   /** convenience: read and write to strings */\n"
add "   public javased(String in, StringWriter out) {\n"
add "     this(new Scanner(in), out);\n"
add "   }\n"
add "\n"
add "   /** make a new machine with a character stream reader */\n"
add "   public javased(Scanner scanner, Writer writer) {\n"
add "     this.patternSpace = new StringBuffer(\"\"); \n"
add "     this.holdSpace = new StringBuffer(\"\"); \n"
add "     this.line = new StringBuffer(\"\"); \n"
add "     this.linesRead = 0;\n"
add "     this.input = scanner;\n"
add "     this.output = writer;\n"
add "     this.eof = false;\n"
add "     this.hasSubstituted = false;\n"
add "     this.readNext = true;\n"
add "     this.autoPrint = true;\n"
add "     // assume that a sed script has no more than 1K range tests! */\n"
add "     this.states = new boolean[1000\];\n"
add "     for (int ii = 0; ii < 1000; ii++) { this.states[ii\] = false; }\n"
add "   }\n"
add "\n"
add "   /** read one line from the input stream and update the machine. */\n"
add "   public void readLine() {\n"
add "     int iChar;\n"
add "     if (this.eof) { System.exit(0); }\n"
add "     // increment lines\n"
add "     this.linesRead++;\n"
add "     if (this.input.hasNext()) {\n"
add "       this.line.setLength(0);\n"
add "       this.line.append(this.input.nextLine());\n"
add "       this.patternSpace.append(this.line);\n"
add "     } \n"
add "     if (!this.input.hasNext()) { this.eof = true; }\n"
add "   }\n"
add "\n"
add "   /** command \"x\": swap the pattern-space with the hold-space */\n"
add "   public void swap() {\n"
add "     String s = new String(this.patternSpace);\n"
add "     this.patternSpace.setLength(0);\n"
add "     this.patternSpace.append(this.holdSpace.toString());\n"
add "     this.holdSpace.setLength(0);\n"
add "     this.holdSpace.append(s);\n"
add "   }\n"
add "\n"
add "   /** command \"y/abc/xyz/\": transliterate */\n"
add "   public void transliterate(String target, String replacement) {\n"
add "     // javacode for translit\n"
add "     //String target      = \"ab\";\n"
add "     //String replacement = \"**\";\n"
add "     //char[\] array = \"abcde\".toString().toCharArray();\n"
add "     int ii = 0;\n"
add "     char[\] array = this.patternSpace.toString().toCharArray();\n"
add "     for (ii = 0; ii < array.length; ii++) {\n"
add "       int index = target.indexOf(array[ii\]);\n"
add "       if (index != -1) {\n"
add "         array[ii\] = replacement.charAt(index);\n"
add "       }\n"
add "     }\n"
add "     this.patternSpace.setLength(0);\n"
add "     this.patternSpace.append(array);\n"
add "   }\n"
add "\n"
add "   /** command \"s///x\": make substitutions on the pattern-space */\n"
add "   public void substitute(\n"
add "     String first, String second, String flags, String writeText) {\n"
add "     // flags can be gip etc\n"
add "     // gnu sed modifiers M,<num>,e,w filename may be tricky here.\n"
add "\n"
add "     Process p;\n"
add "     BufferedReader stdin;\n"
add "     BufferedReader stderr;\n"
add "     String ss = null;\n"
add "     String temp = new String(\"\");\n"
add "     String old = new String(this.patternSpace);\n"
add "     String opsys = System.getProperty(\"os.name\").toLowerCase();\n"
add " \n"
add "     // here replace 1 2 etc (gnu replace group syntax) with\n"
add "     // $1 $2 etc (java syntax)\n"
add "     //second = second.replaceAll(\"\\\\\\\\([0-9\])\",\"X$1\");\n"
add "     //System.out.println(\"sec = \" + second);\n"
add "     // also () gnu group syntax becomes () java group syntax\n"
add "     // but this is already dealt with.\n"
add "\n"
add "     // case insensitive: add \"(?i)\" at beginning\n"
add "     if ((flags.indexOf('i') > -1) ||\n"
add "         (flags.indexOf('I') > -1)) { first = \"(?i)\" + first; }\n"
add "\n"
add "     // multiline matching, check!!\n"
add "     if ((flags.indexOf('m') > -1) ||\n"
add "         (flags.indexOf('M') > -1)) { first = \"(?m)\" + first; }\n"
add "\n"
add "     // <num>- replace only nth match\n"
add "     // todo\n"
add "\n"
add "     // gnu sed considers a substitute has taken place even if the \n"
add "     // pattern space is unchanged! i.e. if matches first pattern.\n"
add "     if (this.patternSpace.toString().matches(\".*\" + first + \".*\")) {\n"
add "       this.hasSubstituted = true;\n"
add "     }\n"
add "\n"
add "     // g- global, replace all.\n"
add "     if (flags.indexOf('g') == -1) {\n"
add "       temp = this.patternSpace.toString().replaceFirst(first, second);\n"
add "     } else {\n"
add "       temp = this.patternSpace.toString().replaceAll(first, second);\n"
add "     }\n"
add "     this.patternSpace.setLength(0);\n"
add "     this.patternSpace.append(temp);\n"
add "     try {\n"
add "       if  (this.hasSubstituted) {\n"
add "         // only print if substitution made, patternspace different ?\n"
add "         if (flags.indexOf('p') != -1) {\n"
add "           this.output.write(this.patternSpace.toString()+'\\n');\n"
add "         }\n"
add "         // execute pattern space, gnu ext\n"
add "         if (flags.indexOf('e') != -1) {\n"
add "           this.output.write(this.execute(this.patternSpace.toString()));\n"
add "           //System.out.print(this.execute(this.patternSpace.toString()));\n"
add "         }\n"
add "         // write pattern space to file, gnu extension, if sub occurred\n"
add "         // The writeText parameter contains 'w' switch plus possible \n"
add "         // whitespace.\n"
add "         if (writeText.length() > 0) {\n"
add "           writeText = writeText.substring(1).trim();\n"
add "           this.writeToFile(writeText);\n"
add "         }\n"
add "       }\n"
add "     } catch (IOException e) {\n"
add "       System.out.println(e.toString());\n"
add "     }\n"
add "\n"
add "   }\n"
add "\n"
add "   /** execute command/pattspace for s///e or e <arg> or \"e\" */\n"
add "   public String execute(String command) {\n"
add "     Process p;\n"
add "     BufferedReader stdin;\n"
add "     BufferedReader stderr;\n"
add "     String ss;\n"
add "     StringBuffer output = new StringBuffer(\"\");\n"
add "     try {\n"
add "       if (System.getProperty(\"os.name\").toLowerCase().contains(\"win\")) {\n"
add "         p = Runtime.getRuntime().exec(new String[\]{\"cmd.exe\", \"/c\", command});\n"
add "       } else {\n"
add "         p = Runtime.getRuntime().exec(new String[\]{\"bash\", \"-c\", command});\n"
add "       }\n"
add "       stdin = new BufferedReader(new InputStreamReader(p.getInputStream()));\n"
add "       stderr = new BufferedReader(new InputStreamReader(p.getErrorStream()));\n"
add "       while ((ss = stdin.readLine()) != null) { output.append(ss + '\\n'); }  \n"
add "       while ((ss = stderr.readLine()) != null) { output.append(ss + '\\n'); } \n"
add "     } catch (IOException e) {\n"
add "       System.out.println(\"sed exec 'e' failed: \" + e);\n"
add "     }\n"
add "     return output.toString();\n"
add "   }\n"
add "\n"
add "   /** command \"W\": save 1st line of patternspace to filename */\n"
add "   public void writeFirstToFile(String fileName) {\n"
add "     try {\n"
add "       File file = new File(fileName);\n"
add "       Writer out = new BufferedWriter(new OutputStreamWriter(\n"
add "          new FileOutputStream(file), \"UTF8\"));\n"
add "       // get first line of ps\n"
add "       out.append(this.patternSpace.toString().split(\"\\\\R\",2)[0\]);\n"
add "       // yourString.split(\"\\R\", 2);\n"
add "       out.flush(); out.close();\n"
add "     } catch (Exception e) {\n"
add "       System.out.println(e.getMessage());\n"
add "     }\n"
add "   }\n"
add "\n"
add "   /** command \"w\": save the patternspace to filename */\n"
add "   public void writeToFile(String fileName) {\n"
add "     try {\n"
add "       File file = new File(fileName);\n"
add "       Writer out = new BufferedWriter(new OutputStreamWriter(\n"
add "          new FileOutputStream(file), \"UTF8\"));\n"
add "       out.append(this.patternSpace.toString());\n"
add "       out.flush(); out.close();\n"
add "     } catch (Exception e) {\n"
add "       System.out.println(e.getMessage());\n"
add "     }\n"
add "   }\n"
add "\n"
add "   /** handle an unsupported command (message + abort) */\n"
add "   public void unsupported(String name) {\n"
add "     String ss =\n"
add "      \"The \" + name + \"command has not yet been implemented\\n\" +\n"
add "      \"in this sed-to-java translator. Branching commands are hard in\\n\" +\n"
add "      \"in a language that doesn't have 'goto'. Your script will not \\n\" + \n"
add "      \"execute properly. Exiting now... \\n\";\n"
add "      System.out.println(ss); System.exit(0);\n"
add "   }\n"
add "\n"
add "   /** run the script with reader and writer. This allows the code to\n"
add "       be used from within another java program, and not just as a \n"
add "       stream filter. */\n"
add "   public void run() throws IOException {\n"
add "     String temp = \"\";    \n"
add "     while (!this.eof) {\n"
add "       this.hasSubstituted = false;\n"
add "       this.patternSpace.setLength(0);\n"
add "       // some sed commands restart without reading a line...\n"
add "       // hence the use of a flag.\n"
add "       if (this.readNext) { this.readLine(); }\n"
add "       this.readNext = true;\n"
add ""
get 
add "\n"
add "       if (this.autoPrint) { \n"
add "         this.output.write(this.patternSpace.toString() + '\\n');\n"
add "         this.output.flush();\n"
add "       }\n"
add "     } \n"
add "   } \n"
add "\n"
add "   /* run the script as a stream filter. remove this main method\n"
add "      to embed the script in another java program */\n"
add "   public static void main(String[\] args) throws Exception { \n"
add "\n"
add "     // read and write to stdin/stdout\n"
add "     javased mm = new javased();\n"
add "     // new Scanner(System.in), \n"
add "     // new BufferedWriter(new OutputStreamWriter(System.out)));\n"
add "     mm.run();\n"
add "\n"
add "     // convert sedstring to java and write to string.\n"
add "     // javased mm = new javased(\"/class/s/ass/ASS/g\", new StringWriter());\n"
add "     // then use mm.output.toString() to get the result (java source code)\n"
add "   }\n"
add " }\n"
add ""
print 
quit 
jump 0
# End of program. 
