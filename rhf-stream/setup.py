from setuptools import setup
from Cython.Build import cythonize
from distutils.extension import Extension

ext_modules=[
    Extension("split", ["split.pyx"]),
    Extension("incr_kurtosis", ["incr_kurtosis.pyx"]),
	Extension("kurtosis_sum", ["kurtosis_sum.pyx"]),
	Extension("anomaly_score", ["anomaly_score.pyx"]),
	Extension("get_attribute", ["get_attribute.pyx"]),
    Extension("rht", ["rht.pyx"]),
	Extension("rhf", ["rhf.pyx"]),  
    #Extension("insert", ["insert.pyx"]),
    #Extension("rhf_stream", ["rhf_stream.pyx"]),
    #Extension("rht_stream", ["rht_stream.pyx"])
]

setup(
    ext_modules = cythonize(ext_modules, gdb_debug=True, annotate=True, compiler_directives={'language_level' : "3"})
)
