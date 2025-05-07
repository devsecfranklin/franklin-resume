# src

The include directory contains the header files for the project. Most if not all of the
.c files in the src directory will have a corresponding .h file in the include directory.
The header files should contain the public API for the module, and the source files should
contain the implementation. This makes it easy to see what the module does without having
to look at the implementation. It also makes it easy to test the module in isolation,
as you can just include the header file in your test file.
