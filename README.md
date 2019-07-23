[![Custom Spark Docker Image](https://img.shields.io/badge/Docker%20Hub-%E2%86%92-blue.svg)](https://hub.docker.com/r/amarbajric/spark-standalone/)
[![Custom Zeppelin Docker Image](https://img.shields.io/badge/Docker%20Hub-%E2%86%92-blue.svg)](https://hub.docker.com/r/amarbajric/spark-standalone/)


# Apache Analytics Docker Images
This repository contains `Dockerfiles` for some Apache projects that are mostly used for analytics tasks.
Currently, this repository includes the following custom docker base images:
- Apache Spark (Standalone mode & Kubernetes mode)
- Apache Flink (Job Cluster Example)
- Apacke Zeppelin

## Apache Spark Docker Image (Standalone mode)
Standalone Spark cluster mode requires a dedicated instance called **master** to coordinate the cluster workloads. Therefore the usage of an additional cluster manager such as Mesos, YARN or Kubernetes is not necessary. However Standalone cluster can be used with all of these cluster managers. Additionally Standalone cluster mode is the most flexible to deliver Spark workloads for Kubernetes, since as of Spark **version 2.4.0** the native Spark Kubernetes support is still very limited.

### Configuration

Standalone mode supports to container roles master and worker. Depending on which one you need to start you may pass either **master** or **worker** command to this container. Worker requires only one argument which is the spark host URL (`spark://host:7077`).

Fine-tune configuration maybe achieved by mounting `/spark/conf/spark-defaults.conf`, `/spark/conf/spark-env.sh` or by passing `SPARK_*` environment variables directly. See the links bellow for more details:

- [Spark Standalone](https://spark.apache.org/docs/latest/spark-standalone.html)
- [Spark configuration](https://spark.apache.org/docs/latest/configuration.html)

### Volumes

- `/spark/work` - directory to use for scratch space and job output logs; only on worker. Can be overridden via `-w path` CLI argument.
- `/tmp` - directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk (`spark.local.dir` setting).


## Apache Flink
The Flink Dockerfile is based upon the official docker image and only adds a custom JAR file. The purpose of this image is to test the deployment and functionality of a Flink job cluster in a dockerized environment.
The included `wordcount.jar` has one Object called `WordCount` that is under the classname `at.fhj.flinkexample`. So, the `main()` function resides can be found under the classname `at.fhj.flinkexample.WordCount`. The Flink job counts the occurence of words of a String and outputs the results to `/opt/results/`.

## Apache Zeppelin
A Web-based notebook that enables data-driven, interactive data analytics and collaborative documents with SQL, Scala and more.
While the `Dockerfile` in `zeppelin/` is based on the [original zeppelin image](https://hub.docker.com/r/apache/zeppelin), this custom Docker Image includes the Apache Spark binaries as this is required for running/connecting
Apache Zeppelin with an external cluster. Apache Zeppelin needs, besides the url to the Spark master node, also the Spark binaries for sending `spark-submit` applications to the external Spark cluster. This requires Zeppelin
to access Spark binaries located under `SPARK_HOME`. While the original Zeppelin Docker Image does not include the Spark binaries, this custom version includes them.

### Configuration
Please consult the documentation from Zeppelin that can be found [here](https://zeppelin.apache.org/).