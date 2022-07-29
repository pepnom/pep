# -------
# testing line counting

start:
 read
 clear
 testeof
 jumpfalse not.eof
   add "lines = " 
   ll
   add "\n"
   print 
   quit
not.eof:
jump start
nop
