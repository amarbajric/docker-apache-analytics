FROM openjdk:8-alpine3.8
## Spark standalone mode Dockerfile

ARG version
ARG release
LABEL com.fhjoanneum.spark.vendor=fhjoanneum \
      com.fhjoanneum.spark.version=$version \
      com.fhjoanneum.spark.release=$release

ENV SPARK_HOME=/spark \
    SPARK_PGP_KEYS="DB0B21A012973FD0 7C6C105FFC8ED089 FD8FFD4C3A0D5564"

RUN adduser -Ds /bin/bash -h ${SPARK_HOME} spark && \
    apk add --no-cache bash tini libc6-compat linux-pam krb5 krb5-libs && \
# download dist
    apk add --virtual .deps --no-cache curl tar gnupg && \
    cd /tmp && export GNUPGHOME=/tmp && \
    file=spark-${version}-bin-hadoop2.7.tgz && \
    curl --remote-name-all -w "%{url_effective} fetched\n" -sSL \
        https://archive.apache.org/dist/spark/spark-${version}/{${file},${file}.asc} && \
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys ${SPARK_PGP_KEYS} && \
    gpg --batch --verify ${file}.asc ${file} && \
# create spark directories
    mkdir -p ${SPARK_HOME}/work ${SPARK_HOME}/conf && chown spark:spark ${SPARK_HOME}/work && \
    tar -xzf ${file} --no-same-owner --strip-components 1 && \
    mv bin data examples jars sbin ${SPARK_HOME} && \
# cleanup
    apk --no-cache del .deps && ls -A | xargs rm -rf

COPY entrypoint.sh /
COPY spark-env.sh ${SPARK_HOME}/conf/

WORKDIR ${SPARK_HOME}/work
ENTRYPOINT [ "/entrypoint.sh" ]

# Specify the User that the actual main process will run as
USER spark:spark





FROM debian:stretch

RUN apt-get update \
 && apt-get install -y curl unzip \
    python3 python3-setuptools \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && easy_install3 pip py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
RUN apt-get update \
 && apt-get install -y openjdk-8-jre \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# HADOOP
# Is needed for SPARK_DIST_CLASSPATH as Spark is using some Hadoop jars for its functionality
ENV HADOOP_VERSION 3.0.0
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 2.4.1
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

WORKDIR $SPARK_HOME

ENV SPARK_INSTANCE_TYPE
CMD ["bin/spark-class", "org.apache.spark.deploy.${SPARK_INSTANCE_TYPE}.${SPARK_INSTANCE_TYPE^}", "${SPARK_MASTER_NODE}"]