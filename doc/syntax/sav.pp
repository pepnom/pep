# Assembled with the script 'compile.pss' 
add "local quotetable = {\n"
print
clear
start:
read
testclass [:space:]
jumpfalse block.end.688
  clear
block.end.688:
# the author
testis "*"
jumpfalse block.end.823
  while [ \t]
  clear
  until "\n"
  clip
  escape "\""
  put
  clear
  add "[\""
  get
  add "\"] = "
  print
block.end.823:
# the quote between """ and """
testis "\""
jumpfalse block.end.1003
  while ["]
  while [ \t]
  clear
  until "\"\"\""
  clip
  clip
  clip
  escape "\""
  put
  clear
  add "[["
  get
  add "]],\n"
  print
block.end.1003:
# ignore all other structures
testis ""
jumptrue block.end.1055
  clear
block.end.1055:
parse:
testeof 
jumpfalse block.end.1508
  add "}\n"
  print
  clear
  add "\n"
  add "\n"
  add "    -- iterate over whole table to get all keys\n"
  add "    local keyset = {}\n"
  add "    for k in pairs(quotetable) do\n"
  add "        table.insert(keyset, k)\n"
  add "    end\n"
  add "    -- get a random key and value\n"
  add "    author = keyset[math.random(#keyset)]\n"
  add "    quote = quotetable[author]\n"
  add "\n"
  add "    print ('<blockquote class=\"quotation\">\\n'..quote)\n"
  add "    print ('<cite>'..author..'</cite>')\n"
  add "    print ('</blockquote>')\n"
  add "\n"
  add "   "
  print
block.end.1508:
jump start 
