SeqASM
======

SeqASM is an extensible assembly-like language for giving
interactivity to a coding problem or teaching modules
while being portable through JSON serialization. It supports
multiple ISAs by using .gd definition file to define the
functionality of a mnemonics

======
Syntax
======

SeqASM's syntax is similar to AT&T assembly syntax with ``$`` as
literal, and ``%`` as referencing to memory, but the main difference
is that literals need data type, and there are 2 ways to reference memory
with ``%`` for assemble time substitution and ``%.`` for runtime substitution

Here is an example SeqASM program for calculating the 25th number
in the fibonacci sequence into ``reg1`` memory label

.. code:: asm

    ; Set initial values in memory to define memory labels
    mov $d.0, $m.counter
    mov $d.0, $m.reg1
    mov $d.1, $m.reg2

    loop:
        ; Check if the loop had looped 25 times yet
        cmp %.counter, $d.25
        je exit ; If counter == 25, jumps to exit label

        ; Swap reg1 and reg2
        mov %.reg1, $m.temp ; Uses %. for runtime substitution to get the value of reg1 and place it to temp
        mov %.reg2, $m.reg1 ; mov takes a value and set the memory label, so we substitute the value with
                            ; the value of reg2 then place it at reg1
        mov %.temp, $m.reg2

        add %.reg1, $m.reg2

        ; Increment counter and loop back
        inc $m.counter
        jmp loop

    exit:
        ; Output reg1 to the shell
        shell $s.echo, $s.The_25th_number_in_the_fibonacci_sequence_is_, %.reg1
        cpu_halt ; Optional as the CPU halts if the instruction pointer is >= program length

===
ISA
===

An ISA contains the functionality of mnemonics, packaged into
a .gd file, an empty ISA can be written as

.. code:: gdscript

    extends RefCounted

    var isa_name: StringName = &"" # Name of the ISA, used as the name of the namespace when executing
    var types: Dictionary[String, Callable] = {} # Types defined in the ISA

    # Put your opcode here, the name of the opcode is the same as the name of the function
    # and an opcode will take in an array as argument, first element of the array contains
    # an array containing the reference to the CPU running, and the CPU's memory in that
    # order, the rest of the argument array is the operands with runtime substitution processed

.. toctree::
   :maxdepth: 2
   :caption: ISAs:

   isa/base
   isa/ide
