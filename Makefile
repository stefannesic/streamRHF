local:
	python3 setup.py build_ext --inplace

clean:
	rm -rf src/__py*
	rm -rf build/ cython_debug/
	find ./ -type f \( -iname \*.html -o -iname \*.c -o -iname \*.so \) -delete
