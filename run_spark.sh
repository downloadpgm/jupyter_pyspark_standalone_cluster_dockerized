trap "{ echo Stopping play app >/tmp/msg.txt; /usr/bin/bash -c \"/root/stop_spark.sh\"; exit 0; }" SIGTERM

export JAVA_HOME=/usr/local/jre1.8.0_181
export CLASSPATH=$JAVA_HOME/lib
export PATH=$PATH:.:$JAVA_HOME/bin

export SPARK_HOME=/usr/local/spark-3.0.3-bin-hadoop2.7
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

create_conf_files.sh

service ssh start

echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
ssh-keyscan ${HOSTNAME} >~/.ssh/known_hosts
ssh-keyscan localhost >>~/.ssh/known_hosts
ssh-keyscan 0.0.0.0 >>~/.ssh/known_hosts

if [ -n "${SPARK_HOST_SLAVES}" ]; then

   sleep 30
      
   >${SPARK_HOME}/conf/slaves
   
   for SPARK_HOST in `echo ${SPARK_HOST_SLAVES} | tr ',' ' '`; do
      ssh-keyscan ${SPARK_HOST} >~/.ssh/known_hosts
	  ssh root@${SPARK_HOST} "cat /etc/hostname" >>${SPARK_HOME}/conf/slaves
   done
   
   # start Spark master and slaves nodes
   $SPARK_HOME/sbin/start-master.sh
   $SPARK_HOME/sbin/start-slaves.sh
fi

while [ 1 -eq 1 ]; do
   sleep 10
done
