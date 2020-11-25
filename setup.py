from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules = cythonize("kurtosis_sum.pyx", annotate=True, compiler_directives={'language_level' : "3"})
)
