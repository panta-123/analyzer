FROM centos:centos7

COPY packages_root packages


RUN yum update -q -y
RUN yum group list
ARG DOCKER_TAG
#ENV APP="${DOCKER_TAG//.}"
ENV APP_VERSION=$APP
RUN echo $APP_VERSION

RUN yum -y install epel-release && \
    yum -y install scons && \
    yum -y install git && \
    yum -y install gcc-c++ && \
    yum install -y $(cat packages) \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && rm -f /packages 

ADD https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2-linux-x86_64.tar.gz .
RUN tar -xvf cmake-3.22.2-linux-x86_64.tar.gz
RUN ls -l
RUN mv cmake-3.22.2-linux-x86_64 /usr/local/cmake
RUN ls -l /usr/local/cmake/bin
RUN export PATH="/usr/local/cmake/bin:$PATH"
RUN cmake3 --version
RUN which root-config
ADD https://github.com/JeffersonLab/analyzer/archive/refs/tags/Release-${APP_VERSION}.tar.gz .
RUN tar -xvf Release-${APP_VERSION}.tar.gz
WORKDIR "/analyzer-Release-${APP_VERSION}"
RUN mkdir build
WORKDIR "/analyzer-Release-${APP_VERSION}/build"
RUN cmake3 -DCMAKE_INSTALL_PREFIX=$HOME/local/analyzer ..
RUN make  install -j
ENV PATH="~/local/analyzer/bin:$PATH"
ENV LD_LIBRARY_PATH="~/local/analyzer/lib:$LD_LIBRARY_PATH"

#RUN mkdir -p ~/JLab/Software/Podd/1.7.0
#RUN cmake3 -B build -S . -DCMAKE_INSTALL_PREFIX=~/JLab/Software/Podd/1.7.0
##RUN cmake3 --build build -j
#RUN cmake3 --install build

#RUN export ANALYZER=~/JLab/Software/Podd/1.7.0
#RUN export PATH=$ANALYZER/bin:$PATH
#RUN export LD_LIBRARY_PATH=$ANALYZER/lib64:$LD_LIBRARY_PATH
#RUN echo $PATH
#RUN ANALYZER -h
