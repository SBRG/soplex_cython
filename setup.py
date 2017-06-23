from setuptools import setup, msvc
from sys import platform, argv, version_info

from Cython.Distutils import build_ext, Extension
from Cython.Build import cythonize
from glob import glob
import tarfile
import shutil
import struct
import os.path as path


# files that should not be compiled
soplex_ver = "3.0.0"
soplex_src = ["soplex/src"]
omit = ["example.cpp", "soplexmain.cpp", "testsoplex.cpp"]
bitness = struct.calcsize("P") * 8

# default build options for Linux
include_dirs = ["soplex/src"]  # soplex.h
library_dirs = ["lib"]  # where libsoplex.a is located
sources = ["soplex.pyx"]
extra_compile_args = ["--std=c++0x", "-DWITH_LONG_DOUBLE", "-DSOPLEX_WITH_GMP"]
extra_link_args = []


def soplex_sources(soplex_dir="soplex"):
    sources = glob(soplex_dir + "/src/*.cpp")
    sources = [f for f in sources if not any(o in f for o in omit)]
    return sources


def extract_soplex():
    soplex_file = "soplex-" + soplex_ver + ".tgz"
    with tarfile.open(soplex_file, "r:gz") as tgz_file:
        tgz_file.extractall()
        shutil.move("soplex-" + soplex_ver, "soplex")


def prepare_mpir():
    if path.isdir("mpir") and not path.isdir("lib/mpir"):
        rel = ("mpir/lib/x64/Release" if bitness == 64 else
               "mpir/lib/Win32/Release")
        shutil.copytree(rel, path.join("lib", "mpir"))
        shutil.move("lib/mpir/mpir.lib", "lib/gmp.lib")


# extract files and setup compilation list
extract_soplex()
sources.extend(soplex_sources())


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
    include_dirs.append(".\\lib\\mpir")
    # those are super obvious... not :(
    extra_compile_args = ["-DSOPLEX_WITH_GMP", "/MT", "/EHsc", "-Ox", "-Oi", 
                          "-GR", "-fp:precise", "-D_CRT_SECURE_NO_WARNINGS", 
                          "-DNDEBUG", "-wd4274", "-DWITH_LONG_DOUBLE"]
    prepare_mpir()

ext_modules = cythonize([Extension(
    "soplex", sources,
    include_dirs=include_dirs,
    libraries=["gmp"],
    library_dirs=library_dirs,
    extra_compile_args=extra_compile_args,
    extra_link_args=extra_link_args,
    language="c++")])

setup(
    name="soplex",
    cmdclass={"build_ext": build_ext},
    ext_modules=ext_modules,
    version="0.0.5"
)
