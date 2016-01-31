try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from sys import platform

from Cython.Distutils import build_ext, Extension
from Cython.Build import cythonize

include_dirs = ["../soplex/src"]  # soplex.h
library_dirs = ["./"]  # where libsoplex.a is located
extra_compile_args = ["-std=c++0x", '-DWITH_LONG_DOUBLE', "-DSOPLEX_WITH_GMP"]

if platform == "darwin":
    # paths for homebrew gmp and gmpxx
    include_dirs.append("/usr/local/include")
    library_dirs.append("/usr/local/lib")
elif platform == "win32":
    extra_compile_args = ["-DSOPLEX_WITH_GMP", "/MT", "/EHsc"]

ext_modules = cythonize([Extension(
    "soplex", ["soplex.pyx"],
    include_dirs=include_dirs,
    libraries=["soplex", "gmp"],
    library_dirs=library_dirs,
    extra_compile_args=extra_compile_args,
    language="c++")])

setup(
    name="soplex",
    cmdclass={"build_ext": build_ext},
    ext_modules=ext_modules,
    version="0.0.2"
)
