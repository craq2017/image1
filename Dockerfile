FROM ubuntu:18.04

RUN apt-get -y update && \
    apt-get -y install \
    nano \
    curl \
    python3 \
    python3-pip \
    wget \
    cmake \
    git \
    sudo \
    libsm6 \
    libxrender1 \
    libxext6 \
    libreadline-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
	python-qt4 \
	python3-pyqt5 \
	qtbase5-dev 

RUN git clone -b 'v19.16' --single-branch https://github.com/davisking/dlib.git /root/dlib
# Disable AVX support
RUN sed -i 's/set(AVX_IS_AVAILABLE_ON_HOST 1)/#set(AVX_IS_AVAILABLE_ON_HOST 1)/' /root/dlib/dlib/cmake_utils/check_if_avx_instructions_executable_on_host.cmake
RUN cd /root/dlib && python3 setup.py install --no USE_AVX_INSTRUCTION
RUN rm -rf /root/dlib

RUN pip3 install numpy opencv-python

RUN git clone https://github.com/torch/distro.git /root/torch --recursive
# Disable AVX support
RUN sed -i 's/CHECK_SSE(C "AVX/#CHECK_SSE(C "AVX/' /root/torch/pkg/torch/lib/TH/cmake/FindSSE.cmake
RUN sed -i 's/CHECK_SSE(CXX "AVX/#CHECK_SSE(CXX "AVX/' /root/torch/pkg/torch/lib/TH/cmake/FindSSE.cmake
RUN cd /root/torch && mkdir /opt/torch && export PREFIX=/opt/torch && ./install.sh
RUN git config --global url.https://github.com/.insteadOf git://github.com/
RUN cd /opt/torch/bin && \
    ./luarocks install nn && \
    ./luarocks install dpnn && \
    ./luarocks install optim && \
    ./luarocks install csvigo

RUN rm -rf /root/torch

RUN rm -rf /root/.cache
RUN rm -rf /root/.wget-hsts
RUN apt-get remove -y libreadline-dev libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libpng-dev libtinfo-dev zlib1g-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*
