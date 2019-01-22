FROM ubuntu:16.04

ENV CONDA_HOME /opt/conda
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME /opt/spark
ENV HADOOP_HOME /opt/hadoop

ENV HADOOP_VERSION 2.8.5
ENV SPARK_VERSION 2.4.0
ENV SCALA_VERSION 2.11.8

ENV SPARK_BUILD spark-${SPARK_VERSION}-bin-without-hadoop
ENV HADOOP_BUILD hadoop-${HADOOP_VERSION}

ENV PATH $HADOOP_HOME/bin:$SPARK_HOME/bin:$CONDA_HOME/bin:$PATH
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV SPARK_DIST_CLASSPATH "/opt/spark/jars/*:/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/contrib/capacity-scheduler/*.jar"

WORKDIR /root

RUN apt-get update && apt-get install -y --no-install-recommends locales bzip2 openjdk-8-jdk-headless ssh && apt-get clean
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

COPY Miniconda3-4.5.11-Linux-x86_64.sh /tmp/miniconda.sh
COPY ./environment.yml /tmp/environment.yml
RUN sh /tmp/miniconda.sh -b -p $CONDA_HOME && rm /tmp/miniconda.sh
RUN conda install --file /tmp/environment.yml && conda clean -a

# Spark need ssh between hosts
RUN ssh-keygen -q -f ~/.ssh/docker -N "" &&  cp ~/.ssh/docker.pub ~/.ssh/authorized_keys

# Install Spark 
COPY ${SPARK_BUILD}.tgz /tmp/spark.tgz
RUN tar -C /opt -xf /tmp/spark.tgz && \
    ln -s /opt/$SPARK_BUILD $SPARK_HOME && \
    rm /tmp/spark.tgz

# Install Hadoop 
COPY ${HADOOP_BUILD}.tar.gz /tmp/hadoop.tar.gz
RUN tar -C /opt -xf /tmp/hadoop.tar.gz && \
    ln -s /opt/$HADOOP_BUILD $HADOOP_HOME && \
    rm /tmp/hadoop.tar.gz

# Default redirect s3a endpoint to docker minio
# Redirect hdfs to master host
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY spark-defaults.conf  $SPARK_HOME/conf/spark-defaults.conf

CMD tail -f /dev/null 
