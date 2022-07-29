# Assembled with the script 'compile.pss' 
start:
read
#--------------
testclass [:space:]
jumpfalse block.end.11339
  clear
  jump parse
block.end.11339:
#---------------
# We can ellide all these single character tests, because
# the stack token is just the character itself with a *
# Braces {} are used for blocks, ',' and '.' for concatenating
# tests with OR or AND logic. 'B' and 'E' for begin and end
# tests. 
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
jump block.end.11701
  put
  add "*"
  push
  jump parse
block.end.11701:
#---------------
# format: "text"
testis "\""
jumpfalse block.end.12054
  clear
  ll
  put
  clear
  add "\""
  until "\""
  testends "\""
  jumptrue block.end.11996
    clear
    add "Unterminated quote (\") starting at line "
    get
    add " !\n"
    print
    quit
  block.end.11996:
  put
  clear
  add "quote*"
  push
  jump parse
block.end.12054:
#---------------
# format: 'text', single quotes are converted to double quotes
# but we must escape embedded double quotes.
testis "'"
jumpfalse block.end.12554
  clear
  ll
  put
  clear
  until "'"
  testends "'"
  jumptrue block.end.12429
    clear
    add "Unterminated quote (\") starting at line "
    get
    add "!\n"
    print
    quit
  block.end.12429:
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
block.end.12554:
#---------------
# formats: [:space:] [a-z] [abcd] [:alpha:] etc 
testis "["
jumpfalse block.end.12702
  until "]"
  put
  clear
  add "class*"
  push
  jump parse
block.end.12702:
#---------------
# formats: (eof) (==) etc. I may change this syntax to just
# EOF and ==
testis "("
jumpfalse block.end.13211
  clear
  until ")"
  clip
  put
  testis "eof"
  jumptrue 4
  testis "EOF"
  jumptrue 2 
  jump block.end.12896
    clear
    add "eof*"
    push
    jump parse
  block.end.12896:
  testis "=="
  jumpfalse block.end.12949
    clear
    add "tapetest*"
    push
    jump parse
  block.end.12949:
  add " << unknown test near line "
  ll
  add " of script.\n"
  add " bracket () tests are \n"
  add "   (eof) test if end of stream reached. \n"
  add "   (==)  test if workspace is same as current tape cell \n"
  print
  clear
  quit
block.end.13211:
#---------------
# multiline and single line comments, eg #... and #* ... *#
testis "#"
jumpfalse block.end.14168
  clear
  read
  # calling .restart here is a bug, because the (eof) clause
  # will never be called and the script never written or 
  # printed.
  testis "\n"
  jumpfalse block.end.13485
    clear
    jump start
  block.end.13485:
  # checking for multiline comments of the form "#* \n\n\n *#"
  # these are just ignored at the moment (deleted) 
  testis "*"
  jumpfalse block.end.13986
    until "*#"
    testends "*#"
    jumpfalse block.end.13783
      clear
      jump start
    block.end.13783:
    # make an unterminated multiline comment an error
    # to ease debugging of scripts.
    clear
    add "unterminated multiline comment #* ... *# \n"
    print
    clear
    quit
  block.end.13986:
  # single line comments. some will get lost.
  put
  clear
  add "#"
  get
  until "\n"
  clip
  put
  clear
  add "comment*"
  push
  #clear; .restart 
  clear
  jump parse
block.end.14168:
#----------------------------------
# parse command words (and abbreviations)
# legal characters for keywords (commands)
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRUWS+-<>0^]
jumptrue block.end.14549
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
  bail
block.end.14549:
# my testclass implementation cannot handle complex lists
# eg [a-z+-] this is why I have to write out the whole alphabet
while [abcdefghijklmnopqrstuvwxyzBEOFKGPRUWS+-<>0^]
#----------------------------------
# KEYWORDS 
# here we can test for all the keywords (command words) and their
# abbreviated one letter versions (eg: clip k, clop K etc). Then
# we can print an error message and abort if the word is not a 
# legal keyword for the parse-edit language
testis "a"
jumpfalse block.end.15070
  clear
  add "add"
block.end.15070:
testis "k"
jumpfalse block.end.15100
  clear
  add "clip"
block.end.15100:
testis "K"
jumpfalse block.end.15130
  clear
  add "clop"
block.end.15130:
testis "D"
jumpfalse block.end.15163
  clear
  add "replace"
block.end.15163:
testis "d"
jumpfalse block.end.15194
  clear
  add "clear"
block.end.15194:
testis "t"
jumpfalse block.end.15225
  clear
  add "print"
block.end.15225:
testis "p"
jumpfalse block.end.15254
  clear
  add "pop"
block.end.15254:
testis "P"
jumpfalse block.end.15284
  clear
  add "push"
block.end.15284:
testis "u"
jumpfalse block.end.15317
  clear
  add "unstack"
block.end.15317:
testis "U"
jumpfalse block.end.15348
  clear
  add "stack"
block.end.15348:
testis "G"
jumpfalse block.end.15377
  clear
  add "put"
block.end.15377:
testis "g"
jumpfalse block.end.15406
  clear
  add "get"
block.end.15406:
testis "x"
jumpfalse block.end.15436
  clear
  add "swap"
block.end.15436:
testis ">"
jumpfalse block.end.15464
  clear
  add "++"
block.end.15464:
testis "<"
jumpfalse block.end.15492
  clear
  add "--"
block.end.15492:
testis "m"
jumpfalse block.end.15522
  clear
  add "mark"
block.end.15522:
testis "M"
jumpfalse block.end.15550
  clear
  add "go"
block.end.15550:
testis "r"
jumpfalse block.end.15580
  clear
  add "read"
block.end.15580:
testis "R"
jumpfalse block.end.15611
  clear
  add "until"
block.end.15611:
testis "w"
jumpfalse block.end.15642
  clear
  add "while"
block.end.15642:
testis "W"
jumpfalse block.end.15676
  clear
  add "whilenot"
block.end.15676:
# we can probably omit tests and jumps since they are not
# designed to be used in scripts (only assembled parse programs).
testis "n"
jumpfalse block.end.16154
  clear
  add "count"
block.end.16154:
testis "+"
jumpfalse block.end.16182
  clear
  add "a+"
block.end.16182:
testis "-"
jumpfalse block.end.16210
  clear
  add "a-"
block.end.16210:
testis "0"
jumpfalse block.end.16240
  clear
  add "zero"
block.end.16240:
testis "c"
jumpfalse block.end.16268
  clear
  add "cc"
block.end.16268:
testis "l"
jumpfalse block.end.16296
  clear
  add "ll"
block.end.16296:
testis "^"
jumpfalse block.end.16328
  clear
  add "escape"
block.end.16328:
testis "v"
jumpfalse block.end.16362
  clear
  add "unescape"
block.end.16362:
testis "z"
jumpfalse block.end.16393
  clear
  add "delim"
block.end.16393:
testis "S"
jumpfalse block.end.16424
  clear
  add "state"
block.end.16424:
testis "q"
jumpfalse block.end.16454
  clear
  add "quit"
block.end.16454:
testis "Q"
jumpfalse block.end.16484
  clear
  add "bail"
block.end.16484:
testis "s"
jumpfalse block.end.16515
  clear
  add "write"
block.end.16515:
testis "o"
jumpfalse block.end.16544
  clear
  add "nop"
block.end.16544:
testis "rs"
jumpfalse block.end.16578
  clear
  add "restart"
block.end.16578:
testis "rp"
jumpfalse block.end.16612
  clear
  add "reparse"
block.end.16612:
# some extra syntax for testeof and testtape
testis "<eof>"
jumptrue 4
testis "<EOF>"
jumptrue 2 
jump block.end.16723
  put
  clear
  add "eof*"
  push
  jump parse
block.end.16723:
testis "<==>"
jumpfalse block.end.16781
  put
  clear
  add "tapetest*"
  push
  jump parse
block.end.16781:
testis "add"
jumptrue 92
testis "clip"
jumptrue 90
testis "clop"
jumptrue 88
testis "replace"
jumptrue 86
testis "clear"
jumptrue 84
testis "print"
jumptrue 82
testis "pop"
jumptrue 80
testis "push"
jumptrue 78
testis "unstack"
jumptrue 76
testis "stack"
jumptrue 74
testis "put"
jumptrue 72
testis "get"
jumptrue 70
testis "swap"
jumptrue 68
testis "++"
jumptrue 66
testis "--"
jumptrue 64
testis "mark"
jumptrue 62
testis "go"
jumptrue 60
testis "read"
jumptrue 58
testis "until"
jumptrue 56
testis "while"
jumptrue 54
testis "whilenot"
jumptrue 52
testis "jump"
jumptrue 50
testis "jumptrue"
jumptrue 48
testis "jumpfalse"
jumptrue 46
testis "testis"
jumptrue 44
testis "testclass"
jumptrue 42
testis "testbegins"
jumptrue 40
testis "testends"
jumptrue 38
testis "testeof"
jumptrue 36
testis "testtape"
jumptrue 34
testis "count"
jumptrue 32
testis "a+"
jumptrue 30
testis "a-"
jumptrue 28
testis "zero"
jumptrue 26
testis "cc"
jumptrue 24
testis "ll"
jumptrue 22
testis "escape"
jumptrue 20
testis "unescape"
jumptrue 18
testis "delim"
jumptrue 16
testis "state"
jumptrue 14
testis "quit"
jumptrue 12
testis "bail"
jumptrue 10
testis "write"
jumptrue 8
testis "nop"
jumptrue 6
testis "reparse"
jumptrue 4
testis "restart"
jumptrue 2 
jump block.end.17250
  put
  clear
  add "word*"
  push
  jump parse
block.end.17250:
#------------ 
# the .reparse command and "parse label" is a simple way to 
# make sure that all shift-reductions occur. It should be used inside
# a block test, so as not to create an infinite loop.
testis "parse>"
jumpfalse block.end.17566
  clear
  add "parse:"
  put
  clear
  add "command*"
  push
  jump parse
block.end.17566:
# --------------------
# try to implement begin-blocks, which are only executed
# once, at the beginning of the script (similar to awk's BEGIN {} rules)
testis "begin"
jumpfalse block.end.17782
  put
  add "*"
  push
  jump parse
block.end.17782:
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
# the lexing phase finishes here, and below is the 
# parse/compile phase of the script. Here we pop tokens 
# off the stack and check for sequences of tokens eg word*semicolon*
# If we find a valid series of tokens, we "shift-reduce" or "resolve"
# the token series eg word*semicolon* --> command*
# At the same time, we manipulate (transform) the attributes on the 
# tape, as required. So Tape=|pop|;| becomes |\npop| where the 
# bars | indicate tape cells. (2 tapes cells are merged into 1).
# Each time the stack is reduced, the tape must also be reduced
# 
parse:
#-------------------------------------
# 2 tokens
#-------------------------------------
pop
pop
# All of the below are currently errors, but may not
# be in the future if we expand the syntax of the parse
# language. Also consider:
#    begintext* endtext* quoteset* notclass*, !* ,* ;* B* E*
# It is nice to trap the errors here because we can emit some
# hopefully not-very-cryptic error messages with a line number.
# Otherwise the script writer has to debug with
#   pp -a asm.pp scriptfile -I
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
jump block.end.19642
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script (missing semicolon?) \n"
  print
  clear
  quit
block.end.19642:
testis "{*;*"
jumptrue 6
testis ";*;*"
jumptrue 4
testis "}*;*"
jumptrue 2 
jump block.end.19831
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: misplaced semi-colon? ; \n"
  print
  clear
  quit
block.end.19831:
testis ",*{*"
jumpfalse block.end.19999
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra comma in list? \n"
  print
  clear
  quit
block.end.19999:
testis "command*;*"
jumptrue 4
testis "commandset*;*"
jumptrue 2 
jump block.end.20186
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script: extra semi-colon? \n"
  print
  clear
  quit
block.end.20186:
testis "!*!*"
jumpfalse block.end.20447
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
block.end.20447:
testis "!*{*"
jumptrue 4
testis "!*;*"
jumptrue 2 
jump block.end.20756
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
block.end.20756:
testis ",*command*"
jumpfalse block.end.20926
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
block.end.20926:
testis "!*command*"
jumpfalse block.end.21125
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
block.end.21125:
testis ";*{*"
jumptrue 6
testis "command*{*"
jumptrue 4
testis "commandset*{*"
jumptrue 2 
jump block.end.21328
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
block.end.21328:
testis "{*}*"
jumpfalse block.end.21459
  push
  push
  add "error near line "
  ll
  add " of script: empty braces {}. \n"
  print
  clear
  quit
block.end.21459:
testis "}*command*"
jumpfalse block.end.21606
  push
  push
  add "error near line "
  ll
  add " of script: extra closing brace '}' ?. \n"
  print
  clear
  quit
block.end.21606:
# -------------
# 2 token end-of-stream errors
testeof 
jumpfalse block.end.21830
  testis "command*}*"
  jumpfalse block.end.21826
    push
    push
    add "error near line "
    ll
    add " of script: extra closing brace '}' ?. \n"
    print
    clear
    quit
  block.end.21826:
block.end.21830:
#------------ 
# the .restart command just jumps to the start: label 
# (which is usually followed by a "read" command)
# but '.' is also the AND concatenator, which seems ambiguous,
# but seems to work.
testis ".*word*"
jumpfalse block.end.22520
  clear
  ++
  get
  --
  testis "restart"
  jumpfalse block.end.22198
    clear
    add "jump start"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.22198:
  testis "reparse"
  jumpfalse block.end.22313
    clear
    add "jump parse"
    put
    clear
    add "command*"
    push
    jump parse
  block.end.22313:
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
block.end.22520:
#-----------------------------------------
# compiling comments so as to transfer them to the compiled 
# file. Improve this by just forming rules for
# command*comment* and comment*command* and comment*comment*
# implement these rules to conserve comments
testis "comment*command*"
jumpfalse block.end.22829
  nop
block.end.22829:
testis "command*comment*"
jumpfalse block.end.22866
  nop
block.end.22866:
testis "comment*comment*"
jumpfalse block.end.22903
  nop
block.end.22903:
testends "comment*"
jumpfalse block.end.23153
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.23073
    jump start
  block.end.23073:
  clear
  --
  get
  ++
  add "\n"
  get
  --
  put
  ++
  clear
  jump parse
block.end.23153:
#-----------------------------------------
# There is a problem, that attaching comments to { or } or 
# other trivial tokens makes them disappear because we 
# dont retrieve the attribute for those tokens.
testbegins "comment*"
jumpfalse block.end.23770
  push
  # avoid an infinite loop if only one token on the stack
  testis ""
  jumpfalse block.end.23538
    jump start
  block.end.23538:
  # some tricky juggling of the unknown token
  # get rid of comment* token but conserve other one.
  ++
  put
  pop
  clear
  ++
  get
  push
  clear
  --
  --
  --
  get
  ++
  add "\n"
  get
  --
  put
  ++
  clear
  jump parse
block.end.23770:
# -----------------------
# negated tokens.
# This is a new more elegant way to negate a whole set of 
# tests (tokens) where the negation logic is stored on the 
# stack, not in the current tape cell. We just add "not" to 
# the stack token.
# eg: ![:alpha:] ![a-z] ![abcd] !"abc" !B"abc" !E"xyz"
#  This format is used to indicate a negative class test for 
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
jump block.end.24697
  push
  ++
  put
  --
  clear
  pop
  clear
  add "not"
  # extract the saved token name from the tape
  ++
  ++
  get
  --
  --
  # now we have a token "notquote*" / "notclass*" / "notbegintext*
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.24697:
#-----------------------------------------
# format: E"text" or E'text'
#  This format is used to indicate a "workspace-ends-with" text before
#  a brace block.
testis "E*quote*"
jumpfalse block.end.24969
  clear
  add "endtext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.24969:
#-----------------------------------------
# format: B"sometext" or B'sometext' 
#   A 'B' preceding some quoted text is used to indicate a 
#   'workspace-begins-with' test, before a brace block.
testis "B*quote*"
jumpfalse block.end.25280
  clear
  add "begintext*"
  push
  get
  --
  put
  ++
  clear
  jump parse
block.end.25280:
#--------------------------------------------
# ebnf: command := word, ';' ;
# formats: "pop; push; clear; print; " etc
# all commands need to end with a semi-colon except for 
# .reparse and .restart
testis "word*;*"
jumpfalse block.end.25973
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
  jump block.end.25843
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
  block.end.25843:
  clear
  add "command*"
  # no need to format tape cells because current cell contains word
  push
  jump parse
block.end.25973:
#-----------------------------------------
# ebnf: commandset := command , command ;
testis "command*command*"
jumptrue 4
testis "commandset*command*"
jumptrue 2 
jump block.end.26297
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
block.end.26297:
#-------------------
# here we begin to parse "test*" and "ortestset*" and "andtestset*"
# 
#-------------------
# eg: B"abc" {} or E"xyz" {}
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
jump block.end.27320
  zero
  testbegins "begin"
  jumpfalse block.end.26613
    clear
    add "testbegins "
  block.end.26613:
  testbegins "end"
  jumpfalse block.end.26652
    clear
    add "testends "
  block.end.26652:
  testbegins "quote"
  jumpfalse block.end.26691
    clear
    add "testis "
  block.end.26691:
  testbegins "class"
  jumpfalse block.end.26733
    clear
    add "testclass "
  block.end.26733:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.26865
    clear
    put
    add "testeof "
  block.end.26865:
  testbegins "tapetest"
  jumpfalse block.end.26914
    clear
    put
    add "testtape "
  block.end.26914:
  get
  add "\n"
  add "jumptrue 2 \n"
  # this extra jump has utility when we parse ortestsets and
  # andtestsets.
  add "jump block.end."
  # the final jumpfalse + target will be added when
  # "test*{*commandset*}*" is parsed, or when
  # "ortestset*{*commandset*}*"
  # "andtestset*{*commandset*}*"
  put
  a+
  a+
  a+
  a+
  clear
  add "test*{*"
  push
  push
  jump parse
block.end.27320:
#-------------------
# negated tests
# eg: !B"xyz {} 
#     !E"xyz" {} 
#     !"abc" {}
#     ![a-z] {}
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
jump block.end.28289
  zero
  testbegins "notbegin"
  jumpfalse block.end.27619
    clear
    add "testbegins "
  block.end.27619:
  testbegins "notend"
  jumpfalse block.end.27661
    clear
    add "testends "
  block.end.27661:
  testbegins "notquote"
  jumpfalse block.end.27703
    clear
    add "testis "
  block.end.27703:
  testbegins "notclass"
  jumpfalse block.end.27748
    clear
    add "testclass "
  block.end.27748:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "noteof"
  jumpfalse block.end.27883
    clear
    put
    add "testeof "
  block.end.27883:
  testbegins "nottapetest"
  jumpfalse block.end.27935
    clear
    put
    add "testtape "
  block.end.27935:
  get
  add "\n"
  add "jumpfalse 2 \n"
  # this extra jump has utility when we parse ortestsets and
  # andtestsets.
  add "jump block.end."
  # the final jumpfalse + target will be added later
  # use the accumulator to store the incremented jump target
  put
  a+
  a+
  a+
  a+
  clear
  add "test*{*"
  push
  push
  jump parse
block.end.28289:
#-------------------
# 3 tokens
#-------------------
pop
#-----------------------------
# some 3 token errors!!!
# there are many other of these errors but I am not going
# to write them all.
testis "{*quote*;*"
jumptrue 8
testis "{*begintext*;*"
jumptrue 6
testis "{*endtext*;*"
jumptrue 4
testis "{*class*;*"
jumptrue 2 
jump block.end.28730
  push
  push
  push
  add "error near line "
  ll
  add " (char "
  cc
  add ")"
  add " of script (misplaced semicolon?) \n"
  print
  clear
  quit
block.end.28730:
# to simplify subsequent tests, transmogrify a single command
# to a commandset (multiple commands).
testis "{*command*}*"
jumpfalse block.end.28926
  clear
  add "{*commandset*}*"
  push
  push
  push
  jump parse
block.end.28926:
# rule 
#',' ortestset ::= ',' test '{'
# trigger a transmogrification from test to ortestset token
# and 
# '.' andtestset ::= '.' test '{'
testis ",*test*{*"
jumpfalse block.end.29163
  clear
  add ",*ortestset*{*"
  push
  push
  push
  jump parse
block.end.29163:
# trigger a transmogrification from "test" to "andtest" by
# looking backwards in the stack
testis ".*test*{*"
jumpfalse block.end.29400
  a-
  clear
  add ".*andtestset*{*"
  push
  push
  push
  jump parse
block.end.29400:
# errors! mixing AND and OR concatenation
testis ",*andtestset*{*"
jumptrue 4
testis ".*ortestset*{*"
jumptrue 2 
jump block.end.29732
  push
  push
  push
  add " error: mixing AND (.) and OR (,) concatenation in \n"
  add " in script near line "
  ll
  add " (character "
  cc
  add ") \n"
  print
  clear
  quit
block.end.29732:
#--------------------------------------------
# ebnf: command := keyword , quoted-text , ";" ;
# format: add "text";
testis "word*quote*;*"
jumpfalse block.end.30535
  clear
  get
  testis "replace"
  jumpfalse block.end.30072
    add "< command requires 2 parameters, not 1 \n"
    add "near line "
    ll
    add " of script. \n"
    print
    clear
    quit
  block.end.30072:
  testis "add"
  jumptrue 18
  testis "until"
  jumptrue 16
  testis "while"
  jumptrue 14
  testis "whilenot"
  jumptrue 12
  testis "escape"
  jumptrue 10
  testis "mark"
  jumptrue 8
  testis "go"
  jumptrue 6
  testis "unescape"
  jumptrue 4
  testis "delim"
  jumptrue 2 
  jump block.end.30347
    clear
    add "command*"
    push
    # a command plus argument, eg add "this" 
    --
    get
    add " "
    ++
    get
    --
    put
    ++
    clear
    jump parse
  block.end.30347:
  # error, superfluous argument
  add ": command does not take an argument \n"
  add "near line "
  ll
  add " of script. \n"
  print
  clear
  #state
  quit
block.end.30535:
#----------------------------------
# format: "while [:alpha:] ;" or whilenot [a-z] ;
testis "word*class*;*"
jumpfalse block.end.31043
  clear
  get
  testis "while"
  jumptrue 4
  testis "whilenot"
  jumptrue 2 
  jump block.end.30893
    clear
    add "command*"
    push
    # a command plus argument, eg while [a-z] 
    --
    get
    add " "
    ++
    get
    --
    put
    ++
    clear
    jump parse
  block.end.30893:
  # error 
  add " < command cannot have a class argument \n"
  add "line "
  ll
  add ": error in script \n"
  print
  clear
  quit
block.end.31043:
# -------------------------------
# 4 tokens
# -------------------------------
pop
#-------------------------------------
# ebnf:     command := replace , quote , quote , ";" ;
# example:  replace "and" "AND" ; 
testis "word*quote*quote*;*"
jumpfalse block.end.31704
  clear
  get
  testis "replace"
  jumpfalse block.end.31584
    clear
    add "command*"
    push
    #---------------------------
    # a command plus 2 arguments, eg replace "this" "that"
    --
    get
    add " "
    ++
    get
    add " "
    ++
    get
    --
    --
    put
    ++
    clear
    jump parse
  block.end.31584:
  add " << command does not take 2 quoted arguments. \n"
  add " on line "
  ll
  add " of script.\n"
  quit
block.end.31704:
#-------------------------------------
# format: begin { #* commands *# }
# "begin" blocks which are only executed once (they
# will are assembled before the "start:" label. They must come before
# all other commands.
# "begin*{*command*}*",
testis "begin*{*commandset*}*"
jumpfalse block.end.32088
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
block.end.32088:
# -------------
# parses and compiles concatenated tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
testis "begintext*,*ortestset*{*"
jumptrue 12
testis "endtext*,*ortestset*{*"
jumptrue 10
testis "quote*,*ortestset*{*"
jumptrue 8
testis "class*,*ortestset*{*"
jumptrue 6
testis "eof*,*ortestset*{*"
jumptrue 4
testis "tapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.33012
  testbegins "begin"
  jumpfalse block.end.32417
    clear
    add "testbegins "
  block.end.32417:
  testbegins "end"
  jumpfalse block.end.32457
    clear
    add "testends "
  block.end.32457:
  testbegins "quote"
  jumpfalse block.end.32497
    clear
    add "testis "
  block.end.32497:
  testbegins "class"
  jumpfalse block.end.32540
    clear
    add "testclass "
  block.end.32540:
  # clear the tapecell for testeof and testtape because
  # they take no arguments. 
  testbegins "eof"
  jumpfalse block.end.32675
    clear
    put
    add "testeof "
  block.end.32675:
  testbegins "tapetest"
  jumpfalse block.end.32725
    clear
    put
    add "testtape "
  block.end.32725:
  get
  add "\n"
  add "jumptrue "
  count
  add "\n"
  ++
  ++
  get
  --
  --
  put
  clear
  # this works as long as we dont mix AND and OR concatenations 
  # add "test*{*";
  # need to change to this
  add "ortestset*{*"
  push
  push
  a+
  a+
  jump parse
block.end.33012:
# A collection of negated tests.
testis "notbegintext*,*ortestset*{*"
jumptrue 12
testis "notendtext*,*ortestset*{*"
jumptrue 10
testis "notquote*,*ortestset*{*"
jumptrue 8
testis "notclass*,*ortestset*{*"
jumptrue 6
testis "noteof*,*ortestset*{*"
jumptrue 4
testis "nottapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.33809
  testbegins "notbegin"
  jumpfalse block.end.33284
    clear
    add "testbegins "
  block.end.33284:
  testbegins "notend"
  jumpfalse block.end.33327
    clear
    add "testends "
  block.end.33327:
  testbegins "notquote"
  jumpfalse block.end.33370
    clear
    add "testis "
  block.end.33370:
  testbegins "notclass"
  jumpfalse block.end.33416
    clear
    add "testclass "
  block.end.33416:
  testbegins "noteof"
  jumpfalse block.end.33463
    clear
    put
    add "testeof "
  block.end.33463:
  testbegins "nottapetest"
  jumpfalse block.end.33516
    clear
    put
    add "testtape "
  block.end.33516:
  get
  add "\n"
  add "jumpfalse "
  count
  add "\n"
  ++
  ++
  get
  --
  --
  put
  clear
  # this works as long as we dont mix AND and OR concatenations 
  add "ortestset*{*"
  # need to change to this
  # add "ortestset*{*";
  push
  push
  a+
  a+
  jump parse
block.end.33809:
# this works as long as we dont mix AND and OR concatenations 
# -------------
# AND logic 
# parses and compiles concatenated AND tests
# eg: 'a',B'b',E'c',[def],[:space:],[g-k] { ...
# it is possible to elide this block with the negated block
# for compactness but maybe readability is not as good.
testis "begintext*.*andtestset*{*"
jumptrue 12
testis "endtext*.*andtestset*{*"
jumptrue 10
testis "quote*.*andtestset*{*"
jumptrue 8
testis "class*.*andtestset*{*"
jumptrue 6
testis "eof*,*ortestset*{*"
jumptrue 4
testis "tapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.34737
  testbegins "begin"
  jumpfalse block.end.34351
    clear
    add "testbegins "
  block.end.34351:
  testbegins "end"
  jumpfalse block.end.34391
    clear
    add "testends "
  block.end.34391:
  testbegins "quote"
  jumpfalse block.end.34431
    clear
    add "testis "
  block.end.34431:
  testbegins "class"
  jumpfalse block.end.34474
    clear
    add "testclass "
  block.end.34474:
  testbegins "eof"
  jumpfalse block.end.34518
    clear
    put
    add "testeof "
  block.end.34518:
  testbegins "tapetest"
  jumpfalse block.end.34568
    clear
    put
    add "testtape "
  block.end.34568:
  get
  add "\n"
  add "jumpfalse "
  count
  add "\n"
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
  a+
  a+
  jump parse
block.end.34737:
# eg
# negated tests concatenated with AND logic (.). The 
# negated tests can be chained with non negated tests.
# eg: B'http' . !E'.txt' { ... }
testis "notbegintext*.*andtestset*{*"
jumptrue 12
testis "notendtext*.*andtestset*{*"
jumptrue 10
testis "notquote*.*andtestset*{*"
jumptrue 8
testis "notclass*.*andtestset*{*"
jumptrue 6
testis "noteof*,*ortestset*{*"
jumptrue 4
testis "nottapetest*,*ortestset*{*"
jumptrue 2 
jump block.end.35536
  testbegins "notbegin"
  jumpfalse block.end.35136
    clear
    add "testbegins "
  block.end.35136:
  testbegins "notend"
  jumpfalse block.end.35179
    clear
    add "testends "
  block.end.35179:
  testbegins "notquote"
  jumpfalse block.end.35222
    clear
    add "testis "
  block.end.35222:
  testbegins "notclass"
  jumpfalse block.end.35268
    clear
    add "testclass "
  block.end.35268:
  testbegins "noteof"
  jumpfalse block.end.35315
    clear
    put
    add "testeof "
  block.end.35315:
  testbegins "nottapetest"
  jumpfalse block.end.35368
    clear
    put
    add "testtape "
  block.end.35368:
  get
  add "\n"
  add "jumptrue "
  count
  add "\n"
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
  a+
  a+
  jump parse
block.end.35536:
#-------------------------------------
# we should not have to check for the {*command*}* pattern
# because that has already been transformed to {*commandset*}*
testis "test*{*commandset*}*"
jumptrue 6
testis "andtestset*{*commandset*}*"
jumptrue 4
testis "ortestset*{*commandset*}*"
jumptrue 2 
jump block.end.36607
  testbegins "test*{*"
  jumpfalse block.end.36157
    clear
    # get rid of unnecessary jump but only in "test" cases 
    get
    # for positive tests (eg [a-z] {...})
    replace "jumptrue 2 \njump" "jumpfalse"
    put
    # for negative tests (eg ![a-z] {...})
    replace "jumpfalse 2 \njump" "jumptrue"
    put
  block.end.36157:
  clear
  ++
  ++
  add "  "
  get
  replace "\n" "\n  "
  put
  --
  --
  clear
  get
  # the final jump (to the closing brace) has already been
  # coded in the "test*{*" rule or the other rules.
  # we just need to add the label number with "cc"
  cc
  add "\n"
  ++
  ++
  get
  add "\nblock.end."
  cc
  add ":"
  --
  --
  put
  clear
  add "command*"
  push
  # always reparse/compile
  jump parse
block.end.36607:
# put the 4 (or less) tokens back on the stack
push
push
push
push
testeof 
jumpfalse block.end.38330
  print
  clear
  #---------------------
  # check if the script correctly parsed (there should only
  # be one token on the stack, namely "commandset*" or "command*"
  pop
  pop
  testis "commandset*"
  jumptrue 4
  testis "command*"
  jumptrue 2 
  jump block.end.37343
    push
    --
    add "# Assembled with the script 'compile.pss' \n"
    add "start:\n"
    get
    # an extra space because of a bug in compile()
    add "\njump start \n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    # print
    # save the compiled script to 'sav.pp'
    write
    clear
    quit
  block.end.37343:
  testis "beginblock*commandset*"
  jumptrue 4
  testis "beginblock*command*"
  jumptrue 2 
  jump block.end.37824
    clear
    add "# Assembled with the script 'compile.pss' \n"
    get
    add "\n"
    ++
    add "start:\n"
    get
    # an extra space because of a bug in compile()
    add "\njump start \n"
    # put a copy of the final compilation into the tapecell
    # so it can be inspected interactively.
    put
    # print
    # also save the compiled script to 'sav.pp'
    write
    clear
    quit
  block.end.37824:
  push
  push
  # state
  clear
  add "After compiling with 'compile.pss' (at EOF): \n "
  add "  parse error in input script, check syntax: \n "
  add "  To debug script try the -I switch with \n "
  add "   >> pp -If script -i 'some input' \n "
  add "  or to debug the compilation process try: \n "
  add "   >> pp -Ia asm.pp script' \n "
  print
  clear
  # clear sav.pp because script could not be compiled
  write
  # bail means exit with error
  bail
block.end.38330:
# not eof
# there is an implicit .restart command here (jump start)
jump start 
