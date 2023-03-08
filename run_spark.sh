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

if [ -n "${SPARK_HOST_SLAVES}" ]; then

   # monitor if all spark slaves are available
   # if so, proceed with spark slaves setup
   hosts_OK=0
   while [ ${hosts_OK} -eq 0 ]; do

      result=0
      for SPARK_HOST in `echo ${SPARK_HOST_SLAVES} | tr ',' ' '`; do
         ssh -q root@${SPARK_HOST} "echo 2>1" >/dev/null
         result=$(echo $?)
         # echo ${result}
         if [ ${result} -ne 0 ]; then
            echo ${SPARK_HOST} 'not available'
            sleep 2
            break
         fi
      done

      if [ ${result} -eq 0 ]; then
         hosts_OK=1
      else
         hosts_OK=0
      fi

   done
   # sleep 20
   
   >${SPARK_HOME}/conf/slaves

   for SPARK_HOST in `echo ${SPARK_HOST_SLAVES} | tr ',' ' '`; do
      ssh-keyscan ${SPARK_HOST} >>~/.ssh/known_hosts
          ssh root@${SPARK_HOST} "cat /etc/hostname" >>${SPARK_HOME}/conf/slaves
   done

   # start Spark master and slaves nodes
   $SPARK_HOME/sbin/start-master.sh
   $SPARK_HOME/sbin/start-slaves.sh
fi
