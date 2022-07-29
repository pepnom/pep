# Assembled with the script 'compile.pss' 
start:
 
#   translate.perl.pss 
#
#   This is a parse-script which translates parse-scripts into perl
#   code, using the 'pep' tool. The script creates a standalone 
#   perl program
#   
#   The virtual machine and engine is implemented in plain c at
#   http://bumble.sf.net/books/pars/pep.c. This implements a script
#   language with a syntax reminiscent of sed and awk (much simpler than
#   awk, but more complex than sed).
#   
#STATUS
#
#  Adapting from the ruby version. Not working. 
#
#NOTES
#   
#   some strange bug with quote parsing in the compiler compile.pss
#   seen in the parse(""); fn
#
#   Using an associative array to implement the machine.
#
#   Do I need to pass a global reference to the machine to the 
#   'methods' or just a reference that will mutate the data-structure??
#
#   man perlfunc is a handy reference for perl functions
#   perl has a "goto"
#
#   In other translation scripts, we use labelled loops and
#   break/continue to implement the parse> label and .reparse .restart
#   commands. Breaks could be used to implement the quit command but arent.
#
#   Does perl support labelled loops? No, one option is to set a flag
#   when .restart .reparse is called to break the outer loop
#
#   We can use "run once" loops eg " while true do ... break; end " an 
#   example is in the translate.tcl.pss script. 
#
#TODO
#
#   Maybe convert the generated code to use a "parse" method with 
#   some kind of a stream reader. 
#
#SEE ALSO
#   
#   At http://bumble.sf.net/books/pars/
#
#   tr/translate.java.pss, tr/translate.py.pss
#     A very similar script for compiling scripts into java and python
#
#   compile.pss
#     compiles a script into an "assembly" format that can be loaded
#     and run on the parse-machine with the -a  switch. This performs
#     the same function as "asm.pp" 
#
#TEST SCRIPTS
#
#  * test escaping
#  >> pep.rb 'r;escape "c";t;d;' "abcxcabc"
#  >> pep.rb 'r;unescape "c";t;d;' 'ab\cx\\cabc'
#
#  so unescaping should be more intelligent.
#
#  
#TESTING
#
#   * test simple scripts (using helper function), 1st and 2nd generation
#   >> pep.tt perl
#   (still have to implement pep.tt for perl in helpers.pars.sh
#
#   * use helper to test 2nd gen script translation
#   >> pep.pls "r;a':';t;d;" "abc"
#
#   * use helper function in peprc to see palindromes
#   >> pep.plff eg/palindrome.pss /usr/share/dict/words
#
#   * use the bash helper functions to test (from helpers.pars.sh)
#   >> pep.plf eg/json.check.simplenum.pss '{"here":2}'
#
#   The line above compiles the script to perl in the folder
#   pars/eg/perl/json.check.simplenum.pss and runs it with the input.
#
#   check multiline text with 'add' and 'until'
#
#   * one comprehensive test is to run the script on itself
#   >> pep -f translate.rb.pss translate.rb.pss > eg/perl/translate.rb.rb
#   >> chmod a+x eg/perl/translate.perl.pl
#   >> echo "r;t;d;" | eg/perl/translate.perl.pl
#
#   run the translator on itself
#   -----
#     pep -f translate.rb.pss translate.rb.pss > test.rb
#     echo "nop;r;t;t;d;" | ./test.rb 
#   ,,,,
#
#WATCH OUT FOR
#
#  treatment of regexes is different (for while whilenot etc). Eg in
#  ruby [[:space:]] is unicode aware but \s is not
#
#  until needs to actually count how many trailing '\' or
#  escape chars there are !...
#
#  make sure .reparse and .restart work before and after the 
#  parse> label. done.
#
#  Make sure escaping and multiline arguments work.
#
#  "until" does not read at least one character.
#
#  #{...} must be escaped otherwise variable interpolations happens.
#
#BUGS
#   
#  2nd gen is not working well yet
#
#  unescape doesnt work, not sure why.
#
#  unescaping needs to be more careful. eg
#  "ab\cab\\cabc" in this case we should just remove all \c to c
#
#  rewrite until code to check for multiple trailing escape
#  chars.
#
#SOLVED BUGS TO WATCH FOR 
#
#  * the line below was throwing an error (compile.pss)
#  >> add '", "\\'; get; add '")'; --; put; clear;
#
#  This needed to be fixed in compile.pss and also in eg translation
#  script.
#
#  Multiline add should not add extra spaces,
#
#  Java needs a double escape \\\\ before some chars, but ruby doesnt 
#
#  escape needs to use the machine escape char. 
#  found and fixed a bug in java whilenot/while. The code exits if the 
#  character is not found, which is not correct.
#
#  Found and fixed a bug in the (==) code ie in java (stringa == stringb)
#  doesnt work. 
#
#  "until" bug where the code did not read 
#  at least one character.
#
#  Read must exit if at end of stream, but while/whilenot/until, no.
#
#TASKS 
#
#HISTORY
#
#  13 july 2022
#    Converting from a normal perl hash, to an object oriented 
#    perl idiom. (bless etc). Perl oo seems quite odd.
#  25 june 2022
#    A lot of conversion work.
#  24 June 2022
#    Began to adapt from the ruby code.
#
#
read
#--------------
testclass [:space:]
jumpfalse block.end.4751
  clear
  jump parse
block.end.4751:
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
jump block.end.5187
  put
  add "*"
  push
  jump parse
block.end.5187:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.5724
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
  jumptrue block.end.5582
    clear
    add "Unterminated quote character (\") starting at "
    get
    add " !\n"
    print
    quit
  block.end.5582:
  # check for empty quotes as arguments for escape etc 
  replace "#{" "\\#{"
  put
  clear
  add "quote*"
  push
  jump parse
block.end.5724:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.6448
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
  jumptrue block.end.6188
    clear
    add "Unterminated quote (') starting at "
    get
    add "!\n"
    print
    quit
  block.end.6188:
  clip
  escape "\""
  # #{ does string interpolation in ruby which is not 
  # what we want. Also unescape \'
  replace "#{" "\\#{"
  unescape "'"
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
block.end.6448:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
# should class tests really be multiline??!
testis "["
jumpfalse block.end.10251
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
  jumpfalse block.end.6972
    clear
    add "pep script error at line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty character class [] \n"
    print
    quit
  block.end.6972:
  testends "]"
  jumptrue block.end.7259
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
  block.end.7259:
  # need to escape quotes? ruby uses /.../ to match
  escape "\""
  # the caret is not a negation operator in pep scripts
  replace "^" "\\^"
  # save the class on the tape
  put
  clop
  clop
  testbegins "-"
  jumptrue block.end.7594
    # not a range class, eg [a-z] so need to escape '-' chars
    clear
    get
    replace "-" "\\-"
    put
  block.end.7594:
  testbegins "-"
  jumpfalse block.end.7982
    # a range class, eg [a-z], check if it is correct
    clip
    clip
    testis "-"
    jumptrue block.end.7976
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
    block.end.7976:
  block.end.7982:
  clear
  get
  # restore class text
  testbegins "[:"
  jumpfalse 3
  testends ":]"
  jumpfalse 2 
  jump block.end.8147
    clear
    add "malformed character class starting at "
    get
    add "!\n"
    print
    quit
  block.end.8147:
  # class in the form [:digit:]
  testbegins "[:"
  jumpfalse 3
  testis "[:]"
  jumpfalse 2 
  jump block.end.9382
    clip
    clip
    clop
    clop
    # unicode posix character classes 
    # Also, abbreviations (not implemented in gh.c yet.)
    # this should not be tricky in ruby because posix is supported
    testis "alnum"
    jumptrue 4
    testis "N"
    jumptrue 2 
    jump block.end.8447
      clear
      add "[[:alnum:]]"
    block.end.8447:
    testis "alpha"
    jumptrue 4
    testis "A"
    jumptrue 2 
    jump block.end.8495
      clear
      add "[[:alpha:]]"
    block.end.8495:
    # ? can use s.ascii_only?()
    testis "ascii"
    jumptrue 4
    testis "I"
    jumptrue 2 
    jump block.end.8577
      clear
      add "[[:ascii:]]"
    block.end.8577:
    # non-standard ruby posix class 'word'
    testis "word"
    jumptrue 4
    testis "W"
    jumptrue 2 
    jump block.end.8668
      clear
      add "[[:word:]]"
    block.end.8668:
    testis "blank"
    jumptrue 4
    testis "B"
    jumptrue 2 
    jump block.end.8716
      clear
      add "[[:blank:]]"
    block.end.8716:
    testis "cntrl"
    jumptrue 4
    testis "C"
    jumptrue 2 
    jump block.end.8764
      clear
      add "[[:cntrl:]]"
    block.end.8764:
    testis "digit"
    jumptrue 4
    testis "D"
    jumptrue 2 
    jump block.end.8812
      clear
      add "[[:digit:]]"
    block.end.8812:
    testis "graph"
    jumptrue 4
    testis "G"
    jumptrue 2 
    jump block.end.8860
      clear
      add "[[:graph:]]"
    block.end.8860:
    testis "lower"
    jumptrue 4
    testis "L"
    jumptrue 2 
    jump block.end.8908
      clear
      add "[[:lower:]]"
    block.end.8908:
    testis "print"
    jumptrue 4
    testis "P"
    jumptrue 2 
    jump block.end.8956
      clear
      add "[[:print:]]"
    block.end.8956:
    testis "punct"
    jumptrue 4
    testis "T"
    jumptrue 2 
    jump block.end.9004
      clear
      add "[[:punct:]]"
    block.end.9004:
    testis "space"
    jumptrue 4
    testis "S"
    jumptrue 2 
    jump block.end.9052
      clear
      add "[[:space:]]"
    block.end.9052:
    testis "upper"
    jumptrue 4
    testis "U"
    jumptrue 2 
    jump block.end.9100
      clear
      add "[[:upper:]]"
    block.end.9100:
    testis "xdigit"
    jumptrue 4
    testis "X"
    jumptrue 2 
    jump block.end.9150
      clear
      add "[[:xdigit:]]"
    block.end.9150:
    testbegins "[["
    jumptrue block.end.9375
      put
      clear
      add "pep script error at line "
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
    block.end.9375:
  block.end.9382:
  
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
  add "/^"
  get
  add "+$/"
  put
  clear
  # add quotes around the class and limits around the 
  # class so it can be used with the string.matches() method
  # (must match the whole string, not just one character)
  add "class*"
  push
  jump parse
block.end.10251:
#---------------
# formats: (eof) (EOF) (==) etc. 
testis "("
jumpfalse block.end.10722
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.10405
    clear
    add "eof*"
    push
    jump parse
  block.end.10405:
  testis "=="
  jumpfalse block.end.10458
    clear
    add "tapetest*"
    push
    jump parse
  block.end.10458:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.10722:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.11980
  clear
  read
  testis "\n"
  jumpfalse block.end.10858
    clear
    jump parse
  block.end.10858:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.11739
    # save the line number for possible error message later
    clear
    ll
    put
    clear
    until "*#"
    testends "*#"
    jumpfalse block.end.11484
      # convert to python comments (#), python doesnt have multiline
      # comments, as far as I know
      clip
      clip
      replace "\n" "\n#"
      put
      clear
      # create a "comment" parse token
      # comment-out this line to remove multiline comments from the 
      # compiled python
      # add "comment*"; push; 
      jump parse
    block.end.11484:
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
  block.end.11739:
  # single line comments. some will get lost.
  put
  clear
  add "#"
  get
  until "\n"
  clip
  put
  clear
  # comment out this below to remove single line comments
  # from the output
  add "comment*"
  push
  jump parse
block.end.11980:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.12367
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
block.end.12367:
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
jumpfalse block.end.12951
  clear
  add "lines"
block.end.12951:
testis "cc"
jumpfalse block.end.12983
  clear
  add "chars"
block.end.12983:
# one letter command abbreviations
testis "a"
jumpfalse block.end.13050
  clear
  add "add"
block.end.13050:
testis "k"
jumpfalse block.end.13080
  clear
  add "clip"
block.end.13080:
testis "K"
jumpfalse block.end.13110
  clear
  add "clop"
block.end.13110:
testis "D"
jumpfalse block.end.13143
  clear
  add "replace"
block.end.13143:
testis "d"
jumpfalse block.end.13174
  clear
  add "clear"
block.end.13174:
testis "t"
jumpfalse block.end.13205
  clear
  add "print"
block.end.13205:
testis "p"
jumpfalse block.end.13234
  clear
  add "pop"
block.end.13234:
testis "P"
jumpfalse block.end.13264
  clear
  add "push"
block.end.13264:
testis "u"
jumpfalse block.end.13297
  clear
  add "unstack"
block.end.13297:
testis "U"
jumpfalse block.end.13328
  clear
  add "stack"
block.end.13328:
testis "G"
jumpfalse block.end.13357
  clear
  add "put"
block.end.13357:
testis "g"
jumpfalse block.end.13386
  clear
  add "get"
block.end.13386:
testis "x"
jumpfalse block.end.13416
  clear
  add "swap"
block.end.13416:
testis ">"
jumpfalse block.end.13444
  clear
  add "++"
block.end.13444:
testis "<"
jumpfalse block.end.13472
  clear
  add "--"
block.end.13472:
testis "m"
jumpfalse block.end.13502
  clear
  add "mark"
block.end.13502:
testis "M"
jumpfalse block.end.13530
  clear
  add "go"
block.end.13530:
testis "r"
jumpfalse block.end.13560
  clear
  add "read"
block.end.13560:
testis "R"
jumpfalse block.end.13591
  clear
  add "until"
block.end.13591:
testis "w"
jumpfalse block.end.13622
  clear
  add "while"
block.end.13622:
testis "W"
jumpfalse block.end.13656
  clear
  add "whilenot"
block.end.13656:
testis "n"
jumpfalse block.end.13687
  clear
  add "count"
block.end.13687:
testis "+"
jumpfalse block.end.13715
  clear
  add "a+"
block.end.13715:
testis "-"
jumpfalse block.end.13743
  clear
  add "a-"
block.end.13743:
testis "0"
jumpfalse block.end.13773
  clear
  add "zero"
block.end.13773:
testis "c"
jumpfalse block.end.13804
  clear
  add "chars"
block.end.13804:
testis "l"
jumpfalse block.end.13835
  clear
  add "lines"
block.end.13835:
testis "^"
jumpfalse block.end.13867
  clear
  add "escape"
block.end.13867:
testis "v"
jumpfalse block.end.13901
  clear
  add "unescape"
block.end.13901:
testis "z"
jumpfalse block.end.13932
  clear
  add "delim"
block.end.13932:
testis "S"
jumpfalse block.end.13963
  clear
  add "state"
block.end.13963:
testis "q"
jumpfalse block.end.13993
  clear
  add "quit"
block.end.13993:
testis "s"
jumpfalse block.end.14024
  clear
  add "write"
block.end.14024:
testis "o"
jumpfalse block.end.14053
  clear
  add "nop"
block.end.14053:
testis "rs"
jumpfalse block.end.14087
  clear
  add "restart"
block.end.14087:
testis "rp"
jumpfalse block.end.14121
  clear
  add "reparse"
block.end.14121:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.14232
  put
  clear
  add "eof*"
  push
  jump parse
block.end.14232:
testis "<==>"
jumpfalse block.end.14290
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.14290:
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
jump block.end.14618
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
block.end.14618:
# show information if these "deprecated" commands are used
testis "Q"
jumptrue 4
testis "bail"
jumptrue 2 
jump block.end.15025
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
block.end.15025:
testis "add"
jumptrue 82
testis "clip"
jumptrue 80
testis "clop"
jumptrue 78
testis "replace"
jumptrue 76
testis "upper"
jumptrue 74
testis "lower"
jumptrue 72
testis "cap"
jumptrue 70
testis "clear"
jumptrue 68
testis "print"
jumptrue 66
testis "state"
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
jump block.end.15426
  put
  clear
  add "word*"
  push
  jump parse
block.end.15426:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop. There is
# no "goto" in java so we need to use labelled loops to 
# implement .reparse/parse>
testis "parse>"
jumpfalse block.end.16085
  clear
  count
  testis "0"
  jumptrue block.end.15929
    clear
    add "script error:\n"
    add "  extra parse> label at line "
    ll
    add ".\n"
    print
    quit
  block.end.15929:
  clear
  add "# parse> parse label"
  put
  clear
  add "parse>*"
  push
  # use accumulator to indicate after parse> label
  a+
  jump parse
block.end.16085:
# --------------------
# implement "begin-blocks", which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.16296
  put
  add "*"
  push
  jump parse
block.end.16296:
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
jump block.end.18036
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
block.end.18036:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.18231
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
block.end.18231:
testis ",*{*"
jumpfalse block.end.18401
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
block.end.18401:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.18590
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
block.end.18590:
testis "!*!*"
jumpfalse block.end.18853
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
block.end.18853:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.19168
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
block.end.19168:
testis ",*command*"
jumpfalse block.end.19344
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
block.end.19344:
testis "!*command*"
jumpfalse block.end.19549
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
block.end.19549:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.19758
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
block.end.19758:
testis "{*}*"
jumpfalse block.end.19892
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.19892:
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.20123
  push
  push
  add "error near line "
  ll
  add " of script:\n  classes ([a-z], [:space:] etc). \n"
  add "  cannot use the 'begin' or 'end' modifiers (B/E) \n"
  print
  clear
  quit
block.end.20123:
testis "comment*{*"
jumpfalse block.end.20315
  push
  push
  add "error near line "
  ll
  add " of script: comments cannot occur between \n"
  add " a test and a brace ({). \n"
  print
  clear
  quit
block.end.20315:
testis "}*command*"
jumpfalse block.end.20465
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.20465:

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
jumpfalse block.end.22038
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.21505
    clear
    count
    # this is the opposite of .reparse, using run-once loops
    # cant do next before label, infinite loop.
    # need to set flag variable. There is a subtlety: .restart can
    # exist without parse> (although it would be unusual). 
    # before (or without) the parse> label
    testis "0"
    jumpfalse block.end.21373
      clear
      # use the comment '# restart' so we can replace
      # this with 'break' if the parse> label appears later
      add "restart = 1; next; # restart"
    block.end.21373:
    testis "1"
    jumpfalse block.end.21410
      clear
      add "break"
    block.end.21410:
    # after the parse> label
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21505:
  testis "reparse"
  jumpfalse block.end.21825
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.21724
      clear
      add "break"
    block.end.21724:
    testis "1"
    jumpfalse block.end.21757
      clear
      add "next"
    block.end.21757:
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21825:
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
block.end.22038:
#---------------------------------
# Compiling comments so as to transfer them to the java 
testis "comment*command*"
jumptrue 6
testis "command*comment*"
jumptrue 4
testis "commandset*comment*"
jumptrue 2 
jump block.end.22289
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
block.end.22289:
testis "comment*comment*"
jumpfalse block.end.22403
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
block.end.22403:
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
jump block.end.23201
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
block.end.23201:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.23707
  clear
  add "endtext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.23664
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
  block.end.23664:
  --
  put
  ++
  clear
  jump parse
block.end.23707:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.24254
  clear
  add "begintext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.24211
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
  block.end.24211:
  --
  put
  ++
  clear
  jump parse
block.end.24254:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.27520
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
  jump block.end.24820
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
  block.end.24820:
  testis "clip"
  jumpfalse block.end.25019
    clear
    add "if (!$mm->{'work'} == '') {       # clip \n"
    add "  $mm->{'work'} = substr($mm->{'work'}, 1, -2);   # clip \n"
    add "}"
    put
  block.end.25019:
  # check indices
  testis "clop"
  jumpfalse block.end.25234
    clear
    add "if ($mm->{'work'} ne '') {       # clop \n"
    add "  $mm->{'work'} = substr($mm->{'work'},0,-1);  # clop \n"
    add "}"
    put
  block.end.25234:
  testis "clear"
  jumpfalse block.end.25305
    clear
    add "$mm->{'work'} = '';        # clear"
    put
  block.end.25305:
  testis "upper"
  jumpfalse block.end.25385
    clear
    add "$mm->{'work'} = uc($mm->{'work'});  # upper"
    put
  block.end.25385:
  testis "lower"
  jumpfalse block.end.25465
    clear
    add "$mm->{'work'} = lc($mm->{'work'});  # lower"
    put
  block.end.25465:
  testis "cap"
  jumpfalse block.end.25538
    clear
    add "$mm->{'work'} .capitalize! # capital"
    put
  block.end.25538:
  testis "print"
  jumpfalse block.end.25609
    clear
    add "print $mm->{\"work\"};       # print"
    put
  block.end.25609:
  testis "state"
  jumpfalse block.end.25680
    clear
    add "$mm->printState();         # state"
    put
  block.end.25680:
  testis "pop"
  jumpfalse block.end.25731
    clear
    add "$mm->popToken();"
    put
  block.end.25731:
  testis "push"
  jumpfalse block.end.25784
    clear
    add "$mm->pushToken();"
    put
  block.end.25784:
  testis "unstack"
  jumpfalse block.end.25876
    clear
    add "while ($mm->popToken()) { next; }  # unstack "
    put
  block.end.25876:
  testis "stack"
  jumpfalse block.end.25964
    clear
    add "while ($mm->pushToken()) { next; } # stack "
    put
  block.end.25964:
  testis "put"
  jumpfalse block.end.26067
    clear
    add "$mm->{'tape'}[$mm->{'cell'}] = $mm->{'work'};   # put "
    put
  block.end.26067:
  testis "get"
  jumpfalse block.end.26168
    clear
    add "$mm->{'work'} .= $mm->{'tape'}[$mm->{'cell'}];  # get"
    put
  block.end.26168:
  testis "swap"
  jumpfalse block.end.26338
    clear
    add "$mm->{'work'}, $mm->{'tape'}[$mm->{'cell'}] = \n"
    add "  $mm->{'tape'}[$mm->{'cell'}], $mm->{'work'}    # swap "
    put
  block.end.26338:
  testis "++"
  jumpfalse block.end.26399
    clear
    add "$mm->increment();      # ++"
    put
  block.end.26399:
  testis "--"
  jumpfalse block.end.26496
    clear
    add "if ($mm->{'cell'} > 0) { $mm->{'cell'} -= 1; } # --"
    put
  block.end.26496:
  testis "read"
  jumpfalse block.end.26564
    clear
    add "$mm->readChar();         # read"
    put
  block.end.26564:
  testis "count"
  jumpfalse block.end.26656
    clear
    add "$mm->{'work'} .= $mm->{'counter'};     # count "
    put
  block.end.26656:
  testis "a+"
  jumpfalse block.end.26722
    clear
    add "$mm->{'counter'} += 1;  # a+ "
    put
  block.end.26722:
  testis "a-"
  jumpfalse block.end.26788
    clear
    add "$mm->{'counter'} -= 1;  # a- "
    put
  block.end.26788:
  testis "zero"
  jumpfalse block.end.26856
    clear
    add "$mm->{'counter'} = 0;   # zero "
    put
  block.end.26856:
  testis "chars"
  jumpfalse block.end.26938
    clear
    add "$mm->{'work'} .= $mm->{'charsRead'}; # chars "
    put
  block.end.26938:
  testis "lines"
  jumpfalse block.end.27020
    clear
    add "$mm->{'work'} .= $mm->{'linesRead'}; # lines "
    put
  block.end.27020:
  testis "nochars"
  jumpfalse block.end.27103
    clear
    add "$mm->{'charsRead'} = 0;           # nochars "
    put
  block.end.27103:
  testis "nolines"
  jumpfalse block.end.27186
    clear
    add "$mm->{'linesRead'} = 0;           # nolines "
    put
  block.end.27186:
  # use a labelled loop to quit script.
  testis "quit"
  jumpfalse block.end.27272
    clear
    add "exit();"
    put
  block.end.27272:
  # inline this?
  testis "write"
  jumpfalse block.end.27366
    clear
    add "File->write('sav.pp', $mm->{'work'} )"
    put
  block.end.27366:
  # convert to "pass" which does nothing. 
  testis "nop"
  jumpfalse block.end.27466
    clear
    add "# nop: no-operation"
    put
  block.end.27466:
  clear
  add "command*"
  push
  jump parse
block.end.27520:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.27844
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
block.end.27844:
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
jump block.end.29158
  testbegins "begin"
  jumpfalse block.end.28339
    clear
    add "$mm->{'work'} =~ /^"
  block.end.28339:
  testbegins "end"
  jumpfalse block.end.28394
    clear
    add "$mm->{'work'} .end_with?("
  block.end.28394:
  testbegins "quote"
  jumpfalse block.end.28444
    clear
    add "$mm->{'work'}  == "
  block.end.28444:
  testbegins "class"
  jumpfalse block.end.28549
    clear
    add "$mm->{'work'} =~ /"
    # unicode categories are also regexs 
  block.end.28549:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.28686
    clear
    put
    add "$mm->{'eof'}"
  block.end.28686:
  testbegins "tapetest"
  jumpfalse block.end.28791
    clear
    put
    add "$mm->{'work'}  == $mm->{'tape'}[$mm->{'cell'}]"
  block.end.28791:
  get
  # a hack
  #B"mm.work.match?" { add ')'; }
  testbegins "$mm->{'eof'}"
  jumptrue 3
  testbegins "$mm->{'work'} =="
  jumpfalse 2 
  jump block.end.28905
    add ")"
  block.end.28905:
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
block.end.29158:
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
jump block.end.30311
  testbegins "notbegin"
  jumpfalse block.end.29642
    clear
    add "$mm->{'work'} !~ /^"
  block.end.29642:
  testbegins "notend"
  jumpfalse block.end.29701
    clear
    add "!$mm->{'work'} .end_with?("
  block.end.29701:
  testbegins "notquote"
  jumpfalse block.end.29753
    clear
    add "$mm->{'work'} != "
  block.end.29753:
  testbegins "notclass"
  jumpfalse block.end.29866
    clear
    add "!$mm->{'work'} .match?("
    # ruby unicode categories are regexs 
  block.end.29866:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.30006
    clear
    put
    add "!$mm->{'eof')"
  block.end.30006:
  testbegins "nottapetest"
  jumpfalse block.end.30107
    clear
    put
    add "$mm->{'work'}  != $mm->{'tape'}[$mm->{'cell'}]"
  block.end.30107:
  get
  testbegins "!$mm->{'eof'}"
  jumptrue 3
  testbegins "$mm->{'work'}  !="
  jumpfalse 2 
  jump block.end.30174
    add ")"
  block.end.30174:
  put
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.30311:
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
jump block.end.30788
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
block.end.30788:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.30984
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.30984:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.31451
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
block.end.31451:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.36079
  clear
  get
  testis "replace"
  jumpfalse block.end.31794
    # error 
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.31794:
  # check whether argument is single character, otherwise
  # throw an error. Also, check that argument is not empty
  # eg "". Its probably silly to allow while/while not to
  # have a quote argument, since the same can be achieved with
  # >> while [a]; etc
  testis "escape"
  jumptrue 8
  testis "unescape"
  jumptrue 6
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.33014
    # This is trickier than I thought it would be.
    clear
    ++
    get
    --
    # check that arg not empty, (but an empty quote is ok 
    # for the second arg of 'replace'
    testis "\"\""
    jumpfalse block.end.32534
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
    block.end.32534:
    # quoted text has the quotes still around it.
    # also handle escape characters like \n \r etc
    # this needs to be better
    clip
    clop
    clop
    clop
    # B "\\" { clip; } 
    clip
    testis ""
    jumptrue block.end.32990
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
    block.end.32990:
    clear
    get
  block.end.33014:
  testis "mark"
  jumpfalse block.end.33168
    clear
    add "$mm->{'marks'}[$mm->{'cell] = "
    ++
    get
    --
    add " # mark"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33168:
  testis "go"
  jumpfalse block.end.33304
    clear
    add "goToMark($mm, "
    ++
    get
    --
    add ")  # go"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33304:
  testis "delim"
  jumpfalse block.end.33508
    clear
    # the delimiter should be a single character, no?
    add "$mm->{'delimiter'} = "
    ++
    get
    --
    add " # delim "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33508:
  testis "add"
  jumpfalse block.end.33749
    clear
    add "$mm->{'work'} .= "
    ++
    get
    --
    add ";"
    # handle multiline text
    # check this! \\n or \n
    replace "\n" "\"\n$mm->{\"work\"} .= \"\\n"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33749:
  testis "while"
  jumpfalse block.end.33996
    clear
    add "while ($mm->{'peep'} == "
    ++
    get
    --
    add ");   # while \n"
    add "  if ($mm->{'eof'}) { break; }\n  $mm->readChar();\n"
    add "}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33996:
  testis "whilenot"
  jumpfalse block.end.34226
    clear
    add "while $mm->{'peep'} != "
    ++
    get
    --
    add ";   # whilenot \n"
    add "  if ($mm->{'eof'}) { break; }\n  read(%mm);\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34226:
  testis "until"
  jumpfalse block.end.34831
    clear
    add "$mm->until("
    ++
    get
    --
    # error until cannot have empty argument
    testis "$mm->until(\"\""
    jumpfalse block.end.34695
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
    block.end.34695:
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34831:
  testis "escape"
  jumpfalse block.end.35474
    clear
    ++
    # argument still has quotes around it
    # it should be a single character since this has been previously
    # checked.
    get
    clip
    clop
    put
    clear
    # A strange ruby fact: gsub("'", "\\'") doesnt work
    # but gsub("'", "\\\\'") does. Hence the hack below
    add "$mm->{\"work\"} =~ s/\""
    get
    add "\"/\""
    # a hack, for the quirk above, but this hack will not work
    # if mm.escape != '\\'
    testends "\"\'\", \""
    jumpfalse block.end.35356
      add "$mm->{'escape'}"
    block.end.35356:
    add "#{$mm->{\"escape\"}"
    get
    add "\")  # escape"
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35474:
  # replace \n with n for example (only 1 character)
  testis "unescape"
  jumpfalse block.end.35888
    clear
    ++
    # unescape is not trivial, need to walk the string
    # hence the method rather than one-liner
    #add 'mm.unescapeChar('; get; add ')  # unescape'; 
    add "$mm->{\"work\"} =~ s/$mm->{\"escape\"}+"
    get
    add ", "
    get
    add ")  # escape"
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35888:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.36079:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.36920
  clear
  get
  testis "while"
  jumpfalse block.end.36511
    clear
    add "# while  \n"
    # the ruby pat.match? method should be faster than others
    add "while "
    ++
    get
    --
    add ".match?($mm->{'peep)\n"
    add "  if $mm->{'eof { break }\n  mm->read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36511:
  testis "whilenot"
  jumpfalse block.end.36767
    clear
    add "# whilenot  \n"
    add "while !"
    ++
    get
    --
    add ".match?($mm->{'peep)\n"
    add "  if $mm->{'eof { break }\n"
    add "  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36767:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.36920:
# arrange the parse> label loops
# also, change .restart code before the parse label
testeof 
jumpfalse block.end.37995
  testis "commandset*parse>*commandset*"
  jumptrue 8
  testis "command*parse>*commandset*"
  jumptrue 6
  testis "commandset*parse>*command*"
  jumptrue 4
  testis "command*parse>*command*"
  jumptrue 2 
  jump block.end.37991
    clear
    # indent both code blocks
    add "  "
    get
    replace "\n" "\n  "
    # change .restart code before parse> label
    replace "next # restart" "break; # restart"
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
    add "\n# lex block \n"
    add "while 1 {\n"
    get
    add "\n  break;\n}\n"
    ++
    ++
    add "if (restart) { restart = 0; next; }\n"
    # indent code block
    # add "  "; get; replace "\n" "\n  "; put; clear;
    # ruby doesnt support labelled loops (but swift does, and go?)
    # add "parse: \n";
    add "\n# parse block \n"
    add "while 1 {\n"
    get
    add "\n  break \n} # parse\n"
    --
    --
    put
    clear
    add "commandset*"
    push
    jump parse
  block.end.37991:
block.end.37995:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# bnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.38795
  clear
  get
  testis "replace"
  jumpfalse block.end.38626
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    clear
    add "# replace \n"
    add "if ($mm->{'work'} == \"\") { \n"
    add "  $mm->{'work'} .gsub!("
    ++
    get
    add ", "
    ++
    get
    add ")\n }\n"
    --
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.38626:
  add "Pep script error on line "
  ll
  add " (character "
  cc
  add "): \n"
  add "  command does not take 2 quoted arguments. \n"
  print
  quit
block.end.38795:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.39179
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
block.end.39179:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# these 2 tests should be all that is necessary
testis "test*,*ortestset*{*"
jumptrue 4
testis "test*,*test*{*"
jumptrue 2 
jump block.end.39523
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
block.end.39523:
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
jump block.end.40092
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
block.end.40092:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.40676
  clear
  # indent the code for readability
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
  # block end required
  add "\n}"
  --
  --
  put
  clear
  add "command*"
  push
  # always reparse/compile
  jump parse
block.end.40676:
# -------------
# multi-token end-of-stream errors
# not a comprehensive list of errors...
testeof 
jumpfalse block.end.41471
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
  jump block.end.40986
    add "  Error near end of script at line "
    ll
    add ". Test with no brace block? \n"
    print
    clear
    quit
  block.end.40986:
  testends "quote*"
  jumptrue 6
  testends "class*"
  jumptrue 4
  testends "word*"
  jumptrue 2 
  jump block.end.41211
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
  block.end.41211:
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
  jump block.end.41467
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
  block.end.41467:
block.end.41471:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.50440
  print
  clear
  add "#!/usr/bin/perl\n"
  add "use strict;\n"
  add "  # create the virtual machine object code and save it\n"
  add "  # somewhere on the tape.\n"
  add "\n"
  add "  # code generated by \"translate.perl.pss\" a pep script\n"
  add "  # see http://bumble.sf.net/books/pars/tr/\n"
  add "  # require something\n"
  add "\n"
  add "  # mm is the machine object. I will just use an associative array\n"
  add "  # instead of an object. This approach is also used in the tcl translator\n"
  add "  # tr/translate.tcl.pss\n"
  add "package Machine;\n"
  add "\n"
  add "  sub new {\n"
  add "    my $class = shift;  # \n"
  add "\n"
  add "    my $self = {\n"
  add "      size => 300,      # how many initial elements in tape/marks array\n"
  add "      eof => 0,         # end of stream reached?\n"
  add "      charsRead => 0,   # how many chars already read\n"
  add "      linesRead => 1,   # how many lines already read\n"
  add "      escape => \"\\\\\",\n"
  add "      delimiter => \"*\", # push/pop delimiter (default \"*\")\n"
  add "      counter => 0,     # a counter for anything\n"
  add "      work => \"\",       # the workspace\n"
  add "      stack => (),      # stack for parse tokens \n"
  add "      cell => 0,                # current tape cell\n"
  add "      tape => (),       # a list of attribute for tokens \n"
  add "      marks => (),      # marked tape cells \n"
  add "      # or dont initialse peep until \"parse()\" calls \"setInput()\"\n"
  add "      #todo\n"
  add "      peep => \"\" \n"
  add "    };\n"
  add "\n"
  add "\n"
  add "    $self->{\"peep\"} = getc(STDIN);\n"
  add "    #$self->{\"tape\"} = 100;\n"
  add "    #$self->{\"marks\"} = 100;\n"
  add "    $self->{\"tape\"} = (\"\") x 100;\n"
  add "    $self->{\"marks\"} = (\"\") x 100;\n"
  add "    $self->{\"size\"} = 100;\n"
  add "    # or use this, which may not duplicate the references\n"
  add "    # $my @arr = map { [] } 1..100;\n"
  add "    # set up the machine? \n"
  add "    # peep => getc(STDIN); \n"
  add "    bless $self, $class;\n"
  add "    return $self;\n"
  add "  }\n"
  add "\n"
  add "  # if (@tape < 5) check if length of tape is 4 or less\n"
  add "  sub setInput {\n"
  add "    my $self = shift;   # pointer to the machine\n"
  add "    my $newInput = shift; \n"
  add "    print \"to be implemented\";\n"
  add "  }\n"
  add "\n"
  add "  # read one character from the input stream and \n"
  add "  #    update the machine.\n"
  add "  sub readChar {\n"
  add "    my $self = shift;   # the Machine object\n"
  add "    if ($self->{\"eof\"}) { exit; }\n"
  add "    $self->{\"charsRead\"} += 1;\n"
  add "    # increment lines\n"
  add "    if ($self->{\"peep\"} == \"\\n\") { $self->{\"linesRead\"} += 1; }\n"
  add "    $self->{\"work\"} .= $self->{\"peep\"};\n"
  add "    $self->{\"peep\"} = getc(STDIN);\n"
  add "    #check\n"
  add "    if (eof(STDIN)) { $self->{\"eof\"} = 1; }\n"
  add "  }\n"
  add "\n"
  add "  # test if all chars in workspace are in unicode category\n"
  add "  sub isInCategory {\n"
  add "    my $self = shift;   # pointer to the machine\n"
  add "    my $cat = shift; \n"
  add "    #for ch in $self->{\"work\"}\n"
  add "    #  if not category(ch).start_with?(cat) then return false end\n"
  add "    #return True\n"
  add "  }\n"
  add "\n"
  add "  # this needs to actually walk the string\n"
  add "  # eg \"ab\cab\\cab\c\"\n"
  add "  # not trivial\n"
  add "  sub unescapeChar {\n"
  add "    my $self = shift;   # the machine\n"
  add "    my $c = shift;\n"
  add "    # check\n"
  add "    $self->{\"work\"} =~ s/\\Q$self->{\"escape\"}$c/$c/;\n"
  add "  }\n"
  add "\n"
  add "  # add escape character : trivial?\n"
  add "  sub escapeChar {\n"
  add "    my $self = shift;   # the machine\n"
  add "    my $c = shift;\n"
  add "    $self->{\"work\"} =~ s/$c/\\Q$self->{\"escape\"}$c/;\n"
  add "  }\n"
  add "\n"
  add "  # a helper for the multiescape until bug\n"
  add "  sub countEscaped {\n"
  add "    my $self = shift;   # the machine\n"
  add "    my $suffix = shift; \n"
  add "    my $count = 0;\n"
  add "    # no check\n"
  add "    my $s = $self->{\"work\"};\n"
  add "    $s =~ s/$suffix$//;\n"
  add "    while ($s =~ /$self->{\"escape\"}$/) {\n"
  add "      $count += 1;\n"
  add "      $s =~ s/$self->{\"escape\"}$//;\n"
  add "    }\n"
  add "    return $count;\n"
  add "  }\n"
  add "\n"
  add "  # reads the input stream until the workspace end with text \n"
  add "  sub until {\n"
  add "    my $self = shift;   # the machine\n"
  add "    my $suffix = shift; \n"
  add "    # read at least one character\n"
  add "    if ($self->{\"eof\"}) { return; }\n"
  add "    # pass a reference to the machine hash with \% not %\n"
  add "    $self->readChar();\n"
  add "    while (1) { \n"
  add "      if ($self->{\"eof\"}) { return; }\n"
  add "      # need to count the @escape chars preceding suffix\n"
  add "      # if odd, keep reading, if even, stop\n"
  add "      if ($self->{\"work\"} =~ /\Q$suffix$/) { \n"
  add "        if ($self->countEscaped($suffix) % 2 == 0) { return; }\n"
  add "      }\n"
  add "      $self->readChar()\n"
  add "    }\n"
  add "  }  \n"
  add "\n"
  add "  # this implements the ++ command incrementing the tape pointer\n"
  add "  # and growing the tape and marks arrays if required\n"
  add "  sub increment {\n"
  add "    my $self = shift;   # the machine\n"
  add "    $self->{\"cell\"} += 1;\n"
  add "    if ($self->{\"cell\"} >= $self->{\"tape\"}) { \n"
  add "      # lengthen the tape and marks arrays by assigning to\n"
  add "      # length var\n"
  add "      $self->{\"tape\"} = $self->{\"tape\"} + 40;\n"
  add "      $self->{\"marks\"} = $self->{\"marks\"} + 40;\n"
  add "      $self->{\"size\"} = $self->{\"tape\"};\n"
  add "    }\n"
  add "  }\n"
  add "\n"
  add "  # pop the first token from the stack into the workspace */\n"
  add "  sub popToken {\n"
  add "    my $self = shift;   # the machine, not local\n"
  add "    if (!$self->{\"stack\"}) { return 0; }\n"
  add "    $self->{\"work\"} = pop(@{$self->{\"stack\"}}) + $self->{\"work\"};\n"
  add "    if ($self->{\"cell\"} > 0) { $self->{\"cell\"} -= 1; }\n"
  add "    return 1;\n"
  add "  }\n"
  add "\n"
  add "  # push the first token from the workspace to the stack \n"
  add "  sub pushToken {\n"
  add "    my $self = shift;   # a pointer to the machine\n"
  add "    # dont increment the tape pointer on an empty push\n"
  add "    if ($self->{\"work\"} == \"\") { return 0; }\n"
  add "    # need to get this from the delimiter.\n"
  add "    my $iFirst = index($self->{\"work\"}, $self->{\"delimiter\"});\n"
  add "    if ($iFirst == -1 ) {\n"
  add "      push(@{$self->{\"stack\"}}, $self->{\"work\"}); \n"
  add "      $self->{\"work\"} = \"\"; return 1;\n"
  add "    }\n"
  add "    # s[i..j] means all chars from i to j\n"
  add "    # s[i,n] means n chars from i\n"
  add "    push(@{$self->{\"stack\"}}, substr($self->{\"work\"}, 0, $iFirst));\n"
  add "    $self->{\"work\"} = substr($self->{\"work\"}, $iFirst+1, -1);\n"
  add "    $self->increment();\n"
  add "    return 1;\n"
  add "  }\n"
  add "\n"
  add "  sub printState {\n"
  add "   # print \"Stack[#{@self{\\"stack\\"}.join(, )}] Work[#{$self->{\\"work\\"}}] Peep[#{$self->{\\"peep\\"}}]\"\n"
  add "   # print \"Acc:#{$self->{\"counter\"}} Esc:#{$self->{\"escape\"}} Delim:#{$self->{\"delimiter\"}} Chars:#{$self->{\"charsRead\"}}\" +\n"
  add "   #      \" Lines:#{$self->{\"linesRead\"}} Cell:#{$self->{\"cell\"}}\"\n"
  add "  }\n"
  add "\n"
  add "  sub goToMark {\n"
  add "    my $self = shift;   # a pointer to the machine\n"
  add "    my $mark = shift; \n"
  add "    # search the marks \n"
  add "    for my $ii (0..$self->{\"marks\"}) {\n"
  add "      if (@{$self->{\"marks\"}}[$ii] eq $mark) {\n"
  add "        $self->{\"cell\"} = $ii; \n"
  add "        return;\n"
  add "      }\n"
  add "    }\n"
  add "    # mark was not found- fatal error!\n"
  add "    print(\"bad mark $mark!\");\n"
  add "    exit();\n"
  add "  }\n"
  add "\n"
  add "\n"
  add "  # this is where the actual parsing/compiling code should go\n"
  add "  # so that it can be used by other perl classes/objects. Also\n"
  add "  # should have a stream argument.\n"
  add "  sub parse {\n"
  add "    my $self = shift;  # a machine reference\n"
  add "    my $s = shift;\n"
  add "    # this was causing a strange bug in the compiler, \n"
  add "    # when there was no space between the quotes. \"unterminated quote\"\n"
  add "    print(\" \");\n"
  add "  } \n"
  add "\n"
  add "# end of Machine methods definition\n"
  add "\n"
  add "# will become:\n"
  add "# mm.parse(sys.stdin)  or \n"
  add "# mm.parse(\"abcdef\") or\n"
  add "# open f; mm.parse(f)\n"
  add "# the restart flag, which allows .restart to work before the \n"
  add "# parse label, in languages (like ruby) that dont have \n"
  add "# labelled loops\n"
  add "my $restart = 0;\n"
  add "my $mm = Machine->new(); \n"
  add "\n "
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
  jump block.end.49012
    clear
    # indent generated code (6 spaces) for readability.
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    # restore the java preamble from the tape
    ++
    get
    --
    #add 'script: \n';
    add "while (!$mm->{\"eof\"}) { \n"
    get
    # end block marker required in perl
    add "\n}\n"
    add "\n\n# end of generated code\n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    print
    clear
    quit
  block.end.49012:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.49749
    clear
    # indentation not needed here 
    #add ""; get; 
    #replace "\n" "\n"; put; clear; 
    # indent main code for readability.
    ++
    add "  "
    get
    replace "\n" "\n  "
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
    #add "script: \n";
    add "while (!$mm->{'eof'}) { \n"
    get
    # end block marker required in perl
    add "\n}\n"
    add "\n\n# end of generated code\n"
    # put a copy of the final compilation into the tapecell
    # for interactive debugging.
    put
    print
    clear
    quit
  block.end.49749:
  push
  push
  # try to explain some more errors
  unstack
  testbegins "parse>"
  jumpfalse block.end.50015
    put
    clear
    add "[error] pep syntax error:\n"
    add "  The parse> label cannot be the 1st item \n"
    add "  of a script \n"
    print
    quit
  block.end.50015:
  put
  clear
  clear
  add "After compiling with 'translate.perl.pss' (at EOF): \n "
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
block.end.50440:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
