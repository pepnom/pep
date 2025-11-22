#!/usr/bin/bash
dir=object
cc -o pep \
    $dir/pep.c $dir/tapecell.c $dir/tape.c $dir/buffer.c $dir/colours.c \
    $dir/charclass.c $dir/command.c $dir/parameter.c $dir/instruction.c \
    $dir/labeltable.c $dir/program.c $dir/machine.c $dir/exitcode.c \
    $dir/machine.interp.c
echo "* compiled pep interpreter (executable is 'pep')"
