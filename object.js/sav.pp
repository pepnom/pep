# Assembled with the script 'compile.pss' 
start:
 
#   tr/translate.js.pss 
#
#   This is a parse-script which translates parse-scripts into javascript
#   code, using the 'pep' parsing tool. Javascript is an important 
#   language because it is so ubiquitous on the web and on the server
#   (with "node"). This script will be able to translate itself into
#   javascript (as can translate.go.pss, translate.java.pss translate.py.pss
#   etc)
#   
#   The virtual machine and engine is implemented in plain c at
#   http://bumble.sf.net/books/pars/pep.c. This implements a script
#   language with a syntax reminiscent of sed and awk (simpler than
#   awk, but more complex than sed).
#   
#STATUS
#
#   21 june 2022
#     Just begun by adapting translate.go.pss
#
#NOTES
#   
#   The command "until;" can be implemented as 
#     >> mm.until(mm.tape[mm.cell]);
#
#   Really I should remove the syntax <while "x";> from the 
#   script language because this can be expressed with
#   <while [x]>. This will reduce complexity. Also, in the 
#   case <while [x]> we should translate as "for mm.peep=='x' { read }
#
#   * write function isType() with function argument
#   ---
#    type fn func(rune) bool
#    // eg unicode.IsLetter('x')
#    func isType(type fn, s string) {
#      loop through each char in s
#    }
#    // call
#    if isType(unicode.IsLetter, mm.work) 
#    while isType(unicode.IsLetter, mm.peep) read
#   ,,,
#
#   unicode.IsLetter('x') for [:alpha:]
#
#   In other translation scripts, we use labelled loops and
#   break/continue to implement the parse> label and .reparse .restart
#   commands. Breaks could be used to implement the quit command but arent.
#
#   Does go support labelled loops? yes
#
#   We can use "run once" loops eg " for true do ... break; end " an 
#   example is in the translate.tcl.pss script. 
#
#SEE ALSO
#   
#   At http://bumble.sf.net/books/pars/
#
#   tr/translate.java.pss, tr/translate.py.pss tr/translate.rb.pss
#     very similar scripts for compiling scripts into java and python,
#     ruby and more
#
#   compile.pss
#     compiles a script into an "assembly" format that can be loaded
#     and run on the parse-machine with the -a  switch. This performs
#     the same function as "asm.pp" 
#
#TESTING
#
#   Comprehensive testing can be done with
#   >> pep.tt javascript
#
#   A simple "state" command maybe useful for debugging these 
#   translation scripts and the corresponding machines. 
#
#   * use a helper script to test begin blocks, stack delimiter, and pushing
#   >> pep.jss 'begin { delim "/";} r; add "/";push; state; d;' 
#   >> pep.jss 'begin { delim "/";} r; add "/";push; state; d;' "abcd"
#
#   check multiline text with 'add' and 'until'
#
#WATCH OUT FOR
#
#  treatment of regexes is different (for while whilenot etc). Eg in
#  ruby [[:space:]] is unicode aware but \s is not
#
#  make sure .reparse and .restart work before and after the 
#  parse> label.
#
#  Make sure escaping and multiline arguments work.
#
#BUGS
#   
#  will reparse or restart work in a begin block?
#
#  parse> label just after begin block or after all code.
#
#  multiline add not working?
#
#  mark code may not be correct
#
#SOLVED BUGS TO WATCH FOR 
#
#  * the line below was throwing an error, problem was in compile.pss 
#  >> add '", "\\'; get; add '")'; --; put; clear;
#
#  Java needs a double escape \\\\ before some chars, but ruby doesnt languages no.
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
#  21 June 2022
#    Just begun this javascript version, adapting from go and 
#    using the javascript code in object.js/Machine.js as a guide.
#
#
read
#--------------
# make character number relative to line number for 
# syntax error messages
testclass [\n]
jumpfalse block.end.3986
  nochars
  clear
  jump parse
block.end.3986:
testclass [:space:]
jumpfalse block.end.4024
  clear
  jump parse
block.end.4024:
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
jump block.end.4460
  put
  add "*"
  push
  jump parse
block.end.4460:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.4913
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
  jumptrue block.end.4855
    clear
    add "Unterminated quote character (\") starting at "
    get
    add " !\n"
    print
    quit
  block.end.4855:
  put
  clear
  add "quote*"
  push
  jump parse
block.end.4913:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.5592
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
  jumptrue block.end.5377
    clear
    add "Unterminated quote (') starting at "
    get
    add "!\n"
    print
    quit
  block.end.5377:
  # empty quotes '' may be legal, for example as the second arg
  # to replace.
  clip
  escape "\""
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
block.end.5592:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
# should class tests really be multiline??!
testis "["
jumpfalse block.end.10066
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
  jumpfalse block.end.6116
    clear
    add "pep script error at line "
    ll
    add " (character "
    cc
    add "): \n"
    add "  empty character class [] \n"
    print
    quit
  block.end.6116:
  testends "]"
  jumptrue block.end.6403
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
  block.end.6403:
  # need to escape quotes? 
  escape "\""
  # the caret is not a negation operator in pep char classes
  # but dont have to escape caret because not using regexs
  # replace "^" "\\^";
  # save the class on the tape
  put
  clop
  clop
  testbegins "-"
  jumptrue block.end.6833
    # not a range class, eg [a-z] but dont need to escape '-' chars
    # because not using regexs
    #clear; get; replace '-' '\\-'; put;
    nop
  block.end.6833:
  testbegins "-"
  jumpfalse block.end.7512
    # a range class, eg [a-z], check if it is correct
    clip
    clip
    testis "-"
    jumptrue block.end.7215
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
    block.end.7215:
    # correct format, eg: [a-z] now translate to a 
    # format that can be used by a go function
    clear
    get
    replace "[" "'"
    replace "]" "'"
    replace "-" "','"
    # now='a','z'
    put
    clear
    add "isInRange("
    get
    put
    clear
    add "class*"
    push
    jump parse
  block.end.7512:
  clear
  get
  # restore class text
  testbegins "[:"
  jumpfalse 3
  testends ":]"
  jumpfalse 2 
  jump block.end.7677
    clear
    add "malformed character class starting at "
    get
    add "!\n"
    print
    quit
  block.end.7677:
  # class in the form [:digit:]
  testbegins "[:"
  jumpfalse 3
  testis "[:]"
  jumpfalse 2 
  jump block.end.9305
    clip
    clip
    clop
    clop
    # unicode posix character classes 
    # Also, abbreviations (not implemented in pep.c yet.)
    # classes like [[:alpha:]] are only ascii in golang, but
    # see also unicode.IsLower('x');
    # fix!
    testis "alnum"
    jumptrue 4
    testis "N"
    jumptrue 2 
    jump block.end.8039
      clear
      add "isInClass(unicode.IsLetter"
    block.end.8039:
    #"alpha","A" { clear; add "[[:alpha:]]"; }
    testis "alpha"
    jumptrue 4
    testis "A"
    jumptrue 2 
    jump block.end.8151
      clear
      add "isInClass(unicode.IsLetter"
    block.end.8151:
    # check! 
    # non-standard posix class 'word' and ascii
    # check!
    testis "ascii"
    jumptrue 4
    testis "I"
    jumptrue 2 
    jump block.end.8311
      clear
      add "isInRange(rune(0), rune(unicode.MaxASCII) "
    block.end.8311:
    testis "word"
    jumptrue 4
    testis "W"
    jumptrue 2 
    jump block.end.8373
      clear
      add "isInClass(unicode.IsLetter"
    block.end.8373:
    # fix!
    testis "blank"
    jumptrue 4
    testis "B"
    jumptrue 2 
    jump block.end.8448
      clear
      add "isInClass(unicode.IsSpace"
    block.end.8448:
    testis "cntrl"
    jumptrue 4
    testis "C"
    jumptrue 2 
    jump block.end.8512
      clear
      add "isInClass(unicode.IsControl"
    block.end.8512:
    testis "digit"
    jumptrue 4
    testis "D"
    jumptrue 2 
    jump block.end.8574
      clear
      add "isInClass(unicode.IsDigit"
    block.end.8574:
    testis "graph"
    jumptrue 4
    testis "G"
    jumptrue 2 
    jump block.end.8638
      clear
      add "isInClass(unicode.IsGraphic"
    block.end.8638:
    testis "lower"
    jumptrue 4
    testis "L"
    jumptrue 2 
    jump block.end.8700
      clear
      add "isInClass(unicode.IsLower"
    block.end.8700:
    testis "print"
    jumptrue 4
    testis "P"
    jumptrue 2 
    jump block.end.8762
      clear
      add "isInClass(unicode.IsPrint"
    block.end.8762:
    testis "punct"
    jumptrue 4
    testis "T"
    jumptrue 2 
    jump block.end.8824
      clear
      add "isInClass(unicode.IsPunct"
    block.end.8824:
    testis "space"
    jumptrue 4
    testis "S"
    jumptrue 2 
    jump block.end.8886
      clear
      add "isInClass(unicode.IsSpace"
    block.end.8886:
    testis "upper"
    jumptrue 4
    testis "U"
    jumptrue 2 
    jump block.end.8948
      clear
      add "isInClass(unicode.IsUpper"
    block.end.8948:
    testis "xdigit"
    jumptrue 4
    testis "X"
    jumptrue 2 
    jump block.end.9019
      clear
      add "isInList(\"0123456789abcdefABCDEF\""
    block.end.9019:
    testbegins "isIn"
    jumptrue 3
    testbegins "["
    jumpfalse 2 
    jump block.end.9251
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
    block.end.9251:
    put
    clear
    add "class*"
    push
    jump parse
  block.end.9305:
  
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
  # must be a list eg [abcdefg]
  clear
  get
  replace "[" "\""
  replace "]" "\""
  put
  clear
  add "isInList("
  get
  put
  clear
  add "class*"
  push
  jump parse
block.end.10066:
#---------------
# formats: (eof) (EOF) (==) etc. 
testis "("
jumpfalse block.end.10537
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.10220
    clear
    add "eof*"
    push
    jump parse
  block.end.10220:
  testis "=="
  jumpfalse block.end.10273
    clear
    add "tapetest*"
    push
    jump parse
  block.end.10273:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.10537:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.11788
  clear
  read
  testis "\n"
  jumpfalse block.end.10682
    nochars
    clear
    jump parse
  block.end.10682:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.11546
    # save the line number for possible error message later
    clear
    ll
    put
    clear
    until "*#"
    testends "*#"
    jumpfalse block.end.11291
      # convert to go comments (/*...*/ and //)
      # or just one multiline
      clip
      clip
      replace "\n" "\n//"
      put
      clear
      # create a "comment" parse token
      # comment-out this line to remove multiline comments from the 
      # translated golang code 
      # add "comment*"; push; 
      jump parse
    block.end.11291:
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
  block.end.11546:
  # single line comments. some will get lost.
  put
  clear
  add "//"
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
block.end.11788:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.12175
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
block.end.12175:
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
jumpfalse block.end.12759
  clear
  add "lines"
block.end.12759:
testis "cc"
jumpfalse block.end.12791
  clear
  add "chars"
block.end.12791:
# one letter command abbreviations
testis "a"
jumpfalse block.end.12858
  clear
  add "add"
block.end.12858:
testis "k"
jumpfalse block.end.12888
  clear
  add "clip"
block.end.12888:
testis "K"
jumpfalse block.end.12918
  clear
  add "clop"
block.end.12918:
testis "D"
jumpfalse block.end.12951
  clear
  add "replace"
block.end.12951:
testis "d"
jumpfalse block.end.12982
  clear
  add "clear"
block.end.12982:
testis "t"
jumpfalse block.end.13013
  clear
  add "print"
block.end.13013:
testis "p"
jumpfalse block.end.13042
  clear
  add "pop"
block.end.13042:
testis "P"
jumpfalse block.end.13072
  clear
  add "push"
block.end.13072:
testis "u"
jumpfalse block.end.13105
  clear
  add "unstack"
block.end.13105:
testis "U"
jumpfalse block.end.13136
  clear
  add "stack"
block.end.13136:
testis "G"
jumpfalse block.end.13165
  clear
  add "put"
block.end.13165:
testis "g"
jumpfalse block.end.13194
  clear
  add "get"
block.end.13194:
testis "x"
jumpfalse block.end.13224
  clear
  add "swap"
block.end.13224:
testis ">"
jumpfalse block.end.13252
  clear
  add "++"
block.end.13252:
testis "<"
jumpfalse block.end.13280
  clear
  add "--"
block.end.13280:
testis "m"
jumpfalse block.end.13310
  clear
  add "mark"
block.end.13310:
testis "M"
jumpfalse block.end.13338
  clear
  add "go"
block.end.13338:
testis "r"
jumpfalse block.end.13368
  clear
  add "read"
block.end.13368:
testis "R"
jumpfalse block.end.13399
  clear
  add "until"
block.end.13399:
testis "w"
jumpfalse block.end.13430
  clear
  add "while"
block.end.13430:
testis "W"
jumpfalse block.end.13464
  clear
  add "whilenot"
block.end.13464:
testis "n"
jumpfalse block.end.13495
  clear
  add "count"
block.end.13495:
testis "+"
jumpfalse block.end.13523
  clear
  add "a+"
block.end.13523:
testis "-"
jumpfalse block.end.13551
  clear
  add "a-"
block.end.13551:
testis "0"
jumpfalse block.end.13581
  clear
  add "zero"
block.end.13581:
testis "c"
jumpfalse block.end.13612
  clear
  add "chars"
block.end.13612:
testis "l"
jumpfalse block.end.13643
  clear
  add "lines"
block.end.13643:
testis "^"
jumpfalse block.end.13675
  clear
  add "escape"
block.end.13675:
testis "v"
jumpfalse block.end.13709
  clear
  add "unescape"
block.end.13709:
testis "z"
jumpfalse block.end.13740
  clear
  add "delim"
block.end.13740:
testis "S"
jumpfalse block.end.13771
  clear
  add "state"
block.end.13771:
testis "q"
jumpfalse block.end.13801
  clear
  add "quit"
block.end.13801:
testis "s"
jumpfalse block.end.13832
  clear
  add "write"
block.end.13832:
testis "o"
jumpfalse block.end.13861
  clear
  add "nop"
block.end.13861:
testis "rs"
jumpfalse block.end.13895
  clear
  add "restart"
block.end.13895:
testis "rp"
jumpfalse block.end.13929
  clear
  add "reparse"
block.end.13929:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.14040
  put
  clear
  add "eof*"
  push
  jump parse
block.end.14040:
testis "<==>"
jumpfalse block.end.14098
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.14098:
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
jump block.end.14426
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
block.end.14426:
# show information if these "deprecated" commands are used
testis "Q"
jumptrue 4
testis "bail"
jumptrue 2 
jump block.end.14760
  put
  clear
  add "The instruction '"
  get
  add "' near line "
  ll
  add " (character "
  cc
  add ")\n"
  add "is no longer part of the pep language. \n"
  add "use 'quit' instead of 'bail'' \n"
  print
  clear
  quit
block.end.14760:
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
jump block.end.15161
  put
  clear
  add "word*"
  push
  jump parse
block.end.15161:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop. There may not be
# any "goto" in js so we need to use labelled loops or runonce loops to 
# implement .reparse/parse>
testis "parse>"
jumpfalse block.end.15844
  clear
  count
  testis "0"
  jumptrue block.end.15688
    clear
    add "script error:\n"
    add "  extra parse> label at line "
    ll
    add ".\n"
    print
    quit
  block.end.15688:
  clear
  add "# parse> parse label"
  put
  clear
  add "parse>*"
  push
  # use accumulator to indicate after parse> label
  a+
  jump parse
block.end.15844:
# --------------------
# implement "begin-blocks", which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.16055
  put
  add "*"
  push
  jump parse
block.end.16055:
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
jump block.end.17795
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
block.end.17795:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.17990
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
block.end.17990:
testis ",*{*"
jumpfalse block.end.18160
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
block.end.18160:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.18349
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
block.end.18349:
testis "!*!*"
jumpfalse block.end.18612
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
block.end.18612:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.18927
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
block.end.18927:
testis ",*command*"
jumpfalse block.end.19103
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
block.end.19103:
testis "!*command*"
jumpfalse block.end.19308
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
block.end.19308:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.19517
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
block.end.19517:
testis "{*}*"
jumpfalse block.end.19651
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.19651:
testis "B*class*"
jumptrue 4
testis "E*class*"
jumptrue 2 
jump block.end.19882
  push
  push
  add "error near line "
  ll
  add " of script:\n  classes ([a-z], [:space:] etc). \n"
  add "  cannot use the 'begin' or 'end' modifiers (B/E) \n"
  print
  clear
  quit
block.end.19882:
testis "comment*{*"
jumpfalse block.end.20074
  push
  push
  add "error near line "
  ll
  add " of script: comments cannot occur between \n"
  add " a test and a brace ({). \n"
  print
  clear
  quit
block.end.20074:
testis "}*command*"
jumpfalse block.end.20224
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.20224:

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
jumpfalse block.end.21588
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.21051
    clear
    count
    # this is the opposite of .reparse, using run-once loops
    # cant do next before label, infinite loop
    # need to set flag variable. I think go has labelled loops
    # before the parse> label
    testis "0"
    jumpfalse block.end.20916
      clear
      add "restart = true; continue // restart"
    block.end.20916:
    testis "1"
    jumpfalse block.end.20953
      clear
      add "break"
    block.end.20953:
    # after the parse> label
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21051:
  testis "reparse"
  jumpfalse block.end.21375
    clear
    count
    # check accumulator to see if we are in the "lex" block
    # or the "parse" block and adjust the .reparse compilation
    # accordingly.
    testis "0"
    jumpfalse block.end.21270
      clear
      add "break"
    block.end.21270:
    testis "1"
    jumpfalse block.end.21307
      clear
      add "continue"
    block.end.21307:
    put
    clear
    add "command*"
    push
    jump parse
  block.end.21375:
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
block.end.21588:
#---------------------------------
# Compiling comments so as to transfer them to the java 
testis "comment*command*"
jumptrue 6
testis "command*comment*"
jumptrue 4
testis "commandset*comment*"
jumptrue 2 
jump block.end.21839
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
block.end.21839:
testis "comment*comment*"
jumpfalse block.end.21953
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
block.end.21953:
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
jump block.end.22751
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
block.end.22751:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.23257
  clear
  add "endtext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.23214
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
  block.end.23214:
  --
  put
  ++
  clear
  jump parse
block.end.23257:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.23804
  clear
  add "begintext*"
  push
  get
  testis "\"\""
  jumpfalse block.end.23761
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
  block.end.23761:
  --
  put
  ++
  clear
  jump parse
block.end.23804:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.27028
  clear
  # check if command requires parameter
  get
  testis "add"
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
  jump block.end.24357
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
  block.end.24357:
  # the new until; syntax, read until work ends with current tape cell
  testis "until"
  jumpfalse block.end.24530
    clear
    add "mm.until(mm.tape[mm.cell]));  /* until (cell) */"
    put
  block.end.24530:
  testis "clip"
  jumpfalse block.end.24576
    clear
    add "mm.clip();"
    put
  block.end.24576:
  testis "clop"
  jumpfalse block.end.24622
    clear
    add "mm.clop();"
    put
  block.end.24622:
  testis "clear"
  jumpfalse block.end.24693
    clear
    add "mm.work = \"\";          /* clear */"
    put
  block.end.24693:
  # go code
  testis "upper"
  jumpfalse block.end.24791
    clear
    add "mm.work = strings.ToUpper(mm.work);/* upper */"
    put
  block.end.24791:
  testis "lower"
  jumpfalse block.end.24874
    clear
    add "mm.work = strings.ToLower(mm.work);/* lower */"
    put
  block.end.24874:
  testis "cap"
  jumpfalse block.end.24972
    clear
    add "mm.work = strings.Title(strings.ToLower(mm.work)); // capital"
    put
  block.end.24972:
  testis "print"
  jumpfalse block.end.25053
    clear
    add "process.stdout.write(mm.work);   /* print */"
    put
  block.end.25053:
  testis "state"
  jumpfalse block.end.25121
    clear
    add "mm.printState();       // state"
    put
  block.end.25121:
  testis "pop"
  jumpfalse block.end.25165
    clear
    add "mm.pop();"
    put
  block.end.25165:
  testis "push"
  jumpfalse block.end.25211
    clear
    add "mm.push();"
    put
  block.end.25211:
  testis "unstack"
  jumpfalse block.end.25294
    clear
    add "while (mm.pop()) {}   /* unstack */ "
    put
  block.end.25294:
  testis "stack"
  jumpfalse block.end.25372
    clear
    add "while (mm.push()) {}  /* stack */"
    put
  block.end.25372:
  testis "put"
  jumpfalse block.end.25459
    clear
    add "mm.tape[mm.cell] = mm.work;  /* put */"
    put
  block.end.25459:
  testis "get"
  jumpfalse block.end.25545
    clear
    add "mm.work += mm.tape[mm.cell]; /* get */"
    put
  block.end.25545:
  testis "swap"
  jumpfalse block.end.25661
    clear
    add "mm.work, mm.tape[mm.cell] = mm.tape[mm.cell], mm.work; /* swap */"
    put
  block.end.25661:
  testis "++"
  jumpfalse block.end.25726
    clear
    add "mm.increment();     /* ++ */ \n"
    put
  block.end.25726:
  testis "--"
  jumpfalse block.end.25806
    clear
    add "if (mm.cell > 0) { mm.cell--; }  /* -- */"
    put
  block.end.25806:
  testis "read"
  jumpfalse block.end.25879
    clear
    add "mm.readChar()             /* read */"
    put
  block.end.25879:
  testis "count"
  jumpfalse block.end.25964
    clear
    add "mm.work += mm.counter; /* count */ "
    put
  block.end.25964:
  testis "a+"
  jumpfalse block.end.26026
    clear
    add "mm.counter++;    /* a+ */"
    put
  block.end.26026:
  testis "a-"
  jumpfalse block.end.26088
    clear
    add "mm.counter--;    /* a- */"
    put
  block.end.26088:
  testis "zero"
  jumpfalse block.end.26152
    clear
    add "mm.counter = 0;  /* zero */"
    put
  block.end.26152:
  testis "chars"
  jumpfalse block.end.26239
    clear
    add "mm.work += mm.charsRead; /* chars */"
    put
  block.end.26239:
  testis "lines"
  jumpfalse block.end.26326
    clear
    add "mm.work += mm.linesRead; /* lines */"
    put
  block.end.26326:
  testis "nochars"
  jumpfalse block.end.26396
    clear
    add "mm.charsRead = 0; /* nochars */"
    put
  block.end.26396:
  testis "nolines"
  jumpfalse block.end.26466
    clear
    add "mm.linesRead = 0; /* nolines */"
    put
  block.end.26466:
  # use a labelled loop to quit script.
  testis "quit"
  jumpfalse block.end.26558
    clear
    add "break script;"
    put
  block.end.26558:
  # inline this?
  testis "write"
  jumpfalse block.end.26914
    clear
    # go syntax
    add "/* write */\n"
    add "f, err := os.Create(\"sav.pp\")\n"
    add "if err != nil { panic(err) }\n"
    add "defer f.Close()\n"
    add "_, err = f.WriteString(mm.work)\n"
    add "if err != nil { panic(err) }\n"
    add "f.Sync()"
    put
  block.end.26914:
  testis "nop"
  jumpfalse block.end.26975
    clear
    add "/* nop eliminated */"
    put
  block.end.26975:
  clear
  add "command*"
  push
  jump parse
block.end.27028:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.27352
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
block.end.27352:
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
jump block.end.28572
  testbegins "begin"
  jumpfalse block.end.27868
    clear
    add "mm.work.startsWith("
    get
    add ")"
  block.end.27868:
  testbegins "end"
  jumpfalse block.end.27929
    clear
    add "mm.work.endsWith("
    get
    add ")"
  block.end.27929:
  testbegins "quote"
  jumpfalse block.end.27977
    clear
    add "mm.work == "
    get
  block.end.27977:
  testbegins "class"
  jumpfalse block.end.28102
    # go condition syntax
    # use helper function isInClass
    clear
    get
    add ", mm.work)"
  block.end.28102:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.28233
    clear
    put
    add "mm.eof"
  block.end.28233:
  testbegins "tapetest"
  jumpfalse block.end.28319
    clear
    put
    add "mm.work == mm.tape[mm.cell]"
  block.end.28319:
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
block.end.28572:
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
jump block.end.29672
  testbegins "notbegin"
  jumpfalse block.end.29068
    clear
    add "!mm.work.startsWith("
    get
    add ")"
  block.end.29068:
  testbegins "notend"
  jumpfalse block.end.29133
    clear
    add "!mm.work.endsWith("
    get
    add ")"
  block.end.29133:
  testbegins "notquote"
  jumpfalse block.end.29184
    clear
    add "mm.work != "
    get
  block.end.29184:
  testbegins "notclass"
  jumpfalse block.end.29319
    # produces !isInClass(.. or !isInList(.. or !isInRange(..
    clear
    add "!"
    get
    add ", mm.work)"
  block.end.29319:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.29453
    clear
    put
    add "!mm.eof"
  block.end.29453:
  testbegins "nottapetest"
  jumpfalse block.end.29535
    clear
    put
    add "mm.work != mm.tape[mm.cell]"
  block.end.29535:
  put
  clear
  add "test*"
  push
  # the trick below pushes the right token back on the stack.
  get
  add "*"
  push
  jump parse
block.end.29672:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------
# some 3 token errors!!!
# not a comprehensive list
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
jump block.end.30131
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
block.end.30131:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.30327
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.30327:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.30794
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
block.end.30794:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.35688
  clear
  get
  testis "replace"
  jumpfalse block.end.31137
    # error 
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.31137:
  # disable "while <quote>" syntax since it is not necessary
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.31447
    add "[error] while/whilenot should not have quoted  \n"
    add "single character argument. Use eg: while [x] instead\n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.31447:
  # check whether argument is single character, otherwise
  # throw an error. Also, convert to single quotes for go
  # which is
  testis "delim"
  jumptrue 6
  testis "escape"
  jumptrue 4
  testis "unescape"
  jumptrue 2 
  jump block.end.33093
    # This is trickier than I thought it would be.
    clear
    ++
    get
    # check that arg not empty, (but an empty quote is ok 
    # for the second arg of 'replace'
    testis "\"\""
    jumpfalse block.end.32048
      clear
      add "[pep error] near line "
      ll
      add " (or char "
      cc
      add "): \n"
      add "  command '"
      --
      get
      ++
      add "' "
      add "cannot have an empty argument (\"\") \n"
      print
      quit
    block.end.32048:
    # quoted text has the quotes still around it.
    # also handle escape characters like \n \r etc
    # Also, unicode escape sequences like \u0x2222
    clip
    clop
    clip
    testis ""
    jumptrue 3
    testbegins "\\"
    jumpfalse 2 
    jump block.end.32499
      clear
      add "[pep error] Pep script error near line "
      ll
      add " (character "
      cc
      add "): \n"
      add "  command '"
      get
      add "' takes only a single character argument. \n"
      print
      quit
    block.end.32499:
    testbegins "\\"
    jumpfalse block.end.32869
      clip
      testis ""
      jumptrue block.end.32861
        clear
        add "[pep error] Pep script error near line "
        ll
        add " (character "
        cc
        add "): \n"
        add "  command '"
        --
        get
        add "' takes only a single character argument or \n"
        add " and escaped single char eg: \n \t \f etc"
        print
        quit
      block.end.32861:
    block.end.32869:
    # replace double quotes with single for argument
    clear
    get
    escape "'"
    unescape "\""
    clip
    clop
    put
    clear
    add "'"
    get
    add "'"
    put
    # re-get the command name
    --
    clear
    get
  block.end.33093:
  testis "mark"
  jumpfalse block.end.33241
    clear
    add "mm.marks[mm.cell] = "
    ++
    get
    --
    add " /* mark */"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33241:
  testis "go"
  jumpfalse block.end.33389
    clear
    add "mm.goToMark("
    ++
    get
    --
    add ")  /* go to mark */\n"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33389:
  testis "delim"
  jumpfalse block.end.33591
    clear
    # the delimiter should be a single character, no?
    add "mm.delimiter = "
    ++
    get
    --
    add " /* delim */ "
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33591:
  testis "add"
  jumpfalse block.end.33804
    clear
    add "mm.work += "
    ++
    get
    --
    # handle multiline text check this! \\n or \n
    replace "\n" "\"\nmm.work += \"\\n"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.33804:
  # not used now
  testis "while"
  jumpfalse block.end.34057
    clear
    add "/* while */\n"
    add "for (mm.peep == "
    ++
    get
    --
    add ") {\n"
    add "  if mm.eof { break }\n  mm.read()\n"
    add "}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34057:
  # not used now
  testis "whilenot"
  jumpfalse block.end.34301
    clear
    add "/* whilenot */\n"
    add "for (mm.peep != "
    ++
    get
    --
    add ") {\n"
    add "  if mm.eof { break }\n  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34301:
  testis "until"
  jumpfalse block.end.34902
    clear
    add "mm.until("
    ++
    get
    --
    # error until cannot have empty argument
    testis "mm.until(\"\""
    jumpfalse block.end.34766
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
    block.end.34766:
    # handle multiline argument
    replace "\n" "\\n"
    add ");"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.34902:
  testis "escape"
  jumpfalse block.end.35220
    clear
    ++
    # argument still has quotes around it
    # it should be a single character since this has been previously
    # checked.
    add "mm.work = mm.work.replace("
    get
    add ", mm.escape+"
    get
    add ")"
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35220:
  # replace \n with n for example (only 1 character)
  testis "unescape"
  jumpfalse block.end.35497
    clear
    ++
    # use the machine escape char
    add "mm.work = mm.work.replace(mm.escape+"
    get
    add ", "
    get
    add ")"
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.35497:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.35688:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.36456
  clear
  get
  testis "while"
  jumpfalse block.end.36050
    clear
    add "/* while */\n"
    add "for "
    ++
    get
    --
    add ", string(mm.peep)) {\n"
    add "  if mm.eof { break }\n  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36050:
  testis "whilenot"
  jumpfalse block.end.36303
    clear
    add "/* whilenot */\n"
    add "for !"
    ++
    get
    --
    add ", string(mm.peep)) {\n"
    add "  if mm.eof { break; }\n"
    add "  mm.read()\n}"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.36303:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.36456:
# arrange the parse> label loops
testeof 
jumpfalse block.end.37609
  testis "commandset*parse>*commandset*"
  jumptrue 8
  testis "command*parse>*commandset*"
  jumptrue 6
  testis "commandset*parse>*command*"
  jumptrue 4
  testis "command*parse>*command*"
  jumptrue 2 
  jump block.end.37605
    clear
    # indent both code blocks
    add "  "
    get
    replace "\n" "\n  "
    # go has labelled loops, but complains if the label
    # is not used. So we have to use the flag technique
    # to make restart with before/after/without the parse> label
    replace "continue // restart" "break // restart"
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
    # it appears that go has labelled loops
    add "\n/* lex block */\n"
    add "for true { \n"
    get
    add "\n  break \n}\n"
    ++
    ++
    add "if restart { restart = false; continue; }"
    # indent code block
    # add "  "; get; replace "\n" "\n  "; put; clear;
    # using flag technique 
    add "\n// parse block \n"
    add "for true {\n"
    get
    add "\n  break \n} // parse\n"
    --
    --
    put
    clear
    add "commandset*"
    push
    jump parse
  block.end.37605:
block.end.37609:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# bnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.38503
  clear
  get
  # check! go replace syntax
  # not used here
  # match1, err := regexp.MatchString("geeks", str)
  testis "replace"
  jumpfalse block.end.38334
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    clear
    add "/* replace */\n"
    # add 'if mm.work != "" { \n';
    add "mm.work = mm.work.replace("
    ++
    get
    add ", "
    ++
    get
    add ");\n"
    --
    --
    put
    clear
    add "command*"
    push
    jump parse
  block.end.38334:
  add "Pep script error on line "
  ll
  add " (character "
  cc
  add "): \n"
  add "  command does not take 2 quoted arguments. \n"
  print
  quit
block.end.38503:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.38887
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
block.end.38887:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# these 2 tests should be all that is necessary
testis "test*,*ortestset*{*"
jumptrue 4
testis "test*,*test*{*"
jumptrue 2 
jump block.end.39231
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
block.end.39231:
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
jump block.end.39800
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
block.end.39800:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.40384
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
block.end.40384:
# -------------
# multi-token end-of-stream errors
# not a comprehensive list of errors...
testeof 
jumpfalse block.end.41179
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
  jump block.end.40694
    add "  Error near end of script at line "
    ll
    add ". Test with no brace block? \n"
    print
    clear
    quit
  block.end.40694:
  testends "quote*"
  jumptrue 6
  testends "class*"
  jumptrue 4
  testends "word*"
  jumptrue 2 
  jump block.end.40919
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
  block.end.40919:
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
  jump block.end.41175
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
  block.end.41175:
block.end.41179:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.52184
  print
  clear
  # create the virtual machine object code and save it
  # somewhere on the tape.
  add "\n"
  add "// code generated by \"translate.js.pss\" a pep script\n"
  add "// http://bumble.sf.net/books/pars/tr/\n"
  add "\n"
  add "  var fs = require(\"fs\");\n"
  add "\n"
  add "  function visible(text) {\n"
  add "    if (text == null) return \"EOF=null\";\n"
  add "    text = text.replace(/\\n/g, \"\\n\");\n"
  add "    text = text.replace(/\\t/g, \"\\t\");\n"
  add "    text = text.replace(/\\r/g, \"\\r\");\n"
  add "    text = text.replace(/\\f/g, \"\\f\");\n"
  add "    return text\n"
  add "  }\n"
  add "\n"
  add "  // this returns 0 when end of stream reached!!!\n"
  add "  console.read = len => {\n"
  add "    var read;\n"
  add "    var buff = Buffer.alloc(len);\n"
  add "    read = fs.readSync(process.stdin.fd, buff, 0, len);\n"
  add "    if (read == 0) { return null; } \n"
  add "    return buff.toString();\n"
  add "  };\n"
  add "\n"
  add "  // this could be useful in the java version to convert to\n"
  add "  // unicode categories. inBlock, inScript etc\n"
  add "  function classToRegex(text) {\n"
  add "    // convert ctype.h character classes to javascript regex classes\n"
  add "    // These are only approximate conversions\n"
  add "    // [0-9]\n"
  add "    if (text == \"[:digit:]\") { text = \"\\d\"; }\n"
  add "    // [ \\f\\n\\r\\t\\v]\n"
  add "    if (text == \"[:space:]\") { text = \"\\s\"; }\n"
  add "    // [A-Za-z0-9_]\n"
  add "    if (text == \"[:alnum:]\") { text = \"\\w\"; }\n"
  add "    // not implemented. just matches everthing.\n"
  add "    if (text == \"[:cntrl:]\") { text = \".\"; }\n"
  add "    // maybe not in ctype.h\n"
  add "    if (text == \"[:blank:]\") { text = \"[ \\t]\"; }\n"
  add "    // it would be nice to make this unicode-aware (i.e lower case\n"
  add "    // in any character set.\n"
  add "    if (text == \"[:lower:]\") { text = \"[a-z]\"; }\n"
  add "    if (text == \"[:upper:]\") { text = \"[A-Z]\"; }\n"
  add "    if (text == \"[:xdigit:]\") { text = \"[A-Za-f0-9]\"; }\n"
  add "    if (text == \"[:punct:]\") { text = \"\"; }\n"
  add "    return text;\n"
  add "  }\n"
  add "\n"
  add "module.exports = {\n"
  add "  Machine: function() {\n"
  add "   //FILE * inputstream;   //source of characters\n"
  add "   this.peep = \"\";         // next char in the stream, may have EOF\n"
  add "   this.stack = [];        // stack to hold parse tokens\n"
  add "   this.work = \"\";  // \n"
  add "   this.tape = [];       // array of strings for token values \n"
  add "   this.tape[0] = \"\";    // init first element of tape array \n"
  add "   this.marks = [];      // array of marks on the tape (mark/go)\n"
  add "   this.cell = 0; // integer pointer to current tape cell\n"
  add "   this.counter = 0; // used for counting\n"
  add "   this.charsRead = 0;   // how many characters read from input stream\n"
  add "   this.linesRead = 1;   // how many lines already read from input stream \n"
  add "   this.flag = false;    // used for tests (not here).\n"
  add "   this.delimiter = \"*\"; // to separate tokens on the stack\n"
  add "   this.escape = \"\\\\\"; // escape character, default \"\\"\n"
  add "\n"
  add "   this.peep = console.read(1);\n"
  add "   process.stdin.setEncoding(\"utf8\");\n"
  add "\n"
  add "   this.setInput = function(newInput) {\n"
  add "     process.stdout.write(\"to be implemented\")\n"
  add "   }\n"
  add "\n"
  add "   // read one utf8 character from the input stream and \n"
  add "   // update the machine.\n"
  add "\n"
  add "   this.readChar = function() {\n"
  add "     if (this.peep == null) {\n"
  add "       return;          \n"
  add "     }\n"
  add "     // increment line and char counters\n"
  add "     this.charsRead++;\n"
  add "     if (this.peep == \"\\n\") { this.lines++; }\n"
  add "     this.workspace += this.peep;\n"
  add "     // read next char from stream\n"
  add "     this.peep = console.read(1);\n"
  add "   }\n"
  add "\n"
  add "   // remove escape character: trivial method ?\n"
  add "   // check the python code for this, and the c code in machine.interp.c\n"
  add "   this.unescapeChar = function(char) {\n"
  add "     // if this.work = \"\" { return }\n"
  add "     this.work = this.work.replace(this.work, \"\\\\\"+c, c, -1)\n"
  add "   }\n"
  add "\n"
  add "   // add escape character : trivial?\n"
  add "   this.escapeChar = function(char) {\n"
  add "     this.work = this.work.replace(c, \"\\\\\"+c, -1)\n"
  add "   }\n"
  add "\n"
  add "  /** a helper function to count trailing escapes */\n"
  add "  this.countEscapes = function(suffix) {\n"
  add "    var count = 0;\n"
  add "    var ss = \"\";\n"
  add "    if (this.work.endsWith(suffix)) {\n"
  add "      ss = strings.TrimSuffix(this.work, suffix);\n"
  add "    }\n"
  add "    while (ss.endsWith(this.escape)) { \n"
  add "      ss = strings.TrimSuffix(ss, string(this.escape));\n"
  add "      count++;\n"
  add "    }\n"
  add "    return count\n"
  add "  }\n"
  add "\n"
  add "\n"
  add "  // reads the input stream until the workspace ends with the\n"
  add "  // given character or text, ignoring escaped characters\n"
  add "  this.until = function(suffix) {\n"
  add "    if (this.eof) { return; }\n"
  add "    // read at least one character\n"
  add "    this.read()\n"
  add "    while (true) { \n"
  add "      if (this.eof) { return; }\n"
  add "      // we need to count the this.Escape chars preceding suffix\n"
  add "      // if odd, keep reading, if even, stop\n"
  add "      if (this.work.endsWith(suffix)) {\n"
  add "        if (this.countEscapes(suffix) % 2 == 0) { return; }\n"
  add "      }\n"
  add "      this.readChar();\n"
  add "    }\n"
  add "  }  \n"
  add "\n"
  add "  /* read the input stream until the workspace ends with the \n"
  add "     text in the current tape cell. This is the pep/nom command \n"
  add "     \"until;\" with no argument. The command also needs to be implemented\n"
  add "     in the pep interpreter and other translation scripts */\n"
  add "  // BUT we can just call this.until(this.tape[this.cell]) ??\n"
  add "  this.untilTape = function() {\n"
  add "    if (this.eof) { return; }\n"
  add "    // read at least one character\n"
  add "    this.readChar()\n"
  add "    while (true) { \n"
  add "      if (this.eof) { return; }\n"
  add "      // we need to count the this.Escape chars preceding suffix\n"
  add "      // if odd, keep reading (because the end text is escaped), \n"
  add "      // but if even, stop reading \n"
  add "      if (this.work.endsWith(this.tape[this.cell])) {\n"
  add "        if (this.countEscapes(this.tape[this.cell])  % 2 == 0) { return; }\n"
  add "      }\n"
  add "      this.readChar();\n"
  add "    }\n"
  add "  }\n"
  add "\n"
  add "  /* increment the tape pointer (command ++) and grow the \n"
  add "     tape and marks arrays if necessary */\n"
  add "  this.increment = function() { \n"
  add "    this.cell++;\n"
  add "    if (this.cell >= this.tape.length) {\n"
  add "      // grow the marks/tape arrays by 20 when the \n"
  add "      // tape size is exceeded.\n"
  add "      for (ii=0; ii++; ii<20) {\n"
  add "        this.tape[this.tape.length+ii] = \"\"; \n"
  add "        this.marks[this.marks.length+ii] = \"\";\n"
  add "      }\n"
  add "      this.size = this.tape.length;\n"
  add "    }\n"
  add "  }\n"
  add "\n"
  add "  /* pop the top token on the stack onto the beginning of the \n"
  add "     workspace buffer */\n"
  add "  this.pop = function() {\n"
  add "    if (this.stack.length == 0) return false;\n"
  add "    this.work = this.stack.pop() + this.work;\n"
  add "    if (this.cell > 0) this.cell--;\n"
  add "    return true;\n"
  add "  }\n"
  add "\n"
  add "  this.push = function() {\n"
  add "    if (this.work == \"\") return false;\n"
  add "    var first = this.work.indexOf(this.delimiter);\n"
  add "    if (first > -1) {\n"
  add "      this.stack.push(this.work.slice(0, first+1));\n"
  add "      this.work = this.work.slice(first+1);\n"
  add "    } else {\n"
  add "      this.stack.push(this.work);\n"
  add "      this.work = \"\";\n"
  add "    }\n"
  add "    // use increment to handle growing the tape and marks\n"
  add "    // arrays if required\n"
  add "    this.increment();\n"
  add "    return true;\n"
  add "  }\n"
  add "\n"
  add "  // \n"
  add "  /*\n"
  add "  this.printState() = function() { \n"
  add "    fmt.Printf(\"Stack %v Work[%s] Peep[%c] \\n\", this.stack, this.work, this.peep)\n"
  add "    fmt.Printf(\"Acc:%v Esc:%c Delim:%c Chars:%v\", \n"
  add "      this.counter, this.escape, this.delimiter, this.charsRead)\n"
  add "    fmt.Printf(\" Lines:%v Cell:%v EOF:%v \\n\", this.linesRead, this.cell, this.eof)\n"
  add "    for (ii = 0; ii < this.tape.length; ii++) {\n"
  add "      fmt.Printf(\"%v [%s] \\n\", ii, vv)\n"
  add "      if ii > 4 { return; }\n"
  add "    }\n"
  add "  } \n"
  add "  */\n"
  add "\n"
  add "  this.goToMark = function(mark) {\n"
  add "    var markFound = false;\n"
  add "    for (ii = 0; ii < this.marks.length; ii++) {\n"
  add "      if (this.marks[ii] == mark) {\n"
  add "        this.cell = ii; markFound = true; break;\n"
  add "      }\n"
  add "    }\n"
  add "    if (this.tape[ii] == null) { this.tape[ii] = \"\"; }\n"
  add "    if (markFound == false) {\n"
  add "      process.stdout.write(\"badmark \" + mark + \"!\");\n"
  add "      exit();\n"
  add "    }\n"
  add "\n"
  add "  }\n"
  add "\n"
  add "  // this is where the actual parsing/compiling code should go\n"
  add "  // so that it can be used by other go classes/objects. Also\n"
  add "  // should have a stream argument.\n"
  add "  this.parse = function(reader, writer) {\n"
  add "  } \n"
  add "\n"
  add "  this.clip = function() {\n"
  add "    if (this.work == \"\") return;\n"
  add "    this.work = \n"
  add "      this.work.substring(0, this.work.length-1);\n"
  add "  }\n"
  add "\n"
  add "  this.clop = function() {\n"
  add "    if (this.work == \"\") return;\n"
  add "    this.work = this.work.substring(1);\n"
  add "  }\n"
  add "\n"
  add "  this.swap = function() {\n"
  add "    //if (this.tape[this.tapePointer] == null) \n"
  add "    //  this.tape[this.tapePointer] == \"\";\n"
  add "    var text = this.workspace;\n"
  add "    this.workspace = this.tape[this.tapePointer];\n"
  add "    this.tape[this.tapePointer] = text;\n"
  add "  }\n"
  add "\n"
  add "  /* \n"
  add "  go code:\n"
  add "  func isInClass(typeFn fn, s string) bool {\n"
  add "    if s == \"\" { return false; }\n"
  add "    for _, rr := range s {\n"
  add "      //if !unicode.IsLetter(rr) {\n"
  add "      if !typeFn(rr) { return false }\n"
  add "    }\n"
  add "    return true\n"
  add "  }\n"
  add "  */\n"
  add "\n"
  add "  /* range in format \'a,z\' */\n"
  add "  /*\n"
  add "  // go code\n"
  add "  func isInRange(start rune, end rune, s string) bool {\n"
  add "    if s == \"\" { return false; }\n"
  add "    for _, rr := range s {\n"
  add "      if (rr < start) || (rr > end) { return false }\n"
  add "    }\n"
  add "    return true\n"
  add "  }\n"
  add "  */\n"
  add "  /* list of unicode chars */\n"
  add "  /*\n"
  add "  func isInList(list string, s string) bool {\n"
  add "    return strings.ContainsAny(s, list)\n"
  add "  }\n"
  add "  */\n"
  add " } // machine\n"
  add "\n"
  add "\n"
  add "  var mm = new Machine();\n"
  add "  var restart = false; \n"
  add "  "
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
  jump block.end.50644
    clear
    # indent generated code for readability.
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    # restore the go preamble from the tape
    ++
    get
    --
    add "script: \n"
    add "  while (mm.peep != null) { \n"
    get
    add "\n  }\n"
    add "\n} // exports \n"
    add "\n\n/* end of generated javascript code */\n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    print
    clear
    quit
  block.end.50644:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.51487
    clear
    # indentation not needed here 
    #add ""; get; 
    #replace "\n" "\n"; put; clear; 
    # indent main code for readability.
    ++
    add "    "
    get
    replace "\n" "\n    "
    put
    clear
    --
    # get js preamble (Machine object definition) from tape
    ++
    ++
    get
    --
    --
    get
    add "\n"
    ++
    # a labelled loop for "quit" (but quit can just exit?)
    add "script: \n"
    add "  while (mm.peep != null) { \n"
    get
    # end block marker required in 'go'
    add "\n  }\n"
    add "\n} // exports \n"
    add "\n\n/* end of translated javascript code */\n"
    # put a copy of the final compilation into the tapecell
    # to help in interactive debugging with "pep -I ..."
    put
    print
    clear
    quit
  block.end.51487:
  push
  push
  # try to explain some more errors
  unstack
  testbegins "parse>"
  jumpfalse block.end.51753
    put
    clear
    add "[error] pep syntax error:\n"
    add "  The parse> label cannot be the 1st item \n"
    add "  of a script \n"
    print
    quit
  block.end.51753:
  put
  clear
  clear
  add "[error] After compiling with 'translate.js.pss' (at EOF): \n "
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
block.end.52184:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
