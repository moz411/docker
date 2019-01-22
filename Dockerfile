FROM ubuntu:16.04

ENV CONDA_HOME /opt/conda
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV KAFKA_HOME /opt/kafka
ENV STORM_HOME /opt/storm
ENV ZOOKEEPER_HOME /opt/zookeeper

ENV KAFKA_VERSION 2.12-2.1.0
ENV STORM_VERSION 1.2.2
ENV ZOOKEEPER_VERSION 3.4.12

ENV KAFKA_BUILD kafka_${KAFKA_VERSION}
ENV STORM_BUILD apache-storm-${STORM_VERSION}
ENV ZOOKEEPER_BUILD zookeeper-${ZOOKEEPER_VERSION}

ENV PATH $KAFKA_HOME/bin:$STORM_HOME/bin:$ZOOKEEPER_HOME/bin:$CONDA_HOME/bin:$PATH
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8 
ENV LANGUAGE en_US.UTF-8

WORKDIR /root

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get install -y --no-install-recommends locales bzip2 openjdk-8-jdk-headless ssh && \
	apt-get clean
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

COPY Miniconda3-latest-Linux-x86_64.sh /tmp/miniconda.sh
COPY ./environment.yml /tmp/environment.yml
RUN sh /tmp/miniconda.sh -b -p $CONDA_HOME && rm /tmp/miniconda.sh
RUN conda install --file /tmp/environment.yml && conda clean -a

# Ssh between hosts
RUN ssh-keygen -q -f ~/.ssh/docker -N "" && cp ~/.ssh/docker.pub ~/.ssh/authorized_keys

# Install Kafka 
COPY ${KAFKA_BUILD}.tgz /tmp/kafka.tgz
RUN tar -C /opt -xf /tmp/kafka.tar.gz && \
    ln -s /opt/$KAFKA_BUILD $KAFKA_HOME && \
    rm /tmp/kafka.tgz
    
# Install Storm 
COPY ${STORM_BUILD}.tar.gz /tmp/storm.tgz
RUN tar -C /opt -xf /tmp/storm.tgz && \
    ln -s /opt/$STORM_BUILD $STORM_HOME && \
    rm /tmp/storm.tgz

# Install Zookeeper 
COPY ${ZOOKEEPER_BUILD}.tar.gz /tmp/zoo.tgz
RUN tar -C /opt -xf /tmp/zoo.tgz && \
    ln -s /opt/$ZOOKEEPER_BUILD $ZOOKEEPER_HOME && \
    rm /tmp/zoo.tgz

# Default redirect s3a endpoint to docker minio
# Redirect hdfs to master host
COPY core-site.xml $KAFKA_HOME/etc/hadoop/core-site.xml
COPY spark-defaults.conf  $STORM_HOME/conf/spark-defaults.conf

CMD tail -f /dev/null 
