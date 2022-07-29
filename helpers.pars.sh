#!/usr/bin/bash
# This file contains a number of bash functions to help in
# compiling and running the code in /books/pars/. Put a line like
#   >> source ~/sf/htdocs/books/pars/helpers.pep.sh
# into the .bashrc file so that these functions will be available
#
# HISTORY
#   27 june 2022
#     Adding some perl translation helpers.
#   15 june 2022
#     Adding an 'info' parameter to a number of functions, such as 
#     pep.gof pep.tcf pep.jaf etc. Another useful function would 
#     translate a pep script into all available languages and then
#     run the translated script with input, and check the output for
#     validity.
#   17 aug 2021
#     add 2nd gen java helper pep.jass also worked on pep.tt function
#   15 aug 2021
#     added 2nd gen testing for pep.tt, relies on 2nd generation
#     helper script such as "pep.rbss"
#   16 june 2021
#     Adding various functions, changing name to .peprc to be more unixy
#   15 june 2020
#     converting to use executable name "pep"
#   16 July 2019
#     began this file as helpers.pars.sh
#

# the name of the executable
name="pep"
# last name of folder where code tree is
dir="pars"
# base folder 
bdir="/home/wworth/sf/htdocs/books/pars"
# main server rsync url  
url="matth3wbishop,bumble@web.sf.net:htdocs/books/$dir"
# nearly free speech server rsync url  
nfsurl="mjbishop_holaday@ssh.phx.nearlyfreespeech.net:/home/public/books/$dir"

# this variable allows pep to find the assember script "asm.pp"
export ASMPP="/home/wworth/sf/htdocs/books/pars/"

#alias pep='cd ~/sf/htdocs/books/pars/; ./pep'
alias pep='$bdir/pep'
alias pp=pep
alias javapp='cd ~/sf/htdocs/ppj;ls'
alias ppj=javapp

function pep.pr {
  enscript -o - -2r -f Courier7 ~/sf/htdocs/books/pars/gh.c | ps2pdf - gh.pdf
}

# edits the helpers.pars.sh file and reloads it in .bashrc 
function peprc {
  vim ~/sf/htdocs/books/pars/helpers.pars.sh
  source ~/.bashrc
}

alias ghh=peprc

# compiles the machine.methods.c class 
function methcc {
  gcc machine.methods.c -o test 
}

# Compiles pep.c with no warnings 
function pepc {
  echo -e "
    Compiling 'pep.c' as executable '$name' 
    using datestamp: $(date +%d%b%Y-%I%P)"
  cd ~/sf/htdocs/books/pars
  # The line below adds the compile time and date to the version
  sed "/v31415\"; *$/s/v31415/$(date +%d%b%Y-%I%P)/" pep.c > pep.pre.c
  gcc pep.pre.c -o $name 
}

function pepbk {
  echo -e "
    Compiling 'pars-book.txt' as html into pars-book.html 
    Using the pep script 'eg/mark.html.pss' "
    # using datestamp: $(date +%d%b%Y-%I%P)"
  cd ~/sf/htdocs/books/pars
  # The line below adds the compile time 
  # sed "/v31415\"; *$/s/v31415/$(date +%d%b%Y-%I%P)/" pep.c > pep.pre.c
  pep -f eg/mark.html.pss pars-book.txt > pars-book.html
}

# Compiles code with all gcc warnings which is a good idea 
function pepw {
  echo -e "
    Compiling 'pep.c' as executable $name 
    using datestamp: $(date +%d%b%Y-%I%P)"
  cd ~/sf/htdocs/books/pars
  # The line below adds the compile time and date to the version
  sed "/v31415\"; *$/s/v31415/$(date +%d%b%Y-%I%P)/" pep.c > pep.pre.c
  gcc -Wall pep.pre.c -o $name 
}
alias pep.ccw=pepw

# Compiles and runs the gh.c
function pepr {
  echo -e "
    Compiling 'pep.c' as executable '$name'
    using datestamp: $(date +%d%b%Y-%I%P)"
  cd ~/sf/htdocs/books/pars
  cp pep.c pep.pre.c
  # The line below adds the compile time and date to the version
  sed "/v31415\"; *$/s/v31415/$(date +%d%b%Y-%I%P)/" pep.c > pep.pre.c
  gcc pep.pre.c -o $name && ./$name
}

# rsyncs to a usb 
function lexo {
  echo -e " saving pep folder to LEX-ORANGE usb memory"
  rsync -rvuhi ~/sf/htdocs/books/pars/ /media/rowantree/LEX-ORANGE8/sf/htdocs/books/pars/
}

# rsyncs to a usb 
function pep.ima {
  echo -e " saving pep folder to IMA-GREEN usb memory"
  rsync -rvuhi ~/sf/htdocs/books/pars/ /Volumes/IMA-GREEN8G/sf/htdocs/books/pars/
}

# edit the booklet about the virtual machine parser 
function pepbook {
  vim ~/sf/htdocs/books/pars/pars-book.txt
}
alias parsbook=pepbook

#alias pep='cd ~/sf/htdocs/books/pars/; vim ~/sf/htdocs/books/pars/pepo.c'
alias gh=pep
alias pp=pep

# upload just one file to pep folder 
function pep.u {  
  if [ "$1" == "" ]; then
    echo -e "
      Upload one file to server
      try pep.u <filename>"
    return
  fi
  rsync -v -e ssh --progress ~/sf/htdocs/books/pars/$1 "$url/$1"
}
alias pep.u=pep.u

# download just one file from code folder 
function pep.d {  
  if [ "$1" == "" ]; then
    echo -e "try pep.d <filename>"
    exit
  fi
  rsync -v -e ssh --progress "$url/$1" ~/sf/htdocs/books/pars/$1 
}

# upload the whole pep folder 
function pepuu {  
 rsync -rvuhi -e ssh --progress \
    --exclude '*.diff' \
    --exclude '*.o' \
    --exclude '*.swp' \
    ~/sf/htdocs/books/$dir/ "$url/"
}
alias ghuu=pepuu
alias pep.uu=pepuu

# upload folder tree and clean (delete!!) extraneous 
function pepuuDD {  
 echo -e "
   UPLOADING AND DELETING EXTRANEOUS FILES ON THE SERVER!!!
   Server: $url
   Folder: $dir
   Hit control-c to abort "

 rsync -rvuhi -e ssh --progress --delete \
    --exclude '*.diff' \
    --exclude '*.o' \
    --exclude '*.swp' ~/sf/htdocs/books/pars/ "$url"
}
alias ghuuDD=pepuuDD

# download the pars folder and subfolder and clean (delete!!) extraneous 
function pepddDD {  
 echo -e "
   DOWNLOADING FROM THE SF SERVER AND DELETING EXTRANEOUS LOCAL FILES!!!
   Hit control-c to abort "

 rsync -rvuhi -e ssh --progress --delete \
    --exclude '*.diff' \
    --exclude '*.o' \
    --exclude '*.swp' "$url/" \
    ~/sf/htdocs/books/pars/ 
}

# download the folder tree 
function pepdd {  
 echo -e "
   DOWNLOADING FROM THE SERVER
   Server: $url/
   Max file size: none
   Hit control-c to abort "

 rsync -rvuhi -e ssh --progress \
    --exclude '*.diff' \
    --exclude '*.o' \
    --exclude '*.swp' "$url/" ~/sf/htdocs/books/pars/ 
}

# upload the pep book to nfs
function pep.uun {
 echo -n "
   Uploading the '$bdir' to the holaday site at nearlyfreespeech.
   mjbishop_holaday@ssh.phx.nearlyfreespeech.net:/home/public/books/$dir
  "
 rsync -rvuhi -e ssh --progress \
    --exclude '*.diff' \
    --exclude '*.swp' \
    --exclude '*.o' \
    ~/sf/htdocs/books/pars/ "$nfsurl/"
}
alias pepuun=pep.uun

# upload the pep folder and subfolder and clean (delete!!) extraneous 
function pep.uunDD {  
 echo -e "
   UPLOADING AND DELETING EXTRANEOUS FILES ON THE NFS SERVER!!!
   Server: $nfsurl
   Hit control-c to abort "

 rsync -rvuhi -e ssh --progress --delete \
    --exclude '*.diff' \
    --exclude '*.o' \
    --exclude '*.swp' ~/sf/htdocs/books/pars/ "$nfsurl/"
}

# display help functions
function pep.help {
  cat $0 | sed -n '/function/{s/function//;s/{//p}; /^#/p;' | less
}

# edit book management script and this file 
function pep.bk {
  vim $0 ~/sf/htdocs/books/bash/app/books.sh  
}

# compile the pep tool using the object files in the "object" folder.
# this probably should be in a make file.
function pepco {
  h=~/sf/htdocs/books/$dir
  f=~/sf/htdocs/books/$dir/object
  gcc -o $h/$name \
    $f/pep.c $f/tapecell.c $f/tape.c $f/buffer.c $f/colours.c \
    $f/charclass.c $f/command.c $f/parameter.c $f/instruction.c \
    $f/labeltable.c $f/program.c $f/machine.c $f/exitcode.c \
    $f/machine.interp.c
}
alias pep.cco=pepco

alias ompp='cd ~/sf/htdocs/books/pars/; ./ompp'

# compile the ompp tool using the object files in the "object" folder.
# this needs to become a make file.
function omco {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/object
  gcc -o $h/ompp \
    $f/ompp.c $f/tapecell.c $f/tape.c $f/buffer.c $f/colours.c \
    $f/charclass.c $f/command.c $f/parameter.c $f/instruction.c \
    $f/labeltable.c $f/program.c $f/machine.c $f/exitcode.c \
    $f/machine.interp.c
}

# compile the pep tool with -g switch for valgrind debugging
# use the Makefile in pars/object instead of this.
function pepcv {
  h=~/sf/htdocs/books/$dir
  f=~/sf/htdocs/books/$dir/object
  echo -e "Building '$name' executable with gcc -g switch for valgrind check"
  gcc -g -o $h/$name \
    $f/pep.c $f/tapecell.c $f/tape.c $f/buffer.c $f/colours.c \
    $f/charclass.c $f/command.c $f/parameter.c $f/instruction.c \
    $f/labeltable.c $f/program.c $f/machine.c $f/exitcode.c \
    $f/machine.interp.c
}
alias pep.cv=pepcv

# just run pp with valgrind memory checking
alias vpep="valgrind --leak-check=yes ./$name"

# make a static library out of the machine object files, so that we can
# easily compile 'compilable' scripts created with 
# compile.c.pss
# use make instead. use with
#   gcc -o test test.o -Lobject/ -lmachine

function peplib {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/object
  name="machine"
  # rebuild all object files
  echo -e "Building machine object files in $f "
  cd $f; 
  gcc -c *.c
  # not all of these files are really necessary. 
  echo -e "Creating static library 'lib$name.a' in $f "
  ar rcs $f/lib$name.a $f/buffer.o $f/charclass.o $f/colours.o $f/command.o $f/exitcode.o $f/instruction.o $f/labeltable.o $f/machine.o $f/machine.interp.o $f/machine.methods.o $f/parameter.o $f/program.o $f/tape.o $f/tapecell.o
}

# compile a stand-alone executable parsing script 
function pepcl {
  if [ "$1" == "" ]; then
    echo -e "
      Compiles a machine script to a standalone executable with
      the code in books/pars/object/. The resulting file has extension '.exec'
      try pepcl <filename>  "
    return
  fi
  file=$1
  f=~/sf/htdocs/books/pars/object
  gcc -o ${file%.?*}.exec $file  -L$f -lmachine -I$f
}

alias ppo="~/sf/htdocs/books/pars/object/ppo"

# installs the man page pep.man at /usr/share/man/man1
function pepman {
  h=~/sf/htdocs/books/$dir
  f=~/sf/htdocs/books/$dir/object
  # use the line below for handcoded man pages. But I think 
  # I will use a2x even though it is very slow.
  # cp $h/pep.man $h/pep.1
  # install -g 0 -o 0 -m 0644 $h/pep.1 /usr/local/man/man1/
  sudo install -g 0 -o 0 -m 0644 $h/$name.1 /usr/share/man/man1/
  # gzip /usr/local/man/man1/pep.1
  sudo gzip /usr/share/man/man1/$name.1
}
alias pep.man=pepman

# generate a man page 
function pepaman {
  echo -e "creating man page from file pep.1.man.txt
     output file is pep.1  Test with 'man ./pep.1'
     This requires the asciidoc package installed and xmllint
     + xsltproc.  The processing with xsltproc takes a ridiculously 
     long time!!
     "
  # requires xmllint, xsltproc
  cp $name.man.adoc $name.1.txt
  a2x -v --doctype manpage --format manpage $name.1.txt
  # create a pdf
  # man -l -Tps pep.1 | ps2pdf - pep.1.pdf
}

# creates a tar ball of the folder tree for publishing to sourceforge 
function pep.tar {
  h=~/sf/htdocs/books/$dir
  f=~/sf/htdocs/books/$dir/object
  rm $h/tempInput.txt $h/temp.txt $h/pep.1.txt 
  cd $h
  tar --exclude=ppc.old \
      --exclude=old.pp.first \
      --exclude=old.pp.mono \
      --exclude='*.swp' \
      --exclude='helpers.*' \
      --exclude='temp*' --exclude='*2019*' -czvf ../pars.tar.gz .
  echo -e "
    Created tar ball of $h 
    This can be published to the sourceforge project download 
    with 'pep.pub'
  "
}

# publish files to sourceforge download site
function pep.pub {
  h=~/sf/htdocs/books/
  rsync -e ssh $h/pars.tar.gz matth3wbishop@frs.sourceforge.net:/home/frs/project/bumble/pp/
  # cd /home/frs/project/fooproject
}

# compile script into python into pars/eg/python folder and run with input
function pep.pys {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/python
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input']
      translates a script into python source code and prints it 
      to stdout. If 'input' is given the code is compiled and run with the
      given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.py.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.py.pss -i "$script" > $h/eg/python/test.py
  chmod a+x $h/eg/python/test.py
  # echo -e "[running script in eg/python/test.py]"
  echo -n "$input" | $h/eg/python/test.py
}


# testing 2nd generation script execution in python
# first the translator is translated into python, then the inline script
# is translated with the new translator, then if input is given
# the script is run
function pep.pyss {
  lang="py"
  langname="python"
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/$langname
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'language' 'script' ['input'] [no]
      translates a script into $langname source code *using the $langname
      translator* (2nd gen) and prints it 
      to stdout. If 'input' is given the code is run with the
      given input. 
      if [no] is given do not recompile translate.$lang.$lang " 
    return
  fi
  trscript=$bdir/eg/$langname/translate.$lang.$lang
  egdir=$bdir/eg/$langname
  if [ "$3" == "" ] || [ ! -f $trscript ]; then
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $trscript 
    chmod a+x $trscript 
  fi

  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | $trscript | less
    return
  fi
  input=$2
  echo "$script" | $trscript > $bdir/eg/$langname/test.$lang
  # echo -e "[running the script eg/$lang/test.$lang 2nd generation]" 
  chmod a+x $bdir/eg/$langname/test.$lang
  echo -n "$input" | $h/eg/$langname/test.$lang
}

# compile scriptfile into python into pars/eg/python folder and run with input
function pep.pyf {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/python
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile ['input']
      translates a scriptfile into python source code and prints it 
      to stdout. If 'input' is given the code is compiled and run with the
      given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.py.pss $script | less 
    return
  fi
  input=$2
  file=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.py.pss $script > $h/eg/python/$file.py
  chmod a+x $h/eg/python/$file.py
  echo -e "[running script in eg/python/$file.py]"
  echo -n "$input" | $h/eg/python/$file.py
}

# compile scriptfile into python into pars/eg/python folder and run with input
function pep.pyff {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/python
  egdir=~/sf/htdocs/books/eg/python
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile ['input']
      translates a scriptfile into python source code and prints it 
      to stdout. If 'input' is given the code is compiled and run with the
      given input" 
    return
  fi
  file=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.py.pss $file 
    return
  fi
  input=$2
  file=$(basename ${file%.?*})
  pep -f $bdir/tr/translate.py.pss "$script" > $h/eg/python/$file.py
  chmod a+x $h/eg/python/$file.py
  echo -e "[running script in eg/python/$file.py]"
  cat $input | $h/eg/python/$file.py
}

# compile a script into javascript and run with input if given
function pep.jss {
  egdir=$bdir/eg/js
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates a script file into javascript source code and prints it 
      to stdout. If 'input' is given the code is compiled and run with the
      given input. If the 3rd parameter is 'info', then translation and 
      execution information is given." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.js.pss -i "$script"
    return
  fi
  input=$2; 

  if [ "$3" == "info" ]; then
    pep -f $bdir/tr/translate.js.pss -i "$script" > $egdir/test.js
    echo "Translated $script into javascript with tr/translate.js.pss "
    echo "Compiled $script to eg/javascript/$newname"
    echo "javascript size: $(du -sh $egdir/test.js | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo -n $input | node $egdir/test.js
    echo "[execution times]"
  else
    pep -f $bdir/tr/translate.js.pss -i "$script" > $egdir/test.js
    echo -n $input | node $egdir/test.js
  fi

}

# compile a scriptfile into javascript and run with input if given
function pep.jsf {
  egdir=$bdir/eg/js
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'scriptfile' ['input'] [info]
      translates a script file into javascript source code and prints it 
      to stdout. If 'input' is given the code is run with the
      given input string. If the 3rd parameter is 'info', then translation and 
      execution information is given." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.js.pss "$script"
    return
  fi
  input=$2; 
  newname=$(basename ${script%.?*}).js
  if [ "$3" == "info" ]; then
    pep -f $bdir/tr/translate.js.pss "$script" > $egdir/$newname
    echo "Translated $script into javascript with tr/translate.js.pss "
    echo "Translated $script to eg/javascript/$newname"
    echo "javascript size: $(du -sh $egdir/$newname | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo $input | node $egdir/$newname 
    echo "[execution times]"
  else
    pep -f $bdir/tr/translate.js.pss "$script" > $egdir/$newname
    echo $input | node $egdir/$newname 
  fi
}

# compile a scriptfile into javascript and run with inputfile if given
function pep.jsff {
  egdir=$bdir/eg/js
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'scriptfile' ['inputfile'] [info]
      translates a script file into javascript source code and prints it 
      to stdout. If the inputfile is given the code is run with the
      given inputfile. If the 3rd parameter is 'info', then translation and 
      execution information is given." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.js.pss "$script"
    return
  fi
  input=$2; 
  newname=$(basename ${script%.?*}).js
  if [ "$3" == "info" ]; then
    pep -f $bdir/tr/translate.js.pss "$script" > $egdir/$newname
    echo "Translated $script into javascript with tr/translate.js.pss "
    echo "Translated $script to eg/javascript/$newname"
    echo "javascript size: $(du -sh $egdir/$newname | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time cat $input | node $egdir/$newname 
    echo "[execution times]"
  else
    pep -f $bdir/tr/translate.js.pss "$script" > $egdir/$newname
    cat $input | node $egdir/$newname 
  fi
}

function pep.jjss {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/object.js
  if [ "$1" == "" ]; then
    echo -e "
    usage: pep.jjss 'script'
      compile script into java and print to stdout "
    return
  fi
  script=$1; 
  cd $h
  pep -f translate.java.pss -i $script 
}

# translate scriptfile into java and print to stdout or run if input given
function pep.jaf {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/java
  egdir=$bdir/eg/java
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates a script file into java source code and prints it 
      to stdout. If 'input' is given the code is compiled and run with the
      given input. If the 3rd parameter is given, then compilation and 
      execution information is given." 
    return
  fi
  script=$1
  if [ ! -f $script ]; then
    echo "Can't find file $script"; return; 
  fi
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.java.pss $script
    return
  fi
  input=$2
  # example substitution ${f/.html/.php};
  # make a filename suitable for the java class name
  newname=$(basename $script)
  newname=${newname%.*}
  newname=${newname//./}
  newname=${newname// /}
  pep -f $bdir/tr/translate.java.pss $script > $egdir/$newname.java
  # change the class name to the filename 
  sed -i "s/Machine/$newname/g" $egdir/$newname.java

  if [ "$3" == "info" ]; then
    echo "Translated $script into java source with tr/translate.java.pss "
    echo "Compiled $script to eg/java/$newname"
    time javac -classpath $egdir $egdir/$newname.java
    echo "[javac compilation time]"
    echo "compiled size: $(du -sh $egdir/$newname.class | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    time echo -n "$input" | java -classpath $egdir $newname 
    echo "[execution times]"
  else
    javac -classpath $egdir $egdir/$newname.java
    echo -n "$input" | java -classpath $egdir $newname 
  fi
}

# translate scriptfile into java and print to stdout or run if inputfile fiven
function pep.jaff {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/java
  egdir=$bdir/eg/java
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile [inputfile] [info]
      translates a script file into java source code and prints it 
      to stdout. If an inputfile is given the code is compiled and run with the
      given input from that file. If the 3rd parameter is given, 
      then compilation and execution information is given." 
    return
  fi
  script=$1
  if [ ! -f $script ]; then
    echo "Can't find file $script"; return; 
  fi
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.java.pss $script
    return
  fi
  input=$2
  # example substitution ${f/.html/.php};
  # make a filename suitable for the java class name
  newname=$(basename $script)
  newname=${newname%.*}
  newname=${newname//./}
  newname=${newname// /}
  pep -f $bdir/tr/translate.java.pss $script > $egdir/$newname.java
  # change the class name to the filename 
  sed -i "s/Machine/$newname/g" $egdir/$newname.java

  if [ "$3" != "" ]; then
    echo "Translated $script into java source with tr/translate.java.pss "
    echo "Compiled $script to eg/java/$newname"
    time javac -classpath $egdir $egdir/$newname.java
    echo "[javac compilation time]"
    echo "compiled size: $(du -sh $egdir/$newname.class | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    time cat $input | java -classpath $egdir $newname 
    echo "[execution times]"
  else
    javac -classpath $egdir $egdir/$newname.java
    cat $input | java -classpath $egdir $newname 
  fi
}

# translate script into java and print to stdout or run if input given
function pep.jas {

  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/java
  egdir=$bdir/eg/java
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates an inline script into java source code and prints it 
      to stdout. If 'input' is given the code is compiled and run with the
      given input. If the 3rd parameter is 'info' then compilation and 
      execution time is displayed." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.java.pss -i "$script"
    return
  fi
  input=$2
  newname="Test"

  pep -f $bdir/tr/translate.java.pss -i "$script" > $egdir/Test.java
  #cd $bdir/eg/java/; 
  # change the class name to "Test"
  sed -i "s/Machine/Test/g" $egdir/Test.java

  if [ "$3" == "info" ]; then
    echo "Translated inline script into java source with tr/translate.java.pss "
    echo "Compiling inline script to eg/java/$newname ..."
    time javac -classpath $egdir $egdir/$newname.java
    echo "[javac compilation time]"
    echo "compiled size: $(du -sh $egdir/$newname.class | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    time echo -n "$input" | java -classpath $egdir $newname 
    echo "[execution times]"
  else
    javac -classpath $egdir $egdir/$newname.java
    echo -n "$input" | java -classpath $egdir $newname 
  fi
}

# test 2nd generation scripts in java 
function pep.jass {
  lang="java"
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/java
  egdir=$bdir/eg/java/; 
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] no
      translates a script into $lang source code *using the $lang
      translator* (2nd generation) and prints it to stdout. If 'input' 
      is given the code is run with the given input. 
      if [no] is given do not recompile translate.$lang.$lang " 
    return
  fi
  recompile=$3
  cd $bdir/eg/java/; 
  if [ "$recompile" == "" ] || [ ! -f $bdir/eg/$lang/Machine.class ]; then
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $bdir/eg/$lang/Machine.$lang
    javac Machine.java
  fi
  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | java Machine 
    return
  fi
  input=$2

  cd $bdir/eg/java/; 
  echo "$script" | java Machine > $h/eg/java/Test.java
  # change the class name to "Test"
  sed -i "s/Machine/Test/g" Test.java
  #echo -e "Compiling Machine.java with javac."
  javac Test.java
  #echo -e "running eg/java/Machine.class ..." 
  #chmod a+x $bdir/eg/ruby/test.rb
  echo -n "$input" | java Test 
  cd $h
}

# translate scriptfile into tcl and print to stdout or run if input given
function pep.tcf {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/tcl
  egdir=$bdir/eg/tcl

  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'scriptfile' ['inline-input'] [info]
      translates a scriptfile to tcl source code and prints it 
      to stdout. If 'input' is given the code is run with the
      given input. If the 3rd parameter is 'info' then the execution
      time is also displayed." 
    return
  fi
  file=$1; 
  script=$file
  if [ ! -f $script ]; then
    echo "Can't find script file '$script'"; return; 
  fi
  newfile=${file##*/}
  newname=${newfile%.?*}.tcl
  if [ "$2" == "" ]; then
    pep -f $h/tr/translate.tcl.pss $file
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.tcl.pss $file > $egdir/$newname
  chmod a+x $egdir/$newname

  if [ "$3" == "info" ]; then
    echo "Translated $script into tcl source with tr/translate.tcl.pss "
    echo "translated size: $(du -sh $egdir/$newname | cut -f 1) $newname"
    echo "[tcl script output ...] "
    time echo -n "$input" | $egdir/$newname
    echo "[execution time]"
  else
    echo -n "$input" | $egdir/$newname
  fi
}

# translate scriptfile into tcl and print to stdout or run with inputfile if given
function pep.tcff {
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'scriptfile' ['inputfile']
      translates a scriptfile to tcl source code and prints it 
      to stdout. If 'input' is given the code is run with the
      given input" 
    return
  fi
  file=$1; 
  newfile=${file##*/}
  newname=${newfile%.?*}.tcl
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.tcl.pss $file
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.tcl.pss $file > $bdir/eg/tcl/$newname
  echo -e "[running the script eg/tcl/$newname]" 
  chmod a+x $bdir/eg/tcl/$newname
  cat $input | $bdir/eg/tcl/$newname
}

# translate script into tcl and print to stdout or run if input given
function pep.tcs {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/tcl
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input']
      translates a script to tcl source code and prints it 
      to stdout. If 'input' is given the code is run with the
      given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.tcl.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.tcl.pss -i "$script" > $h/eg/tcl/test.tcl
  #echo -e "running the script eg/tcl/test.tcl ..." 
  chmod a+x $bdir/eg/tcl/test.tcl
  echo -n "$input" | $h/eg/tcl/test.tcl
}

# testing 2nd generation script execution 
# first the translator is translated in tcl, then the inline script
# is translated with the new tcl translator, then if input is given
# the script is run
function pep.tss {
  lang="tcl"
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/$lang
  egdir=$bdir/eg/$lang

  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [no]
      translates a script into $lang source code *using the $lang
      translator* (2nd gen) and prints it 
      to stdout. If 'input' is given the code is run with the
      given input. 
      if [no] is given do not recompile translate.$lang.$lang " 
    return
  fi
  if [ "$3" == "" ]; then
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $bdir/eg/$lang/translate.$lang.$lang
    chmod a+x $bdir/eg/$lang/translate.$lang.$lang
  fi

  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | $bdir/eg/$lang/translate.$lang.$lang | less
    return
  fi
  input=$2
  echo "$script" | $bdir/eg/$lang/translate.$lang.$lang > $bdir/eg/$lang/test.$lang
  # echo -e "[running the script eg/$lang/test.$lang 2nd generation]" 
  chmod a+x $bdir/eg/$lang/test.$lang
  echo -n "$input" | $h/eg/$lang/test.$lang
}


# rust helpers.
# translate script into rust and print to stdout or run if input given
function pep.rss {
  egdir=$bdir/eg/rust
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates a script into rust source code and prints it 
      to stdout. If 'input' is given the code is compiled and 
      run with the given input. If the 3rd parameter is 'info' then
      compilation and execution times are displayed along with the 
      script output." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.rust.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.rust.pss -i "$script" > $egdir/test.rs
  if [ "$3" == "info" ]; then
    echo "Translated script into go source with translate.go.pss "
    echo "Compiling script to eg/rust/test ..."
    time rustc -o $egdir/test $egdir/test.rs
    echo "[compilation time] "
    echo "compiled size: $(du -sh $egdir/test | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo -n "$input" | $egdir/test
    echo "[execution time]"
  else
    rustc -o $egdir/test $egdir/test.rs
    echo -n "$input" | $egdir/test
  fi
}



# translate script file into rust and print to stdout or run if input given
function pep.rsf {
  lang=rust
  langname=rust
  egdir=$bdir/eg/$lang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile ['input'] [info]
      translates a scriptfile into $lang source code and prints it 
      to stdout. If 'input' is given the file is compiled into 
      pars/eg/$lang/ and run with the given input. If any 3rd 
      parameter is given, compilation information is given." 
    return
  fi
  script=$1
  if [ ! -f $script ]; then
    echo "Can't find script file '$script'"; return; 
  fi

  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.$lang.pss $script
    return
  fi

  input=$2
  newname=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.$lang.pss $script > $egdir/$newname.rs
  if [ "$3" == "info" ]; then
    echo "Translated $script into go source with translate.go.pss "
    echo "Compiling $script to eg/go/$newname ..."
    time rustc -o $egdir/$newname $egdir/$newname.rs
    echo "[compilation time] "
    echo "compiled size: $(du -sh $egdir/$newname | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo -n "$input" | $egdir/$newname
    echo "[execution time]"
  else
    rustc -o $egdir/$newname $egdir/$newname.rs
    echo -n "$input" | $egdir/$newname
  fi
}

#-------------------
# go helpers

# translate script into go and print to stdout or run if input given
function pep.gos {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/go
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates a script into go source code and prints it 
      to stdout. If 'input' is given the code is compiled and 
      run with the given input. If the 3rd parameter is 'info' then
      compilation and execution times are displayed along with the 
      script output." 
    return
  fi
  script=$1
  egdir=$bdir/eg/go
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.go.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.go.pss -i "$script" > $egdir/test.go
  if [ "$3" == "info" ]; then
    echo "Translated script into go source with translate.go.pss "
    echo "Compiling script to eg/go/test ..."
    time go build -o $egdir/$newname $egdir/test.go
    echo "[compilation time] "
    echo "compiled size: $(du -sh $egdir/test | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo -n "$input" | $egdir/test
    echo "[execution time]"
  else
    go build -o $egdir/test $egdir/test.go
    echo -n "$input" | $egdir/test
  fi
}



# create the go script translator (for second gen tests) 
function pep.gotr {
  lang="go"
  egdir=$bdir/eg/$lang

  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} no/yes 
      translates the $lang translator in $lang and compiles it.
      If the 1st argument is 'no' then the translator will not be
      regenerated nor recompiled, but if yes it will be. "
    return
  fi

  recompile=$1
  if [ "$recompile" == "yes" ] || [ ! -f $bdir/eg/$lang/translate.$lang.$lang ]; then
    cd $egdir
    echo "
      translating and compiling '$lang' translator 
      as eg/$lang/translate.$lang.$lang "
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $egdir/translate.$lang.$lang
    go build $egdir/translate.$lang.$lang 
    cd $bdir
  else
    echo "Did nothing!"
  fi
}

# test 2nd generation scripts in go
function pep.goss {
  lang="go"
  h=~/sf/htdocs/books/pars
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [no-recompile]
      translates a script into $lang source code *using the $lang
      translator* (2nd generation) and prints it to stdout. If 'input' 
      is given the code is run with the given input. 
      if [no] is given do not recompile translate.$lang.$lang " 
    return
  fi
  recompile=$3
  egdir=$bdir/eg/$lang
  cd $egdir
  if [ "$recompile" == "" ] || [ ! -f $bdir/eg/$lang/translate.$lang.$lang ]; then
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $egdir/translate.$lang.$lang
    go build $egdir/translate.$lang.$lang 
  fi
  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | $egdir/translate.$lang
    return
  fi
  input=$2

  cd $egdir; 
  echo "$script" | $egdir/translate.$lang > $egdir/test.go
  go build $egdir/test.go
  echo -n "$input" | $egdir/test
  cd $bdir
}

# translate script file into go and print to stdout or run if input given
function pep.gof {
  lang=go
  langname=golang
  egdir=$bdir/eg/$lang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile ['input'] [info]
      translates a scriptfile into $lang source code and prints it 
      to stdout. If 'input' is given the file is compiled into 
      pars/eg/$lang/ and run with the given input. If any 3rd 
      parameter is given, compilation information is given." 
    return
  fi
  script=$1
  if [ ! -f $script ]; then
    echo "Can't find script file '$script'"; return; 
  fi

  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.go.pss $script
    return
  fi

  input=$2
  newname=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.go.pss $script > $egdir/$newname.go

  if [ "$3" == "info" ]; then
    echo "Translated $script into go source with translate.go.pss "
    echo "Compiling $script to eg/go/$newname ..."
    time go build -o $egdir/$newname $egdir/$newname.go
    echo "[compilation time] "
    echo "compiled size: $(du -sh $egdir/$newname | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo -n "$input" | $egdir/$newname
    echo "[execution time]"
  else
    go build -o $egdir/$newname $egdir/$newname.go
    echo -n "$input" | $egdir/$newname
  fi

}

# translate script file into go and print to stdout or run if input-file given
function pep.goff {
  lang=go
  langname=golang
  egdir=$bdir/eg/$lang

  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile [<input-file>]
      translates a scriptfile into $lang source code and prints it 
      to stdout. If the <input-file> is given the script file is 
      translated and compiled into $lang in the folder
      pars/eg/$lang/ and run with the given input-file" 
    return
  fi
  script=$1
  if [ ! -f $script ]; then
    echo "Can't find script file '$script'"; return; 
  fi

  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.go.pss $script
    return
  fi

  inputfile=$2
  if [ ! -f $inputfile ]; then
    echo "Can't find the input file '$inputfile'"; return; 
  fi
  newname=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.go.pss $script > $egdir/$newname.go
  go build -o $egdir/$newname $egdir/$newname.go
  cat $inputfile | $egdir/$newname
}

# c++ helpers

# translate script into c++ and print to stdout or run if input given
function pep.cps {
  lang=cpp
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/$lang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input']
      translates a script into $lang source code and prints it 
      to stdout. If 'input' is given the code is compiled with gcc and 
      run with the given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.$lang.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.$lang.pss -i "$script" > $h/eg/$lang/test.cpp
  gcc -o $h/eg/$lang/test.ex $h/eg/$lang/test.cpp 
  #echo -e "running the translated script eg/$lang/test.ex ..." 
  echo -n "$input" | $h/eg/$lang/test.ex
}

#-------------------
# translation to c helpers

# translate script into c and print to stdout or run if input given
function pep.cs {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/clang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input']
      translates a script into plain c source code and prints it 
      to stdout. If 'input' is given the code is compiled and 
      run with the given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.c.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.c.pss -i "$script" > $h/eg/clang/test.c
  g=~/sf/htdocs/books/pars/object
  #echo "Compiling eg/clang/test.c ... "
  # need to compile with the pep c library
  # the c translator does not produce 'stand-alone' code
  gcc -o $h/eg/clang/test.ex $h/eg/clang/test.c -L$g -lmachine -I$g
  #echo -e "running the translated script eg/clang/test.ex ..." 
  echo -n "$input" | $h/eg/clang/test.ex
}


# test 2nd generation scripts in c
function pep.css {
  lang="c"
  langname="clang"
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/clang
  g=~/sf/htdocs/books/pars/object
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] no
      translates a script into $lang source code *using the $lang
      translator* (2nd generation) and prints it to stdout. If 'input' 
      is given the code is run with the given input. 
      if [no] is given do not recompile translate.$langname.$lang " 
    return
  fi
  cd $bdir/eg/$clang/; 
  trsource=$bdir/eg/$langname/translate.$langname.$lang
  trex=$bdir/eg/$langname/translate.$langname.ex
  egdir=$bdir/eg/$langname
  if [ "$3" == "" ]; then
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $trsource
    gcc -o $trex $trsource -L$g -lmachine -I$g
    chmod a+x $trex
  fi
  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | $trex 
    return
  fi
  input=$2

  cd $egdir; 
  echo "$script" | $trex > $egdir/test.c
  gcc -o $egdir/test.ex $egdir/test.c -L$g -lmachine -I$g
  chmod a+x $egdir/test.ex
  echo -n "$input" | $egdir/test.ex 
}

# trying to create test rig for translator scripts.
function pep.test.clang() {

  a=$(pep.cs 'r;add "."; clop; t;d;' "abc")
  if [ "$a" != "..." ]; then
    echo "clop error";
  fi

  a=$(pep.cs 'r;add "xx"; clip; t;d;' "abc")
  if [ "$a" != "axbxcx" ]; then
    echo "clop error";
  fi
}

# create test rig for translator scripts.
# test data is in tr/tr.test.txt
# very useful. Also, added testing for multiline add, 
# for eg/ script files such as eg/json.check.pss and mark.latex.pss
#
function pep.tt() {
  command=""
  # a helper command to generate and execute 2nd gen scripts
  gencommand=""

  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} <language> [batch] [start-at] [ascii|uni]
      tests the pep translation script for the given language.
      eg, ${FUNCNAME[0]} c 
         tests the script tr/translate.c.pss using scripts and 
         input data in the file tr/tr.test.txt. The oneline pep
         scripts are translated into the target language (and then
         compiled- if necessary) and then run with the given input
         and checked against the expected output. 
       Parameters:
         [batch] given, the test script will continue even when an error 
            is encountered. If "ascii" or "uni" is the 3rd parameter
         [start-at] tests will start at the comment line beginning with
            the start-at text 
         [ascii|uni] only ascii or only unicode tests will be performed
            not implemented
         "
    return
  fi
  lang="$1"
  batch="$2"
  startat="$3"
  mode="$4"
  case "$lang" in 
    go | golang)
      command="pep.gos"
      gencommand="pep.goss"
      lang="go"; langname="golang"
      ;;
    c | clang)
      command="pep.cs"
      gencommand="pep.css"
      lang="c"; langname="clang"
      ;;
    js | javascript)
      command="pep.jss"
      lang="js"; langname="javascript"
      ;;
    java | j)
      command="pep.jas"
      gencommand="pep.jass"
      lang="java"; langname="java"
      ;;
    rb | ruby)
      command="pep.rbs"
      gencommand="pep.rbss"
      lang="rb"; langname="ruby"
      ;;
    python | py)
      command="pep.pys"
      gencommand="pep.pyss"
      lang="py"; langname="python"
      ;;
    tcl | t)
      command="pep.ts"
      gencommand="pep.tss"
      lang="tcl"; langname="tcl"
      ;;
    *)
      echo "A pep translator may not exist for '$langname'!"
      return
      ;;
  esac 

  trdir=$bdir/tr
  testfile=$bdir/tr/tr.test.txt
  errorfile=$bdir/tr/errors.$langname.txt
  tests=0
  errors=0
  done=false

  # translation script could be called translate.ruby.pss
  # or translate.rb.pss
  trscript=$bdir/tr/translate.$langname.pss
  if [ ! -f $trscript ]; then
    trscript=$bdir/tr/translate.$lang.pss
  fi

  # where the test script is compiled to: eg eg/ruby/test.rb
  ccscript=$bdir/eg/$langname/test.$lang
  if [ ! -f $ccscript ]; then
    ccscript=$bdir/eg/$lang/test.$lang
  fi

  echo "
Test results for translating pep scripts
Translation Script: $trscript
Language: $langname
Date: $(date)
Tests 1st gen: 0
Errors 1st gen: 0
Time Taken 1gen: 0
Tests 2nd gen: 0
Errors 2nd gen: 0
Time Taken 2gen: 0
Error results: " > $errorfile

  echo "Testing pep translator for language '$langname'"
  echo "Helper script '$command'"
  echo "Testfile '$testfile'"
  echo "Translator scripts are called tr/translate.<lang>.pss "

  starttime="$(date -u +%s)"

  #sed '/^\s*#/d;/^\s*$/d' $testfile | while read -r line
  #sed '/^\s*$/d' $testfile | while read -r line

  startnow="true"
  if [ "$startat" != "" ]; then
    startnow="false"
  fi

  cat $testfile | while read -r line
  do
    if [[ "$line" =~ ^\s*#.*$ ]]; then
      echo "$line"
      if [[ "$line" =~ $startat ]]; then
        startnow="true"
      fi 
      continue
    fi
    if [[ "$line" =~ ^\s*$ ]]; then
      echo "$line"
      continue
    fi

    if [ "$startnow" == "false" ]; then
      echo "[startat \"$startat\"] skipping $line"
      continue
    fi

    (( tests++ ))
    #echo "line: $line"
    script=$(echo "$line" | awk -F'[ ]*[/][/][ ]*' '{print $1}')
    input=$(echo "$line" | awk -F'[ ]*[/][/][ ]*' '{print $2}')
    output=$(echo "$line" | awk -F'[ ]*[/][/][ ]*' '{print $3}')
    uni=$(echo "$line" | awk -F'[ ]*[/][/][ ]*' '{print $4}')
    # uni is unicode utf8 indicator

    res=$($command "$script" "$input")
    sed -i 's/^\s*Tests 1st gen:.*$/Tests 1st gen: '$tests'/' $errorfile
    if [ "$res" != "$output" ]; then
      echo "[error] '$script' '$input' expected '$output'"
      echo "but result was [$res] "
      (( errors++ ))
      echo "tests=$tests"
      echo "errors=$errors"
      done=true
      if [[ $batch =~ ^ba.*$ ]]; then
        sed -i 's/^\s*Errors 1st gen:.*$/Errors 1st gen: '$errors'/' $errorfile
        echo "[error] '$script' '$input' expected: '$output' result: [$res] " \
           >> $errorfile
        continue
      else
        break;
      fi
    else 
      echo "[ok] '$script' '$input' RESULT [$output]"
    fi
  done

  endtime="$(date -u +%s)"
  elapsed="$(($endtime-$starttime))"
  echo "Total of $elapsed seconds elapsed for tests"
  sed -i 's/^\s*Time Taken 1gen:.*$/Time Taken 1gen: '$elapsed'/' $errorfile

  if [ "$batch" != "batch" ]; then 
    echo -n "
  Choose an option:
    c - view last compiled file [eg/$langname/test.$lang]
    t - view translation script [tr/translate.$lang.pss]
    s - edit script test file [tr/tr.test.txt]
    e - view the error file $errorfile 
    n - continue with 2nd gen tests 
    x - exit test script
    >"
    while read com ; do

      echo $com
      if [ "$com" == "c" ]; then
        vim $ccscript
      fi
      if [ "$com" == "t" ]; then
        vim $trscript
      fi
      if [ "$com" == "s" ]; then
        vim $bdir/tr/tr.test.txt
      fi
      if [ "$com" == "e" ]; then
        vim $errorfile
      fi
      if [ "$com" == "n" ]; then
        break
      fi
      if [ "$com" == "x" ]; then
        echo "Bye!"; break
      fi
      echo -n "
  Choose an option:
    c - view last compiled file [eg/$langname/test.$lang]
    t - view translation script [tr/translate.$lang.pss]
    s - edit script test file [tr/tr.test.txt]
    e - view the error file $errorfile 
    n - continue with 2nd gen tests 
    x - exit test script
    >"
    done
  fi

  # reset errors and tests for 2nd generation tests
  errors=$(sed -n '/Errors:/s/Errors:\s*//p' $errorfile)
  tests=$(sed -n '/Tests:/s/Tests:\s*//p' $errorfile)
  echo -e "
    [1st gen tests]
    language=$langname
    tests=$tests errors=$errors
  "
  errors=0
  tests=0

  if [ "$gencommand" == "" ]; then
    echo "No 2nd generation helper script found"
    return
  fi

  echo "Now testing 2nd gen commands for '$langname'"
  echo "Helper script '$gencommand'"
  echo "Testfile '$testfile'"

  echo "Recompiling translator"
  $gencommand 'r;t;d' ' '
  #sed '/^\s*#/d;/^\s*$/d' $testfile | while read -r line
  cat $testfile | while read -r line
  do
    #echo "line: $line"
    if [[ $line =~ ^\s*#.*$ ]]; then
      echo "$line"
      continue
    fi
    if [[ $line =~ ^\s*$ ]]; then
      echo "$line"
      continue
    fi
    (( tests++ ))
    script=$(echo $line | awk -F'[ ]*[/][/][ ]*' '{print $1}')
    input=$(echo $line | awk -F'[ ]*[/][/][ ]*' '{print $2}')
    output=$(echo $line | awk -F'[ ]*[/][/][ ]*' '{print $3}')

    res=$($gencommand "$script" "$input" norecompile)
    sed -i 's/^\s*Tests 2nd gen:.*$/Tests 2nd gen: '$tests'/' $errorfile
    if [ "$res" != "$output" ]; then
      echo "[error] '$script' '$input' expected '$output'"
      echo "but result was [$res] "
      echo " "
      echo "while testing 2nd gen pep translator for language '$langname'"
      echo "Helper script '$gencommand'"
      echo "Testfile '$testfile'"
      (( errors++ ))
      #if [ "$batch" != "" ]; then
      if [[ $batch =~ ^ba.*$ ]]; then
        sed -i 's/^\s*Errors 2nd gen:.*$/Errors 2nd gen: '$errors'/' $errorfile
        echo "[error 2nd] '$script' '$input' expected: '$output' result: [$res] " \
           >> $errorfile
        continue
      else
        break;
      fi
    else
      echo "[2nd ok] '$script' '$input' RESULT [$output]"
    fi
  done
  if [ "$batch" != "batch" ]; then 
    echo -n "
  Choose an option:
    c - view last compiled file [eg/$langname/test.$lang]
    t - view translation script [tr/translate.$lang.pss]
    s - edit script test file [tr/tr.test.txt]
    e - view error file 
    T - view compiled translation script eg/$langname/translate.$lang.$lang 
    d - delete the compiled translation script eg/$langname/translate.$lang.$lang 
    x - exit test script
    >"

   cctrscript=$bdir/eg/$langname/translate.$langname.$lang
   if [ ! -f $cctrscript ]; then
     cctrscript=$bdir/eg/$langname/translate.$lang.$lang
   fi
   if [ ! -f $cctrscript ]; then
     cctrscript=$bdir/eg/$lang/translate.$lang.$lang
   fi
   if [ ! -f $cctrscript ]; then
     cctrscript=$bdir/eg/$lang/translate.$langname.$lang
   fi

    while read com ; do
      echo $com
      if [ "$com" == "c" ]; then
        vim $ccscript
      fi
      if [ "$com" == "t" ]; then
        vim $trscript
      fi
      if [ "$com" == "s" ]; then
        vim $bdir/tr/tr.test.txt
      fi
      if [ "$com" == "e" ]; then
        vim $errorfile
      fi
      if [ "$com" == "T" ]; then
        vim $cctrscript 
      fi
      if [ "$com" == "d" ]; then
        rm $cctrscript 
      fi
      if [ "$com" == "x" ]; then
        echo "Bye!"; break
      fi

      echo -n "
  Choose an option:
    c - view last compiled file [eg/$langname/test.$lang]
    t - view translation script [tr/translate.$lang.pss]
    s - edit script test file [tr/tr.test.txt]
    d - delete the compiled translation script eg/$langname/translate.$lang.$lang 
    e - view error file 
    x - exit test script
    >"

    done
    return
  fi
}

# translate script file into c and print to stdout or run if input given
function pep.cf {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/clang
  egdir=$bdir/eg/clang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile ['input'] [info]
      translates a scriptfile into c source code (not unicode aware)
      and prints it to stdout. If 'input' is given the file is compiled into 
      pars/eg/clang/ and run with the given input. If the 3rd parameter
      is 'info', then compilation and execution times are shown."
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.c.pss $script
    return
  fi
  input=$2
  file=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.c.pss $script > $egdir/$file.c
  g=~/sf/htdocs/books/pars/object

  if [ "$3" == "info" ]; then
    echo "Translated $script into c source with tr/translate.c.pss "
    echo "Compiling $script to eg/clang/$file.c"
    time gcc -o $egdir/$file.ex $egdir/$file.c -L$g -lmachine -I$g
    echo "[c compilation time]"
    echo "compiled size: $(du -sh $egdir/$file.ex | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    chmod a+x $egdir/$file.ex
    time echo -n "$input" | $egdir/$file.ex
    echo "[execution times]"
  else
    gcc -o $egdir/$file.ex $egdir/$file.c -L$g -lmachine -I$g
    #gcc -o $h/eg/clang/$file.ex $h/eg/clang/$file.c -L$g -lmachine -I$g
    chmod a+x $egdir/$file.ex
    echo -n "$input" | $egdir/$file.ex
  fi
}

# translate script file into c and run with file as input if given
function pep.cff {
  egdir=$bdir/eg/clang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile [input-file] [info]
      translates a scriptfile into c source code (not unicode aware)
      and prints it to stdout. If 'input-file' is given the file is compiled into 
      pars/eg/clang/ and run with the given input. If the 3rd parameter
      is 'info', then compilation and execution times are shown."
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.c.pss $script
    return
  fi
  input=$2
  file=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.c.pss $script > $egdir/$file.c
  g=~/sf/htdocs/books/pars/object

  if [ "$3" == "info" ]; then
    echo "Translated $script into c source with tr/translate.c.pss "
    echo "Compiling $script to eg/clang/$file.c"
    time gcc -o $egdir/$file.ex $egdir/$file.c -L$g -lmachine -I$g
    echo "[c compilation time]"
    echo "compiled size: $(du -sh $egdir/$file.ex | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    chmod o+x $egdir/$file.ex
    time cat $input | $egdir/$file.ex
    echo "[execution times]"
  else
    gcc -o $egdir/$file.ex $egdir/$file.c -L$g -lmachine -I$g
    chmod o+x $egdir/$file.ex
    cat $input | $egdir/$file.ex
  fi
}

#-------------------
# Perl translation helpers

# translate script into perl and print to stdout or run if input given
function pep.pls {
  egdir=$bdir/eg/perl
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates a script into perl source code using 
      tr/translate.perl.pss and prints it to stdout. If 'input' 
      is given the code is run with the given input. If the 3rd parameter
      is 'info' is given then the execution time is displayed.
      " 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.perl.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.perl.pss -i "$script" > $egdir/test.pl
  chmod a+x $egdir/test.pl
  if [ "$3" == "info" ]; then
    echo "Translated $script into perl with tr/translate.perl.pss "
    echo "into file eg/perl/test.pl"
    echo "javascript size: $(du -sh $egdir/test.pl | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo $input | $egdir/test.pl
    echo "[execution times]"
  else
    echo $input | $egdir/test.pl
  fi
}

# translate script file into perl and print to stdout or run if input given
function pep.plf {
  egdir=$bdir/eg/perl
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'scriptfile' ['input'] [info]
      translates a .pss scriptfile into perl source code using 
      tr/translate.perl.pss and prints it to stdout. If 'input' 
      is given the code is run with the given input. If the 3rd parameter
      is 'info' is given then the execution time is displayed.
      " 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.perl.pss "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.perl.pss "$script" > $egdir/test.pl
  chmod a+x $egdir/test.pl
  if [ "$3" == "info" ]; then
    echo "Translated $script into perl with tr/translate.perl.pss "
    echo "into file eg/perl/test.pl"
    echo "javascript size: $(du -sh $egdir/test.pl | cut -f 1)"
    echo " "
    echo "[script output ...] "
    time echo $input | $egdir/test.pl
    echo "[execution times]"
  else
    echo $input | $egdir/test.pl
  fi
}

#-------------------
# Ruby translation helpers

# translate script into ruby and print to stdout or run if input given
function pep.rbs {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/ruby
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input']
      translates a script into ruby source code and prints it 
      to stdout. If 'input' is given the code is run with the
      given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.ruby.pss -i "$script"
    return
  fi
  input=$2
  pep -f $bdir/tr/translate.ruby.pss -i "$script" > $h/eg/ruby/test.rb
  #echo -e "[running the script eg/ruby/test.rb]" 
  chmod a+x $bdir/eg/ruby/test.rb
  echo -n "$input" | $h/eg/ruby/test.rb
}

# testing 2nd generation script execution 
# first the translator is translated in ruby, then the inline script
# is translated with the new ruby translator, then if input is given
# the script is run
function pep.rbss {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/ruby
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [no]
      translates a script into ruby source code *using the ruby
      translator* (2nd gen) and prints it 
      to stdout. If 'input' is given the code is run with the
      given input. 
      if [no] is given do not recompile translate.ruby.rb " 
    return
  fi
  lang=rb
  langname=ruby
  trscript=$bdir/eg/$langname/translate.$langname.$lang
  egdir=$bdir/eg/$langname

  if [ "$3" == "" ] || [ ! -f $trscript ]; then
    pep -f $bdir/tr/translate.ruby.pss $bdir/tr/translate.ruby.pss \
      > $trscript
    chmod a+x $trscript
  fi

  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | $bdir/eg/ruby/translate.ruby.rb | less
    return
  fi
  input=$2
  echo "$script" | $bdir/eg/ruby/translate.ruby.rb > $bdir/eg/ruby/test.rb
  # echo -e "[running the script eg/ruby/test.rb 2nd generation]" 
  chmod a+x $bdir/eg/ruby/test.rb
  echo -n "$input" | $h/eg/ruby/test.rb
}

# translate scriptfile into ruby and print to stdout or run if input given
function pep.rbf {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/ruby
  egdir=$bdir/eg/ruby
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile ['input']
      translates a scriptfile into ruby source code and prints it 
      to stdout. If 'input' is given the code is run with the
      given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.ruby.pss "$script" | less
    return
  fi
  input=$2
  file=$(basename ${script%.?*})
  pep -f $bdir/tr/translate.ruby.pss "$script" > $egdir/$file.rb
  echo -e "[running the script eg/ruby/test.rb]" 
  chmod a+x $bdir/eg/ruby/$file.rb
  echo -n "$input" | $egdir/$file.rb
}

# translate scriptfile into ruby and print to stdout or run with input file 
function pep.rbff {
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/ruby
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} scriptfile [inputfile]
      translates a scriptfile into ruby source code and prints it 
      to stdout. If 'inputfile' is given the code is run with the
      given input" 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/tr/translate.ruby.pss "$script"
    return
  fi
  input=$2
  file=$(basename ${file%.?*})
  pep -f $bdir/tr/translate.ruby.pss "$script" > $h/eg/ruby/$file.rb
  echo -e "[running the script eg/ruby/test.rb]" 
  chmod a+x $bdir/eg/ruby/$file.rb
  cat $input | $h/eg/ruby/$file.rb
}


# testing 2nd generation script execution 
# first the translator is translated into a language, then the inline script
# is translated with the new translator, then if input is given
# the script is run
function pep.genss {
  lang="tcl"
  h=~/sf/htdocs/books/pars
  f=~/sf/htdocs/books/pars/eg/$lang
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'language' 'script' ['input'] [no]
      translates a script into $lang source code *using the $lang
      translator* (2nd gen) and prints it 
      to stdout. If 'input' is given the code is run with the
      given input. 
      if [no] is given do not recompile translate.$lang.$lang " 
    return
  fi
  if [ "$3" == "" ]; then
    pep -f $bdir/tr/translate.$lang.pss $bdir/tr/translate.$lang.pss \
      > $bdir/eg/$lang/translate.$lang.$lang
    chmod a+x $bdir/eg/$lang/translate.$lang.$lang
  fi

  script=$1
  if [ "$2" == "" ]; then
    echo "$script" | $bdir/eg/$lang/translate.$lang.$lang | less
    return
  fi
  input=$2
  echo "$script" | $bdir/eg/$lang/translate.$lang.$lang > $bdir/eg/$lang/test.$lang
  # echo -e "[running the script eg/$lang/test.$lang 2nd generation]" 
  chmod a+x $bdir/eg/$lang/test.$lang
  echo -n "$input" | $h/eg/$lang/test.$lang
}

#------------
# pars book functions

alias pb="vim ~/sf/htdocs/books/pars/pars-book.txt"

# convert the booklet to LaTeX but not pdf 
function pep.lb {
  # echo "Converting pars-book.txt into latex with mark.latex.pss"
  cd $bdir
  pep -f eg/mark.latex.pss pars-book.txt | less 
}

# make the pdf booklet from pars-book.txt with pars/eg/mark.latex.pss
function pep.mb {
  echo "Converting pars-book.txt into pdf with mark.latex.pss"
  cd $bdir
  pep -f eg/mark.latex.pss pars-book.txt > book.tex
  # run twice for table of contents
  pdflatex book.tex
  pdflatex book.tex
  echo "Made book.pdf"
}

# make the pdf booklet from pars-book.txt with pars/eg/mark.latex.pss
function pep.mbs {
  echo "Converting pars-book.txt into pdf with mark.latex.simple.pss"
  cd $bdir
  pep -f eg/mark.latex.simple.pss pars-book.txt > pars-book.tex
  # run twice for table of contents
  pdflatex pars-book.tex
  pdflatex pars-book.tex
  echo "Made pars-book.pdf"
}

# translate a sed script into java and print to stdout or run if input given
# 
function pep.sedjas {
  egdir=$bdir/eg/java
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates an inline sed script into java source code and prints it 
      to stdout. If 'input' is given the java code is compiled and run with the
      given input. If the 3rd parameter is 'info' then compilation and 
      execution time is displayed." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/eg/sed.tojava.pss -i "$script"
    return
  fi
  input=$2
  # newname="Test"
  newname="javased"

  pep -f $bdir/eg/sed.tojava.pss -i "$script" > $egdir/$newname.java
  #cd $bdir/eg/java/; 
  # change the class name to "Test"
  sed -i "s/javased/$newname/g" $egdir/$newname.java

  if [ "$3" == "info" ]; then
    echo "Translated inline sed script into java with eg/sed.tojava.pss "
    echo "Compiling inline script to eg/java/$newname.class ..."
    time javac -classpath $egdir $egdir/$newname.java
    echo "[javac compilation time]"
    echo "compiled size: $(du -sh $egdir/$newname.class | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    time echo -n "$input" | java -classpath $egdir $newname 
    echo "[execution times]"
  else
    javac -classpath $egdir $egdir/$newname.java
    echo -n "$input" | java -classpath $egdir $newname 
  fi
}

# translate a sed script into java and print to stdout or run if input
# file is given
# 
function pep.sedjaf {
  egdir=$bdir/eg/java
  if [ "$1" == "" ]; then
    echo -e "
    usage: ${FUNCNAME[0]} 'script' ['input'] [info]
      translates an inline sed script into java source code and prints it 
      to stdout. If 'input' is given the java code is compiled and run with the
      given inputfile. If the 3rd parameter is 'info' then compilation and 
      execution time is displayed." 
    return
  fi
  script=$1
  if [ "$2" == "" ]; then
    pep -f $bdir/eg/sed.tojava.pss -i "$script"
    return
  fi
  input=$2
  newname="Test"

  pep -f $bdir/eg/sed.tojava.pss -i "$script" > $egdir/Test.java
  # change the class name to "Test"
  sed -i "s/javased/Test/g" $egdir/Test.java

  if [ "$3" == "info" ]; then
    echo "Translated inline sed script into java with eg/sed.tojava.pss "
    echo "Compiling inline script to eg/java/$newname.class ..."
    time javac -classpath $egdir $egdir/$newname.java
    echo "[javac compilation time]"
    echo "compiled size: $(du -sh $egdir/$newname.class | cut -f 1)"
    echo " "
    echo "[compiled script output ...] "
    time cat "$input" | java -classpath $egdir $newname 
    echo "[execution times]"
  else
    javac -classpath $egdir $egdir/$newname.java
    cat "$input" | java -classpath $egdir $newname 
  fi
}

