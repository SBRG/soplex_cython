try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from sys import platform

from Cython.Distutils import build_ext, Extension
from Cython.Build import cythonize

include_dirs = ["../build/soplex-2.0.0/src"] # soplex.h
library_dirs = ["./"] # where libsoplex.a is located

if platform == "darwin":
    # paths for homebrew gmp and gmpxx
    include_dirs.append("/usr/local/include")
    library_dirs.append("/usr/local/lib")

ext_modules = cythonize([Extension("soplex", ["soplex.pyx"],
    include_dirs=include_dirs,
    libraries=["soplex", "gmp", "gmpxx"],
    library_dirs=library_dirs,
    extra_compile_args=["-std=c++0x", '-DWITH_LONG_DOUBLE', "-DSOPLEX_WITH_GMP"],
    language="c++")])

setup(
    name = "soplex",
    cmdclass = {"build_ext": build_ext},
    ext_modules = ext_modules
)
