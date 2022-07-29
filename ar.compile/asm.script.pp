start:
read
testclass [:space:]
jumpfalse not.in.class.4109
clear
jump 0
not.in.class.4109:
testis "{"
jumptrue 3 
testis "}"
jumptrue 4 
 jumptrue 3 
 testis ";"
jumptrue 4 
 jumptrue 3 
 testis ","
jumptrue 4 
 jumptrue 3 
 testis "!"
jumptrue 4 
 jumptrue 3 
 testis "B"
jumptrue 4 
 jumptrue 3 
 testis "E"

jumpfalse not.quoteset.text.4330
put
add "*"
push
jump parse
not.quoteset.text.4330:
testis "\""
jumpfalse not.text.4446
until "\""
put
clear
add "quote*"
push
jump parse
not.text.4446:
testis "'"
jumpfalse not.text.4656
clear
add "\""
until "'"
clip
add "\""
put
clear
add "quote*"
push
jump parse
not.text.4656:
testis "["
jumpfalse not.text.4803
until "]"
put
clear
add "class*"
push
jump parse
not.text.4803:
testis "("
jumpfalse not.text.4996
clear
until ")"
clip
put
clear
add "state*"
push
jump parse
not.text.4996:
testis "#"
jumpfalse not.text.5630
clear
read
testis "\n"
jumpfalse not.text.5132
clear
jump 0
not.text.5132:
testis "*"
jumpfalse not.text.5576
until "*#"
testends "*#"
jumpfalse not.ends.5329
clear
jump 0
not.ends.5329:
clear
add "unterminated multiline comment #* ... *# \n"
add "see also 'until' bug in gh.c \n"
print
clear
quit
not.text.5576:
until "\n"
clear
jump 0
not.text.5630:
testclass [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^.]
jumptrue is.in.class.6011
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
is.in.class.6011:
while [abcdefghijklmnopqrstuvwxyzBEKGPRWS+-<>0^.]
testis "a"
jumpfalse not.text.6550
clear
add "add"
not.text.6550:
testis "k"
jumpfalse not.text.6580
clear
add "clip"
not.text.6580:
testis "K"
jumpfalse not.text.6610
clear
add "clop"
not.text.6610:
testis "D"
jumpfalse not.text.6643
clear
add "replace"
not.text.6643:
testis "d"
jumpfalse not.text.6674
clear
add "clear"
not.text.6674:
testis "t"
jumpfalse not.text.6705
clear
add "print"
not.text.6705:
testis "p"
jumpfalse not.text.6734
clear
add "pop"
not.text.6734:
testis "P"
jumpfalse not.text.6764
clear
add "push"
not.text.6764:
testis "G"
jumpfalse not.text.6793
clear
add "put"
not.text.6793:
testis "g"
jumpfalse not.text.6822
clear
add "get"
not.text.6822:
testis "x"
jumpfalse not.text.6852
clear
add "swap"
not.text.6852:
testis ">"
jumpfalse not.text.6880
clear
add "++"
not.text.6880:
testis "<"
jumpfalse not.text.6908
clear
add "--"
not.text.6908:
testis "r"
jumpfalse not.text.6938
clear
add "read"
not.text.6938:
testis "R"
jumpfalse not.text.6969
clear
add "until"
not.text.6969:
testis "w"
jumpfalse not.text.7000
clear
add "while"
not.text.7000:
testis "W"
jumpfalse not.text.7034
clear
add "whilenot"
not.text.7034:
testis "b"
jumpfalse not.text.7194
clear
add "jump"
not.text.7194:
testis "j"
jumpfalse not.text.7228
clear
add "jumptrue"
not.text.7228:
testis "J"
jumpfalse not.text.7263
clear
add "jumpfalse"
not.text.7263:
testis "="
jumpfalse not.text.7295
clear
add "testis"
not.text.7295:
testis "?"
jumpfalse not.text.7330
clear
add "testclass"
not.text.7330:
testis "b"
jumpfalse not.text.7366
clear
add "testbegins"
not.text.7366:
testis "B"
jumpfalse not.text.7400
clear
add "testends"
not.text.7400:
testis "E"
jumpfalse not.text.7433
clear
add "testeof"
not.text.7433:
testis "*"
jumpfalse not.text.7467
clear
add "testtape"
not.text.7467:
testis "n"
jumpfalse not.text.7498
clear
add "count"
not.text.7498:
testis "+"
jumpfalse not.text.7526
clear
add "a+"
not.text.7526:
testis "-"
jumpfalse not.text.7554
clear
add "a-"
not.text.7554:
testis "0"
jumpfalse not.text.7584
clear
add "zero"
not.text.7584:
testis "c"
jumpfalse not.text.7612
clear
add "cc"
not.text.7612:
testis "l"
jumpfalse not.text.7640
clear
add "ll"
not.text.7640:
testis "^"
jumpfalse not.text.7672
clear
add "escape"
not.text.7672:
testis "v"
jumpfalse not.text.7706
clear
add "unescape"
not.text.7706:
testis "S"
jumpfalse not.text.7737
clear
add "state"
not.text.7737:
testis "q"
jumpfalse not.text.7767
clear
add "quit"
not.text.7767:
testis "Q"
jumpfalse not.text.7797
clear
add "bail"
not.text.7797:
testis "s"
jumpfalse not.text.7828
clear
add "write"
not.text.7828:
testis "o"
jumpfalse not.text.7857
clear
add "nop"
not.text.7857:
testis "add"
jumptrue 3 
testis "clip"
jumptrue 4 
 jumptrue 3 
 testis "clop"
jumptrue 4 
 jumptrue 3 
 testis "replace"
jumptrue 4 
 jumptrue 3 
 testis "clear"
jumptrue 4 
 jumptrue 3 
 testis "print"
jumptrue 4 
 jumptrue 3 
 testis "pop"
jumptrue 4 
 jumptrue 3 
 testis "push"
jumptrue 4 
 jumptrue 3 
 testis "put"
jumptrue 4 
 jumptrue 3 
 testis "get"
jumptrue 4 
 jumptrue 3 
 testis "swap"
jumptrue 4 
 jumptrue 3 
 testis "++"
jumptrue 4 
 jumptrue 3 
 testis "--"
jumptrue 4 
 jumptrue 3 
 testis "read"
jumptrue 4 
 jumptrue 3 
 testis "until"
jumptrue 4 
 jumptrue 3 
 testis "while"
jumptrue 4 
 jumptrue 3 
 testis "whilenot"
jumptrue 4 
 jumptrue 3 
 testis "jump"
jumptrue 4 
 jumptrue 3 
 testis "jumptrue"
jumptrue 4 
 jumptrue 3 
 testis "jumpfalse"
jumptrue 4 
 jumptrue 3 
 testis "testis"
jumptrue 4 
 jumptrue 3 
 testis "testclass"
jumptrue 4 
 jumptrue 3 
 testis "testbegins"
jumptrue 4 
 jumptrue 3 
 testis "testends"
jumptrue 4 
 jumptrue 3 
 testis "testeof"
jumptrue 4 
 jumptrue 3 
 testis "testtape"
jumptrue 4 
 jumptrue 3 
 testis "count"
jumptrue 4 
 jumptrue 3 
 testis "a+"
jumptrue 4 
 jumptrue 3 
 testis "a-"
jumptrue 4 
 jumptrue 3 
 testis "zero"
jumptrue 4 
 jumptrue 3 
 testis "cc"
jumptrue 4 
 jumptrue 3 
 testis "ll"
jumptrue 4 
 jumptrue 3 
 testis "escape"
jumptrue 4 
 jumptrue 3 
 testis "unescape"
jumptrue 4 
 jumptrue 3 
 testis "state"
jumptrue 4 
 jumptrue 3 
 testis "quit"
jumptrue 4 
 jumptrue 3 
 testis "bail"
jumptrue 4 
 jumptrue 3 
 testis "write"
jumptrue 4 
 jumptrue 3 
 testis "nop"

jumpfalse not.quoteset.text.8264
put
clear
add "word*"
push
jump parse
not.quoteset.text.8264:
testis ".restart"
jumpfalse not.text.8478
clear
add "jump 0"
put
clear
add "command*"
push
jump parse
not.text.8478:
testis ".reparse"
jumpfalse not.text.8796
clear
add "jump parse"
put
clear
add "command*"
push
jump parse
not.text.8796:
testis "parse>"
jumpfalse not.text.8896
clear
add "parse:"
put
clear
add "command*"
push
jump parse
not.text.8896:
add " << unknown command on line "
ll
add " (char "
cc
add ")"
add " of source file. \n"
print
clear
quit
parse:
pop
pop
testis "word*word*"
jumptrue 3 
testis "word*}*"
jumptrue 4 
 jumptrue 3 
 testis "quote*word*"
jumptrue 4 
 jumptrue 3 
 testis "quote*class*"
jumptrue 4 
 jumptrue 3 
 testis "quote*state*"
jumptrue 4 
 jumptrue 3 
 testis "quote*}*"
jumptrue 4 
 jumptrue 3 
 testis "class*word*"
jumptrue 4 
 jumptrue 3 
 testis "class*quote*"
jumptrue 4 
 jumptrue 3 
 testis "class*class*"
jumptrue 4 
 jumptrue 3 
 testis "class*state*"
jumptrue 4 
 jumptrue 3 
 testis "class*}*"
jumptrue 4 
 jumptrue 3 
 testis "notclass*word*"
jumptrue 4 
 jumptrue 3 
 testis "notclass*quote*"
jumptrue 4 
 jumptrue 3 
 testis "notclass*class*"
jumptrue 4 
 jumptrue 3 
 testis "notclass*state*"
jumptrue 4 
 jumptrue 3 
 testis "notclass*}*"

jumpfalse not.quoteset.text.10602
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
not.quoteset.text.10602:
testis "{*;*"
jumptrue 3 
testis ";*;*"
jumptrue 4 
 jumptrue 3 
 testis "}*;*"

jumpfalse not.quoteset.text.10791
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
not.quoteset.text.10791:
testis ",*{*"
jumpfalse not.text.10959
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
not.text.10959:
testis "!*{*"
jumpfalse not.text.11139
push
push
add "error near line "
ll
add " (char "
cc
add ")"
add " of script: misplaced negation operator (!)? \n"
print
clear
quit
not.text.11139:
testis "!*command*"
jumptrue 3 
testis "!*quote*"

jumpfalse not.quoteset.text.11352
push
push
add "error near line "
ll
add " (char "
cc
add ") \n"
add " The negation operator (!) is not valid in this context. \n"
print
clear
quit
not.quoteset.text.11352:
testis ";*{*"
jumptrue 3 
testis "command*{*"
jumptrue 4 
 jumptrue 3 
 testis "commandset*{*"

jumpfalse not.quoteset.text.11555
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
not.quoteset.text.11555:
testis "{*}*"
jumpfalse not.text.11686
push
push
add "error near line "
ll
add " of script: empty braces {}. \n"
print
clear
quit
not.text.11686:
testis "!*class*"
jumpfalse not.text.11985
clear
add "notclass*"
push
get
--
put
++
clear
jump parse
not.text.11985:
testis "E*quote*"
jumpfalse not.text.12257
clear
add "endtext*"
push
get
--
put
++
clear
jump parse
not.text.12257:
testis "B*quote*"
jumpfalse not.text.12568
clear
add "begintext*"
push
get
--
put
++
clear
jump parse
not.text.12568:
testis "word*;*"
jumpfalse not.text.13162
clear
get
testis "add"
jumptrue 3 
testis "until"
jumptrue 4 
 jumptrue 3 
 testis "while"
jumptrue 4 
 jumptrue 3 
 testis "whilenot"
jumptrue 4 
 jumptrue 3 
 testis "escape"
jumptrue 4 
 jumptrue 3 
 testis "unescape"
jumptrue 4 
 jumptrue 3 
 testis "replace"

jumpfalse not.quoteset.text.13032
add " < command needs an argument, on line: "
ll
print
clear
quit
not.quoteset.text.13032:
clear
add "command*"
push
jump parse
not.text.13162:
testis "command*command*"
jumptrue 3 
testis "commandset*command*"

jumpfalse not.quoteset.text.13489
clear
add "commandset*"
push
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
not.quoteset.text.13489:
pop
testis "quote*,*quote*"
jumpfalse not.text.14188
clear
add "testis "
get
add "\njumptrue 3 \n"
++
++
add "testis "
get
add "\n"
--
--
put
clear
add "quoteset*"
push
jump parse
not.text.14188:
testis "quoteset*,*quote*"
jumpfalse not.text.14565
clear
get
++
++
add "jumptrue 4 \n "
add "jumptrue 3 \n "
add "testis "
get
add "\n"
--
--
put
clear
add "quoteset*"
push
jump parse
not.text.14565:
testis "word*quote*;*"
jumpfalse not.text.15375
clear
get
testis "replace"
jumpfalse not.text.14917
add "< command requires 2 parameters, not 1 \n"
add "near line "
ll
add " of script. \n"
print
clear
quit
not.text.14917:
testis "add"
jumptrue 3 
testis "until"
jumptrue 4 
 jumptrue 3 
 testis "while"
jumptrue 4 
 jumptrue 3 
 testis "whilenot"
jumptrue 4 
 jumptrue 3 
 testis "escape"
jumptrue 4 
 jumptrue 3 
 testis "unescape"

jumpfalse not.quoteset.text.15179
clear
add "command*"
push
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
not.quoteset.text.15179:
add ": command does not take an argument \n"
add "near line "
ll
add " of script. \n"
print
clear
quit
not.text.15375:
testis "word*class*;*"
jumpfalse not.text.15882
clear
get
testis "while"
jumptrue 3 
testis "whilenot"

jumpfalse not.quoteset.text.15732
clear
add "command*"
push
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
not.quoteset.text.15732:
add " < command cannot have a class argument \n"
add "line "
ll
add ": error in script \n"
print
clear
quit
not.text.15882:
pop
testis "word*quote*quote*;*"
jumpfalse not.text.16529
clear
get
testis "replace"
jumpfalse not.text.16409
clear
add "command*"
push
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
not.text.16409:
add " << command does not take 2 quoted arguments. \n"
add " on line "
ll
add " of script.\n"
quit
not.text.16529:
testis "quote*{*commandset*}*"
jumptrue 3 
testis "quote*{*command*}*"

jumpfalse not.quoteset.text.17044
clear
add "testis "
get
add "\njumpfalse not.text."
cc
add "\n"
++
++
get
add "\nnot.text."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.quoteset.text.17044:
testis "quoteset*{*commandset*}*"
jumptrue 3 
testis "quoteset*{*command*}*"

jumpfalse not.quoteset.text.17660
clear
get
add "\njumpfalse not.quoteset.text."
cc
add "\n"
++
++
get
add "\nnot.quoteset.text."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.quoteset.text.17660:
testis "begintext*{*commandset*}*"
jumptrue 3 
testis "begintext*{*command*}*"

jumpfalse not.quoteset.text.18153
clear
add "testbegins "
get
add "\njumpfalse not.begins."
cc
add "\n"
++
++
get
add "\nnot.begins."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.quoteset.text.18153:
testis "endtext*{*commandset*}*"
jumptrue 3 
testis "endtext*{*command*}*"

jumpfalse not.quoteset.text.18649
clear
add "testends "
get
add "\njumpfalse not.ends."
cc
add "\n"
++
++
get
add "\nnot.ends."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.quoteset.text.18649:
testis "class*{*commandset*}*"
jumptrue 3 
testis "class*{*command*}*"

jumpfalse not.quoteset.text.19227
clear
add "testclass "
get
add "\njumpfalse not.in.class."
cc
add "\n"
++
++
get
add "\nnot.in.class."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.quoteset.text.19227:
testis "notclass*{*commandset*}*"
jumptrue 3 
testis "notclass*{*command*}*"

jumpfalse not.quoteset.text.19789
clear
add "testclass "
get
add "\njumptrue is.in.class."
cc
add "\n"
++
++
get
add "\nis.in.class."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.quoteset.text.19789:
testis "state*{*commandset*}*"
jumptrue 3 
testis "state*{*command*}*"

jumpfalse not.quoteset.text.20759
clear
get
testis "eof"
jumpfalse not.text.20210
clear
add "testeof "
add "\njumpfalse not.eof."
cc
add "\n"
++
++
get
add "\nnot.eof."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.text.20210:
testis "=="
jumpfalse not.text.20499
clear
add "testtape "
add "\njumpfalse not.testtape."
cc
add "\n"
++
++
get
add "\nnot.testtape."
cc
--
--
add ":"
put
clear
add "command*"
push
jump parse
not.text.20499:
add ": unknown state test near line "
ll
add " of script.\n"
add " State tests are \n"
add "   (eof) test if end of stream reached. \n"
add "   (==)  test if workspace is same as current tape cell \n"
print
clear
quit
not.quoteset.text.20759:
push
push
push
push
testeof 
jumpfalse not.eof.21759
print
clear
pop
pop
testis "commandset*"
jumptrue 3 
testis "command*"

jumpfalse not.quoteset.text.21399
push
--
add "start:\n"
get
add "\njump start \n"
put
write
clear
quit
not.quoteset.text.21399:
push
push
clear
add "After compiling with 'compile.pss' (at EOF): \n "
add "  parse error in input script, check syntax or try \n "
add "  'pp -Ia asm.pp script' to debug compilation \n "
print
clear
write
bail
not.eof.21759:
jump start 
