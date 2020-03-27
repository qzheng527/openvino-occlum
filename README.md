# openvino-occlum

It is a OpenVino demo on [`Occlum`](https://github.com/occlum/occlum) library OS (LibOS) for [`Intel SGX`](https://software.intel.com/en-us/sgx).

## Build openvino container image on alpine with musl libc on your host

```
docker build --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy -t openvino-alpine ./openvino-alpine/
```

## Run Occlum container image on your host

First make sure the prerequisites ([steps 1 and 2](https://github.com/occlum/occlum#how-to-use)) have been done on your host.
```
docker run --rm -it --device /dev/isgx --name occlum  occlum/occlum:0.10.0-ubuntu18.04
```

## Copy required openvino libs/bins to the running occlum container

```
./import_alpine_openvino.sh occlum
```

## Set up and run the openvino demo in occlum container

### Prepare the models and sample inference picture first

Because of the limited SGX memory in my host, I couldn't run benchmark_app.
In our case, we use sample app object_detection_sample_ssd for demo.
So I choose model person-detection-retail-0013.

```
wget https://download.01.org/opencv/2020/openvinotoolkit/2020.1/open_model_zoo/models_bin/1/person-detection-retail-0013/FP16/person-detection-retail-0013.bin
wget https://download.01.org/opencv/2020/openvinotoolkit/2020.1/open_model_zoo/models_bin/1/person-detection-retail-0013/FP16/person-detection-retail-0013.xml
```

Also, prepare one bmp picure for reference.
It is /root/people.bmp in this case.

### Run the demo

```
./run_demo_on_occlum.sh
```

You will get the inference result.
BTW, out_0.bmp creation failure issue is expected due to RO fs.
