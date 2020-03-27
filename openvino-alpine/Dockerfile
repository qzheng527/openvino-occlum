from python:3.7-alpine3.10

COPY ./scripts /openvino

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk update && apk --no-cache add bash cmake make curl wget zlib gcc g++ git linux-headers

RUN cd /openvino && \
        ./download_and_build_openvino_2020.sh
