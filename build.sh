rm -rf build soplex.cpp soplex.so
python setup.py build
cp build/lib*/*.so soplex.so
rm -r build soplex.cpp
python test.py
