soplex_cython
=============

Cython bindings to SoPlex 3. Build soplex first using the following instructions, then this extension.

# Compile soplex and install soplex_cython

## Part 1: Build SoPlex 

1. [Download](http://soplex.zib.de/#download) and unzip the SoPlex source code.
2. Install gmp.
   - mac: ```brew install gmp```
   - Ubuntu: ```sudo apt-get install libgmp-dev```
3. Apply patch to allow for compiling with long double precision
   - ```cd [soplex root]/src```
   - ```patch -b < [soplex_cython root]/long-double.patch```
   - ```cd ..```
4. Compile soplex
   - run ```export USRCPPFLAGS=" -DWITH_LONG_DOUBLE "```
   - ```make SHARED=true GMP=true ZLIB=false VERBOSE=true```
   - This may fail to link, which is fine.
5. Compile a library for static linking (libsoplex.a)
   - On a mac first run ```rm obj/*/lib/gzstream.o``` 
   - Run ```ar crs libsoplex.a obj/*/lib/*```

## Part 2: Build soplex_cython

1. Copy libsoplex.a from the previous build step to the soplex_cython directory.
2. Edit setup.py so include_dirs points to the src folder of soplex.
3. Run ```./build.sh``` which will build the extension
4. Use ```setup.py install``` to install just like any other python package.

## Requirements
1. A recent version of Cython. Can be installed with ```pip install cython```
2. Python versions >= 2.7

## Common errors
1. **```undefined symbol: _ZN6soplex6SoPlex13changeRhsRealEiRKe``` when running ```build.sh```**
   - Errors similar to this usually occur when SoPlex is not compiled in part 1 with the long double flag correctly set 
   - Verify that you see "-DWITH_LONG_DOUBLE" in the output when compiling SoPlex in part 1
