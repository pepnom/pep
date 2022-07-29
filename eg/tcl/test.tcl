#!/usr/bin/tclsh

# code generated by "translate.tcl.pss" a pep script
# see bumble.sf.net/books/pars/
#import sys    # 

  # make a new machine. Standard tcl doesnt have objects
  # so I will use an associative array, instead.
  #array set mm {
  #  eof false     # end of stream reached?
  #  charsRead 0   # how many chars already read
  #  linesRead 1   # how many lines already read
  #  escape "\\"
  #  delimiter "*" # push/pop delimiter (default "*")
  #  counter 0     # a counter for anything
  #  work ""       # the workspace
  #  stack {}    # stack for parse tokens 
  #  cell 0      # current tape cell
  #  size 100    # the initial tape/marks list size
  #  tape {}     # a list of attribute for tokens 
  #  marks {}    # marked tape cells
  #  peep [read stdin 1] 
  #}

  # make a new machine. Standard tcl doesnt have objects
  # so I will use an associative array, instead.
  array set mm {
    eof false     
    charsRead 0  
    linesRead 1 
    escape "\\"
    delimiter "*" 
    counter 0    
    work ""     
    stack {}   
    cell 0    
    size 0 
    tape {}  
    marks {}
    peep {} 
  }

  # Adds more elements to the tape and marks lists 
  proc MoreTape {} { 
    global mm
    for {set ii 0} {$ii < 100} {incr ii} { 
      lappend mm(tape) ""; lappend mm(marks) "";
    }
    incr mm(size) 100
  }

  # initialises a machine  
  proc Init {} { 
    global mm
    set mm(peep) [ read stdin 1 ]
    # or Read;
    MoreTape;
  }

  # read one character from the input stream and 
  #    update the machine.
  proc Read {} { 
    # use upvar eg
    # upvar $machine mm
    global mm
    if { $mm(eof) } { exit }
    incr mm(charsRead)
    # increment lines
    if { $mm(peep) eq "\n" } { incr mm(linesRead) }
    append mm(work) $mm(peep)
    set mm(peep) [ read stdin 1 ]
    if {[eof stdin]} { set mm(eof) true; set mm(peep) -1 }
  } 

  # increment tape pointer by one: trivial method? But need
  # to increase tape/marks size if exceeded
  proc Increment {} { global mm; incr mm(cell) } 

  # remove escape character: trivial method ?
  proc UnescapeChar {c} {
    global mm
    #if { $mm(work) ne "" } $mm(work = $mm(work.replace("\\"+c, c)
  }

  # add escape character : trivial
  proc EscapeChar {c} {
    global mm
    #if { $mm(work) ne "" } { $mm(work = $mm(work.replace(c, "\\"+c) }
  }

  # pop the first token from the stack into the workspace */
  proc Pop {} { 
    global mm
    if {[llength $mm(stack)] == 0} { return false }
    # prepend last stack item, and delete the item
    set mm(work) "[lindex $mm(stack) end]$mm(work)"
    set mm(stack) [lrange $mm(stack) 0 [expr [llength $mm(stack)]-2]] 
    if {$mm(cell) > 0} { incr mm(cell) -1 }
    return true
  }
  
  # push the first token from the workspace to the stack 
  proc Push {} {
    # lappend list $value
    # dont increment the tape pointer on an empty push
    global mm
    if { $mm(work) eq "" } { return false }
    # need to get this from the delimiter.
    set firstdelim [string first $mm(delimiter) $mm(work)]
    if {$firstdelim == -1} {
      lappend mm(stack) $mm(work)
      set mm(work) ""
      incr mm(cell) 1
      # a hack because "stack" hangs otherwise (never returns false)
      return false
      #return true
    }
    lappend mm(stack) [string range $mm(work) 0 $firstdelim]
    set mm(work) [string range $mm(work) [expr {$firstdelim+1}] end]
    incr mm(cell) 1
    return true
  }

  # a helper function
  proc IsEscaped {suffix} {
    global mm
    # remove suffix
    set count 0
    set last [expr {[string last $suffix $mm(work)]-1}]
    set new [string range $mm(work) 0 $last]
    # now count trailing escape chars
    while {[string index $new end] eq $mm(escape)} {
      set last [expr {[string last $mm(escape) $new]-1}]
      set new [string range $new 0 $last]
      incr count
    }
    # puts count=$count
    if { $count == 1 } { return true }
    if {[expr {($count % 2) == 0}]} { return false } else { return true }
  }

  # reads the input stream until the workspace end with text 
  proc Until {suffix} { 
    # read at least one character
    global mm
    if { $mm(eof) } { return }
    Read;
    while true { 
      if {$mm(eof)} { return }
      # this must count trailing escapes
      if {[string match *$suffix $mm(work)] && ![IsEscaped $suffix]} { return }
      Read;
    }
  }  

  # maybe not required 
  proc Swap {} { 
    global mm
    set s $mm(work)
    set mm(work) $mm(tape)[$mm(cell)]
    # could be a problem if $s has spaces in it. (becomes a list)
    lset mm(tape) $mm(cell) $s
  }

  proc GoToMark {mark} { 
    # or use tcls lsearch here.
    global mm
    set ii [lsearch -exact $mm(marks) $mark]
    if {$ii >= 0} { set mm(cell) $ii 
    } else { puts "badmark '$mark'!"; exit; }
  }

  proc WriteToFile {} { 
    global mm
    set f [open sav.pp w 0600]  
    puts $f $mm(work)
    close $f
  }

  # useful for debugging, the "state" command
  proc State {} { 
    global mm
    puts "---------- Machine State --------------";
    puts -nonewline " Stack\[[join $mm(stack) {}]\] Work\[$mm(work)\] ";
    puts "Peep\[$mm(peep)\]";
    puts -nonewline " Acc:$mm(counter) Esc:$mm(escape) ";
    puts -nonewline "Delim:$mm(delimiter) Chars:$mm(charsRead) ";
    puts "Lines:$mm(linesRead)";
    puts "---------- Tape (size:$mm(size))  --------------";
    set ii 0
    while { $ii < 7 } {
      puts -nonewline "  $ii";
      if { $ii == $mm(cell) } { 
        puts -nonewline "> "
      } else { puts -nonewline "  " }
      # display marks
      if { [lindex $mm(marks) $ii] ne "" } { 
        puts -nonewline "\"[lindex $mm(marks) $ii]\" "
      } else { puts -nonewline ". " }

      puts "\[[lindex $mm(tape) $ii]\]";
      incr ii
    }
  }
  # end of tcl pep Machine "class" (array) definition

  # a flag var to make .restart work in run-once loops
  set restart false
  # initialise the machine
  Init;
 
while !$mm(eof) { 
  Read;           # read
  lset mm(marks) $mm(cell) "h"; # mark
  GoToMark "h" 
  puts -nonewline $mm(work);    # print
  puts -nonewline $mm(work);    # print
  set mm(work) "";       # clear
}
# end of generated code
