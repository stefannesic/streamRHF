local:
	python3 setup.py build_ext --inplace

install:
	python3 setup.py install --user

clean:
	rm -rf src/__py*
	rm -rf build/ cython_debug/ dist/ UNKNOWN.egg-info/
	find ./ -type f \( -iname \*.html -o -iname \*.c -o -iname \*.so \) -delete
