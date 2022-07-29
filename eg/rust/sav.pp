# Assembled with the script 'compile.pss' 
start:
 
#
#   translate.rust.pss 
#
#   This is a parse-script which translates parse-scripts into rust
#   code, using the 'pep' tool. The script creates a standalone 
#   compilable rust program.
#   
#   The virtual machine and engine is implemented in plain c at
#   http://bumble.sf.net/books/pars/pep.c. This implements a script language
#   with a syntax reminiscent of sed and awk (much simpler than awk, but
#   more complex than sed).
#   
#STATUS
#
#    Adapting code, but I am finding rust very confusing and 
#    unnecessarily complicated. May work on the cpp translator instead.
#
#NOTES
#   
#   no multiline comments in rust?
#
#   We may use labelled loops and break/continue to implement the 
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
#   translate.java.pss
#     A very similar script for compiling scripts into java
#     And all the other translation scripts in pars/tr/
#
#TESTING
#
#   * testing the multiple escaped until bug
#   >> pep.rsas 'r;until"c";add".";t;d;' 'ab\\cab\cabc'
#
#   Complex scripts can be translated into java and work,
#   including this script itself. 
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
#  These are java bugs, not rust.
#
#  Xdigit in java not valid class.
#
#  Its a bit strange to talk about a multicharacter string being "escaped"
#  (eg when calling 'until') but this is allowed in the pep engine.
#
#  add "\{"; will generate an "illegal escape character" error
#  when trying to compile the generated java code. I need to 
#  consider what to do in this situation (eg escape \ to \\ ?)
#
#SOLVED BUGS
# 
#  check "go/mark" code. what happens if the mark is not found?? 
#  throw error and exit I think.
#
#  found a bug in "replace" code, which was returning from inline code.
#
#RUST NOTES
#
#   * delete a string
#   >> s.clear()
#
#   * a vector of chars
#   >> let mut chars: Vec<char> = pangram.chars().collect();
#    
#   * append a char to a string
#   ----
#    s.push(c);
#    // append string 
#    string.push_str(", ");
#   ,,,
#
#  * iterate an array
#  -----
#   for word in pangram.split_whitespace().rev() {
#        println!("> {}", word);
#   }
#   ,,,
#
#TASKS 
#
#HISTORY
#    
#  4 july 2022
#    Began to adapt from tr/translate.java.pss
#    Also working on eg/sed.tojava.pss
#    
#
read
#--------------
testclass [:space:]
jumpfalse block.end.2869
  clear
  jump parse
block.end.2869:
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
jump block.end.3305
  put
  add "*"
  push
  jump parse
block.end.3305:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.3758
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
  jumptrue block.end.3700
    clear
    add "Unterminated quote character (\") starting at "
    get
    add " !\n"
    print
    quit
  block.end.3700:
  put
  clear
  add "quote*"
  push
  jump parse
block.end.3758:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.4339
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
  jumptrue block.end.4222
    clear
    add "Unterminated quote (') starting at "
    get
    add "!\n"
    print
    quit
  block.end.4222:
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
block.end.4339:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
# should class tests really be multiline??!
testis "["
jumpfalse block.end.8029
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
  jumpfalse block.end.4863
    clear
    add "pep script error at line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty character class [] \n"
    print
    quit
  block.end.4863:
  testends "]"
  jumptrue block.end.5150
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
  block.end.5150:
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
  jumptrue block.end.5577
    # not a range class, eg [a-z] so need to escape '-' chars
    # java requires a double escape
    clear
    get
    replace "-" "\\\\-"
    put
  block.end.5577:
  testbegins "-"
  jumpfalse block.end.5965
    # a range class, eg [a-z], check if it is correct
    clip
    clip
    testis "-"
    jumptrue block.end.5959
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
    block.end.5959:
  block.end.5965:
  clear
  get
  # restore class text
  testbegins "[:"
  jumpfalse 3
  testends ":]"
  jumpfalse 2 
  jump block.end.6130
    clear
    add "malformed character class starting at "
    get
    add "!\n"
    print
    quit
  block.end.6130:
  testbegins "[:"
  jumpfalse 3
  testis "[:]"
  jumpfalse 2 
  jump block.end.7169
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
    jump block.end.6336
      clear
      add "\\\\p{Alnum}"
    block.end.6336:
    testis "alpha"
    jumptrue 4
    testis "A"
    jumptrue 2 
    jump block.end.6385
      clear
      add "\\\\p{Alpha}"
    block.end.6385:
    testis "ascii"
    jumptrue 4
    testis "I"
    jumptrue 2 
    jump block.end.6434
      clear
      add "\\\\p{ASCII}"
    block.end.6434:
    testis "blank"
    jumptrue 4
    testis "B"
    jumptrue 2 
    jump block.end.6483
      clear
      add "\\\\p{Blank}"
    block.end.6483:
    testis "cntrl"
    jumptrue 4
    testis "C"
    jumptrue 2 
    jump block.end.6532
      clear
      add "\\\\p{Cntrl}"
    block.end.6532:
    testis "digit"
    jumptrue 4
    testis "D"
    jumptrue 2 
    jump block.end.6581
      clear
      add "\\\\p{Digit}"
    block.end.6581:
    testis "graph"
    jumptrue 4
    testis "G"
    jumptrue 2 
    jump block.end.6630
      clear
      add "\\\\p{Graph}"
    block.end.6630:
    testis "lower"
    jumptrue 4
    testis "L"
    jumptrue 2 
    jump block.end.6679
      clear
      add "\\\\p{Lower}"
    block.end.6679:
    testis "print"
    jumptrue 4
    testis "P"
    jumptrue 2 
    jump block.end.6728
      clear
      add "\\\\p{Print}"
    block.end.6728:
    testis "punct"
    jumptrue 4
    testis "T"
    jumptrue 2 
    jump block.end.6777
      clear
      add "\\\\p{Punct}"
    block.end.6777:
    testis "space"
    jumptrue 4
    testis "S"
    jumptrue 2 
    jump block.end.6826
      clear
      add "\\\\p{Space}"
    block.end.6826:
    testis "upper"
    jumptrue 4
    testis "U"
    jumptrue 2 
    jump block.end.6875
      clear
      add "\\\\p{Upper}"
    block.end.6875:
    testis "xdigit"
    jumptrue 4
    testis "X"
    jumptrue 2 
    jump block.end.6926
      clear
      add "\\\\p{XDigit}"
    block.end.6926:
    testbegins "\\\\p{"
    jumptrue block.end.7163
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
    block.end.7163:
  block.end.7169:
  
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
block.end.8029:
#---------------
# formats: (eof) (EOF) (==) etc. 
testis "("
jumpfalse block.end.8500
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.8183
    clear
    add "eof*"
    push
    jump parse
  block.end.8183:
  testis "=="
  jumpfalse block.end.8236
    clear
    add "tapetest*"
    push
    jump parse
  block.end.8236:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.8500:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.9641
  clear
  read
  testis "\n"
  jumpfalse block.end.8636
    clear
    jump parse
  block.end.8636:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.9486
    # save the line number for possible error message later
    clear
    ll
    put
    clear
    until "*#"
    testends "*#"
    jumpfalse block.end.9231
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
    block.end.9231:
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
  block.end.9486:
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
block.end.9641:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.10028
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
block.end.10028:
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
jumpfalse block.end.10612
  clear
  add "lines"
block.end.10612:
testis "cc"
jumpfalse block.end.10644
  clear
  add "chars"
block.end.10644:
# one letter command abbreviations
testis "a"
jumpfalse block.end.10711
  clear
  add "add"
block.end.10711:
testis "k"
jumpfalse block.end.10741
  clear
  add "clip"
block.end.10741:
testis "K"
jumpfalse block.end.10771
  clear
  add "clop"
block.end.10771:
testis "D"
jumpfalse block.end.10804
  clear
  add "replace"
block.end.10804:
testis "d"
jumpfalse block.end.10835
  clear
  add "clear"
block.end.10835:
testis "t"
jumpfalse block.end.10866
  clear
  add "print"
block.end.10866:
testis "p"
jumpfalse block.end.10895
  clear
  add "pop"
block.end.10895:
testis "P"
jumpfalse block.end.10925
  clear
  add "push"
block.end.10925:
testis "u"
jumpfalse block.end.10958
  clear
  add "unstack"
block.end.10958:
testis "U"
jumpfalse block.end.10989
  clear
  add "stack"
block.end.10989:
testis "G"
jumpfalse block.end.11018
  clear
  add "put"
block.end.11018:
testis "g"
jumpfalse block.end.11047
  clear
  add "get"
block.end.11047:
testis "x"
jumpfalse block.end.11077
  clear
  add "swap"
block.end.11077:
testis ">"
jumpfalse block.end.11105
  clear
  add "++"
block.end.11105:
testis "<"
jumpfalse block.end.11133
  clear
  add "--"
block.end.11133:
testis "m"
jumpfalse block.end.11163
  clear
  add "mark"
block.end.11163:
testis "M"
jumpfalse block.end.11191
  clear
  add "go"
block.end.11191:
testis "r"
jumpfalse block.end.11221
  clear
  add "read"
block.end.11221:
testis "R"
jumpfalse block.end.11252
  clear
  add "until"
block.end.11252:
testis "w"
jumpfalse block.end.11283
  clear
  add "while"
block.end.11283:
testis "W"
jumpfalse block.end.11317
  clear
  add "whilenot"
block.end.11317:
testis "n"
jumpfalse block.end.11348
  clear
  add "count"
block.end.11348:
testis "+"
jumpfalse block.end.11376
  clear
  add "a+"
block.end.11376:
testis "-"
jumpfalse block.end.11404
  clear
  add "a-"
block.end.11404:
testis "0"
jumpfalse block.end.11434
  clear
  add "zero"
block.end.11434:
testis "c"
jumpfalse block.end.11465
  clear
  add "chars"
block.end.11465:
testis "l"
jumpfalse block.end.11496
  clear
  add "lines"
block.end.11496:
testis "^"
jumpfalse block.end.11528
  clear
  add "escape"
block.end.11528:
testis "v"
jumpfalse block.end.11562
  clear
  add "unescape"
block.end.11562:
testis "z"
jumpfalse block.end.11593
  clear
  add "delim"
block.end.11593:
testis "S"
jumpfalse block.end.11624
  clear
  add "state"
block.end.11624:
testis "q"
jumpfalse block.end.11654
  clear
  add "quit"
block.end.11654:
testis "s"
jumpfalse block.end.11685
  clear
  add "write"
block.end.11685:
testis "o"
jumpfalse block.end.11714
  clear
  add "nop"
block.end.11714:
testis "rs"
jumpfalse block.end.11748
  clear
  add "restart"
block.end.11748:
testis "rp"
jumpfalse block.end.11782
  clear
  add "reparse"
block.end.11782:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.11893
  put
  clear
  add "eof*"
  push
  jump parse
block.end.11893:
testis "<==>"
jumpfalse block.end.11951
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.11951:
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
jump block.end.12279
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
block.end.12279:
# show information if these "deprecated" commands are used
testis "Q"
jumptrue 6
testis "bail"
jumptrue 4
testis "state"
jumptrue 2 
jump block.end.12694
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
block.end.12694:
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
jump block.end.13087
  put
  clear
  add "word*"
  push
  jump parse
block.end.13087:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop. There is
# no "goto" in java so we need to use labelled loops to 
# implement .reparse/parse>
testis "parse>"
jumpfalse block.end.13735
  clear
  count
  testis "0"
  jumptrue block.end.13590
    clear
    add "script error:\n"
    add "  extra parse> label at line "
    ll
    add ".\n"
    print
    quit
  block.end.13590:
  clear
  add "// parse>"
  put
  clear
  add "parse>*"
  push
  # use accumulator to indicate after parse> label
  a+
  jump parse
block.end.13735:
# --------------------
# implement "begin-blocks", which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.13946
  put
  add "*"
  push
  jump parse
block.end.13946:
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
jump block.end.15686
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
block.end.15686:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.15881
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
block.end.15881:
testis ",*{*"
jumpfalse block.end.16051
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
block.end.16051:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.16240
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
block.end.16240:
testis "!*!*"
jumpfalse block.end.16503
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
block.end.16503:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.16818
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
block.end.16818:
testis ",*command*"
jumpfalse block.end.16994
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
block.end.16994:
testis "!*command*"
jumpfalse block.end.17199
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
block.end.17199:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.17408
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
block.end.17408:
testis "{*}*"
jumpfalse block.end.17542
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.17542:
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.17773
  push
  push
  add "error near line "
  ll
  add " of script:\n  classes ([a-z], [:space:] etc). \n"
  add "  cannot use the 'begin' or 'end' modifiers (B/E) \n"
  print
  clear
  quit
block.end.17773:
testis "comment*{*"
jumpfalse block.end.17965
  push
  push
  add "error near line "
  ll
  add " of script: comments cannot occur between \n"
  add " a test and a brace ({). \n"
  print
  clear
  quit
block.end.17965:
testis "}*command*"
jumpfalse block.end.18115
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.18115:

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
jumpfalse block.end.19378
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.18829
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
  block.end.18829:
  testis "reparse"
  jumpfalse block.end.19165
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.19053
      clear
      add "break lex;"
    block.end.19053:
    testis "1"
    jumpfalse block.end.19097
      clear
      add "continue parse;"
    block.end.19097:
    put
    clear
    add "command*"
    push
    jump parse
  block.end.19165:
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
block.end.19378:
#---------------------------------
# Compiling comments so as to transfer them to the java 
testis "comment*command*"
jumptrue 6
testis "command*comment*"
jumptrue 4
testis "commandset*comment*"
jumptrue 2 
jump block.end.19629
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
block.end.19629:
testis "comment*comment*"
jumpfalse block.end.19743
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
block.end.19743:
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
jump block.end.20541
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
block.end.20541:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.21047
  clear
  add "endtext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.21004
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
  block.end.21004:
  --
  put
  ++
  clear
  jump parse
block.end.21047:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.21594
  clear
  add "begintext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.21551
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
  block.end.21551:
  --
  put
  ++
  clear
  jump parse
block.end.21594:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.24812
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
  jump block.end.22160
    put
    clear
    add "'"
    get
    add "'"
    add " << command needs an argument, on line "
    ll
    add " of script.\n"
    print
    clear
    quit
  block.end.22160:
  testis "clip"
  jumpfalse block.end.22239
    clear
    add "mm.work.pop();    /* clip */"
    put
  block.end.22239:
  testis "clop"
  jumpfalse block.end.22383
    clear
    add "if !mm.work.is_empty() { /* clop */\n"
    add "  mm.work.remove(0); \n}   "
    put
  block.end.22383:
  testis "clear"
  jumpfalse block.end.22463
    clear
    add "mm.work.clear();  /* clear */"
    put
  block.end.22463:
  testis "upper"
  jumpfalse block.end.22578
    clear
    add "let mm.work = mm.work.to_uppercase(); /* upper */"
    put
  block.end.22578:
  testis "lower"
  jumpfalse block.end.22692
    clear
    add "let mm.work = mm.work.to_lowercase(); /* lower */"
    put
  block.end.22692:
  testis "cap"
  jumpfalse block.end.22895
    clear
    add "if !mm.work.is_empty() { /* cap */\n"
    add "let mm.work = mm.work.remove(0).to_uppercase().to_string() + "
    add " &mm.work; } "
    put
  block.end.22895:
  testis "print"
  jumpfalse block.end.22982
    clear
    add "print!(\"{}\", mm.work); /* print */"
    put
  block.end.22982:
  testis "pop"
  jumpfalse block.end.23026
    clear
    add "mm.pop();"
    put
  block.end.23026:
  testis "push"
  jumpfalse block.end.23072
    clear
    add "mm.push();"
    put
  block.end.23072:
  testis "unstack"
  jumpfalse block.end.23158
    clear
    add "while mm.pop();          /* unstack */"
    put
  block.end.23158:
  testis "stack"
  jumpfalse block.end.23241
    clear
    add "while mm.push();          /* stack */"
    put
  block.end.23241:
  testis "put"
  jumpfalse block.end.23385
    clear
    add "mm.tape[mm.cell].clear(); /* put */\n"
    add "mm.tape[mm.cell).append(mm.work); "
    put
  block.end.23385:
  testis "get"
  jumpfalse block.end.23493
    clear
    add "mm.work.push_str(mm.tape[mm.cell)); /* get */"
    put
  block.end.23493:
  testis "swap"
  jumpfalse block.end.23570
    clear
    add "mem::swap(&mut <tape.cell>, &mut <work>);"
    put
  block.end.23570:
  testis "++"
  jumpfalse block.end.23650
    clear
    add "mm.increment();               /* ++ */"
    put
  block.end.23650:
  testis "--"
  jumpfalse block.end.23746
    clear
    add "if mm.cell > 0 { mm.cell -= 1; } /* -- */"
    put
  block.end.23746:
  testis "read"
  jumpfalse block.end.23803
    clear
    add "mm.read(); /* read */"
    put
  block.end.23803:
  testis "count"
  jumpfalse block.end.23907
    clear
    add "mm.work.push_str(mm.accumulator); /* count */"
    put
  block.end.23907:
  testis "a+"
  jumpfalse block.end.23970
    clear
    add "mm.accumulator += 1; /* a+ */"
    put
  block.end.23970:
  testis "a-"
  jumpfalse block.end.24033
    clear
    add "mm.accumulator -= 1; /* a- */"
    put
  block.end.24033:
  testis "zero"
  jumpfalse block.end.24099
    clear
    add "mm.accumulator = 0; /* zero */"
    put
  block.end.24099:
  testis "chars"
  jumpfalse block.end.24193
    clear
    add "mm.work.push_str(mm.charsRead); /* chars */"
    put
  block.end.24193:
  testis "lines"
  jumpfalse block.end.24287
    clear
    add "mm.work.push_str(mm.linesRead); /* lines */"
    put
  block.end.24287:
  testis "nochars"
  jumpfalse block.end.24357
    clear
    add "mm.charsRead = 0; /* nochars */"
    put
  block.end.24357:
  testis "nolines"
  jumpfalse block.end.24427
    clear
    add "mm.linesRead = 0; /* nolines */"
    put
  block.end.24427:
  # use a labelled loop to quit script.
  testis "quit"
  jumpfalse block.end.24519
    clear
    add "break script;"
    put
  block.end.24519:
  testis "write"
  jumpfalse block.end.24644
    clear
    add "fs::write(\"sav.pp\", mm.work).expect(\"Unable to write file\");"
    put
  block.end.24644:
  # just eliminate since it does nothing.
  testis "nop"
  jumpfalse block.end.24758
    clear
    add "/* nop: no-operation eliminated */"
    put
  block.end.24758:
  clear
  add "command*"
  push
  jump parse
block.end.24812:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.25136
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
block.end.25136:
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
jump block.end.26286
  testbegins "begin"
  jumpfalse block.end.25632
    clear
    add "mm.work.starts_with("
  block.end.25632:
  testbegins "end"
  jumpfalse block.end.25680
    clear
    add "mm.work.ends_with("
  block.end.25680:
  testbegins "quote"
  jumpfalse block.end.25724
    clear
    add "mm.work.eq(&"
  block.end.25724:
  testbegins "class"
  jumpfalse block.end.25772
    clear
    add "mm.work.matches("
  block.end.25772:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.25902
    clear
    put
    add "mm.eof"
  block.end.25902:
  testbegins "tapetest"
  jumpfalse block.end.26000
    clear
    put
    add "(mm.work.eq(&mm.tape[mm.cell))"
  block.end.26000:
  get
  testbegins "mm.eof"
  jumptrue block.end.26033
    add ")"
  block.end.26033:
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
block.end.26286:
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
jump block.end.27331
  testbegins "notbegin"
  jumpfalse block.end.26772
    clear
    add "!mm.work.starts_with("
  block.end.26772:
  testbegins "notend"
  jumpfalse block.end.26824
    clear
    add "!mm.work.ends_with("
  block.end.26824:
  testbegins "notquote"
  jumpfalse block.end.26872
    clear
    add "!mm.work.eq(&"
  block.end.26872:
  testbegins "notclass"
  jumpfalse block.end.26924
    clear
    add "!mm.work.matches("
  block.end.26924:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.27058
    clear
    put
    add "!mm.eof"
  block.end.27058:
  testbegins "nottapetest"
  jumpfalse block.end.27160
    clear
    put
    add "(!mm.work.eq(&mm.tape[mm.cell))"
  block.end.27160:
  get
  testbegins "!mm.eof"
  jumptrue block.end.27194
    add ")"
  block.end.27194:
  put
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.27331:
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
jump block.end.27808
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
block.end.27808:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.28004
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.28004:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.28471
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
block.end.28471:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.32301
  clear
  get
  testis "replace"
  jumpfalse block.end.28814
    # error 
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.28814:
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
  jump block.end.29812
    # This is trickier than I thought it would be.
    clear
    ++
    get
    --
    # check that arg not empty, (but an empty quote is ok 
    # for the second arg of 'replace'
    testis "\"\""
    jumpfalse block.end.29364
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
    block.end.29364:
    # quoted text has the quotes still around it.
    # also handle escape characters like \n \r etc
    clip
    clop
    clop
    clop
    # B "\\" { clip; } 
    clip
    testis ""
    jumptrue block.end.29788
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
    block.end.29788:
    clear
    get
  block.end.29812:
  testis "mark"
  jumpfalse block.end.30052
    clear
    add "/* mark */ \n"
    add "mm.marks[mm.cell).clear(); // mark \n"
    add "mm.marks[mm.cell).push_str("
    ++
    get
    --
    add "); // mark"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.30052:
  testis "go"
  jumpfalse block.end.30192
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
  block.end.30192:
  testis "delim"
  jumpfalse block.end.30514
    clear
    # this.delimiter.setCharAt(0, text.charAt(0));
    # only the first character of the delimiter argument is used. 
    add "mm.delimiter.clear(); /* delim */\n"
    add "mm.delimiter.push_str("
    ++
    get
    --
    add "); "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.30514:
  testis "add"
  jumpfalse block.end.30746
    clear
    add "mm.work.push_str("
    ++
    get
    --
    # handle multiline text
    replace "\n" "\"); \nmm.work.push_str(\"\\n"
    add "); /* add */"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.30746:
  testis "while"
  jumpfalse block.end.30968
    clear
    add "while (mm.peep == "
    ++
    get
    --
    add ".charAt(0)) /* while */\n "
    add " { if mm.eof {break;} mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.30968:
  testis "whilenot"
  jumpfalse block.end.31191
    clear
    add "while (mm.peep != "
    ++
    get
    --
    add ".charAt(0)) /* whilenot */\n "
    add " { if mm.eof {break;} mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.31191:
  testis "until"
  jumpfalse block.end.31792
    clear
    add "mm.until("
    ++
    get
    --
    # error until cannot have empty argument
    testis "mm.until(\"\""
    jumpfalse block.end.31656
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
    block.end.31656:
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.31792:
  # But really, can't the "replace" command just be used
  # instead of escape/unescape?? This seems a flaw in the 
  # machine design.
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.32110
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
  block.end.32110:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.32301:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.33036
  clear
  get
  testis "while"
  jumpfalse block.end.32654
    clear
    add "/* while */ \n"
    add "while (mm.peep.matches("
    ++
    get
    --
    add ")) { if mm.eof { break; } mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.32654:
  testis "whilenot"
  jumpfalse block.end.32883
    clear
    add "/* whilenot */ \n"
    add "while (!mm.peep).matches("
    ++
    get
    --
    add ")) { if mm.eof { break; } mm.read(); }"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.32883:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.33036:
# arrange the parse> label loops
testeof 
jumpfalse block.end.33746
  testis "commandset*parse>*commandset*"
  jumptrue 8
  testis "command*parse>*commandset*"
  jumptrue 6
  testis "commandset*parse>*command*"
  jumptrue 4
  testis "command*parse>*command*"
  jumptrue 2 
  jump block.end.33742
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
    add "loop { \n"
    get
    add "\n  break parse;\n}"
    --
    --
    put
    clear
    add "commandset*"
    push
    jump parse
  block.end.33742:
block.end.33746:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# bnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.34623
  clear
  get
  testis "replace"
  jumpfalse block.end.34454
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    clear
    add "/* replace */ \n"
    add "if !mm.work.is_empty() { \n"
    add "  temp = mm.work.replace("
    ++
    get
    add ", "
    ++
    get
    add ");\n"
    add "  mm.work.clear(); \n"
    add "  mm.work.push_str(temp);\n} "
    --
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34454:
  add "pep script error on line "
  ll
  add " (character "
  cc
  add "): \n"
  add "  command does not take 2 quoted arguments. \n"
  print
  quit
block.end.34623:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.35007
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
block.end.35007:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# these 2 tests should be all that is necessary
testis "test*,*ortestset*{*"
jumptrue 4
testis "test*,*test*{*"
jumptrue 2 
jump block.end.35351
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
block.end.35351:
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
jump block.end.35920
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
block.end.35920:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.36483
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
block.end.36483:
# -------------
# multi-token end-of-stream errors
# not a comprehensive list of errors...
testeof 
jumpfalse block.end.37278
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
  jump block.end.36793
    add "  Error near end of script at line "
    ll
    add ". Test with no brace block? \n"
    print
    clear
    quit
  block.end.36793:
  testends "quote*"
  jumptrue 6
  testends "class*"
  jumptrue 4
  testends "word*"
  jumptrue 2 
  jump block.end.37018
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
  block.end.37018:
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
  jump block.end.37274
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
  block.end.37274:
block.end.37278:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.46441
  print
  clear
  # create the virtual machine object code and save it
  # somewhere on the tape.
  add "\n"
  add "\n"
  add " /* Rust code generated by \"translate.rust.pss\" */\n"
  add "\n"
  add " // use std::mem;     // for swap\n"
  add " use std::io;\n"
  add " use std::io::Read;\n"
  add " use std::io::BufReader;\n"
  add " use std::io::BufRead;\n"
  add " use std::process;\n"
  add " use std::fs;\n"
  add "\n"
  add " pub struct Machine {\n"
  add "   accumulator: i32,          // counter for anything\n"
  add "   peep: char,                // next char in input stream\n"
  add "   charsRead: u32,            // No. of chars read so far\n"
  add "   linesRead: u32,            // No. of lines read so far\n"
  add "   work: String,          // text accumulator\n"
  add "   stack: Vec<String>,    // parse token stack\n"
  add "   LENGTH: u32,           // tape initial length\n"
  add "   // vectors are growable in rust\n"
  add "   tape: Vec<String>,     // array of token attributes, growable\n"
  add "   marks: Vec<String>,    // tape marks\n"
  add "   cell: u32,             // pointer to current cell\n"
  add "   input: BufReader<File>,   // text input stream\n"
  add "   eof: bool,             // end of stream reached?\n"
  add "   flag: bool,          // not used here\n"
  add "   escape: String,      // char used to \"escape\" others \"\\\"\n"
  add "   delimiter: String    // push/pop delimiter (default is \"*\")\n"
  add "   \n"
  add " }\n"
  add "\n"
  add " impl Machine {\n"
  add "\n"
  add "   // read from stdin or from a file or a string.\n"
  add "   // BufReader::new(io::stdin())\n"
  add "   // BufReader::new(fs::File::open(filename).unwrap())\n"
  add "   // let mut streader = StringReader::new(\"Line 1\\nLine 2\");\n"
  add "   // let mut bufreader = BufReader::new(streader);\n"
  add "\n"
  add "   /** make a new machine with input from stdin */\n"
  add "   /*\n"
  add "   pub fn new() -> Self {\n"
  add "     return Machine::new(BufReader::new(io::stdin()));\n"
  add "   }\n"
  add "   */\n"
  add "   \n"
  add "   /** make a new machine with input from a string and\n"
  add "       output to a string */\n"
  add "   /*\n"
  add "   stringreader is a crate. \n"
  add "   pub fn new(input: String, output: String) -> Self {\n"
  add "     let mut reader = StringReader::new(input);\n"
  add "     return Machine::new(BufReader::new(reader));\n"
  add "   }\n"
  add "   */\n"
  add "   \n"
  add "   /** make a new machine with a buffered stream reader */\n"
  add "   pub fn new<R: BufRead>(reader: R) -> Self {\n"
  add "     Self {\n"
  add "       LENGTH: 100,\n"
  add "       // BufReader::new(io::stdin())\n"
  add "       input: reader,\n"
  add "       eof: false,\n"
  add "       flag: false,\n"
  add "       charsRead: 0, \n"
  add "       linesRead: 1, \n"
  add "       escape: String::from(\"\\\\\"),\n"
  add "       delimiter: String::from(\"*\"),\n"
  add "       accumulator: 0,\n"
  add "       work: String::new(),\n"
  add "       stack: vec![\"\".to_string(),100],\n"
  add "       cell: 0,\n"
  add "       tape: vec![\"\".to_string(),100],\n"
  add "       marks: vec![\"\".to_string(),100],\n"
  add "       cell: 0,\n"
  add "       marks: Vec::new(),\n"
  add "       peep: Self.input.read()\n"
  add "     } // self\n"
  add "   }\n"
  add "\n"
  add "   /** read one character from the input stream and \n"
  add "       update the machine. */\n"
  add "   pub fn readNext(&mut self) {\n"
  add "     //int iChar;\n"
  add "     if self.eof { process::exit(0); }\n"
  add "     self.charsRead += 1;\n"
  add "     // increment lines\n"
  add "     if self.peep == \'\\n\' { self.linesRead += 1; }\n"
  add "     self.work.push(self.peep);\n"
  add "     self.peep = self.input.read(); \n"
  add "     if self.peep == -1 { self.eof = true; }\n"
  add "   }\n"
  add "\n"
  add "   /** increment tape pointer by one */\n"
  add "   pub fn increment(&mut self) {\n"
  add "     self.cell += 1;\n"
  add "     if self.cell >= self.LENGTH {\n"
  add "       self.tape.push(String::from(\"\"));\n"
  add "       self.marks.push(String::from(\"\"));\n"
  add "       self.LENGTH += 1;\n"
  add "     }\n"
  add "   }\n"
  add "   \n"
  add "   /** remove escape character  */\n"
  add "   pub fn unescapeChar(&mut self, c: char) {\n"
  add "     if !self.work.is_empty() {\n"
  add "       let s: String = self.work.replace(\"\\\\\"+c, c+\"\");\n"
  add "       self.work.clear(); self.work.push_str(s);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** add escape character  */\n"
  add "   pub fn escapeChar(&mut self, c: char) {\n"
  add "     if !self.work.is_empty() {\n"
  add "       let s: String = self.work.replace(c+\"\", \"\\\\\"+c);\n"
  add "       self.work.clear(); self.work.push_str(s);\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** whether trailing escapes \\\\ are even or odd */\n"
  add "   // untested code. check! eg try: add \"x \\\\\"; print; etc\n"
  add "   pub fn isEscaped(&mut self, ss: String, sSuffix: String) -> bool {\n"
  add "     let count: i32 = 0; \n"
  add "     if ss.chars().count() < 2 { return false; }\n"
  add "     if ss.chars().count() <= sSuffix.chars().count() { return false; }\n"
  add "     if ss.indexOf(self.escape.charAt(0)) == -1 \n"
  add "       { return false; }\n"
  add "     let pos: i32 = ss.chars().count()-sSuffix.length();\n"
  add "     while (pos > -1) && (ss.charAt(pos) == self.escape.charAt(0)) {\n"
  add "       count += 1; pos -= 1;\n"
  add "     }\n"
  add "     if count % 2 == 0 { return false; }\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   /* a helper to see how many trailing \\\\ escape chars */\n"
  add "   pub fn countEscaped(&mut self, sSuffix: String) -> u32 {\n"
  add "     let mut s = String::new();\n"
  add "     let count: i32 = 0;\n"
  add "     let index: i32 = self.work.lastIndexOf(sSuffix);\n"
  add "     // remove suffix if it exists\n"
  add "     if index > 0 {\n"
  add "       s = self.work.substring(0, index);\n"
  add "     }\n"
  add "     while s.ends_with(self.escape) {\n"
  add "       count += 1;\n"
  add "       s = s.substring(0, s.lastIndexOf(self.escape));\n"
  add "     }\n"
  add "     return count;\n"
  add "   }\n"
  add "\n"
  add "   /** reads the input stream until the work end with text */\n"
  add "   // can test this with\n"
  add "   pub fn until(&mut self, sSuffix: String) {\n"
  add "     // read at least one character\n"
  add "     if self.eof { return; }\n"
  add "     self.readNext();\n"
  add "     loop {\n"
  add "       if self.eof { return; }\n"
  add "       if self.work.ends_with(sSuffix) {\n"
  add "         if self.countEscaped(sSuffix) % 2 == 0 { return; }\n"
  add "       }\n"
  add "       self.readNext();\n"
  add "     }\n"
  add "   }\n"
  add "\n"
  add "   /** pop the first token from the stack into the workspace */\n"
  add "   pub fn pop(&mut self) -> bool {\n"
  add "     if self.stack.len() == 0 { return false; }\n"
  add "     self.work.insert_str(0, self.stack.pop().as_str());     \n"
  add "     if self.cell > 0 { self.cell -= 1; }\n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   // push the first token from the workspace to the stack \n"
  add "   pub fn push(&mut self) -> bool {\n"
  add "     let sItem: String = String::new();\n"
  add "     // dont increment the tape pointer on an empty push\n"
  add "     if self.work.is_empty() { return false; }\n"
  add "     // need to get this from self.delim not \"*\"\n"
  add "     let iFirstStar: u32 = self.work.indexOf(self.delimiter);\n"
  add "     if iFirstStar != -1 {\n"
  add "       sItem = self.work.substring(0, iFirstStar + 1);\n"
  add "       self.work.delete(0, iFirstStar + 1);\n"
  add "     }\n"
  add "     else {\n"
  add "       sItem = self.work;\n"
  add "       self.work.clear();\n"
  add "     }\n"
  add "     self.stack.push(sItem);     \n"
  add "     self.increment(); \n"
  add "     return true;\n"
  add "   }\n"
  add "\n"
  add "   // swap not required, use mem::swap\n"
  add "\n"
  add "   // save the workspace to file \"sav.pp\" */\n"
  add "   // not required.\n"
  add "   pub fn writeToFile(&mut self) {\n"
  add "     fs::write(\"sav.pp\", self.work).expect(\"Unable to write file\");\n"
  add "   }\n"
  add "\n"
  add "   pub fn goToMark(&mut self, mark: String) {\n"
  add "     for (ii, thismark) in self.marks.iter().enumerate() {\n"
  add "       if thismark.eq(&mark) { self.cell = ii; return; }\n"
  add "     }\n"
  add "     print!(\"badmark \'{}\'!\", mark); \n"
  add "     process::exit(1);\n"
  add "   }\n"
  add "\n"
  add "   /** parse/check/compile the input */\n"
  add "   pub fn parse(&mut self) {\n"
  add "     //this is where the actual parsing/compiling code should go \n"
  add "     //but this means that all generated code must use\n"
  add "     //\"self.\" not \"mm.\"\n"
  add "     let ii = 1;\n"
  add "   }\n"
  add " }\n"
  add "\n"
  add " fn main() -> io::Result<()> { \n"
  add "    // BufReader::new(io::stdin())\n"
  add "    let temp: String = String::new();    \n"
  add "    let mm: Machine = Machine::new(BufReader::new(io::stdin())); \n"
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
  jump block.end.45048
    clear
    # indent generated code (6 spaces) for readability.
    add "      "
    get
    replace "\n" "\n      "
    put
    clear
    # restore the rust preamble from the tape
    ++
    get
    --
    add "\n"
    add "    \'script: \n"
    add "    while !mm.eof {\n"
    get
    add "\n    }"
    add "\n  }\n"
    #add "\n}\n";
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    print
    clear
    quit
  block.end.45048:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.45752
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
    # get rust preamble from tape
    ++
    ++
    get
    --
    --
    get
    add "\n"
    ++
    # a labelled loop for "quit" (but quit can just exit?)
    add "    'script: \n"
    add "    while !mm.eof {\n"
    get
    add "\n    }"
    add "\n  }\n"
    #add "\n}\n";
    # put a copy of the final compilation into the tapecell
    # for interactive debugging.
    put
    print
    clear
    quit
  block.end.45752:
  push
  push
  # try to explain some more errors
  unstack
  testbegins "parse>"
  jumpfalse block.end.46018
    put
    clear
    add "[error] pep syntax error:\n"
    add "  The parse> label cannot be the 1st item \n"
    add "  of a script \n"
    print
    quit
  block.end.46018:
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
block.end.46441:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
