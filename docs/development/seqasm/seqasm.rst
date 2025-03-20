SeqASM
======

SeqASM is a Turing complete assembly-like language for
giving interactivity to a coding problem or teaching modules
while being portable through JSON serialization. It supports
multiple ISAs by using .gd definition file to define the
functionality of a mnemonics

======
Syntax
======

SeqASM's syntax is similar to AT&T assembly syntax with ``$`` as
literal, and ``%`` as referencing to memory, but the main difference
is that literals need data type, and there are 2 ways to reference memory
with ``%`` for assemble time substitution and ``%.`` for runtime substitution.
The separator for the opcode/operands is a ``~`` to support spaces in operands
for some mnemonic like ``shell``

Here is some example SeqASM program for calculating the 25th number
in the fibonacci sequence into ``reg1`` memory label

.. code::

    ; Set initial values in memory to define memory labels
    mov~$d.0~$m.counter
    mov~$d.0~$m.reg1
    mov~$d.1~$m.reg2

    loop:
        ; Check if the loop had looped 25 times yet
        cmp~%.counter~$d.25
        je~>exit ; If counter == 25, jumps to exit label

        ; Swap reg1 and reg2
        mov~%.reg1~$m.temp ; Uses %. for runtime substitution to get the value of reg1 and place it to temp
        mov~%.reg2~$m.reg1 ; mov takes a value and set the memory label, so we substitute the value with
                           ; the value of reg2 then place it at reg1
        mov~%.temp~$m.reg2

        add~%.reg1~$m.reg2

        ; Increment counter and loop back
        inc~$m.counter
        jmp~>loop

    exit:
        ; Output reg1 to the shell
        shell~$s.echo The 25th number in the fibonacci sequence is ~%.reg1
        cpu_halt ; Optional as the CPU halts if the instruction pointer is >= program length



