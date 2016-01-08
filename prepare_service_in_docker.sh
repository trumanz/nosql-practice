#!/bin/sh

CASSANDRA_NODE_NUMBER=2

start_nodes(){
   local CASSANDRA_CLIENT_PORT=10000
   local COUNT=$CASSANDRA_NODE_NUMBER 
   while [ $COUNT  -gt 0 ]; do 
       local CONTAINER_NAME="cassandra$COUNT"
       echo "Start $CONTAINER_NAME"
       docker run --name=$CONTAINER_NAME   -h $CONTAINER_NAME  -t -d -i  -p "$CASSANDRA_CLIENT_PORT:9042"  trumanz/dsecassandra   /bin/bash
       CASSANDRA_CLIENT_PORT=$(($CASSANDRA_CLIENT_PORT + 1))
       COUNT=$((COUNT - 1))
   done
}




start_service() {

   IP1=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra1)
   echo "cassandra1 IP $IP1"
  
   local COUNT=$CASSANDRA_NODE_NUMBER 
   while [ $COUNT  -gt 0 ]; do 
       local CONTAINER_NAME="cassandra$COUNT"
       echo "start $CONTAINER_NAME cassandra service"
       docker exec  -d -t -i  $CONTAINER_NAME   sh -c "env SEED_IPS=${IP1} DATA_CENTER=dc_cassandra /run-cassandra.sh"
       COUNT=$((COUNT - 1))
   done
   
}

wait_service(){
   RETRY_MAX=10
   while [ $RETRY_MAX -gt 0 ]; do
        docker exec -ti   cassandra1  /opt/dse-4.8.2/bin/nodetool status 2>&1
        if [ $? -eq 0 ]; then
           echo "successful"
           break
        else 
           echo "retry"
           sleep 2
        fi
        RETRY_MAX=$((RETRY_MAX - 1))
   done
   docker exec -ti   cassandra1  /opt/dse-4.8.2/bin/nodetool  status 
}

start_nodes
start_service
wait_service
