
# spark-env.sh (SPARK)
# ============
echo 'export JAVA_HOME=/usr/local/jre1.8.0_181' >$SPARK_HOME/conf/spark-env.sh
echo 'export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=FILESYSTEM -Dspark.deploy.recoveryDirectory=/root/recover"' >>$SPARK_HOME/conf/spark-env.sh
chmod +x $SPARK_HOME/conf/spark-env.sh