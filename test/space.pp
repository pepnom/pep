#
# convert all spaces to dots 
# Test this with 
#   pp -sa space.pp

start:

  read
  testeof
  jumpfalse not.eof
  add "from space script"
  write
not.eof:

  testclass [:space:]
  jumpfalse not.space
    clear
    add "."
    print
    clear
    jump start
not.space:
  print
  clear

  jump start
