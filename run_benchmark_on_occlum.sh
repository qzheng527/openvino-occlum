#!/bin/bash
openvino_app=object_detection_sample_ssd
alpine_root=/root/alpine_openvino
infer_pic=/root/people.bmp
infer_model=/root/person-detection-retail-0013
inference_bin=$alpine_root/openvino/openvino_src/bin/intel64/Release
set -e

# 1. Init Occlum Workspace
rm -rf occlum_context
mkdir occlum_context
cd occlum_context
occlum init
jq '.vm.user_space_size = "256MB"' Occlum.json > temp_Occlum.json
jq '.process.default_stack_size = "4MB"' Occlum.json > temp_Occlum.json
jq '.process.default_heap_size = "32MB"' Occlum.json > temp_Occlum.json
jq '.process.default_mmap_size = "192MB"' Occlum.json > temp_Occlum.json
mv temp_Occlum.json Occlum.json

# 2. Copy files into Occlum Workspace and Build
cp $inference_bin/$openvino_app image/bin
cp $inference_bin/lib/*.so image/lib
cp $inference_bin/lib/plugins.xml image/lib

# tbb
cp $alpine_root/usr/local/lib/libtbb.so.2 image/lib/
cp $alpine_root/usr/local/lib/libtbbmalloc.so.2 image/lib/

# opencv
cp $alpine_root/usr/local/lib64/libopencv_imgcodecs.so.4.2 image/lib/
cp $alpine_root/usr/local/lib64/libopencv_imgproc.so.4.2 image/lib/
cp $alpine_root/usr/local/lib64/libopencv_core.so.4.2 image/lib/

cp $alpine_root/lib/libc.musl-x86_64.so.1 image/lib/

mkdir image/proc
cp /proc/cpuinfo image/proc

# 3. Download models
mkdir image/model
#wget https://download.01.org/opencv/2020/openvinotoolkit/2020.1/open_model_zoo/models_bin/1/person-detection-retail-0013/FP16/person-detection-retail-0013.bin
#wget https://download.01.org/opencv/2020/openvinotoolkit/2020.1/open_model_zoo/models_bin/1/person-detection-retail-0013/FP16/person-detection-retail-0013.xml
cp $infer_model.bin image/model/model.bin
cp $infer_model.xml image/model/model.xml
cp $infer_pic image/model/pic.bmp

# 4. Build
occlum build

# 5. Run Openvino sample
occlum run /bin/$openvino_app -i /model/pic.bmp -m /model/model.xml
