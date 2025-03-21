COSH
====

Source code: `scripts/core/cosh/cosh.gd <https://github.com/46768/nsc2025/blob/documentation-seqasm/scripts/core/cosh/cosh.gd>`_

.. toctree::
    :maxdepth: 2
    :caption: Content:

    shell-modules

COSH is a modular shell designed for running functions as commands to allow the
user to interact with parts of the game. It uses a callable dictionary with the
command as the key, and the callable that runs when a command is ran by the
user as the value allowing for interactive system while requiring minimal GUI.

.. note::

    COSH is not a GUI element, it's a class that have the necessary properties
    and methods exposed that allows for making a GUI wrapper around it. COSH
    can be used directly by code but for the purpose of the game it's built for
    a terminal is made for better user experience

========================
Initializing a new shell
========================

Initializing a shell requires a :abbr:`VFS (Virtual filesystem)` to attach to
for the shell to function as most of the shell's functionality involves file
management and running commands on file much like a normal shell. By default
a new shell instance will start at the root of the filesystem and have the
builtin commands loaded. Additional commands can be added via shell modules

.. seealso::

    :doc:`shell-modules`

======================
Running shell commands
======================

To run a command, you can use the ``run_command`` method by giving the command
string in the first argument, and a PackedStringArray for the command arguments
in the second argument, the command output will be appended to the 
``output_buffer`` property of the shell and the ``output_changed`` signal will
be emitted with no additional data. Additionaly you can use ``run_command_slient``
to run a command without modifying the output buffer
