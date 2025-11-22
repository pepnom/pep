
INSTALL_PATH?=/usr/local

objects = \
  tapecell.c tape.c buffer.c colours.c \
  charclass.c command.c parameter.c instruction.c \
  labeltable.c program.c machine.c exitcode.c \
  machine.methods.c machine.interp.c

# compile the ompp tool using the object files in the "object" folder.
# this needs to become a make file.
h=~/sf/htdocs/books/pars
f=~/sf/htdocs/books/pars/object

# build the pep engine (byte char c) 
pep: pep.c $(objects)
	gcc -o ../pep pep.c $(objects)

#pep: gh.c $(objects)
#	gcc -o ../pep gh.c $(objects)

# pepper is an interactive debugger, but so is pep 
pepper: ompp.c $(objects)
	gcc -o ../pepper ompp.c $(objects) 

# compile the pep tool with -g switch for valgrind debugging
vpp: pep.c $(objects) 
	gcc -g -o ../vpp pep.c $(objects)
#vpp: gh.c $(objects) 
#	gcc -g -o ../vpp gh.c $(objects)

# make install should do
# copy pep to /usr/local/bin
# copy pep.1.gz to /usr/share/man/man1/  (man page)
# copy asm.pp to /usr/local/etc/
# an example install target using the 'install' program for permissions
#install: somefile.a
#        install -d $(DESTDIR)$(PREFIX)/lib/
#        install -m 644 unixlib.a $(DESTDIR)$(PREFIX)/lib/
#        install -d $(DESTDIR)$(PREFIX)/include/
#        install -m 644 unixlib.h $(DESTDIR)$(PREFIX)/include/ 
