local:
	python3 setup.py build_ext --inplace

clean:
	rm *.c *.html *.so
	rm -r __py* build/ cython_debug/
