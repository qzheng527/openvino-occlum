#!/bin/bash
PREFIX=/usr/local
THREADING=TBB
SCRIPT_PATH=/openvino
set -e


build_opencv() {
    rm -rf deps/opencv && mkdir -p deps/opencv
    pushd deps/opencv
    #git clone https://github.com/opencv/opencv .
    #git checkout tags/4.2.0 -b 4.2.0
    wget https://github.com/opencv/opencv/archive/4.2.0.tar.gz && tar xf 4.2.0.tar.gz --strip-components 1
    mkdir build
    cd build
    cmake ../ \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=$PREFIX \
        -DENABLE_PRECOMPILED_HEADERS=OFF \
        -DBUILD_opencv_java=OFF -DBUILD_JAVA_SUPPORT=OFF \
        -DWITH_1394=OFF -DWITH_IPP=OFF \
        -DBUILD_EXAMPLES=OFF -DWITH_FFMPEG=OFF \
        -DWITH_QT=OFF -DWITH_CUDA=OFF -DWITH_TBB=ON \
	-DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF
    make -j
    make install
    popd
}

build_tbb() {
    rm -rf deps/tbb_cmake && mkdir -p deps/tbb_cmake
    pushd deps/tbb_cmake
    wget https://github.com/oneapi-src/oneTBB/archive/v2020.1.tar.gz && tar xf v2020.1.tar.gz --strip-components 1
    # patches to support build on musl https://github.com/oneapi-src/oneTBB/pull/203
    patch -p1 < $SCRIPT_PATH/0001-src-tbbmalloc-proxy.cpp-__GLIBC_PREREQ-is-not-define.patch
    patch -p1 < $SCRIPT_PATH/0002-mallinfo-is-glibc-specific-API-mark-it-so.patch
    python3 ./build/build.py --tbbroot ./ --prefix $PREFIX --install-libs --install-devel
    popd
}


# Build OpenVINO
build_openvino() {
    rm -rf openvino_src && mkdir openvino_src
    pushd openvino_src
    git clone https://github.com/opencv/dldt .
    git checkout tags/2020.1 -b 2020.1
    git submodule update --init --recursive

    rm -rf build && mkdir build && cd build
    cmake ../ \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="-Wno-error=stringop-overflow=" \
      -DCMAKE_C_FLAGS="-Wno-error=stringop-overflow=" \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DTHREADING=TBB \
      -DENABLE_MKL_DNN=ON \
      -DENABLE_CLDNN=OFF \
      -DENABLE_VPU=OFF \
      -DENABLE_OPENCV=OFF \
      -DENABLE_MYRIAD=OFF \
      -DENABLE_GNA=OFF \
      -DTBB_DIR=$PREFIX/lib/cmake/tbb/ \
      -DOpenCV_DIR=$PREFIX/lib64/cmake/opencv4
    make -j 4
    popd
}


echo "Build OpenVINO with TBB threading"
build_tbb
build_opencv
build_openvino
