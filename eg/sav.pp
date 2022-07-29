# Assembled with the script 'compile.pss' 
start:
 
#
#   translate.java.pss 
#
#   This is a parse-script which translates parse-scripts into java
#   code, using the 'pep' tool. The script creates a standalone 
#   compilable java program.
#   
#   The virtual machine and engine is implemented in plain c at
#   http://bumble.sf.net/books/pars/gh.c. This implements a script language
#   with a syntax reminiscent of sed and awk (much simpler than awk, but
#   more complex than sed).
#   
#   This code was originally created in a straightforward manner by adapting
#   the code in 'compile.js.pss' which compiles scripts to javascript 
#
#NOTES
#   
#   We use labelled loops and break/continue to implement the 
#   parse> label and .reparse .restart commands. Breaks are also
#   used to implement the quit and bail commands.
#
#TODO
#
#   Convert the parsing code to a method which takes an input
#   stream as a parameter. This way the same parser/compiler 
#   can be used with a string/file/stdin etc and can also be 
#   used by other classes/objects.
#
#SEE ALSO
#   
#   At http://bumble.sf.net/books/pars/
#
#   compile.tcl.pss
#     A very similar script for compiling scripts into tcl
#
#   compile.py.pss
#     A script translator for python.
#
#   compile.pss
#     compiles a script into an "assembly" format that can be loaded
#     and run on the parse-machine with the -a  switch. This performs
#     the same function as "asm.pp" 
#
#TESTING
#
#   * testing the multiple escaped until bug
#   >> pep.jas 'r;until"c";add".";t;d;' 'ab\\cab\cabc'
#
#   Complex scripts can be translated into java and work,
#   including this script itself. 
#
#   eg/natural.language.pss seems to translate well to java.
#
#  * the following is working!
#  ----
#    pep -f compile.java.pss eg/mark.html.pss > Machine.java
#    javac Machine.java
#    cat pars-book.txt | java Machine
#  ,,,,
#
#   The following is working!:
#   -----
#     pep -f compile.java.pss compile.java.pss > Machine.java
#     javac Machine.java
#     cat eg/exp.tolisp.pss | java Machine > Machine.java
#     javac Machine.java
#     echo "(a+2)*3+4" | java Machine
#   ,,,
#
#   This is fairly complex. The script translates itself into
#   java, and then that translator is used to translate 
#   another script into java, which is then executed....
#
#   But even more complex stuff is also working, such as
#   self referentiality cubed!!! 
#   -----
#     pep -f compile.java.pss compile.java.pss > Machine.java
#     javac Machine.java
#     cat compile.java.pss | java Machine > Machine.java
#     javac Machine.java
#     cat eg/exp.tolisp.pss | java Machine > Machine.java
#     javac Machine.java
#     echo "(a+2)*3+4" | java Machine
#   ,,,
#
#   The script can be tested with something like
#   ----
#     pep -f compile.java.pss -i "r;[aeiou]{a '=vowel\n';t;}d;" > Machine.java
#     javac Machine.java; 
#     echo "abcdefhijklmnop" | java Machine
#   ,,, 
#
#   The output will be java code which is equivalent to the 
#   script provided to the -i switch.
#
#   * a very comprehensive test is to run it on itself
#   >> pep -f compile.java.pss compile.java.pss > Machine.java
#
#   This is the "shangrilah" of pep scripts.
#
#   And then we could do!!
#   >> cat compile.java.pss | java Machine
#   which is self-referentiality squared, but I am not sure what
#   its use is.
#
#GOTCHAS
#
#  I was trying to run 
#  >> pep -e "r;a'\\';print;d;" -i "abc"
#  and I kept getting an unterminated quote message, which I thought I
#  had fixed in machine.interp.c (until code). But the problem was actually
#  the bash shell which resolves \\ to \ in double quotes, but not single quotes!
#
#BUGS
#   
#  Xdigit not valid class.
#
#  Its a bit strange to talk about a multicharacter string being "escaped"
#  (eg when calling 'until') but this is allowed in the pep engine.
#
#  add "\{"; will generate an "illegal escape character" error
#  when trying to compile the generated java code. I need to 
#  consider what to do in this situation (eg escape \ to \\ ?)
#
#  check "go/mark" code. what happens if the mark is not found?? 
#  throw error and exit I think.
#
#SOLVED BUGS
# 
#  found a bug in "replace" code, which was returning from inline code.
#
#  Found and fixed a bug in the (==) code ie in java (stringa == stringb)
#  doesnt work. 
#
#  found and fixed a bug in java whilenot/while. The code exits if the 
#  character is not found, which is not correct.
#
#  delimiter was hardcoded in push
#  solved an "until" bug where the java code did not read 
#  at least one character.
#
#TASKS 
#
#HISTORY
#    
#  17 june 2022
#    converted the tape and marks arrays to ArrayList so that
#    they can grow dynamically.
#  15 july 2021
#    probably fixed the multiple escape char "until" bug with
#    the countEscaped() function.
#
#  10 july 2021
#    Trying to fix the 'until' code so that we can write 'add "x \\\\";'
#    or add "x\\\"x"; fixed in compile.pss, now fix in translate.java.pss
#
#  30 july 2020
#    Found "bug", that a begin block with no other code 
#    is not allowed as a script.
#
#  29 july 2020
#    found a bug in "go" (not getting text from tape).
#    Also, delimiter was hard-coded in "push"
#    Found a bug in "clop" (a return statement)
#    
#  25 july 2020
#
#    The translation of eg/mark.html.pss is now working. That 
#    means that many complex scripts now work with this script.
#
#    Found another bug in the matches code. classes must match
#    the whole string, not just one character, so they need to 
#    be eg: "^[a-z]+$" not just "[a-z]"
#
#    Found a bug in the code for "tapetest*" and "nottapetest*"
#    ie (==) and !(==). I was using the wrong equals operator for 
#    java. I found this bug by using a new vim command on 
#    code in the pars-book.txt. This command translates to java and 
#    then compiles and runs pep fragments. This is a useful debugging
#    technique.
#
#  24 july 2020
#
#    Very great advances today. See the testing heading for
#    a strange but true self compilation example.
#
#    The script successfully translates itself into java!!
#    So the following works
#    -----
#      pep -f compile.java.pss compile.java.pss > Machine.java
#      javac Machine.java
#      echo "nop;r;t;t;d;" | java Machine
#    ,,,,
#
#    This script translates eg/json.parse.pss into a seemingly
#    correct java program. It translates eg/mark.html.pss into
#    compilable java code, but doesnt transform the text to 
#    html correctly.
#
#    completely changed the way andtestset* and ortestset* tokens
#    are parsed. This has greatly simplified the logic.
#    First tests show that the script is working, although there will
#    be bugs.
#
#  23 july 2020
#    
#    Extensive revision of this script. rewriting methods as "inline".
#    But revision is incomplete. This script should become 
#    a good template for writing similar scripts in other languages.
#
#  22 july 2020
#
#    Changed the stack code to use the java.util.Stack class.  In the process of
#    rethinking this script and reforming it. I will include the Machine class
#    within the output of the script, so that there are no dependencies on
#    external code. . Also, I will remove trivial methods from the class.
#
#  Oct 2019
#    Made functions ppjjs, ppjjss, ppjjf in helpers.pars.sh so that java
#    scripts can be easily run.
#
#  30 sept 2019
#    basic scripts working. whilenotPeep and whilePeep need to 
#    be written properly. Also, translate unicode categories in
#    [:text:] format to java regex.
#
#  27 sept 2019
#    Began to adapt this script from compile.javascript.pss
#
#
read
#--------------
testclass [:space:]
jumpfalse block.end.7500
  testclass [\n]
  jumpfalse block.end.7456
    nochars
  block.end.7456:
  clear
  testeof 
  jumptrue block.end.7487
    jump start
  block.end.7487:
  jump parse
block.end.7500:
#---------------
# We can ellide all these single character tests, because
# the stack token is just the character itself with a *
# Braces {} are used for blocks of commands, ',' and '.' for concatenating
# tests with OR or AND logic. 'B' and 'E' for begin and end
# tests, '!' is used for negation, ';' is used to terminate a 
# command.
testis "{"
jumptrue 16
testis "}"
jumptrue 14
testis ";"
jumptrue 12
testis ","
jumptrue 10
testis "."
jumptrue 8
testis "!"
jumptrue 6
testis "B"
jumptrue 4
testis "E"
jumptrue 2 
jump block.end.7936
  put
  add "*"
  push
  jump parse
block.end.7936:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.8389
  # save the start line number (for error messages) in case 
  # there is no terminating quote character.
  clear
  add "line "
  ll
  add " (character "
  cc
  add ") "
  put
  clear
  add "\""
  until "\""
  testends "\""
  jumptrue block.end.8331
    clear
    add "Unterminated quote character (\") starting at "
    get
    add " !\n"
    print
    quit
  block.end.8331:
  put
  clear
  add "quote*"
  push
  jump parse
block.end.8389:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.8970
  # save the start line number (for error messages) in case 
  # there is no terminating quote character.
  clear
  add "line "
  ll
  add " (character "
  cc
  add ") "
  put
  clear
  until "'"
  testends "'"
  jumptrue block.end.8853
    clear
    add "Unterminated quote (') starting at "
    get
    add "!\n"
    print
    quit
  block.end.8853:
  clip
  escape "\""
  put
  clear
  add "\""
  get
  add "\""
  put
  clear
  add "quote*"
  push
  jump parse
block.end.8970:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
# should class tests really be multiline??!
testis "["
jumpfalse block.end.12660
  # save the start line number (for error messages) in case 
  # there is no terminating bracket character.
  clear
  add "line "
  ll
  add " (character "
  cc
  add ") "
  put
  clear
  add "["
  until "]"
  testis "[]"
  jumpfalse block.end.9494
    clear
    add "pep script error at line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty character class [] \n"
    print
    quit
  block.end.9494:
  testends "]"
  jumptrue block.end.9781
    clear
    add "Unterminated class text ([...]) starting at "
    get
    add "\n"
    add "      class text can be used in tests or with the 'while' and \n"
    add "      'whilenot' commands. For example: \n"
    add "        [:alpha:] { while [:alpha:]; print; clear; }\n"
    add "      "
    print
    quit
  block.end.9781:
  # need to escape quotes so they dont interfere with the
  # quotes java needs for .matches("...")
  escape "\""
  # the caret is not a negation operator in pep scripts
  replace "^" "\\\\^"
  # save the class on the tape
  put
  clop
  clop
  testbegins "-"
  jumptrue block.end.10208
    # not a range class, eg [a-z] so need to escape '-' chars
    # java requires a double escape
    clear
    get
    replace "-" "\\\\-"
    put
  block.end.10208:
  testbegins "-"
  jumpfalse block.end.10596
    # a range class, eg [a-z], check if it is correct
    clip
    clip
    testis "-"
    jumptrue block.end.10590
      clear
      add "Error in pep script at line "
      ll
      add " (character "
      cc
      add "): \n"
      add " Incorrect character range class "
      get
      add "\n"
      add "   For example:\n"
      add "     [a-g]  # correct\n"
      add "     [f-gh] # error! \n"
      print
      clear
      quit
    block.end.10590:
  block.end.10596:
  clear
  get
  # restore class text
  testbegins "[:"
  jumpfalse 3
  testends ":]"
  jumpfalse 2 
  jump block.end.10761
    clear
    add "malformed character class starting at "
    get
    add "!\n"
    print
    quit
  block.end.10761:
  testbegins "[:"
  jumpfalse 3
  testis "[:]"
  jumpfalse 2 
  jump block.end.11800
    clip
    clip
    clop
    clop
    # unicode posix character classes in java 
    # Also, abbreviations (not implemented in gh.c yet.)
    testis "alnum"
    jumptrue 4
    testis "N"
    jumptrue 2 
    jump block.end.10967
      clear
      add "\\\\p{Alnum}"
    block.end.10967:
    testis "alpha"
    jumptrue 4
    testis "A"
    jumptrue 2 
    jump block.end.11016
      clear
      add "\\\\p{Alpha}"
    block.end.11016:
    testis "ascii"
    jumptrue 4
    testis "I"
    jumptrue 2 
    jump block.end.11065
      clear
      add "\\\\p{ASCII}"
    block.end.11065:
    testis "blank"
    jumptrue 4
    testis "B"
    jumptrue 2 
    jump block.end.11114
      clear
      add "\\\\p{Blank}"
    block.end.11114:
    testis "cntrl"
    jumptrue 4
    testis "C"
    jumptrue 2 
    jump block.end.11163
      clear
      add "\\\\p{Cntrl}"
    block.end.11163:
    testis "digit"
    jumptrue 4
    testis "D"
    jumptrue 2 
    jump block.end.11212
      clear
      add "\\\\p{Digit}"
    block.end.11212:
    testis "graph"
    jumptrue 4
    testis "G"
    jumptrue 2 
    jump block.end.11261
      clear
      add "\\\\p{Graph}"
    block.end.11261:
    testis "lower"
    jumptrue 4
    testis "L"
    jumptrue 2 
    jump block.end.11310
      clear
      add "\\\\p{Lower}"
    block.end.11310:
    testis "print"
    jumptrue 4
    testis "P"
    jumptrue 2 
    jump block.end.11359
      clear
      add "\\\\p{Print}"
    block.end.11359:
    testis "punct"
    jumptrue 4
    testis "T"
    jumptrue 2 
    jump block.end.11408
      clear
      add "\\\\p{Punct}"
    block.end.11408:
    testis "space"
    jumptrue 4
    testis "S"
    jumptrue 2 
    jump block.end.11457
      clear
      add "\\\\p{Space}"
    block.end.11457:
    testis "upper"
    jumptrue 4
    testis "U"
    jumptrue 2 
    jump block.end.11506
      clear
      add "\\\\p{Upper}"
    block.end.11506:
    testis "xdigit"
    jumptrue 4
    testis "X"
    jumptrue 2 
    jump block.end.11557
      clear
      add "\\\\p{XDigit}"
    block.end.11557:
    testbegins "\\\\p{"
    jumptrue block.end.11794
      put
      clear
      add "Pep script syntax error near line "
      ll
      add " (character "
      cc
      add "): \n"
      add "Unknown character class '"
      get
      add "'\n"
      print
      clear
      quit
    block.end.11794:
  block.end.11800:
  
  #     alnum - alphanumeric like [0-9a-zA-Z] 
  #     alpha - alphabetic like [a-zA-Z] 
  #     blank - blank chars, space and tab 
  #     cntrl - control chars, ascii 000 to 037 and 177 (del) 
  #     digit - digits 0-9 
  #     graph - graphical chars same as :alnum: and :punct: 
  #     lower - lower case letters [a-z] 
  #     print - printable chars ie :graph: + space 
  #     punct - punctuation ie !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~. 
  #     space - all whitespace, eg \n\r\t vert tab, space, \f 
  #     upper - upper case letters [A-Z] 
  #     xdigit - hexadecimal digit ie [0-9a-fA-F] 
  #    
  put
  clear
  # add quotes around the class and limits around the 
  # class so it can be used with the string.matches() method
  # (must match the whole string, not just one character)
  add "\"^"
  get
  add "+$\""
  put
  clear
  add "class*"
  push
  jump parse
block.end.12660:
#---------------
# formats: (eof) (EOF) (==) etc. 
testis "("
jumpfalse block.end.13131
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.12814
    clear
    add "eof*"
    push
    jump parse
  block.end.12814:
  testis "=="
  jumpfalse block.end.12867
    clear
    add "tapetest*"
    push
    jump parse
  block.end.12867:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.13131:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.14272
  clear
  read
  testis "\n"
  jumpfalse block.end.13267
    clear
    jump parse
  block.end.13267:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.14117
    # save the line number for possible error message later
    clear
    ll
    put
    clear
    until "*#"
    testends "*#"
    jumpfalse block.end.13862
      # convert to /* ... */ java multiline comment
      clip
      clip
      put
      clear
      add "/*"
      get
      add "*/"
      # create a "comment" parse token
      put
      clear
      # comment-out this line to remove multiline comments from the 
      # compiled java.
      # add "comment*"; push; 
      jump parse
    block.end.13862:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    add "stating at line number "
    get
    add "\n"
    print
    clear
    quit
  block.end.14117:
  # single line comments. some will get lost.
  put
  clear
  add "//"
  get
  until "\n"
  clip
  put
  clear
  add "comment*"
  push
  jump parse
block.end.14272:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.14659
  # error message about a misplaced character
  put
  clear
  add "!! Misplaced character '"
  get
  add "' in script near line "
  ll
  add " (character "
  cc
  add ") \n"
  print
  clear
  quit
block.end.14659:
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEOFKGPRUWS+-<>0^]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
# make ll an alias for "lines" and cc an alias for chars
testis "ll"
jumpfalse block.end.15243
  clear
  add "lines"
block.end.15243:
testis "cc"
jumpfalse block.end.15275
  clear
  add "chars"
block.end.15275:
# one letter command abbreviations
testis "a"
jumpfalse block.end.15342
  clear
  add "add"
block.end.15342:
testis "k"
jumpfalse block.end.15372
  clear
  add "clip"
block.end.15372:
testis "K"
jumpfalse block.end.15402
  clear
  add "clop"
block.end.15402:
testis "D"
jumpfalse block.end.15435
  clear
  add "replace"
block.end.15435:
testis "d"
jumpfalse block.end.15466
  clear
  add "clear"
block.end.15466:
testis "t"
jumpfalse block.end.15497
  clear
  add "print"
block.end.15497:
testis "p"
jumpfalse block.end.15526
  clear
  add "pop"
block.end.15526:
testis "P"
jumpfalse block.end.15556
  clear
  add "push"
block.end.15556:
testis "u"
jumpfalse block.end.15589
  clear
  add "unstack"
block.end.15589:
testis "U"
jumpfalse block.end.15620
  clear
  add "stack"
block.end.15620:
testis "G"
jumpfalse block.end.15649
  clear
  add "put"
block.end.15649:
testis "g"
jumpfalse block.end.15678
  clear
  add "get"
block.end.15678:
testis "x"
jumpfalse block.end.15708
  clear
  add "swap"
block.end.15708:
testis ">"
jumpfalse block.end.15736
  clear
  add "++"
block.end.15736:
testis "<"
jumpfalse block.end.15764
  clear
  add "--"
block.end.15764:
testis "m"
jumpfalse block.end.15794
  clear
  add "mark"
block.end.15794:
testis "M"
jumpfalse block.end.15822
  clear
  add "go"
block.end.15822:
testis "r"
jumpfalse block.end.15852
  clear
  add "read"
block.end.15852:
testis "R"
jumpfalse block.end.15883
  clear
  add "until"
block.end.15883:
testis "w"
jumpfalse block.end.15914
  clear
  add "while"
block.end.15914:
testis "W"
jumpfalse block.end.15948
  clear
  add "whilenot"
block.end.15948:
testis "n"
jumpfalse block.end.15979
  clear
  add "count"
block.end.15979:
testis "+"
jumpfalse block.end.16007
  clear
  add "a+"
block.end.16007:
testis "-"
jumpfalse block.end.16035
  clear
  add "a-"
block.end.16035:
testis "0"
jumpfalse block.end.16065
  clear
  add "zero"
block.end.16065:
testis "c"
jumpfalse block.end.16096
  clear
  add "chars"
block.end.16096:
testis "l"
jumpfalse block.end.16127
  clear
  add "lines"
block.end.16127:
testis "^"
jumpfalse block.end.16159
  clear
  add "escape"
block.end.16159:
testis "v"
jumpfalse block.end.16193
  clear
  add "unescape"
block.end.16193:
testis "z"
jumpfalse block.end.16224
  clear
  add "delim"
block.end.16224:
testis "S"
jumpfalse block.end.16255
  clear
  add "state"
block.end.16255:
testis "q"
jumpfalse block.end.16285
  clear
  add "quit"
block.end.16285:
testis "s"
jumpfalse block.end.16316
  clear
  add "write"
block.end.16316:
testis "o"
jumpfalse block.end.16345
  clear
  add "nop"
block.end.16345:
testis "rs"
jumpfalse block.end.16379
  clear
  add "restart"
block.end.16379:
testis "rp"
jumpfalse block.end.16413
  clear
  add "reparse"
block.end.16413:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.16524
  put
  clear
  add "eof*"
  push
  jump parse
block.end.16524:
testis "<==>"
jumpfalse block.end.16582
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.16582:
testis "jump"
jumptrue 18
testis "jumptrue"
jumptrue 16
testis "jumpfalse"
jumptrue 14
testis "testis"
jumptrue 12
testis "testclass"
jumptrue 10
testis "testbegins"
jumptrue 8
testis "testends"
jumptrue 6
testis "testeof"
jumptrue 4
testis "testtape"
jumptrue 2 
jump block.end.16910
  put
  clear
  add "The instruction '"
  get
  add "' near line "
  ll
  add " (character "
  cc
  add ")\n"
  add "can be used in pep assembly code but not scripts. \n"
  print
  clear
  quit
block.end.16910:
# show information if these "deprecated" commands are used
testis "Q"
jumptrue 6
testis "bail"
jumptrue 4
testis "state"
jumptrue 2 
jump block.end.17325
  put
  clear
  add "The instruction '"
  get
  add "' near line "
  ll
  add " (character "
  cc
  add ")\n"
  add "is no longer part of the pep language (july 2020). \n"
  add "use 'quit' instead of 'bail', and use 'unstack; print;' \n"
  add "instead of 'state'. \n"
  print
  clear
  quit
block.end.17325:
testis "add"
jumptrue 80
testis "clip"
jumptrue 78
testis "clop"
jumptrue 76
testis "replace"
jumptrue 74
testis "upper"
jumptrue 72
testis "lower"
jumptrue 70
testis "cap"
jumptrue 68
testis "clear"
jumptrue 66
testis "print"
jumptrue 64
testis "pop"
jumptrue 62
testis "push"
jumptrue 60
testis "unstack"
jumptrue 58
testis "stack"
jumptrue 56
testis "put"
jumptrue 54
testis "get"
jumptrue 52
testis "swap"
jumptrue 50
testis "++"
jumptrue 48
testis "--"
jumptrue 46
testis "mark"
jumptrue 44
testis "go"
jumptrue 42
testis "read"
jumptrue 40
testis "until"
jumptrue 38
testis "while"
jumptrue 36
testis "whilenot"
jumptrue 34
testis "count"
jumptrue 32
testis "a+"
jumptrue 30
testis "a-"
jumptrue 28
testis "zero"
jumptrue 26
testis "chars"
jumptrue 24
testis "lines"
jumptrue 22
testis "nochars"
jumptrue 20
testis "nolines"
jumptrue 18
testis "escape"
jumptrue 16
testis "unescape"
jumptrue 14
testis "delim"
jumptrue 12
testis "quit"
jumptrue 10
testis "write"
jumptrue 8
testis "nop"
jumptrue 6
testis "reparse"
jumptrue 4
testis "restart"
jumptrue 2 
jump block.end.17718
  put
  clear
  add "word*"
  push
  jump parse
block.end.17718:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop. There is
# no "goto" in java so we need to use labelled loops to 
# implement .reparse/parse>
testis "parse>"
jumpfalse block.end.18366
  clear
  count
  testis "0"
  jumptrue block.end.18221
    clear
    add "script error:\n"
    add "  extra parse> label at line "
    ll
    add ".\n"
    print
    quit
  block.end.18221:
  clear
  add "// parse>"
  put
  clear
  add "parse>*"
  push
  # use accumulator to indicate after parse> label
  a+
  jump parse
block.end.18366:
# --------------------
# implement "begin-blocks", which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.18577
  put
  add "*"
  push
  jump parse
block.end.18577:
add " << unknown command on line "
ll
add " (char "
cc
add ")"
add " of source file. \n"
print
clear
quit
# ----------------------------------
# PARSING PHASE:
# Below is the parse/compile phase of the script. Here we pop tokens off the
# stack and check for sequences of tokens eg "word*semicolon*". If we find a
# valid series of tokens, we "shift-reduce" or "resolve" the token series eg
# word*semicolon* --> command*
# At the same time, we manipulate (transform) the attributes on the tape, as
# required. 
parse:
#-------------------------------------
# 2 tokens
#-------------------------------------
pop
pop
# All of the patterns below are currently errors, but may not
# be in the future if we expand the syntax of the parse
# language. Also consider:
#    begintext* endtext* quoteset* notclass*, !* ,* ;* B* E*
# It is nice to trap the errors here because we can emit some
# (hopefully not very cryptic) error messages with a line number.
# Otherwise the script writer has to debug with
#   pep -a asm.pp -I scriptfile 
testis "word*word*"
jumptrue 50
testis "word*}*"
jumptrue 48
testis "word*begintext*"
jumptrue 46
testis "word*endtext*"
jumptrue 44
testis "word*!*"
jumptrue 42
testis "word*,*"
jumptrue 40
testis "quote*word*"
jumptrue 38
testis "quote*class*"
jumptrue 36
testis "quote*state*"
jumptrue 34
testis "quote*}*"
jumptrue 32
testis "quote*begintext*"
jumptrue 30
testis "quote*endtext*"
jumptrue 28
testis "class*word*"
jumptrue 26
testis "class*quote*"
jumptrue 24
testis "class*class*"
jumptrue 22
testis "class*state*"
jumptrue 20
testis "class*}*"
jumptrue 18
testis "class*begintext*"
jumptrue 16
testis "class*endtext*"
jumptrue 14
testis "class*!*"
jumptrue 12
testis "notclass*word*"
jumptrue 10
testis "notclass*quote*"
jumptrue 8
testis "notclass*class*"
jumptrue 6
testis "notclass*state*"
jumptrue 4
testis "notclass*}*"
jumptrue 2 
jump block.end.20317
  add " (Token stack) \nValue: \n"
  get
  add "\nValue: \n"
  ++
  get
  --
  add "\n"
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of pep script (missing semicolon?) \n"
  print
  clear
  quit
block.end.20317:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.20512
  push
  push
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of pep script: misplaced semi-colon? ; \n"
  print
  clear
  quit
block.end.20512:
testis ",*{*"
jumpfalse block.end.20682
  push
  push
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra comma in list? \n"
  print
  clear
  quit
block.end.20682:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.20871
  push
  push
  add "Error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra semi-colon? \n"
  print
  clear
  quit
block.end.20871:
testis "!*!*"
jumpfalse block.end.21134
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: \n double negation '!!' is not implemented \n"
  add " and probably won't be, because what would be the point? \n"
  print
  clear
  quit
block.end.21134:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.21449
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced negation operator (!)? \n"
  add " The negation operator precedes tests, for example: \n"
  add "   !B'abc'{ ... } or !(eof),!'abc'{ ... } \n"
  print
  clear
  quit
block.end.21449:
testis ",*command*"
jumpfalse block.end.21625
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced comma? \n"
  print
  clear
  quit
block.end.21625:
testis "!*command*"
jumpfalse block.end.21830
  push
  push
  add "error near line "
  ll
  add " (at char "
  cc
  add ") \n"
  add " The negation operator (!) cannot precede a command \n"
  print
  clear
  quit
block.end.21830:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.22039
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: no test for brace block? \n"
  print
  clear
  quit
block.end.22039:
testis "{*}*"
jumpfalse block.end.22173
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.22173:
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.22404
  push
  push
  add "error near line "
  ll
  add " of script:\n  classes ([a-z], [:space:] etc). \n"
  add "  cannot use the 'begin' or 'end' modifiers (B/E) \n"
  print
  clear
  quit
block.end.22404:
testis "comment*{*"
jumpfalse block.end.22596
  push
  push
  add "error near line "
  ll
  add " of script: comments cannot occur between \n"
  add " a test and a brace ({). \n"
  print
  clear
  quit
block.end.22596:
testis "}*command*"
jumpfalse block.end.22746
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.22746:

#  E"begin*".!"begin*" {
#    push; push;
#    add "error near line "; lines;
#    add " of script: Begin blocks must precede code \n";
#    print; clear; quit;
#  }
#  
#------------ 
# The .restart command jumps to the first instruction after the
# begin block (if there is a begin block), or the first instruction
# of the script.
testis ".*word*"
jumpfalse block.end.24009
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.23460
    clear
    add "continue script;"
    # not required because we have labelled loops, 
    # continue script works both before and after the parse> label
    # "0" { clear; add "continue script;"; }
    # "1" { clear; add "break lex;"; }
    put
    clear
    add "command*"
    push
    jump parse
  block.end.23460:
  testis "reparse"
  jumpfalse block.end.23796
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.23684
      clear
      add "break lex;"
    block.end.23684:
    testis "1"
    jumpfalse block.end.23728
      clear
      add "continue parse;"
    block.end.23728:
    put
    clear
    add "command*"
    push
    jump parse
  block.end.23796:
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script:  \n"
  add " misplaced dot '.' (use for AND logic or in .reparse/.restart \n"
  print
  clear
  quit
block.end.24009:
#---------------------------------
# Compiling comments so as to transfer them to the java 
testis "comment*command*"
jumptrue 6
testis "command*comment*"
jumptrue 4
testis "commandset*comment*"
jumptrue 2 
jump block.end.24260
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "command*"
  push
  jump parse
block.end.24260:
testis "comment*comment*"
jumpfalse block.end.24374
  clear
  get
  add "\n"
  ++
  get
  --
  put
  clear
  add "comment*"
  push
  jump parse
block.end.24374:
# -----------------------
# negated tokens.
# This is a new more elegant way to negate a whole set of 
# tests (tokens) where the negation logic is stored on the 
# stack, not in the current tape cell. We just add "not" to 
# the stack token.
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
#  This format is used to indicate a negative test for 
#  a brace block. eg: ![aeiou] { add "< not a vowel"; print; clear; }
testis "!*quote*"
jumptrue 12
testis "!*class*"
jumptrue 10
testis "!*begintext*"
jumptrue 8
testis "!*endtext*"
jumptrue 6
testis "!*eof*"
jumptrue 4
testis "!*tapetest*"
jumptrue 2 
jump block.end.25172
  # a simplification: store the token name "quote*/class*/..."
  # in the tape cell corresponding to the "!*" token. 
  replace "!*" "not"
  push
  # this was a bug?? a missing ++; ??
  # now get the token-value
  get
  --
  put
  ++
  clear
  jump parse
block.end.25172:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.25678
  clear
  add "endtext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.25635
    # empty argument is an error
    clear
    add "pep script error near line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty argument for end-test (E\"\") \n"
    print
    quit
  block.end.25635:
  --
  put
  ++
  clear
  jump parse
block.end.25678:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.26225
  clear
  add "begintext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.26182
    # empty argument is an error
    clear
    add "pep script error near line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty argument for begin-test (B\"\") \n"
    print
    quit
  block.end.26182:
  --
  put
  ++
  clear
  jump parse
block.end.26225:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.30322
  clear
  # check if command requires parameter
  get
  testis "add"
  jumptrue 20
  testis "until"
  jumptrue 18
  testis "while"
  jumptrue 16
  testis "whilenot"
  jumptrue 14
  testis "mark"
  jumptrue 12
  testis "go"
  jumptrue 10
  testis "escape"
  jumptrue 8
  testis "unescape"
  jumptrue 6
  testis "delim"
  jumptrue 4
  testis "replace"
  jumptrue 2 
  jump block.end.26781
    put
    clear
    add "'"
    get
    add "'"
    add " command needs an argument, on line "
    ll
    add " of script.\n"
    print
    clear
    quit
  block.end.26781:
  # the new until; command with no argument
  testis "until"
  jumpfalse block.end.26951
    clear
    add "mm.until(mm.tape.get(mm.tapePointer));  /* until (tape) */"
    put
  block.end.26951:
  testis "clip"
  jumpfalse block.end.27218
    clear
    # are these length tests really necessary
    add "if (mm.workspace.length() > 0) { /* clip */\n"
    add "  mm.workspace.delete(mm.workspace.length() - 1, \n"
    add "  mm.workspace.length()); }"
    put
  block.end.27218:
  testis "clop"
  jumpfalse block.end.27386
    clear
    add "if (mm.workspace.length() > 0) { /* clop */\n"
    add "  mm.workspace.delete(0, 1); }   /* clop */"
    put
  block.end.27386:
  testis "clear"
  jumpfalse block.end.27501
    clear
    add "mm.workspace.setLength(0);"
    add "            /* clear */"
    put
  block.end.27501:
  testis "upper"
  jumpfalse block.end.27773
    clear
    add "/* upper */ \n"
    add "for (int i = 0; i < mm.workspace.length(); i++) { \n"
    add "  char c = mm.workspace.charAt(i); \n"
    add "  mm.workspace.setCharAt(i, Character.toUpperCase(c)); } "
    put
  block.end.27773:
  testis "lower"
  jumpfalse block.end.28044
    clear
    add "/* lower */ \n"
    add "for (int i = 0; i < mm.workspace.length(); i++) { \n"
    add "  char c = mm.workspace.charAt(i); \n"
    add "  mm.workspace.setCharAt(i, Character.toLowerCase(c)); } "
    put
  block.end.28044:
  testis "cap"
  jumpfalse block.end.28421
    clear
    add "/* cap */ \n"
    add "for (int i = 0; i < mm.workspace.length(); i++) { \n"
    add "  char c = mm.workspace.charAt(i); \n"
    add "  if (i==0){ mm.workspace.setCharAt(i, Character.toUpperCase(c)); } \n"
    add "  else { mm.workspace.setCharAt(i, Character.toLowerCase(c)); } \n"
    add "}"
    put
  block.end.28421:
  testis "print"
  jumpfalse block.end.28515
    clear
    add "System.out.print(mm.workspace); /* print */"
    put
  block.end.28515:
  testis "pop"
  jumpfalse block.end.28559
    clear
    add "mm.pop();"
    put
  block.end.28559:
  testis "push"
  jumpfalse block.end.28605
    clear
    add "mm.push();"
    put
  block.end.28605:
  testis "unstack"
  jumpfalse block.end.28693
    clear
    add "while (mm.pop());          /* unstack */"
    put
  block.end.28693:
  testis "stack"
  jumpfalse block.end.28777
    clear
    add "while(mm.push());          /* stack */"
    put
  block.end.28777:
  testis "put"
  jumpfalse block.end.28953
    clear
    add "mm.tape.get(mm.tapePointer).setLength(0); /* put */\n"
    add "mm.tape.get(mm.tapePointer).append(mm.workspace); "
    put
  block.end.28953:
  testis "get"
  jumpfalse block.end.29075
    clear
    add "mm.workspace.append(mm.tape.get(mm.tapePointer)); /* get */"
    put
  block.end.29075:
  testis "swap"
  jumpfalse block.end.29121
    clear
    add "mm.swap();"
    put
  block.end.29121:
  testis "++"
  jumpfalse block.end.29219
    clear
    add "mm.increment();"
    add "                 /* ++ */"
    put
  block.end.29219:
  testis "--"
  jumpfalse block.end.29324
    clear
    add "if (mm.tapePointer > 0) mm.tapePointer--; /* -- */"
    put
  block.end.29324:
  testis "read"
  jumpfalse block.end.29381
    clear
    add "mm.read(); /* read */"
    put
  block.end.29381:
  testis "count"
  jumpfalse block.end.29488
    clear
    add "mm.workspace.append(mm.accumulator); /* count */"
    put
  block.end.29488:
  testis "a+"
  jumpfalse block.end.29548
    clear
    add "mm.accumulator++; /* a+ */"
    put
  block.end.29548:
  testis "a-"
  jumpfalse block.end.29608
    clear
    add "mm.accumulator--; /* a- */"
    put
  block.end.29608:
  testis "zero"
  jumpfalse block.end.29674
    clear
    add "mm.accumulator = 0; /* zero */"
    put
  block.end.29674:
  testis "chars"
  jumpfalse block.end.29771
    clear
    add "mm.workspace.append(mm.charsRead); /* chars */"
    put
  block.end.29771:
  testis "lines"
  jumpfalse block.end.29868
    clear
    add "mm.workspace.append(mm.linesRead); /* lines */"
    put
  block.end.29868:
  testis "nochars"
  jumpfalse block.end.29938
    clear
    add "mm.charsRead = 0; /* nochars */"
    put
  block.end.29938:
  testis "nolines"
  jumpfalse block.end.30008
    clear
    add "mm.linesRead = 0; /* nolines */"
    put
  block.end.30008:
  # use a labelled loop to quit script.
  testis "quit"
  jumpfalse block.end.30100
    clear
    add "break script;"
    put
  block.end.30100:
  testis "write"
  jumpfalse block.end.30154
    clear
    add "mm.writeToFile();"
    put
  block.end.30154:
  # just eliminate since it does nothing.
  testis "nop"
  jumpfalse block.end.30268
    clear
    add "/* nop: no-operation eliminated */"
    put
  block.end.30268:
  clear
  add "command*"
  push
  jump parse
block.end.30322:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.30646
  clear
  add "commandset*"
  push
  # format the tape attributes. Add the next command on a newline 
  --
  get
  add "\n"
  ++
  get
  --
  put
  ++
  clear
  jump parse
block.end.30646:
#-------------------
# here we begin to parse "test*" and "ortestset*" and "andtestset*"
# 
#-------------------
# eg: B"abc" {} or E"xyz" {}
# transform and markup the different test types
testis "begintext*,*"
jumptrue 36
testis "endtext*,*"
jumptrue 34
testis "quote*,*"
jumptrue 32
testis "class*,*"
jumptrue 30
testis "eof*,*"
jumptrue 28
testis "tapetest*,*"
jumptrue 26
testis "begintext*.*"
jumptrue 24
testis "endtext*.*"
jumptrue 22
testis "quote*.*"
jumptrue 20
testis "class*.*"
jumptrue 18
testis "eof*.*"
jumptrue 16
testis "tapetest*.*"
jumptrue 14
testis "begintext*{*"
jumptrue 12
testis "endtext*{*"
jumptrue 10
testis "quote*{*"
jumptrue 8
testis "class*{*"
jumptrue 6
testis "eof*{*"
jumptrue 4
testis "tapetest*{*"
jumptrue 2 
jump block.end.31902
  testbegins "begin"
  jumpfalse block.end.31157
    clear
    add "mm.workspace.toString().startsWith("
  block.end.31157:
  testbegins "end"
  jumpfalse block.end.31220
    clear
    add "mm.workspace.toString().endsWith("
  block.end.31220:
  testbegins "quote"
  jumpfalse block.end.31283
    clear
    add "mm.workspace.toString().equals("
  block.end.31283:
  testbegins "class"
  jumpfalse block.end.31347
    clear
    add "mm.workspace.toString().matches("
  block.end.31347:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.31477
    clear
    put
    add "mm.eof"
  block.end.31477:
  testbegins "tapetest"
  jumpfalse block.end.31616
    clear
    put
    add "(mm.workspace.toString().equals(mm.tape.get(mm.tapePointer).toString())"
  block.end.31616:
  get
  testbegins "mm.eof"
  jumptrue block.end.31649
    add ")"
  block.end.31649:
  put
  
  #    #  maybe we could ellide the not tests by doing here
  #    B"not" { clear; add "!"; get; put; }
  #    
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.31902:
#-------------------
# negated tests
# eg: !B"xyz {} !(eof) {} !(==) {}
#     !E"xyz" {} 
#     !"abc" {}
#     ![a-z] {}
testis "notbegintext*,*"
jumptrue 36
testis "notendtext*,*"
jumptrue 34
testis "notquote*,*"
jumptrue 32
testis "notclass*,*"
jumptrue 30
testis "noteof*,*"
jumptrue 28
testis "nottapetest*,*"
jumptrue 26
testis "notbegintext*.*"
jumptrue 24
testis "notendtext*.*"
jumptrue 22
testis "notquote*.*"
jumptrue 20
testis "notclass*.*"
jumptrue 18
testis "noteof*.*"
jumptrue 16
testis "nottapetest*.*"
jumptrue 14
testis "notbegintext*{*"
jumptrue 12
testis "notendtext*{*"
jumptrue 10
testis "notquote*{*"
jumptrue 8
testis "notclass*{*"
jumptrue 6
testis "noteof*{*"
jumptrue 4
testis "nottapetest*{*"
jumptrue 2 
jump block.end.33053
  testbegins "notbegin"
  jumpfalse block.end.32403
    clear
    add "!mm.workspace.toString().startsWith("
  block.end.32403:
  testbegins "notend"
  jumpfalse block.end.32470
    clear
    add "!mm.workspace.toString().endsWith("
  block.end.32470:
  testbegins "notquote"
  jumpfalse block.end.32537
    clear
    add "!mm.workspace.toString().equals("
  block.end.32537:
  testbegins "notclass"
  jumpfalse block.end.32605
    clear
    add "!mm.workspace.toString().matches("
  block.end.32605:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.32739
    clear
    put
    add "!mm.eof"
  block.end.32739:
  testbegins "nottapetest"
  jumpfalse block.end.32882
    clear
    put
    add "(!mm.workspace.toString().equals(mm.tape.get(mm.tapePointer).toString())"
  block.end.32882:
  get
  testbegins "!mm.eof"
  jumptrue block.end.32916
    add ")"
  block.end.32916:
  put
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.33053:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------
# some 3 token errors!!!
# not a comprehensive list of 3 token errors
testis "{*quote*;*"
jumptrue 12
testis "{*begintext*;*"
jumptrue 10
testis "{*endtext*;*"
jumptrue 8
testis "{*class*;*"
jumptrue 6
testis "commandset*quote*;*"
jumptrue 4
testis "command*quote*;*"
jumptrue 2 
jump block.end.33530
  push
  push
  push
  add "[pep error]\n invalid syntax near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script (misplaced semicolon?) \n"
  print
  clear
  quit
block.end.33530:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.33726
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.33726:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.34193
  # push the tokens back to make debugging easier
  push
  push
  push
  add " error: mixing AND (.) and OR (,) concatenation in \n"
  add " in pep script near line "
  ll
  add " (character "
  cc
  add ") \n"
  add " \n"
  add "  For example:\n"
  add "     B\".\".!E\"/\".[abcd./] { print; }  # Correct!\n"
  add "     B\".\".!E\"/\",[abcd./] { print; }  # Error! \n"
  print
  clear
  quit
block.end.34193:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.38075
  clear
  get
  testis "replace"
  jumpfalse block.end.34536
    # error 
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.34536:
  # check whether argument is single character, otherwise
  # throw an error
  testis "escape"
  jumptrue 8
  testis "unescape"
  jumptrue 6
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.35534
    # This is trickier than I thought it would be.
    clear
    ++
    get
    --
    # check that arg not empty, (but an empty quote is ok 
    # for the second arg of 'replace'
    testis "\"\""
    jumpfalse block.end.35086
      clear
      add "[pep error] near line "
      ll
      add " (or char "
      cc
      add "): \n"
      add "  command '"
      get
      add "\' cannot have an empty argument (\"\") \n"
      print
      quit
    block.end.35086:
    # quoted text has the quotes still around it.
    # also handle escape characters like \n \r etc
    clip
    clop
    clop
    clop
    # B "\\" { clip; } 
    clip
    testis ""
    jumptrue block.end.35510
      clear
      add "Pep script error near line "
      ll
      add " (character "
      cc
      add "): \n"
      add "  command '"
      get
      add "' takes only a single character argument. \n"
      print
      quit
    block.end.35510:
    clear
    get
  block.end.35534:
  testis "mark"
  jumpfalse block.end.35799
    clear
    add "/* mark */ \n"
    add "mm.marks.get(mm.tapePointer).setLength(0); // mark \n"
    add "mm.marks.get(mm.tapePointer).append("
    ++
    get
    --
    add "); // mark"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35799:
  testis "go"
  jumpfalse block.end.35939
    clear
    add "mm.goToMark("
    ++
    get
    --
    add ");   /* go */"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35939:
  testis "delim"
  jumpfalse block.end.36264
    clear
    # this.delimiter.setCharAt(0, text.charAt(0));
    # only the first character of the delimiter argument is used. 
    add "mm.delimiter.setLength(0); /* delim */\n"
    add "mm.delimiter.append("
    ++
    get
    --
    add "); "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36264:
  testis "add"
  jumpfalse block.end.36502
    clear
    add "mm.workspace.append("
    ++
    get
    --
    # handle multiline text
    replace "\n" "\"); \nmm.workspace.append(\"\\n"
    add "); /* add */"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36502:
  testis "while"
  jumpfalse block.end.36733
    clear
    add "while ((char) mm.peep == "
    ++
    get
    --
    add ".charAt(0)) /* while */\n "
    add " { if (mm.eof) {break;} mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36733:
  testis "whilenot"
  jumpfalse block.end.36965
    clear
    add "while ((char) mm.peep != "
    ++
    get
    --
    add ".charAt(0)) /* whilenot */\n "
    add " { if (mm.eof) {break;} mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36965:
  testis "until"
  jumpfalse block.end.37566
    clear
    add "mm.until("
    ++
    get
    --
    # error until cannot have empty argument
    testis "mm.until(\"\""
    jumpfalse block.end.37430
      clear
      add "Pep script error near line "
      ll
      add " (character "
      cc
      add "): \n"
      add " empty argument for 'until' \n"
      add " \n"
      add "   For example:\n"
      add "     until '.txt'; until \">\";    # correct   \n"
      add "     until '';  until \"\";        # errors! \n"
      print
      quit
    block.end.37430:
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.37566:
  # But really, can't the "replace" command just be used
  # instead of escape/unescape?? This seems a flaw in the 
  # machine design.
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.37884
    clear
    add "mm."
    get
    add "Char"
    add "("
    ++
    get
    --
    add ".charAt(0));"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.37884:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.38075:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.38865
  clear
  get
  testis "while"
  jumpfalse block.end.38456
    clear
    add "/* while */ \n"
    add "while (Character.toString((char)mm.peep).matches("
    ++
    get
    --
    add ")) { if (mm.eof) { break; } mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.38456:
  testis "whilenot"
  jumpfalse block.end.38712
    clear
    add "/* whilenot */ \n"
    add "while (!Character.toString((char)mm.peep).matches("
    ++
    get
    --
    add ")) { if (mm.eof) { break; } mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.38712:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.38865:
# arrange the parse> label loops
testeof 
jumpfalse block.end.39583
  testis "commandset*parse>*commandset*"
  jumptrue 8
  testis "command*parse>*commandset*"
  jumptrue 6
  testis "commandset*parse>*command*"
  jumptrue 4
  testis "command*parse>*command*"
  jumptrue 2 
  jump block.end.39579
    clear
    # indent both code blocks
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    ++
    ++
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    --
    --
    # add a block so that .reparse works before the parse> label.
    add "lex: { \n"
    get
    add "\n}\n"
    ++
    ++
    # indent code block
    # add "  "; get; replace "\n" "\n  "; put; clear;
    add "parse: \n"
    add "while (true) { \n"
    get
    add "\n  break parse;\n}"
    --
    --
    put
    clear
    add "commandset*"
    push
    jump parse
  block.end.39579:
block.end.39583:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# bnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.40497
  clear
  get
  testis "replace"
  jumpfalse block.end.40328
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    clear
    add "/* replace */ \n"
    add "if (mm.workspace.length() > 0) { \n"
    add "  temp = mm.workspace.toString().replace("
    ++
    get
    add ", "
    ++
    get
    add ");\n"
    add "  mm.workspace.setLength(0); \n"
    add "  mm.workspace.append(temp);\n} "
    --
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.40328:
  add "pep script error on line "
  ll
  add " (character "
  cc
  add "): \n"
  add "  command does not take 2 quoted arguments. \n"
  print
  quit
block.end.40497:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.40881
  clear
  ++
  ++
  get
  --
  --
  put
  clear
  add "beginblock*"
  push
  jump parse
block.end.40881:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# these 2 tests should be all that is necessary
testis "test*,*ortestset*{*"
jumptrue 4
testis "test*,*test*{*"
jumptrue 2 
jump block.end.41225
  clear
  get
  add " || "
  ++
  ++
  get
  --
  --
  put
  clear
  add "ortestset*{*"
  push
  push
  jump parse
block.end.41225:
# dont mix AND and OR concatenations 
# -------------
# AND logic 
# parses and compiles concatenated AND tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# it is possible to elide this block with the negated block
# for compactness but maybe readability is not as good.
# negated tests can be chained with non negated tests.
# eg: B'http' . !E'.txt' { ... }
testis "test*.*andtestset*{*"
jumptrue 4
testis "test*.*test*{*"
jumptrue 2 
jump block.end.41794
  clear
  get
  add " && "
  ++
  ++
  get
  --
  --
  put
  clear
  add "andtestset*{*"
  push
  push
  jump parse
block.end.41794:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.42357
  clear
  # indent the java code for readability
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  add "if ("
  get
  add ") {\n"
  ++
  ++
  get
  add "\n}"
  --
  --
  put
  clear
  add "command*"
  push
  # always reparse/compile
  jump parse
block.end.42357:
# -------------
# multi-token end-of-stream errors
# not a comprehensive list of errors...
testeof 
jumpfalse block.end.43152
  testends "begintext*"
  jumptrue 10
  testends "endtext*"
  jumptrue 8
  testends "test*"
  jumptrue 6
  testends "ortestset*"
  jumptrue 4
  testends "andtestset*"
  jumptrue 2 
  jump block.end.42667
    add "  Error near end of script at line "
    ll
    add ". Test with no brace block? \n"
    print
    clear
    quit
  block.end.42667:
  testends "quote*"
  jumptrue 6
  testends "class*"
  jumptrue 4
  testends "word*"
  jumptrue 2 
  jump block.end.42892
    put
    clear
    add "Error at end of pep script near line "
    ll
    add ": missing semi-colon? \n"
    add "Parse stack: "
    get
    add "\n"
    print
    clear
    quit
  block.end.42892:
  testends "{*"
  jumptrue 16
  testends "}*"
  jumptrue 14
  testends ";*"
  jumptrue 12
  testends ",*"
  jumptrue 10
  testends ".*"
  jumptrue 8
  testends "!*"
  jumptrue 6
  testends "B*"
  jumptrue 4
  testends "E*"
  jumptrue 2 
  jump block.end.43148
    put
    clear
    add "Error: misplaced terminal character at end of script! (line "
    ll
    add "). \n"
    add "Parse stack: "
    get
    add "\n"
    print
    clear
    quit
  block.end.43148:
block.end.43152:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.53131
  print
  clear
  # create the virtual machine object code and save it
  # somewhere on the tape.
  add "\n"
  add "\n"
  add " /* Java code generated by \"translate.java.pss\" */\n"
  add " import java.io.*;\n"
  add " import java.util.regex.*;\n"
  add " import java.util.*;   // contains stack\n"
  add "\n"
  add " public class Machine {\n"
  add "   // using int instead of char so that all unicode code points are\n"
  add "   // available instead of just utf16. (emojis cant fit into utf16)\n"
  add "   private int accumulator;         // counter for anything\n"
  add "   private int peep;                // next char in input stream\n"
  add "   private int charsRead;           // No. of chars read so far\n"
  add "   private int linesRead;           // No. of lines read so far\n"
  add "   public StringBuffer workspace;    // text accumulator\n"
  add "   private Stack<String> stack;      // parse token stack\n"
  add "   private int LENGTH;               // tape initial length\n"
  add "\n"
  add "   // use ArrayLists instead with .add() .get(n) and .set(n, E)\n"
  add "   // ArrayList<StringBuffer> al=new ArrayList<StringBuffer>();\n"
  add "   private List<StringBuffer> tape;      // array of token attributes \n"
  add "   private List<StringBuffer> marks;     // tape marks\n"
  add "   private int tapePointer;          // pointer to current cell\n"
  add "   private Reader input;             // text input stream\n"
  add "   private boolean eof;              // end of stream reached?\n"
  add "   private boolean flag;             // not used here\n"
  add "   private StringBuffer escape;    // char used to \"escape\" others \"\\\"\n"
  add "   private StringBuffer delimiter; // push/pop delimiter (default is \"*\")\n"
  add "   private boolean markFound;      // if the mark was found in tape\n"
  add "   \n"
  add "   /** make a new machine with a character stream reader */\n"
  add "   public Machine(Reader reader) {\n"
  add "     this.markFound = false; \n"
  add "     this.LENGTH = 100;\n"
  add "     this.input = reader;\n"
  add "     this.eof = false;\n"
  add "     this.flag = false;\n"
  add "     this.charsRead = 0; \n"
  add "     this.linesRead = 1; \n"
  add "     this.escape = new StringBuffer(\"\\\\\");\n"
  add "     this.delimiter = new StringBuffer(\"*\");\n"
  add "     this.accumulator = 0;\n"
  add "     this.workspace = new StringBuffer(\"\");\n"
  add "     this.stack = new Stack<String>();\n"
  add "     this.tapePointer = 0;\n"
  add "     this.tape = new ArrayList<StringBuffer>();\n"
  add "     this.marks = new ArrayList<StringBuffer>();\n"
  add "     for (int ii = 0; ii < this.LENGTH; ii++) {\n"
  add "       this.tape.add(new StringBuffer(\"\"));\n"
  add "       this.marks.add(new StringBuffer(\"\"));\n"
  add "     }\n"
  add "\n"
  add "     try\n"
  add "     { this.peep = this.input.read(); } \n"
  add "     catch (java.io.IOException ex) {\n"
  add "       System.out.println(\"read error\");\n"
  add "       System.exit(-1);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** read one character from the input stream and \n"
  add "       update the machine. */\n"
  add "   public void read() {\n"
  add "     int iChar;\n"
  add "     try {\n"
  add "       if (this.eof) { System.exit(0); }\n"
  add "       this.charsRead++;\n"
  add "       // increment lines\n"
  add "       if ((char)this.peep == \'\\n\') { this.linesRead++; }\n"
  add "       this.workspace.append(Character.toChars(this.peep));\n"
  add "       this.peep = this.input.read(); \n"
  add "       if (this.peep == -1) { this.eof = true; }\n"
  add "     }\n"
  add "     catch (IOException ex) {\n"
  add "       System.out.println(\"Error reading input stream\" + ex);\n"
  add "       System.exit(-1);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** increment tape pointer by one */\n"
  add "   public void increment() {\n"
  add "     this.tapePointer++;\n"
  add "     if (this.tapePointer >= this.LENGTH) {\n"
  add "       this.tape.add(new StringBuffer(\"\"));\n"
  add "       this.marks.add(new StringBuffer(\"\"));\n"
  add "       this.LENGTH++;\n"
  add "     }\n"
  add "   }\n"
  add "   \n"
  add "   /** remove escape character  */\n"
  add "   public void unescapeChar(char c) {\n"
  add "     if (workspace.length() > 0) {\n"
  add "       String s = this.workspace.toString().replace(\"\\\\\"+c, c+\"\");\n"
  add "       this.workspace.setLength(0); workspace.append(s);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** add escape character  */\n"
  add "   public void escapeChar(char c) {\n"
  add "     if (workspace.length() > 0) {\n"
  add "       String s = this.workspace.toString().replace(c+\"\", \"\\\\\"+c);\n"
  add "       workspace.setLength(0); workspace.append(s);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** whether trailing escapes \\\\ are even or odd */\n"
  add "   // untested code. check! eg try: add \"x \\\\\"; print; etc\n"
  add "   public boolean isEscaped(String ss, String sSuffix) {\n"
  add "     int count = 0; \n"
  add "     if (ss.length() < 2) return false;\n"
  add "     if (ss.length() <= sSuffix.length()) return false;\n"
  add "     if (ss.indexOf(this.escape.toString().charAt(0)) == -1) \n"
  add "       { return false; }\n"
  add "\n"
  add "     int pos = ss.length()-sSuffix.length();\n"
  add "     while ((pos > -1) && (ss.charAt(pos) == this.escape.toString().charAt(0))) {\n"
  add "       count++; pos--;\n"
  add "     }\n"
  add "     if (count % 2 == 0) return false;\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   /* a helper to see how many trailing \\\\ escape chars */\n"
  add "   private int countEscaped(String sSuffix) {\n"
  add "     String s = \"\";\n"
  add "     int count = 0;\n"
  add "     int index = this.workspace.toString().lastIndexOf(sSuffix);\n"
  add "     // remove suffix if it exists\n"
  add "     if (index > 0) {\n"
  add "       s = this.workspace.toString().substring(0, index);\n"
  add "     }\n"
  add "     while (s.endsWith(this.escape.toString())) {\n"
  add "       count++;\n"
  add "       s = s.substring(0, s.lastIndexOf(this.escape.toString()));\n"
  add "     }\n"
  add "     return count;\n"
  add "   }\n"
  add "\n"
  add "   /** reads the input stream until the workspace end with text */\n"
  add "   // can test this with\n"
  add "   public void until(String sSuffix) {\n"
  add "     // read at least one character\n"
  add "     if (this.eof) return; \n"
  add "     this.read();\n"
  add "     while (true) {\n"
  add "       if (this.eof) return;\n"
  add "       if (this.workspace.toString().endsWith(sSuffix)) {\n"
  add "         if (this.countEscaped(sSuffix) % 2 == 0) { return; }\n"
  add "       }\n"
  add "       this.read();\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** pop the first token from the stack into the workspace */\n"
  add "   public Boolean pop() {\n"
  add "     if (this.stack.isEmpty()) return false;\n"
  add "     this.workspace.insert(0, this.stack.pop());     \n"
  add "     if (this.tapePointer > 0) this.tapePointer--;\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   /** push the first token from the workspace to the stack */\n"
  add "   public Boolean push() {\n"
  add "     String sItem;\n"
  add "     // dont increment the tape pointer on an empty push\n"
  add "     if (this.workspace.length() == 0) return false;\n"
  add "     // need to get this from this.delim not \"*\"\n"
  add "     int iFirstStar = \n"
  add "       this.workspace.indexOf(this.delimiter.toString());\n"
  add "     if (iFirstStar != -1) {\n"
  add "       sItem = this.workspace.toString().substring(0, iFirstStar + 1);\n"
  add "       this.workspace.delete(0, iFirstStar + 1);\n"
  add "     }\n"
  add "     else {\n"
  add "       sItem = this.workspace.toString();\n"
  add "       this.workspace.setLength(0);\n"
  add "     }\n"
  add "     this.stack.push(sItem);     \n"
  add "     this.increment(); \n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   /** swap current tape cell with the workspace */\n"
  add "   public void swap() {\n"
  add "     String s = new String(this.workspace);\n"
  add "     this.workspace.setLength(0);\n"
  add "     this.workspace.append(this.tape.get(this.tapePointer).toString());\n"
  add "     this.tape.get(this.tapePointer).setLength(0);\n"
  add "     this.tape.get(this.tapePointer).append(s);\n"
  add "   }\n"
  add "\n"
  add "   /** save the workspace to file \"sav.pp\" */\n"
  add "   public void writeToFile() {\n"
  add "     try {\n"
  add "       File file = new File(\"sav.pp\");\n"
  add "       Writer out = new BufferedWriter(new OutputStreamWriter(\n"
  add "          new FileOutputStream(file), \"UTF8\"));\n"
  add "       out.append(this.workspace.toString());\n"
  add "       out.flush(); out.close();\n"
  add "     } catch (Exception e) { \n"
  add "       System.out.println(e.getMessage());\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   public void goToMark(String mark) {\n"
  add "     this.markFound = false; \n"
  add "     for (var ii = 0; ii < this.marks.size(); ii++) {\n"
  add "       if (this.marks.get(ii).toString().equals(mark)) { \n"
  add "         this.tapePointer = ii; this.markFound = true; \n"
  add "       }\n"
  add "     }\n"
  add "     if (this.markFound == false) { \n"
  add "       System.out.print(\"badmark \'\" + mark + \"\'!\"); \n"
  add "       System.exit(1);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** parse/check/compile the input */\n"
  add "   public void parse(InputStreamReader input) {\n"
  add "     //this is where the actual parsing/compiling code should go \n"
  add "     //but this means that all generated code must use\n"
  add "     //\"this.\" not \"mm.\"\n"
  add "   }\n"
  add "\n"
  add "  public static void main(String[] args) throws Exception { \n"
  add "    String temp = \"\";    \n"
  add "    Machine mm = new Machine(new InputStreamReader(System.in)); \n"
  # save the code in the current tape cell
  put
  clear
  #---------------------
  # check if the script correctly parsed (there should only
  # be one token on the stack, namely "commandset*" or "command*").
  pop
  pop
  testis "commandset*"
  jumptrue 4
  testis "command*"
  jumptrue 2 
  jump block.end.51740
    clear
    # indent generated code (6 spaces) for readability.
    add "      "
    get
    replace "\n" "\n      "
    put
    clear
    # restore the java preamble from the tape
    ++
    get
    --
    add "\n"
    add "    script: \n"
    add "    while (!mm.eof) {\n"
    get
    add "\n    }"
    add "\n  }"
    add "\n}\n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    print
    clear
    quit
  block.end.51740:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.52442
    clear
    # indent begin block code  
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    # indent main code for readability.
    ++
    add "      "
    get
    replace "\n" "\n      "
    put
    clear
    --
    # get java preamble from tape
    ++
    ++
    get
    --
    --
    get
    add "\n"
    ++
    # a labelled loop for "quit" (but quit can just exit?)
    add "    script: \n"
    add "    while (!mm.eof) {\n"
    get
    add "\n    }"
    add "\n  }"
    add "\n}\n"
    # put a copy of the final compilation into the tapecell
    # for interactive debugging.
    put
    print
    clear
    quit
  block.end.52442:
  push
  push
  # try to explain some more errors
  unstack
  testbegins "parse>"
  jumpfalse block.end.52708
    put
    clear
    add "[error] pep syntax error:\n"
    add "  The parse> label cannot be the 1st item \n"
    add "  of a script \n"
    print
    quit
  block.end.52708:
  put
  clear
  clear
  add "After compiling with 'compile.java.pss' (at EOF): \n "
  add "  parse error in input script. \n "
  print
  clear
  unstack
  put
  clear
  add "Parse stack: "
  get
  add "\n"
  add "   * debug script "
  add "   >> pep -If script -i 'some input' \n "
  add "   *  debug compilation. \n "
  add "   >> pep -Ia asm.pp script' \n "
  print
  clear
  quit
block.end.53131:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
