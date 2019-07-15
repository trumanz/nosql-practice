#!/bin/sh

CASSANDRA_NODE_NUMBER=3

IMAGE="trumanz/dsecassandra"

start_nodes(){
   local CASSANDRA_CLIENT_PORT=10000
   local COUNT=0
   while [ $COUNT  -lt $CASSANDRA_NODE_NUMBER ]; do 
       local CONTAINER_NAME="cassandra$COUNT"
       echo "Start $CONTAINER_NAME"
       docker rm  -f  $CONTAINER_NAME  
       docker run --name=$CONTAINER_NAME   -h $CONTAINER_NAME  -t -d -i  -p "$CASSANDRA_CLIENT_PORT:9042"  $IMAGE   /bin/bash
       CASSANDRA_CLIENT_PORT=$(($CASSANDRA_CLIENT_PORT + 1))
       COUNT=$((COUNT + 1))
   done
}




start_service() {

   IP0=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra0)
   echo "cassandra0 IP $IP0"
  
   local COUNT=0
   while [ $COUNT  -lt $CASSANDRA_NODE_NUMBER ]; do 
       local CONTAINER_NAME="cassandra$COUNT"
       echo "start $CONTAINER_NAME cassandra service"
       docker exec  -d -t -i  $CONTAINER_NAME   sh -c "env SEED_IPS=${IP0} DATA_CENTER=dc_cassandra /config-cassandra.sh"
       docker exec  -d -t -i  $CONTAINER_NAME   sh -c "/opt/dse-4.8.2/bin/dse  cassandra  -f  -c  > /cassandra.log 2>&1"
       COUNT=$((COUNT + 1))
       sleep 60
   done
   
}

wait_service(){
   RETRY_MAX=10
   while [ $RETRY_MAX -gt 0 ]; do
        docker exec -ti   cassandra0  /opt/dse-4.8.2/bin/nodetool status 2>&1
        if [ $? -eq 0 ]; then
           echo "successful"
           break
        else 
           echo "retry"
           sleep 2
        fi
        RETRY_MAX=$((RETRY_MAX - 1))
   done
   docker exec -ti   cassandra0  /opt/dse-4.8.2/bin/nodetool  status 
}

start_nodes
start_service
wait_service
