FROM ubuntu:14.04

# ---------------------------------------
# CUDA 7 installation
# ---------------------------------------

# A docker container with the Nvidia kernel module, CUDA drivers, and torch7 installed
ENV CUDA_RUN http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_7.0.28_linux.run

# The one inside the cuda_7.0.28_linux.run does not mathces with the driver of the host machine
# Following driver version matches our host machine driver.
ENV CUDA_DRIVER http://us.download.nvidia.com/XFree86/Linux-x86_64/352.21/NVIDIA-Linux-x86_64-352.21.run

RUN apt-get update && apt-get install -q -y \
  wget \
  build-essential

RUN wget -q $CUDA_DRIVER && \
  wget -q $CUDA_RUN

RUN chmod +x *.run && \
  ./NVIDIA-Linux-x86_64-352.21.run -s -N --no-kernel-module && \
  ./cuda_7.0.28_linux.run -extract=/ && \
  chmod +x *.run && \
  ./cuda-linux64-rel-*.run -noprompt && \
  rm *.run

# Ensure the CUDA libs and binaries are in the correct environment variables
ENV LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-7.0/lib64
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-7.0/lib64
ENV PATH=$PATH:/usr/local/cuda-7.0/bin

# ---------------------------------------
# Python 2.7 installation
# ---------------------------------------

# remove several traces of debian python
RUN apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# gpg: key 18ADD4FF: public key "Benjamin Peterson <benjamin@python.org>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF

ENV PYTHON_VERSION 2.7.10

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 7.1.0

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		wget

RUN set -x
RUN mkdir -p /usr/src/python
RUN curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz
RUN curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc
RUN gpg --verify python.tar.xz.asc
RUN tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz
RUN rm python.tar.xz*
RUN apt-get install -y -q zlib1g-dev
RUN apt-get install -y -q libssl-dev
RUN apt-get install -q -y \
  libatlas-base-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  libhdf5-serial-dev \
  libleveldb-dev \
  liblmdb-dev \
  libopencv-dev \
  libprotobuf-dev \
  libsnappy-dev \
  protobuf-compiler
RUN apt-get install -q -y --no-install-recommends libboost-all-dev
RUN cd /usr/src/python && ./configure --enable-shared --enable-unicode=ucs4
RUN cd /usr/src/python && make -j$(nproc)
RUN cd /usr/src/python && make install
RUN cd /usr/src/python && ldconfig
RUN curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python2
RUN pip install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION
RUN find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' +
RUN rm -rf /usr/src/python

# install "virtualenv", since the vast majority of users of this image will want it
RUN pip install --no-cache-dir virtualenv

# ---------------------------------------
# Caffe installation
# ---------------------------------------

# Get dependencies
# RUN apt-get install -q -y \
#   libatlas-base-dev \
#   libgflags-dev \
#   libgoogle-glog-dev \
#   libhdf5-serial-dev \
#   libleveldb-dev \
#   liblmdb-dev \
#   libopencv-dev \
#   libprotobuf-dev \
#   libsnappy-dev \
#   protobuf-compiler

# RUN apt-get install -q -y --no-install-recommends libboost-all-dev

# RUN cd /usr/lib/x86_64-linux-gnu && \
#   ln -s libhdf5_serial.so.8.0.2 libhdf5.so && \
#   ln -s libhdf5_serial_hl.so.8.0.2 libhdf5_hl.so

RUN wget http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-2.1.0-Linux-x86_64.sh
RUN bash Anaconda-2.1.0-Linux-x86.sh


# RUN apt-get install -q -y git
# # Build Caffe core
# RUN git clone --depth 1 https://github.com/BVLC/caffe.git /caffe
# # COPY Makefile.config /caffe/
# # WORKDIR /caffe
# RUN cd /caffe &&  cp Makefile.config.example Makefile.config && make all -j$(nproc)

# Install python deps
# RUN pip install -r /caffe/python/requirements.txt
# RUN pip install Cython>=0.19.2
# RUN pip install numpy>=1.7.1
# RUN pip install scipy>=0.13.2
# RUN pip install scikit-image>=0.9.3
# RUN pip install matplotlib>=1.3.1
# RUN pip install ipython>=3.0.0
# RUN pip install h5py>=2.2.0
# RUN pip install leveldb>=0.191
# RUN pip install networkx>=1.8.1
# RUN pip install nose>=1.3.0
# RUN pip install pandas>=0.12.0
# RUN pip install python-dateutil>=1.4,<2
# RUN pip install protobuf>=2.5.0
# RUN pip install python-gflags>=2.0
# RUN pip install pyyaml>=3.10
# RUN pip install Pillow>=2.3.0

#
# # ---------------------------------------
# # CUDA installation
# # ---------------------------------------
# COPY cuda_6.5.14_linux_64.run /opt/
# # ADD http://developer.download.nvidia.com/compute/cuda/6_5/rel/installers/cuda_6.5.14_linux_64.run /opt/
#
# RUN apt-get update && apt-get install -q -y build-essential module-init-tools
#
# RUN cd /opt && \
#   chmod +x *.run && \
#   mkdir nvidia_installers && \
#   ./cuda_6.5.14_linux_64.run -extract=`pwd`/nvidia_installers && \
#   cd nvidia_installers && \
#   ./NVIDIA-Linux-x86_64-340.29.run -s -N --no-kernel-module
#
# RUN cd /opt/nvidia_installers && \
#   ./cuda-linux64-rel-6.5.14-18749181.run -noprompt
#
# # Ensure the CUDA libs and binaries are in the correct environment variables
# ENV LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-6.5/lib64
# ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-6.5/lib64
# ENV PATH=$PATH:/usr/local/cuda-6.5/bin
#
# # Check if expected nvcc version was installed
# RUN nvcc --version | grep V6.5.12
#
#
# # ---------------------------------------
# # Caffe installation
# # ---------------------------------------
#
# # Get dependencies
# RUN apt-get install -q -y \
#   gcc-4.8 \
#   g++-4.8 \
#   libatlas-base-dev \
#   libgflags-dev \
#   libgoogle-glog-dev \
#   libhdf5-serial-dev \
#   libleveldb-dev \
#   liblmdb-dev \
#   libopencv-dev \
#   libprotobuf-dev \
#   libsnappy-dev \
#   protobuf-compiler && \
#   apt-get install -q -y --no-install-recommends libboost-all-dev && \
#   update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-4.8 30 && \
#   update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-4.8 30 && \
#   update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 30 && \
#   update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 30 && \
#   cd /usr/lib/x86_64-linux-gnu && \
#   ln -s libhdf5_serial.so.8.0.2 libhdf5.so && \
#   ln -s libhdf5_serial_hl.so.8.0.2 libhdf5_hl.so
#
# # Build Caffe core
# RUN git clone --depth 1 https://github.com/BVLC/caffe.git /caffe
# COPY Makefile.config /caffe/
# WORKDIR /caffe
# RUN make all
#
# # Install python deps
# # RUN pip install -r /caffe/python/requirements.txt --no-install
