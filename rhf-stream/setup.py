from setuptools import setup
from Cython.Build import cythonize
from distutils.extension import Extension

ext_modules=[
    Extension("rhf_stream", ["rhf_stream.pyx"]),
]

setup(
    ext_modules = cythonize(ext_modules, gdb_debug=True, annotate=True, compiler_directives={'language_level' : "3"})
)
