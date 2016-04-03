try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from sys import platform, argv

from Cython.Distutils import build_ext, Extension
from Cython.Build import cythonize

include_dirs = ["../soplex/src"]  # soplex.h
library_dirs = ["./"]  # where libsoplex.a is located
sources = ["soplex.pyx"]
extra_compile_args = ["-std=c++0x", '-DWITH_LONG_DOUBLE', "-DSOPLEX_WITH_GMP"]
extra_link_args = []

# handle nersc-specific compiling options. This will have to be run with
# a UCS2 version of Python (the default in Ubuntu is UCS4, so a custom
# Python may have to be used.
if "--NERSC" in argv:
    argv.remove("--NERSC")
    extra_link_args = ["-Wl,--wrap=memcpy", "-Wl,-Bsymbolic-functions"]
    sources.append("memcpy.c")  # this prevents a GLIBC2.14 function

if platform == "darwin":
    # paths for homebrew gmp and gmpxx
    include_dirs.append("/usr/local/include")
    library_dirs.append("/usr/local/lib")
elif platform == "win32":
    extra_compile_args = ["-DSOPLEX_WITH_GMP", "/MT", "/EHsc"]

ext_modules = cythonize([Extension(
    "soplex", sources,
    include_dirs=include_dirs,
    libraries=["soplex", "gmp"],
    library_dirs=library_dirs,
    extra_compile_args=extra_compile_args,
    extra_link_args=extra_link_args,
    language="c++")])

setup(
    name="soplex",
    cmdclass={"build_ext": build_ext},
    ext_modules=ext_modules,
    version="0.0.4"
)
