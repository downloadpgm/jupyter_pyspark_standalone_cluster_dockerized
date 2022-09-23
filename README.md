# Jupyter client running into Standalone cluster in Docker

Apache Spark is an open-source, distributed processing system used for big data workloads.

In this demo, a Spark container uses a Spark Standalone cluster as a resource management and job scheduling technology to perform distributed data processing.

This Docker image contains Spark binaries prebuilt and uploaded in Docker Hub.

## Build Jupyter Spark image
```shell
$ git clone https://github.com/mkenjis/apache_binaries
$ wget https://archive.apache.org/dist/spark/spark-3.0.3/spark-3.0.3-bin-hadoop2.7.tgz
$ docker image build -t mkenjis/ubpyspk_img
$ docker login   # provide user and password
$ docker image push mkenjis/ubpyspk_img
```

## Shell Scripts Inside 

> run_spark.sh

Sets up the environment for Spark client by executing the following steps :
- sets environment variables for JAVA and SPARK
- starts the SSH service for passwordless SSH files on start-up

> create_conf_files.sh

Creates the following Hadoop files on $SPARK_HOME/conf directory :
- spark-env.sh

## Start Swarm cluster

1. start swarm mode in node1
```shell
$ docker swarm init --advertise-addr <IP node1>
$ docker swarm join-token manager  # issue a token to add a node as manager to swarm
```

2. add more managers in swarm cluster (node2, node3, ...)
```shell
$ docker swarm join --token <token> <IP nodeN>:2377
```

3. start a spark standalone cluster and spark client
```shell
$ docker stack deploy -c docker-compose.yml spark
$ docker service ls
ID             NAME             MODE         REPLICAS   IMAGE                             PORTS
t3s7ud9u21hr   spark_spk_mst    replicated   1/1        mkenjis/ubpyspk_img:latest   
mi3w7xvf9vyt   spark_spk_wkr1   replicated   1/1        mkenjis/ubpyspk_img:latest   
xlg5ww9q0v6j   spark_spk_wkr2   replicated   1/1        mkenjis/ubpyspk_img:latest   
ni5xrb60u71i   spark_spk_wkr3   replicated   1/1        mkenjis/ubpyspk_img:latest
```

4. access spark master node
```shell
$ docker container ls   # run it in each node and check which <container ID> is running the Spark master constainer
CONTAINER ID   IMAGE                         COMMAND                  CREATED              STATUS              PORTS      NAMES
71717fcd5a01   mkenjis/ubpyspk_img:latest   "/usr/bin/supervisord"   14 minutes ago   Up 14 minutes   4040/tcp, 7077/tcp, 8080-8082/tcp, 10000/tcp   spark_spk_wkr2.1.bf8tsqv5lyfa4h5i8utwvtpch
464730a41833   mkenjis/ubpyspk_img:latest   "/usr/bin/supervisord"   14 minutes ago   Up 14 minutes   4040/tcp, 7077/tcp, 8080-8082/tcp, 10000/tcp   spark_spk_mst.1.n01a49esutmbgv5uum3tdsm6p

$ docker container exec -it <spk_mst ID> bash
```

5. run jupyter notebook --generate-config
```shell
$ jupyter notebook --generate-config
```

6. edit /root/.jupyter/jupyter_notebook_config.py
```shell
$ vi /root/.jupyter/jupyter_notebook_config.py
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8082
```

7. setup a jupyter password
```shell
$ jupyter notebook password
Enter password:  *********
Verify password: *********
```

8. run pyspark
```shell
PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --allow-root --port=8082" pyspark --master spark://<hostname>:7077
```

In the browser, issue the address https://host:8082 to access the Jupyter Notebook.

Provide the credentials previously created

![JUPYTER home](docs/jupyter-login.png)

Click on New button to start a new notebook. Choose Python3 as interpreter

![JUPYTER home](docs/jupyter-python-notebook.png)

Issue Spark commands

![JUPYTER home](docs/jupyter-python-spark.png)
![JUPYTER home](docs/jupyter-python-spark_1.png)