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

# ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
# ENV PATH /opt/conda/bin:$PATH

# RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
# libglib2.0-0 libxext6 libsm6 libxrender1 \
# git mercurial subversion

# RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh -O ~/anaconda.sh && \
# /bin/bash ~/anaconda.sh -b -p /opt/conda && \
# rm ~/anaconda.sh && \
# ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
# echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
# echo "conda activate base" >> ~/.bashrc

# RUN apt-get install -y curl grep sed dpkg && \
# TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
# curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
# dpkg -i tini.deb && \
# rm tini.deb && \
# apt-get clean

# RUN conda install -y -c mila-udem pygpu

# RUN conda install -y pygpu=0.7
# RUN git clone https://github.com/Theano/libgpuarray.git
# RUN cd libgpuarray

# RUN mkdir Build
# RUN cd Build
# you can pass -DCMAKE_INSTALL_PREFIX=/path/to/somewhere to install to an alternate location
# RUN cmake .. -DCMAKE_BUILD_TYPE=Release # or Debug if you are investigating a crash
# RUN make
# RUN make install
# RUN cd ..

# This must be done after libgpuarray is installed as per instructions above.
# RUN python setup.py build
# RUN python setup.py install

RUN apt-get -y install check
RUN python -m pip install Cython
RUN python -m pip install Mako
RUN python -m pip install nose

RUN git clone https://github.com/Theano/libgpuarray.git ~/libgpuarray

RUN mkdir ~/libgpuarray/Build && cd ~/libgpuarray/Build && cmake .. -DCMAKE_BUILD_TYPE=Release && make && make install

RUN cd ~/libgpuarray && python2 setup.py build && python2 setup.py install && ldconfig

