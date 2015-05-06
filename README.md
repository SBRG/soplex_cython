soplex_cython
=============

Cython bindings to soplex 2. Build soplex first, then this extension.

Build soplex
------------
1. [Download](http://soplex.zib.de/#download) and unzip the soplex source code.
2. Install gmp.
  - mac: ```brew install gmp``` and add ```-I/usr/local/include``` to the
    CPPFLAGS section of the Makefile
  - Ubuntu: ```sudo apt-get install libgmp-dev```
3. run ```export USRCPPFLAGS=" -DWITH_LONG_DOUBLE "```
4. Compile soplex using ```make SHARED=true GMP=true ZLIB=false VERBOSE=true```
 - This may fail to link, which is fine.
5. Compile a library for static linking (libsoplex.a)
 - On a mac first run ```rm obj/*/lib/gzstream.o``` 
 - Run ```ar crs libsoplex.a obj/*/lib/*```

Build soplex_cython
-------------------

1. Copy libsoplex.a from the previous build step to the soplex_cython directory.
2. Install Cython if not installed with ```pip install cython```
3. Edit setup.py so include_dirs points to the src folder of soplex.
4. Run ```./build.sh``` which will build the extension and run the
   cobrapy solver unit tests.
5. Use ```setup.py install``` to install just like any other python package.
