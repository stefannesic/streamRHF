from setuptools import setup
from Cython.Build import cythonize
from distutils.extension import Extension

ext_modules=[
	Extension("kurtosis_sum", ["kurtosis_sum.pyx"]),
	Extension("anomaly_score", ["anomaly_score.pyx"]),
	Extension("get_attribute", ["get_attribute.pyx"]),
	Extension("find_instance", ["find_instance.pyx"]),
	Extension("rht", ["rht.pyx"]),
	Extension("rhf", ["rhf.pyx"]),
	Extension("Node", ["Node.pyx"]),
	Extension("Leaf", ["Leaf.pyx"])
]

setup(
    ext_modules = cythonize(ext_modules, annotate=True, compiler_directives={'language_level' : "3"})
)
