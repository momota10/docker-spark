FROM ubuntu:18.04

LABEL Momota Sasaki

# Tool
ENV DEBIAN_FRONTEND=noninteractive

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip nano wget && \
  rm -rf /var/lib/apt/lists/*

# Python
RUN \
  apt-get update && \
  apt-get install -y python python-dev python-pip python-virtualenv python-psycopg2 python-sqlalchemy&& \
  rm -rf /var/lib/apt/lists/*

# R
RUN \
  apt-get update && \
  apt-get install -y r-base

# Java
ARG JAVA_VERSION="8"

RUN \
  apt-get update && \
  apt-get install -y openjdk-${JAVA_VERSION}-jdk && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/openjdk-${JAVA_VERSION}-jdk

ENV JAVA_HOME /usr/lib/jvm/openjdk-${JAVA_VERSION}-jdk

# Spark
ARG SPARK_VERSION="v2.2.0"

RUN git clone --depth 1 --branch ${SPARK_VERSION} https://github.com/apache/spark.git
WORKDIR /spark

ENV R_HOME /usr/lib/R
RUN ./R/install-dev.sh

ENV MAVEN_OPTS "-Xmx2g -XX:ReservedCodeCacheSize=512m"
ARG MAJOR_HADOOP_VERSION="2.7"
RUN ./build/mvn clean dependency:resolve
RUN ./build/mvn -Pyarn -Psparkr -Pmesos -Phive -Phive-thriftserver -Phadoop-${MAJOR_HADOOP_VERSION} -Dhadoop.version=${MAJOR_HADOOP_VERSION}.0 -Dmaven.test.skip=true package

ENV SPARK_HOME /spark
EXPOSE 4040
CMD while true; do echo hello world; sleep 1; done
