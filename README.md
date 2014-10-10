soplex_cython
=============

Cython bindings to soplex 2.0.0

First build soplex using the following steps:

1. Install gmp.
  - mac: ```brew install gmp```
  - Ubuntu: ```sudo apt-get install libgmp-dev```
2. Edit the Makefile
 - Remove -Wconversion from the GCCWARN section
 - Add -DWITH_LONG_DOUBLE to the CPPFLAGS section
 - mac: add ```-I/usr/local/include``` to the CPPFLAGS section
3. Compile soplex using ```make SHARED=true ZLIB=false VERBOSE=true```
 - This may fail to link, which is fine.
4. Compile a library for static linking (libsoplex.a)
 - On a mac first run ```rm obj/*/lib/gzstream.o``` 
 - Run ```ar crs libsoplex.a obj/*/lib/*```

Now that soplex is built, copy libsoplex.a to the soplex_cython directory.

Edit setup.py so include_dirs points to the src folder of soplex.

At this point, Running ```./build.sh``` will build the extension and run the
cobrapy solver unit tests.
