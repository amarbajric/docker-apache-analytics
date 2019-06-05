[![](https://img.shields.io/badge/Apache%20Spark%20Standalone-DockerHub-blue.svg?style=plastic&logo=Apache)](https://hub.docker.com/r/amarbajric/spark-standalone/)
[![](https://img.shields.io/badge/Apache%20Spark%20K8s-DockerHub-blue.svg?style=plastic&logo=Apache)](https://hub.docker.com/r/amarbajric/spark-k8s/)
[![](https://img.shields.io/badge/Apache%20Zeppelin-DockerHub-blue.svg?style=plastic&logo=Apache)](https://hub.docker.com/r/amarbajric/zeppelin/)


# Apache Analytics Docker Images
This repository contains `Dockerfiles` for some Apache projects that are mostly used for analytics tasks.
Currently, this repository includes the following custom docker base images:
- Apache Spark
- Apacke Zeppelin

## Apache Spark Docker Image (Standalone)
Standalone Spark cluster mode requires a dedicated instance called **master** to coordinate the cluster workloads. Therefore the usage of an additional cluster manager such as Mesos, YARN or Kubernetes is not necessary. However Standalone cluster can be used with all of these cluster managers.

### Configuration
Standalone mode supports to container roles master and worker. Depending on which one you need to start you may pass either **master** or **worker** command to this container. Worker requires only one argument which is the spark host URL (`spark://host:7077`).

Fine-tune configuration maybe achieved by mounting `/spark/conf/spark-defaults.conf`, `/spark/conf/spark-env.sh` or by passing `SPARK_*` environment variables directly. See the links bellow for more details:

- [Spark Standalone](https://spark.apache.org/docs/latest/spark-standalone.html)
- [Spark configuration](https://spark.apache.org/docs/latest/configuration.html)

### Volumes
- `/spark/work` - directory to use for scratch space and job output logs; only on worker. Can be overridden via `-w path` CLI argument.
- `/tmp` - directory to use for "scratch" space in Spark, including map output files and RDDs that get stored on disk (`spark.local.dir` setting).

## Apache Spark Docker Image (K8s)
Since the release of Spark 2.3, Kubernetes (K8s) is natively supported as a cluster manager for Apache Spark. In order to use K8s as a cluster manager, an adapted Docker Image is necessary which is deployed by K8s as soon as an application is submitted. The `Dockerfile`, and Docker Image resulting out of this file, are following the guidelines outlined in the official `Dockerfile` that is provided by Apache Spark especially for the use with K8s. Therefore, the `Dockerfile` in `spark-k8s/` contains some parts that are taken from [here](https://github.com/apache/spark/blob/master/resource-managers/kubernetes/docker/src/main/dockerfiles/spark/Dockerfile). In the end, this Docker Image is able to minimize its size, allowing for more efficient dynamic sheduling by K8s.

### Usage
Please refer to the official Apache Spark [documentation](https://spark.apache.org/docs/latest/running-on-kubernetes.html) for more information about how to use this Docker Image in combination with K8s.

## Apache Zeppelin
A Web-based notebook that enables data-driven, interactive data analytics and collaborative documents with SQL, Scala and more.
While the `Dockerfile` in `zeppelin/` is based on the [original zeppelin image](https://hub.docker.com/r/apache/zeppelin), this custom Docker Image includes the Apache Spark binaries as this is required for running/connecting
Apache Zeppelin with an external cluster. Apache Zeppelin needs, besides the url to the Spark master node, also the Spark binaries for sending `spark-submit` applications to the external Spark cluster. This requires Zeppelin
to access Spark binaries located under `SPARK_HOME`. While the original Zeppelin Docker Image does not include the Spark binaries, this custom version includes them.

### Configuration
Please consult the documentation from Zeppelin that can be found [here](https://zeppelin.apache.org/).
