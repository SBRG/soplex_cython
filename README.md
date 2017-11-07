soplex_cython
=============

Cython bindings to SoPlex 3.0.1

# Installation

1. [Download](http://soplex.zib.de/#download) the **SoPlex 3.0.1** source code and unzip it into [soplex_cython root].
2. Install gmp.
   - mac: ```brew install gmp```
   - Ubuntu: ```sudo apt-get install libgmp-dev```
   - Windows: Install MPIR (GMP replacement, which compiles with Visual Studio)
3. Compile soplex
   - ```cd [soplex_cython root]/[soplex root]```
   - ```export USRCPPFLAGS=" -DWITH_LONG_DOUBLE "```
   - ```make SHARED=true GMP=true ZLIB=false VERBOSE=true```
   - This may fail to link, which is fine.

4. Compile and install soplex_cython
   - ```cd [soplex_cython root]```
   - Mac/Linux: ```pip install .```


## Requirements
1. A recent version of Cython. Can be installed with ```pip install cython```
2. Python versions >= 2.7 (>= 3.5 for Windows builds)

## Common errors
1. **```undefined symbol: _ZN6soplex6SoPlex13changeRhsRealEiRKe``` when running ```build.sh```**
   - Errors similar to this usually occur when SoPlex is not compiled in part 1 with the long double flag correctly set 
   - Verify that you see "-DWITH_LONG_DOUBLE" in the output when compiling SoPlex in part 1
