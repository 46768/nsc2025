Code Execution Server
=====================

The code execution server is a server written in python to handle code execution requests.
The server uses a python3 interpreter to execute code rather than a custom python implementation
to ensure python code are executed correctly.

.. note::
    The server ran by the game's IDE uses python 3.13.2 from anaconda

=========
Functions
=========

.. autofunction:: server.cancel_all_tasks
.. autofunction:: server.build_reverse_proxy

======
Packet
======

.. automodule:: packet
    :members:

===
VFS
===

.. automodule:: vfs
    :members:

==============
Code Execution
==============

.. automodule:: code_execution
    :members:
