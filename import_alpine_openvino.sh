#!/bin/bash
set -e
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}"  )" >/dev/null 2>&1 && pwd )"

# Alpine Linux's based OpenVino docker image built previously
alpine_openvino_img="openvino-alpine"
target_container=$1

if [ "$target_container" == "" ];then
cat <<EOF
Import the rootfs of Alpine Linux's OpenVino Docker image into a target Occlum container (/root/alpine_openvino)

USAGE:
    ./import_alpine_openvino.sh <target_container>

<target_container>:
    The id or name of Docker container that you want to copy to.
EOF
    exit 1
fi

alpine_openvino_container="alpine_openvino_docker"
alpine_openvino_tar="$script_dir/alpine_openvino.tar"
alpine_openvino="$script_dir/alpine_openvino"

# Export the rootfs from Alpine's Docker image
docker create --name $alpine_openvino_container $alpine_openvino_img
docker export -o $alpine_openvino_tar $alpine_openvino_container
docker rm $alpine_openvino_container

# Copy the exported rootfs to the Occlum container
rm -rf $alpine_openvino && mkdir -p $alpine_openvino
tar -xf $alpine_openvino_tar -C $alpine_openvino
docker cp $alpine_openvino $target_container:/root/

# Copy run script to the Occlum container
docker cp run_benchmark_on_occlum.sh $target_container:/root/

# Clean up
rm -rf $alpine_openvino $alpine_openvino_tar
