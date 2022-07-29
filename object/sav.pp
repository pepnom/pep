# Assembled with the script 'compile.pss' 
start:
 
#
#   tr/translate.c.pss 
#   
#   This is a parse-script which translates parse-scripts into c
#   code, using the 'pep' tool. The script creates a standalone 
#   compilable c program.
#   
#   The virtual machine and engine is implemented in plain c at
#   http://bumble.sf.net/books/pars/pep.c. This implements a script language
#   with a syntax reminiscent of sed and awk (much simpler than awk, but
#   more complex than sed).
#   
#STATUS 
#
#   july 2022
#     testing with pep.trtest c is mainly working 1st and 2nd gen  
#
#NOTES
#    
#   Or use goto for restart, reparse
#   We use labelled loops and break/continue to implement the 
#   parse> label and .reparse .restart commands. Breaks are also
#   used to implement the quit and bail commands.
#
#TODO
#
#   Parse [...] tests into ranges a-z lists abcd and classes :alnum:
#   and then call the appropriate c function (not the general function
#   workspaceInClassType)
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
#   tr/translate.tcl.pss
#     A very similar script for compiling scripts into tcl
#
#   translate.py.pss
#     A script translator for python.
#
#   compile.pss
#     compiles a script into an "assembly" format that can be loaded
#     and run on the parse-machine with the -a  switch. This performs
#     the same function as "asm.pp" 
#
#TESTING
#
#  Use the pep.tt function in helpers.pars.sh to extensively test
#  1st and 2nd generation. This uses the test input in tr.test.txt
#
#  Things to test: .restart .reparse before and after parse>
#  mark/go. Multiline add.
#
#  try eg/natural.language.pss 
#
#  Not working below because [-] doesnt parse well.
#
#  * try
#  ----
#    pep -f translate.c.pss eg/mark.latex.pss > eg/c/mark.latex.c
#    gcc mark.latex.c; chmod a+x a.out
#    cat pars-book.txt | ./a.out 
#  ,,,,
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
#  When translating eg/mark.latex.pss into c and running on pars-book.txt
#  code blocks are not being recognised (i.e between ---- and ,,,, )
#  This is caused by [-] { ... } not translating properly- or a 
#  bug in the c function "workspaceInClass"
#
#  Segmentation fault when the tape gets too big, as would be expected.
#
#  Still getting "malloc" error with pep.cff lines.with.pss lines.with.pss 
#  The c translation doesn't work with eg/lines.with.pss There is
#  a reference to "machine->tapePointer" which is incorrect.
#  "nottapetest" was wrong
#
#  This test [\]abc] crashes the c translator because c wont accept
#  \] as an escape sequence.
#
#  "Unescape" wont work because the function expects a parameter, not a char.
#  See escapeChar in machine.methods.c for the solution to that.
#
#  Doing pep.cf eg/multiline produces nothing! no output. mysterious
#  bug. After stepping through with -I switch it started to work!
#
#  problems with while/whilenot, probably need different code 
#  for [a-z] and [[:alpha:]] style tests, no?
#
#  Are multiline strings allowed in replace and other commands? or 
#  only in "add"
#
#  The parse label parse> just after the begin block, or after all
#  commands crashes the script. This bug probably exists in all the 
#  translation scripts.
#
#  Its a bit strange to talk about a multicharacter string being "escaped"
#  (eg when calling 'until') but this is allowed in the pep engine.
#
#  add "\{"; will generate an "illegal escape character" error
#  when trying to compile the generated c code. I need to 
#  consider what to do in this situation (eg escape \ to \\ ?)
#
#  Check "go/mark" code. what happens if the mark is not found?? 
#  The script should exit with an error if the mark is not found. 
#  Need a "goToMark()" function.
#
#SOLVED BUGS
# 
#  unstack goes into an eternal loop, just like tr.tcl.pss did as well.
#
#  found and fixed a bug in java whilenot/while. The code exits if the 
#  character is not found, which is not correct.
#
#  The "delimiter" character was hardcoded in push.
#  Solved an "until" bug where the java code did not read 
#  at least one character.
#
#HISTORY
#    
#  19 jul 2022
#    Revising. The way that [] is parsed is not good and doesn't work with
#    [-]{...} for example. It needs to be rewritten.
#
#  20 aug 2021
#    1st and 2nd gen working.
#    continuing to debug, wrote escapeChar to make escape command work
#    and recompiled libmachine. 
#
#  18 july 2021
#    more debugging of while/whilenot. eg/natural.language.pss
#    appears to translate, compile and run.
#
#  17 july 2021
#    rewriting the while/whilenot code for classes, much more
#    efficient now. But need to write some error checking.
#
#  14 july 2021
#
#    checked the 'until' code in the methods file, update to the same
#    as machine.parse.c (in exec)
#
#    wrote some helper scripts in helpers.pars.sh which translate scripts into
#    c, compile them into eg/clang/, and run them with input. Some very simple
#    scripts are compiling and running. The bash function peplib compiles the
#    library archive required to compile the standalone executable.
#
#  10 july 2021
#    
#    Began to adapt from the java translator
#
#
read
#--------------
# in general, just ignore space
testclass [:space:]
jumpfalse block.end.5732
  # reset char counter each line, so that character counter is
  # relative to the current line. This is helpful for syntax error
  # messages.
  testclass [\n]
  jumpfalse block.end.5688
    nochars
  block.end.5688:
  clear
  testeof 
  jumptrue block.end.5719
    jump start
  block.end.5719:
  jump parse
block.end.5732:
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
jump block.end.6168
  put
  add "*"
  push
  jump parse
block.end.6168:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.6621
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
  jumptrue block.end.6563
    clear
    add "Unterminated quote character (\") starting at "
    get
    add " !\n"
    print
    quit
  block.end.6563:
  put
  clear
  add "quote*"
  push
  jump parse
block.end.6621:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.7300
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
  jumptrue block.end.7085
    clear
    add "Unterminated quote (') starting at "
    get
    add "!\n"
    print
    quit
  block.end.7085:
  clip
  escape "\""
  # unescape isnt implemented in machine.methods.c hence this hack
  replace "\\'" "'"
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
block.end.7300:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
# should class tests really be multiline??!
testis "["
jumpfalse block.end.10958
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
  jumpfalse block.end.7824
    clear
    add "pep script error at line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty character class [] \n"
    print
    quit
  block.end.7824:
  testends "]"
  jumptrue block.end.8111
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
  block.end.8111:
  # need to escape quotes so they dont interfere with the
  # enclosing quotes. 
  escape "\""
  # the caret is not a negation operator in pep scripts
  # but the c code doesnt use regexs so should need to escape
  # it.
  #replace "^" "\\\\^";
  # save the class on the tape
  put
  clop
  clop
  testbegins "-"
  jumptrue block.end.8569
    # not a range class, eg [a-z] so need to escape '-' chars
    clear
    get
    #replace '-' '\\-'; 
    put
  block.end.8569:
  testbegins "-"
  jumpfalse block.end.8957
    # a range class, eg [a-z], check if it is correct
    clip
    clip
    testis "-"
    jumptrue block.end.8951
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
    block.end.8951:
  block.end.8957:
  clear
  get
  # restore class text
  testbegins "[:"
  jumpfalse 3
  testends ":]"
  jumpfalse 2 
  jump block.end.9122
    clear
    add "malformed character class starting at "
    get
    add "!\n"
    print
    quit
  block.end.9122:
  testbegins "[:"
  jumpfalse 3
  testis "[:]"
  jumpfalse 2 
  jump block.end.10220
    clip
    clip
    clop
    clop
    # use c type functions in c
    # Also, abbreviations (not implemented in gh.c yet.)
    testis "alnum"
    jumptrue 4
    testis "N"
    jumptrue 2 
    jump block.end.9307
      clear
      add ":alnum"
    block.end.9307:
    testis "alpha"
    jumptrue 4
    testis "A"
    jumptrue 2 
    jump block.end.9350
      clear
      add ":alpha"
    block.end.9350:
    testis "ascii"
    jumptrue 4
    testis "I"
    jumptrue 2 
    jump block.end.9393
      clear
      add ":ascii"
    block.end.9393:
    testis "blank"
    jumptrue 4
    testis "B"
    jumptrue 2 
    jump block.end.9436
      clear
      add ":blank"
    block.end.9436:
    testis "cntrl"
    jumptrue 4
    testis "C"
    jumptrue 2 
    jump block.end.9479
      clear
      add ":cntrl"
    block.end.9479:
    testis "digit"
    jumptrue 4
    testis "D"
    jumptrue 2 
    jump block.end.9522
      clear
      add ":digit"
    block.end.9522:
    testis "graph"
    jumptrue 4
    testis "G"
    jumptrue 2 
    jump block.end.9565
      clear
      add ":graph"
    block.end.9565:
    testis "lower"
    jumptrue 4
    testis "L"
    jumptrue 2 
    jump block.end.9608
      clear
      add ":lower"
    block.end.9608:
    testis "print"
    jumptrue 4
    testis "P"
    jumptrue 2 
    jump block.end.9651
      clear
      add ":print"
    block.end.9651:
    testis "punct"
    jumptrue 4
    testis "T"
    jumptrue 2 
    jump block.end.9694
      clear
      add ":punct"
    block.end.9694:
    testis "space"
    jumptrue 4
    testis "S"
    jumptrue 2 
    jump block.end.9737
      clear
      add ":space"
    block.end.9737:
    testis "upper"
    jumptrue 4
    testis "U"
    jumptrue 2 
    jump block.end.9780
      clear
      add ":upper"
    block.end.9780:
    testis "xdigit"
    jumptrue 4
    testis "X"
    jumptrue 2 
    jump block.end.9825
      clear
      add ":xdigit"
    block.end.9825:
    testbegins ":"
    jumptrue block.end.10065
      put
      clear
      add "[error] Pep script syntax error near line "
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
    block.end.10065:
    # the workspaceInClassType function in machine.methods.c
    # can handle classes ranges and lists
    put
    clear
    add "["
    get
    add ":]"
  block.end.10220:
  
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
  # (must match the whole string, not just one character)
  #add '"'; get; add '"'; put; clear;
  add "class*"
  push
  jump parse
block.end.10958:
#---------------
# formats: (eof) (EOF) (==) etc. 
testis "("
jumpfalse block.end.11429
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.11112
    clear
    add "eof*"
    push
    jump parse
  block.end.11112:
  testis "=="
  jumpfalse block.end.11165
    clear
    add "tapetest*"
    push
    jump parse
  block.end.11165:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.11429:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.12564
  clear
  read
  testis "\n"
  jumpfalse block.end.11565
    clear
    jump parse
  block.end.11565:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.12409
    # save the line number for possible error message later
    clear
    ll
    put
    clear
    until "*#"
    testends "*#"
    jumpfalse block.end.12154
      # convert to /* ... */ c multiline comment
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
      # compiled c.
      # add "comment*"; push; 
      jump parse
    block.end.12154:
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
  block.end.12409:
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
block.end.12564:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.12951
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
block.end.12951:
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
jumpfalse block.end.13535
  clear
  add "lines"
block.end.13535:
testis "cc"
jumpfalse block.end.13567
  clear
  add "chars"
block.end.13567:
# one letter command abbreviations
testis "a"
jumpfalse block.end.13634
  clear
  add "add"
block.end.13634:
testis "k"
jumpfalse block.end.13664
  clear
  add "clip"
block.end.13664:
testis "K"
jumpfalse block.end.13694
  clear
  add "clop"
block.end.13694:
testis "D"
jumpfalse block.end.13727
  clear
  add "replace"
block.end.13727:
testis "d"
jumpfalse block.end.13758
  clear
  add "clear"
block.end.13758:
testis "t"
jumpfalse block.end.13789
  clear
  add "print"
block.end.13789:
testis "p"
jumpfalse block.end.13818
  clear
  add "pop"
block.end.13818:
testis "P"
jumpfalse block.end.13848
  clear
  add "push"
block.end.13848:
testis "u"
jumpfalse block.end.13881
  clear
  add "unstack"
block.end.13881:
testis "U"
jumpfalse block.end.13912
  clear
  add "stack"
block.end.13912:
testis "G"
jumpfalse block.end.13941
  clear
  add "put"
block.end.13941:
testis "g"
jumpfalse block.end.13970
  clear
  add "get"
block.end.13970:
testis "x"
jumpfalse block.end.14000
  clear
  add "swap"
block.end.14000:
testis ">"
jumpfalse block.end.14028
  clear
  add "++"
block.end.14028:
testis "<"
jumpfalse block.end.14056
  clear
  add "--"
block.end.14056:
testis "m"
jumpfalse block.end.14086
  clear
  add "mark"
block.end.14086:
testis "M"
jumpfalse block.end.14114
  clear
  add "go"
block.end.14114:
testis "r"
jumpfalse block.end.14144
  clear
  add "read"
block.end.14144:
testis "R"
jumpfalse block.end.14175
  clear
  add "until"
block.end.14175:
testis "w"
jumpfalse block.end.14206
  clear
  add "while"
block.end.14206:
testis "W"
jumpfalse block.end.14240
  clear
  add "whilenot"
block.end.14240:
testis "n"
jumpfalse block.end.14271
  clear
  add "count"
block.end.14271:
testis "+"
jumpfalse block.end.14299
  clear
  add "a+"
block.end.14299:
testis "-"
jumpfalse block.end.14327
  clear
  add "a-"
block.end.14327:
testis "0"
jumpfalse block.end.14357
  clear
  add "zero"
block.end.14357:
testis "c"
jumpfalse block.end.14388
  clear
  add "chars"
block.end.14388:
testis "l"
jumpfalse block.end.14419
  clear
  add "lines"
block.end.14419:
testis "^"
jumpfalse block.end.14451
  clear
  add "escape"
block.end.14451:
testis "v"
jumpfalse block.end.14485
  clear
  add "unescape"
block.end.14485:
testis "z"
jumpfalse block.end.14516
  clear
  add "delim"
block.end.14516:
testis "S"
jumpfalse block.end.14547
  clear
  add "state"
block.end.14547:
testis "q"
jumpfalse block.end.14577
  clear
  add "quit"
block.end.14577:
testis "s"
jumpfalse block.end.14608
  clear
  add "write"
block.end.14608:
testis "o"
jumpfalse block.end.14637
  clear
  add "nop"
block.end.14637:
testis "rs"
jumpfalse block.end.14671
  clear
  add "restart"
block.end.14671:
testis "rp"
jumpfalse block.end.14705
  clear
  add "reparse"
block.end.14705:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.14816
  put
  clear
  add "eof*"
  push
  jump parse
block.end.14816:
testis "<==>"
jumpfalse block.end.14874
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.14874:
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
jump block.end.15202
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
block.end.15202:
# show information if these "deprecated" commands are used
testis "Q"
jumptrue 4
testis "bail"
jumptrue 2 
jump block.end.15609
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
block.end.15609:
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
testis "pop"
jumptrue 64
testis "push"
jumptrue 62
testis "unstack"
jumptrue 60
testis "stack"
jumptrue 58
testis "put"
jumptrue 56
testis "get"
jumptrue 54
testis "swap"
jumptrue 52
testis "++"
jumptrue 50
testis "--"
jumptrue 48
testis "mark"
jumptrue 46
testis "go"
jumptrue 44
testis "read"
jumptrue 42
testis "until"
jumptrue 40
testis "while"
jumptrue 38
testis "whilenot"
jumptrue 36
testis "count"
jumptrue 34
testis "a+"
jumptrue 32
testis "a-"
jumptrue 30
testis "zero"
jumptrue 28
testis "chars"
jumptrue 26
testis "lines"
jumptrue 24
testis "nochars"
jumptrue 22
testis "nolines"
jumptrue 20
testis "escape"
jumptrue 18
testis "unescape"
jumptrue 16
testis "delim"
jumptrue 14
testis "quit"
jumptrue 12
testis "state"
jumptrue 10
testis "write"
jumptrue 8
testis "nop"
jumptrue 6
testis "reparse"
jumptrue 4
testis "restart"
jumptrue 2 
jump block.end.16010
  put
  clear
  add "word*"
  push
  jump parse
block.end.16010:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop. There is
# a "goto" in c but we will use labelled loops to 
# implement .reparse/parse> anyway
testis "parse>"
jumpfalse block.end.16659
  clear
  count
  testis "0"
  jumptrue block.end.16514
    clear
    add "script error:\n"
    add "  extra parse> label at line "
    ll
    add ".\n"
    print
    quit
  block.end.16514:
  clear
  add "// parse>"
  put
  clear
  add "parse>*"
  push
  # use accumulator to indicate after parse> label
  a+
  jump parse
block.end.16659:
# --------------------
# implement "begin-blocks", which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.16870
  put
  add "*"
  push
  jump parse
block.end.16870:
put
clear
add "[pep syntax error] unknown command '"
get
add "'\n"
add "  near line "
ll
add " (char "
cc
add ")"
add " of source file or input. \n"
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
# parse block
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
jump block.end.18695
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
block.end.18695:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.18890
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
block.end.18890:
testis ",*{*"
jumpfalse block.end.19060
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
block.end.19060:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.19249
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
block.end.19249:
testis "!*!*"
jumpfalse block.end.19512
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
block.end.19512:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.19827
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
block.end.19827:
testis ",*command*"
jumpfalse block.end.20003
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
block.end.20003:
testis "!*command*"
jumpfalse block.end.20208
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
block.end.20208:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.20417
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
block.end.20417:
testis "{*}*"
jumpfalse block.end.20551
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.20551:
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.20782
  push
  push
  add "error near line "
  ll
  add " of script:\n  classes ([a-z], [:space:] etc). \n"
  add "  cannot use the 'begin' or 'end' modifiers (B/E) \n"
  print
  clear
  quit
block.end.20782:
testis "comment*{*"
jumpfalse block.end.20974
  push
  push
  add "error near line "
  ll
  add " of script: comments cannot occur between \n"
  add " a test and a brace ({). \n"
  print
  clear
  quit
block.end.20974:
testis "}*command*"
jumpfalse block.end.21124
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.21124:

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
jumpfalse block.end.22367
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.21821
    clear
    add "continue;"
    # not required because we have a "goto" in c
    # continue works both before and after the parse> label
    # "0" { clear; add "continue script;"; }
    # "1" { clear; add "break lex;"; }
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21821:
  testis "reparse"
  jumpfalse block.end.22154
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.22046
      clear
      add "goto parse;"
    block.end.22046:
    testis "1"
    jumpfalse block.end.22086
      clear
      add "goto parse;"
    block.end.22086:
    put
    clear
    add "command*"
    push
    jump parse
  block.end.22154:
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
block.end.22367:
#---------------------------------
# Compiling comments so as to transfer them to the c output
testis "comment*command*"
jumptrue 6
testis "command*comment*"
jumptrue 4
testis "commandset*comment*"
jumptrue 2 
jump block.end.22621
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
block.end.22621:
testis "comment*comment*"
jumpfalse block.end.22735
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
block.end.22735:
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
jump block.end.23533
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
block.end.23533:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.24039
  clear
  add "endtext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.23996
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
  block.end.23996:
  --
  put
  ++
  clear
  jump parse
block.end.24039:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.24586
  clear
  add "begintext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.24543
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
  block.end.24543:
  --
  put
  ++
  clear
  jump parse
block.end.24586:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.27851
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
  jump block.end.25152
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
  block.end.25152:
  testis "clip"
  jumpfalse block.end.25363
    clear
    add "/* clip */ \n"
    add "if (*mm->buffer.workspace != 0)  \n"
    add "  { mm->buffer.workspace[strlen(mm->buffer.workspace)-1] = '\\0'; }"
    put
  block.end.25363:
  testis "clop"
  jumpfalse block.end.25408
    clear
    add "clop(mm);"
    put
  block.end.25408:
  testis "clear"
  jumpfalse block.end.25510
    clear
    add "mm->buffer.workspace[0] = '\\0';      /* clear */"
    put
  block.end.25510:
  testis "upper"
  jumpfalse block.end.25690
    clear
    add "char *s = mm->buffer.workspace; /* upper */\n"
    add "while (*s) { *s = toupper((unsigned char) *s); s++; } "
    put
  block.end.25690:
  testis "lower"
  jumpfalse block.end.25871
    clear
    add "char *s = mm->buffer.workspace; /* lower */ \n"
    add "while (*s) { *s = tolower((unsigned char) *s); s++; } "
    put
  block.end.25871:
  testis "cap"
  jumpfalse block.end.26116
    clear
    add "char *s = mm->buffer.workspace; /* cap */ \n"
    add "if (*s) { *s = toupper((unsigned char) *s); s++; } \n"
    add "while (*s) { *s = tolower((unsigned char) *s); s++; } "
    put
  block.end.26116:
  testis "print"
  jumpfalse block.end.26222
    clear
    add "printf(\"%s\", mm->buffer.workspace);  /* print */"
    put
  block.end.26222:
  # this is using colours at the moment, not necessary.
  testis "state"
  jumpfalse block.end.26345
    clear
    add "state(mm);      /* state */"
    put
  block.end.26345:
  testis "pop"
  jumpfalse block.end.26388
    clear
    add "pop(mm);"
    put
  block.end.26388:
  testis "push"
  jumpfalse block.end.26433
    clear
    add "push(mm);"
    put
  block.end.26433:
  testis "unstack"
  jumpfalse block.end.26537
    clear
    add "while (pop(mm)) {}          /* unstack */"
    put
  block.end.26537:
  testis "stack"
  jumpfalse block.end.26623
    clear
    add "while (push(mm)) {}          /* stack */"
    put
  block.end.26623:
  testis "put"
  jumpfalse block.end.26666
    clear
    add "put(mm);"
    put
  block.end.26666:
  testis "get"
  jumpfalse block.end.26709
    clear
    add "get(mm);"
    put
  block.end.26709:
  testis "swap"
  jumpfalse block.end.26754
    clear
    add "swap(mm);"
    put
  block.end.26754:
  testis "++"
  jumpfalse block.end.26813
    clear
    add "increment(mm);  /* ++ */ "
    put
  block.end.26813:
  testis "--"
  jumpfalse block.end.26939
    clear
    add "if (mm->tape.currentCell > 0) mm->tape.currentCell--;  /* -- */"
    put
  block.end.26939:
  testis "read"
  jumpfalse block.end.27071
    clear
    add "if (mm->peep == EOF) { break; } else { readChar(mm); }  /* read */"
    put
  block.end.27071:
  testis "count"
  jumpfalse block.end.27119
    clear
    add "count(mm);"
    put
  block.end.27119:
  testis "a+"
  jumpfalse block.end.27180
    clear
    add "mm->accumulator++; /* a+ */"
    put
  block.end.27180:
  testis "a-"
  jumpfalse block.end.27241
    clear
    add "mm->accumulator--; /* a- */"
    put
  block.end.27241:
  testis "zero"
  jumpfalse block.end.27308
    clear
    add "mm->accumulator = 0; /* zero */"
    put
  block.end.27308:
  testis "cc"
  jumptrue 4
  testis "chars"
  jumptrue 2 
  jump block.end.27360
    clear
    add "chars(mm);"
    put
  block.end.27360:
  testis "ll"
  jumptrue 4
  testis "lines"
  jumptrue 2 
  jump block.end.27412
    clear
    add "lines(mm);"
    put
  block.end.27412:
  testis "nochars"
  jumpfalse block.end.27483
    clear
    add "mm->charsRead = 0; /* nochars */"
    put
  block.end.27483:
  testis "nolines"
  jumpfalse block.end.27554
    clear
    add "mm->linesRead = 0; /* nolines */"
    put
  block.end.27554:
  # use a labelled loop to quit script?
  testis "quit"
  jumpfalse block.end.27642
    clear
    add "exit(0);"
    put
  block.end.27642:
  testis "write"
  jumpfalse block.end.27696
    clear
    add "mm.writeToFile();"
    put
  block.end.27696:
  # just eliminate since it does nothing.
  testis "nop"
  jumpfalse block.end.27797
    clear
    add "/* nop: eliminated */"
    put
  block.end.27797:
  clear
  add "command*"
  push
  jump parse
block.end.27851:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.28175
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
block.end.28175:
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
jump block.end.29927
  testbegins "begin"
  jumpfalse block.end.28823
    clear
    # startswith in c
    # if(strncmp(a, b, strlen(b)) == 0) return 1;
    add "strncmp(mm->buffer.workspace, "
    get
    add ", strlen("
    get
    add ")) == 0"
  block.end.28823:
  testbegins "end"
  jumpfalse block.end.28889
    clear
    add "endsWith(mm->buffer.workspace, "
    get
  block.end.28889:
  testbegins "quote"
  jumpfalse block.end.28978
    clear
    add "0 == strcmp(mm->buffer.workspace, "
    get
  block.end.28978:
  # probably could make this faster by simplifying the 
  # workspaceInClassType func, just pass a fn pointer....
  testbegins "class"
  jumpfalse block.end.29226
    # classes dont have quotes around them.
    clear
    add "workspaceInClassType(mm, \""
    get
    add "\""
  block.end.29226:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.29360
    clear
    add "mm->peep == EOF"
  block.end.29360:
  testbegins "tapetest"
  jumpfalse block.end.29603
    clear
    # mm->tape.cells[mm->tape.currentCell].text
    add "strcmp(mm->buffer.workspace, \n"
    add "  mm->tape.cells[mm->tape.currentCell].text) == 0"
    # add mm->tape[mm->tapePointer]) == 0";
  block.end.29603:
  testbegins "mm->peep"
  jumptrue 3
  testbegins "str"
  jumpfalse 2 
  jump block.end.29641
    add ")"
  block.end.29641:
  put
  
  #    #  maybe we could ellide the not tests by doing here
  #    B"not" { clear; add "!"; get; put; }
  #    
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  # eg either .* or ,* or "{*"
  get
  add "*"
  push
  jump parse
block.end.29927:
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
jump block.end.31376
  testbegins "notbegin"
  jumpfalse block.end.30564
    clear
    # startswith in c
    # if(strncmp(a, b, strlen(b)) == 0) return 1;
    add "strncmp(mm->buffer.workspace, "
    get
    add ", strlen("
    get
    add ")) != 0"
  block.end.30564:
  testbegins "notend"
  jumpfalse block.end.30634
    clear
    add "!endsWith(mm->buffer.workspace, "
    get
  block.end.30634:
  testbegins "notquote"
  jumpfalse block.end.30726
    clear
    add "0 != strcmp(mm->buffer.workspace, "
    get
  block.end.30726:
  testbegins "notclass"
  jumpfalse block.end.30813
    clear
    add "!workspaceInClassType(mm, \""
    get
    add "\""
  block.end.30813:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.30950
    clear
    add "mm->peep != EOF"
  block.end.30950:
  testbegins "nottapetest"
  jumpfalse block.end.31201
    clear
    # check this logic!
    add "strcmp(mm->buffer.workspace, \n"
    add "  mm->tape.cells[mm->tape.currentCell].text) != 0"
    #add "strcmp(mm->buffer.workspace, mm->tape[mm->tapePointer]) == 0";
  block.end.31201:
  testbegins "mm->peep"
  jumptrue 3
  testbegins "str"
  jumpfalse 2 
  jump block.end.31239
    add ")"
  block.end.31239:
  put
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.31376:
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
jump block.end.31853
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
block.end.31853:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.32049
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.32049:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.32516
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
block.end.32516:
# arrange the parse> label loops. This is simple in c
# because we have a goto statement
testeof 
jumpfalse block.end.33238
  testis "commandset*parse>*commandset*"
  jumptrue 8
  testis "command*parse>*commandset*"
  jumptrue 6
  testis "commandset*parse>*command*"
  jumptrue 4
  testis "command*parse>*command*"
  jumptrue 2 
  jump block.end.33234
    clear
    # dont have to indent both code blocks
    # add "  "; get; replace "\n" "\n  "; put; clear; ++; ++;
    # add "  "; get; replace "\n" "\n  "; put; clear; --; --;
    # dont need a lex block, because of goto 
    #add "lex:\n";
    get
    #add "\n}\n"; 
    ++
    ++
    # indent code block
    # add "  "; get; replace "\n" "\n  "; put; clear;
    add "\nparse: \n"
    get
    --
    --
    put
    clear
    add "commandset*"
    push
    jump parse
  block.end.33234:
block.end.33238:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.37468
  clear
  get
  testis "replace"
  jumpfalse block.end.33581
    # error 
    add ": command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.33581:
  # check whether argument is single character, otherwise
  # throw an error
  testis "delim"
  jumptrue 10
  testis "escape"
  jumptrue 8
  testis "unescape"
  jumptrue 6
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.34581
    # This is trickier than I thought it would be.
    clear
    ++
    get
    --
    # check that arg not empty, (but an empty quote is ok 
    # for the second arg of 'replace'
    testis "\"\""
    jumpfalse block.end.34133
      clear
      add "[pep error] near line:char "
      ll
      add ":"
      cc
      add "  \n"
      add "The command '"
      get
      add "\' cannot have an empty argument (\"\") \n"
      print
      quit
    block.end.34133:
    # quoted text has the quotes still around it.
    # also handle escape characters like \n \r etc
    clip
    clop
    clop
    clop
    # B "\\" { clip; } 
    clip
    testis ""
    jumptrue block.end.34557
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
    block.end.34557:
    clear
    get
  block.end.34581:
  testis "mark"
  jumpfalse block.end.34767
    clear
    add "strcpy(mm->tape.cells[mm->tape.currentCell].mark, "
    ++
    get
    --
    add "); /* mark */"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34767:
  testis "go"
  jumpfalse block.end.35110
    clear
    add "/* go */ \n"
    add "for (int nn = 0; nn < mm->tape.capacity; nn++) { \n"
    add "  if (strcmp(mm->tape.cells[nn].mark, "
    ++
    get
    --
    add ") == 0) { \n"
    add "    mm->tape.currentCell = nn; \n"
    add "  }\n"
    add "}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35110:
  testis "delim"
  jumpfalse block.end.35517
    clear
    # remove the quotes from around the delimiter and escape ' 
    # because c uses single quotes for chars
    get
    clip
    clop
    testis "'"
    jumpfalse block.end.35301
      clear
      add "\\'"
    block.end.35301:
    put
    clear
    # only the first character of the delimiter argument is used. 
    add "mm->delimiter = '"
    ++
    get
    --
    add "'; /* delim */ "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35517:
  testis "add"
  jumpfalse block.end.35730
    clear
    add "add(mm, "
    ++
    get
    --
    # handle multiline text, check!
    replace "\n" "\"); \nadd(mm, \"\\n"
    add "); "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35730:
  # what is the meaning of while/whilenot with a quote argument??
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.36173
    clear
    add "[error] sorry the c translator does not \n"
    add "  accept a quoted text argument for the '"
    get
    add "'\n"
    add "  command. In anycase, it would not be very useful.\n"
    add "  try while [a-n]; or while [:space:]; or while [aeiou]; \n"
    add "  (At line "
    ll
    add ")\n"
    print
    quit
  block.end.36173:
  testis "until"
  jumpfalse block.end.36776
    clear
    add "until(mm, "
    ++
    get
    --
    # error until cannot have empty argument
    testis "until(mm, \"\""
    jumpfalse block.end.36640
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
    block.end.36640:
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36776:
  # But really, can't the "replace" command just be used
  # instead of escape/unescape?? This seems a flaw in the 
  # machine design. Unescape wont work yet.
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.37294
    put
    clear
    # remove double quotes from argument (to replace with '') 
    # and escape ' because its going in single quotes
    ++
    get
    clip
    clop
    escape "'"
    put
    clear
    --
    get
    add "Char(mm, '"
    ++
    get
    --
    add "');"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.37294:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  quit
block.end.37468:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.39884
  clear
  get
  # what is the meaning of peep with a quote argument??
  # with some tricks I think I can ellide "whilenot" here
  # as well. eg: store "!" or "" in cell, then get it to 
  # negate the logic!
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.39731
    # a trick to negate tests 
    replace "while" ""
    replace "not" "!"
    put
    clear
    # 3 different cases: [a-z] [acx.] [:alpha:] 
    ++
    get
    --
    # check if [a-z] range
    testbegins "["
    jumpfalse 3
    testends "]"
    jumptrue 2 
    jump block.end.39586
      clip
      clip
      clop
      clop
      testis "-"
      jumpfalse block.end.38643
        clear
        ++
        get
        # a trick: turn [a-z] into 'a') && ('z' then insert
        # in code
        replace "[" "'"
        replace "]" "'"
        replace "-" "') && ('"
        put
        clear
        add "while ("
        # here we get the c negation operator "!" which
        # was earlier stored in the cell
        --
        get
        ++
        add "((mm->peep >= "
        get
        --
        add " >= mm->peep)) && readc(mm)) {} /* while */"
        put
        clear
        add "command*"
        push
        jump parse
      block.end.38643:
      # the char class names and function names are the same
      # luckily.
      testis "alnum"
      jumptrue 24
      testis "alpha"
      jumptrue 22
      testis "blank"
      jumptrue 20
      testis "cntrl"
      jumptrue 18
      testis "digit"
      jumptrue 16
      testis "graph"
      jumptrue 14
      testis "lower"
      jumptrue 12
      testis "print"
      jumptrue 10
      testis "punct"
      jumptrue 8
      testis "space"
      jumptrue 6
      testis "upper"
      jumptrue 4
      testis "xdigit"
      jumptrue 2 
      jump block.end.39124
        ++
        put
        --
        clear
        add "while ("
        # insert negation operator, if any
        get
        ++
        add "is"
        get
        --
        add "(mm->peep) && readc(mm)) {}  /* while */"
        put
        clear
        add "command*"
        push
        jump parse
      block.end.39124:
      # bug: \x will crash this because hex digits are 
      # expected by the compiler after it
      clear
      ++
      get
      replace "[" "\""
      replace "]" "\""
      put
      clear
      # insert negation operator, if any.
      add "while ("
      --
      get
      ++
      add "(strchr("
      get
      --
      add ", mm->peep) != NULL) && readc(mm)) {}  /* while */"
      put
      clear
      add "command*"
      push
      jump parse
      #if (!readc(mm)) return;
    block.end.39586:
    put
    clear
    add "[error] strange char class "
    get
    add "!!"
    print
    quit
    #add "command*"; push; .reparse
  block.end.39731:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.39884:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# bnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.40677
  clear
  get
  testis "replace"
  jumpfalse block.end.40500
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    # requires a helper function (in buffer.c).
    clear
    add "replace(mm, "
    ++
    get
    add ", "
    ++
    get
    add ");        /* replace */"
    --
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.40500:
  add "[error] pep script error on line "
  ll
  add " (character "
  cc
  add "): \n"
  add "  command does not take 2 quoted arguments. \n"
  print
  quit
block.end.40677:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.41061
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
block.end.41061:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# these 2 tests should be all that is necessary
testis "test*,*ortestset*{*"
jumptrue 4
testis "test*,*test*{*"
jumptrue 2 
jump block.end.41405
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
block.end.41405:
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
jump block.end.41974
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
block.end.41974:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.42544
  clear
  # indent the generated c code for readability
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
block.end.42544:
# -------------
# multi-token end-of-stream errors
# not a comprehensive list of errors...
testeof 
jumpfalse block.end.43339
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
  jump block.end.42854
    add "  Error near end of script at line "
    ll
    add ". Test with no brace block? \n"
    print
    clear
    quit
  block.end.42854:
  testends "quote*"
  jumptrue 6
  testends "class*"
  jumptrue 4
  testends "word*"
  jumptrue 2 
  jump block.end.43079
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
  block.end.43079:
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
  jump block.end.43335
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
  block.end.43335:
block.end.43339:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.46162
  print
  clear
  # create the virtual machine object code and save it
  # somewhere on the tape.
  add "\n"
  add "\n"
  add " /* c code generated by \"tr/translate.c.pss\" */\n"
  add " /* note: this c engine cannot handle unicode! */\n"
  add "#include <stdio.h> \n"
  add "#include <string.h>\n"
  add "#include <time.h> \n"
  add "#include <ctype.h> \n"
  add "#include \"colours.h\"\n"
  add "#include \"tapecell.h\"\n"
  add "#include \"tape.h\"\n"
  add "#include \"buffer.h\"\n"
  add "#include \"charclass.h\"\n"
  add "#include \"command.h\"\n"
  add "#include \"parameter.h\"\n"
  add "#include \"instruction.h\"\n"
  add "#include \"labeltable.h\"\n"
  add "#include \"program.h\"\n"
  add "#include \"machine.h\"\n"
  add "#include \"exitcode.h\"\n"
  add "#include \"machine.methods.h\"\n"
  add "int main() {\n"
  add "  struct Machine machine;\n"
  add "  struct Machine * mm = &machine;\n"
  add "  newMachine(mm, stdin, 100, 10);\n"
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
  jump block.end.44834
    clear
    # indent generated code (6 spaces) for readability.
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    # restore the c preamble from the tape
    ++
    get
    --
    add "\n"
    add "  script: \n"
    add "  while (!mm->peep != EOF) {\n"
    get
    add "\n  }"
    add "\n}\n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    print
    clear
    quit
  block.end.44834:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.45509
    clear
    # indent begin block code  
    add "  "
    get
    replace "\n" "\n  "
    put
    clear
    # indent main code for readability.
    ++
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    --
    # get c preamble from tape
    ++
    ++
    get
    --
    --
    get
    add "\n"
    ++
    # a labelled loop for "quit" (but quit can just exit?)
    add "  script: \n"
    add "  while (!mm->peep != EOF) {\n"
    get
    add "\n  }"
    add "\n}\n"
    # put a copy of the final compilation into the tapecell
    # for interactive debugging.
    put
    print
    clear
    quit
  block.end.45509:
  push
  push
  # try to explain some more errors
  unstack
  testbegins "parse>"
  jumpfalse block.end.45775
    put
    clear
    add "[error] pep syntax error:\n"
    add "  The parse> label cannot be the 1st item \n"
    add "  of a script \n"
    print
    quit
  block.end.45775:
  put
  clear
  clear
  add "[error] After compiling with 'tr/translate.c.pss' (at EOF): \n "
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
block.end.46162:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
