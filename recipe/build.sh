#!/bin/sh

INCLUDE_PATH="$PREFIX/include"
LIBRARY_PATH="$PREFIX/lib"

export LDFLAGS="-Wl,-rpath,$LIBRARY_PATH $LDFLAGS"
if [[ "$(uname)" == "Darwin" ]]; then
  # scrub problematic -fdebug-prefix-map from C[XX]FLAGS
  # these are loaded in the clang[++] activate scripts
  export CFLAGS=$(echo $CFLAGS | sed -E 's@\-fdebug\-prefix\-map[^ ]*@@g')
  export CXXFLAGS=$(echo $CXXFLAGS | sed -E 's@\-fdebug\-prefix\-map[^ ]*@@g')
fi


mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INCLUDE_PATH="$INCLUDE_PATH" \
  -DCMAKE_LIBRARY_PATH="$LIBRARY_PATH" \
  -DBOOST_ROOT="$PREFIX" \
  -DENABLE_TESTS=1 \
  -DMSHR_ENABLE_VTK=0 \
  ..

make -j${CPU_COUNT} VERBOSE=1
make install

cd ../python
$PYTHON -m pip install -v --no-deps --ignore-installed --no-binary :all: .
