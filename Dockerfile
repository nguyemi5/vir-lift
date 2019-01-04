FROM nvidia/cuda:9.2-runtime-ubuntu16.04
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-1+cuda9.2 && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-core=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

# setup entrypoint
# COPY ./ros_entrypoint.sh /

# ENTRYPOINT ["/ros_entrypoint.sh"]
# CMD ["bash"]

# install ros packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-desktop-full=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*
    
RUN apt-get update && apt-get install -y \
    libalglib-dev \
    gnuplot \
    python-pip \
    python-flufl.lock \
    python-opencv
    
RUN python -m pip install h5py
RUN python -m pip install scipy
RUN python -m pip install parse
RUN pip install git+https://github.com/Theano/Theano.git#egg=Theano
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

# configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV CONTAINER_USER lion
ENV CONTAINER_UID 1000
ENV INSTALLER Miniconda2-latest-Linux-x86_64.sh

# create conda directory for lion user
# RUN mkdir -p /opt/conda && \
# chown lion /opt/conda

# install conda with python 2.7
RUN cd /tmp && \
mkdir -p $CONDA_DIR && \
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
echo $(wget --quiet -O - https://repo.continuum.io/miniconda/ \
| grep -A3 $INSTALLER \
| tail -n1 \
| cut -d\> -f2 \
| cut -d\< -f1 ) $INSTALLER | md5sum -c - && \
/bin/bash $INSTALLER -f -b -p $CONDA_DIR && \
rm $INSTALLER

RUN conda install pygpu

