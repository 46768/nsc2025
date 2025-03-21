Shell Modules
=============

Shell modules are a way to extend the functionality of a COSH instance by adding
commands or signals to it. Modules can be added or remove at runtime meaning
commands/signals can be added or removed at anytime.

======================
Writing a shell module
======================

Writing a shell module involves making a class that's extends a ``COSHModule``
class then setting properites within the ``_init`` method. The base module
class (``COSHModule``) contains 3 properties that should be overwritten which
are the module name (``module_name``) as String, the commands the module
provides (``commands``) as ``Dictionary[String, Callable]``, and the signals
the module provides (``signals``) as ``Dictionary[String, Signal]``. For example

.. code:: gdscript

    class_name COSHExampleModule
    extends COSHModule


    func _init() -> void:
        module_name = "ExampleModule"
        commands = {
            "example_command": example_command,
        }
        signals = {}


    func example_command(shell: COSH, args: PackedStringArray) -> String:
        if args.is_empty():
            return "example_command: missing number in first argument\n"

        var num: int = int(args[0])

        if num % 2 == 0:
            return "num is even\n"
        else:
            return "num is odd\n"

After that, you can initialize ``COSHExampleModule`` with ``.new()`` then add
it to a shell using ``.install_module`` method of the class and using the shell
you are installing the module for as the first argument. The reason for
not making shell modules a static class is that it allows for more flexible
modules as you can make the module takes in argument during initialization
for processing, and that I cant find a way better than using classes for making
shell modules
