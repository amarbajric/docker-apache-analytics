FROM apache/zeppelin:0.8.1
MAINTAINER Amar Bajric <amar.bajric78@gmail.com>

# Spark
# Include Spark in the Zeppelin base image (needed to run Zeppelin with an external cluster that are containerized)
ENV SPARK_VERSION 2.4.3
ENV HADOOP_VERSION 2.7
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_HOME /usr/spark
ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME


ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["bin/zeppelin.sh"]
