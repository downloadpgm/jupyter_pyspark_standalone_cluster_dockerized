FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Central

RUN apt-get update && apt-get install -y supervisor openssh-server openssh-client vim iputils-ping jupyter

WORKDIR /usr/local

# git clone https://github.com/mkenjis/apache_binaries
ADD jre-8u181-linux-x64.tar.gz .
# wget https://archive.apache.org/dist/spark/spark-3.0.3/spark-3.0.3-bin-hadoop2.7.tgz
ADD spark-3.0.3-bin-hadoop2.7.tgz .

WORKDIR /root
RUN echo "" >>.bashrc \
 && echo 'export JAVA_HOME=/usr/local/jre1.8.0_181' >>.bashrc \
 && echo 'export CLASSPATH=$JAVA_HOME/lib' >>.bashrc \
 && echo 'export PATH=$PATH:.:$JAVA_HOME/bin' >>.bashrc \
 && echo "" >>.bashrc \
 && echo 'export SPARK_HOME=/usr/local/spark-3.0.3-bin-hadoop2.7' >>.bashrc \
 && echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native' >>.bashrc \
 && echo 'export HADOOP_CONF_DIR=$SPARK_HOME/conf' >>.bashrc \
 && echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >>.bashrc \
 && echo 'export PYSPARK_PYTHON=/usr/bin/python3.8' >>.bashrc \
 && echo 'export PYSPARK_DRIVER_PYTHON=/usr/bin/jupyter' >>.bashrc

RUN /usr/bin/bash -c "ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null" \
 && cp .ssh/id_rsa.pub .ssh/authorized_keys

COPY create_conf_files.sh .
RUN chmod +x create_conf_files.sh

COPY run_spark.sh .
RUN chmod +x run_spark.sh

COPY stop_spark.sh .
RUN chmod +x stop_spark.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
 
EXPOSE 10000 7077 4040 8080 8081 8082 8888

CMD ["/usr/bin/supervisord"]