FROM nvcr.io/nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

MAINTAINER Nachi nachi@dsaid.gov.sg

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y build-essential \
	git \
	vim \
	libopencv-dev \
	wget

# install darknet
RUN git clone https://github.com/AlexeyAB/darknet.git /root/darknet
WORKDIR /root/darknet
RUN sed -i s/GPU=0/GPU=1/g Makefile
RUN sed -i s/CUDNN=0/CUDNN=1/g Makefile

# to use Tensor Cores if available
ARG CUDNN_HALF
RUN if [ "$CUDNN_HALF" = "True" ]; then \
        sed -i s/CUDNN_HALF=0/CUDNN_HALF=1/g Makefile; \
fi

RUN sed -i s/OPENCV=0/OPENCV=1/g Makefile
RUN sed -i s/LIBSO=0/LIBSO=1/g Makefile
RUN sed -i '17 s/ARCH/# ARCH/' Makefile
RUN sed -i '35 s/# ARCH/ARCH/' Makefile 
RUN make

RUN wget https://pjreddie.com/media/files/yolov3.weights

CMD ["./image_yolov3.sh"]
