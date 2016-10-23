FROM jupyter/datascience-notebook
MAINTAINER Behzad Samadi <behzad@mechatronics3d.com>

# CasADi version
ENV CASADIVERSION=3.1.0-rc1

# Folders
ENV DL=$HOME/Downloads
ENV WS=$HOME/work
ENV ST=$HOME/.ipython/default_profile/startup

# Packages
ENV PKGS="wget unzip gcc g++ gfortran git cmake liblapack-dev pkg-config swig spyder time"
ENV Py2_PKGS="python-pip python-numpy python-scipy python-matplotlib"
ENV JM_PKGS="cython jcc subversion ant openjdk-7-jdk python-dev python-svn python-lxml python-nose zlib1g-dev libboost-dev dpkg-dev build-essential libwebkitgtk-dev libjpeg-dev libtiff-dev libgtk2.0-dev libsdl1.2-dev libgstreamer-plugins-base0.10-dev libnotify-dev freeglut3 freeglut3-dev"
ENV PIP2="jupyter vpython CVXcanon cvxpy"

USER root

# Install required packages
RUN apt-get update && \
    apt-get install -y --install-recommends $PKGS && \
    apt-get install -y --install-recommends $Py2_PKGS && \
    apt-get install -y --install-recommends $JM_PKGS

RUN pip install --upgrade pip
RUN pip install $PIP2

# Install Ipopt
RUN mkdir $DL
RUN wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.6.tgz -O $DL/Ipopt-3.12.6.tgz
RUN cd $DL && \
    tar -xvf Ipopt-3.12.6.tgz
RUN cd $DL/Ipopt-3.12.6/ThirdParty/ASL && ./get.ASL
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Blas && ./get.Blas
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Lapack && ./get.Lapack
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Mumps && ./get.Mumps
RUN cd $DL/Ipopt-3.12.6/ThirdParty/Metis && ./get.Metis
RUN mkdir $DL/Ipopt-3.12.6/build
RUN cd $DL/Ipopt-3.12.6/build && \
    ../configure --prefix=$WS/Ipopt-3.12.6
RUN cd $DL/Ipopt-3.12.6/build && make install

# Install JPype
RUN cd $DL && \
    git clone https://github.com/originell/jpype.git && \
    cd jpype && python setup.py install

# Define environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
ENV IPOPT_HOME=$WS/Ipopt-3.12.6
ENV SEPARATE_PROCESS_JVM=/usr/lib/jvm/java-7-openjdk-amd64/

# Create cvxpy and cvxflow folders
RUN cd $WS && mkdir cvxpy && mkdir cvxflow

# Clone cvxpy
RUN git clone https://github.com/cvxgrp/cvx_short_course.git $WS/cvxpy

# Clone cvxflow
RUN git clone https://github.com/mwytock/cvxflow.git $WS/cvxflow

# Install CasADi for Python 2.7
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/linux/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz/download \
    -O $DL/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz && \
    mkdir $WS/casadi-py27-np1.9.1-v$CASADIVERSION && \
    tar -zxvf $DL/casadi-py27-np1.9.1-v$CASADIVERSION.tar.gz \
    -C $WS/casadi-py27-np1.9.1-v$CASADIVERSION

# Install CasADi for Python 3.5
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/linux/casadi-py35-np1.9.1-v$CASADIVERSION.tar.gz/download \
    -O $DL/casadi-py35-np1.9.1-v$CASADIVERSION.tar.gz && \
    mkdir $WS/casadi-py35-np1.9.1-v$CASADIVERSION && \
    tar -zxvf $DL/casadi-py35-np1.9.1-v$CASADIVERSION.tar.gz \
    -C $WS/casadi-py35-np1.9.1-v$CASADIVERSION
    
# Defining CasADi path for each version
ENV CASADIPATH2=$WS/casadi-py27-np1.9.1-v$CASADIVERSION
ENV CASADIPATH3=$WS/casadi-py35-np1.9.1-v$CASADIVERSION

# Install CasADi examples
RUN wget http://sourceforge.net/projects/casadi/files/CasADi/$CASADIVERSION/casadi-example_pack-v$CASADIVERSION.zip \
    -O $DL/casadi-example_pack-v$CASADIVERSION.zip && \
    mkdir $WS/casadi_examples && \
    unzip $DL/casadi-example_pack-v$CASADIVERSION.zip \
    -d $WS/casadi_examples
    
# Giving the ownership of the folders to the NB_USER
RUN chown -R $NB_USER $DL
RUN chown -R $NB_USER $WS

# Notebook startup script
COPY nb_startup.py $ST
COPY nb_startup.py $WS

USER $NB_USER
