#!/bin/sh
#docker run --name cassandra01  -h  cassandra01   -d    -p   9042:9042   cassandra

#https://hub.docker.com/_/cassandra/

create_cassandra_node(){
   echo "create nodename $1, port map $2"
   #echo casscanra use below 
   #http://docs.datastax.com/en/cassandra/2.0/cassandra/security/secureFireWall_r.html
   docker run --name=$1  --hostname=$1   -t -i  -d  -p $2  trumanz/cassandra  /bin/bash
#docker run --name cassandra01  -h  cassandra01   -d    -p   9042:9042   cassandra
#docker run --name cassandra02  -h  cassandra02   -d -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cassandra01)" cassandra
   
}

SEED_NODES="node0 node1"
REST_NODES="node3 node4 node5"
# seed node first, then rest nodes, 
ALL_NODES="$SEED_NODES $REST_NODES"

create_cluster(){
  local CLIENT_PORT=10000
  for node in $ALL_NODES; do 
     create_cassandra_node  "$node" "$CLIENT_PORT:9042"
     CLIENT_PORT=$(($CLIENT_PORT + 1))
  done 
}



config(){
   IP0=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  node0)
   IP3=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  node3)
   SEED_IPS=""
   for node in $SEED_NODES; do 
       IP=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  $node)
       SEED_IPS=${SEED_IPS}${IP},
   done
   for  node in $ALL_NODES; do 
      echo "configure $node"
      docker exec -t -i  $node  cp  /etc/cassandra/cassandra.yaml  /etc/cassandra/cassandra.yaml.orig
      docker exec -t -i  $node  sed -i  "s/- seeds: \"127.0.0.1\"/- seeds: \"$SEED_IPS\"/g" /etc/cassandra/cassandra.yaml
      docker exec -t -i  $node  sed -i  "s/listen_address: localhost/listen_address:/g" /etc/cassandra/cassandra.yaml
      docker exec -t -i  $node  sed -i  "s/rpc_address: localhost/rpc_address: 0.0.0.0/g" /etc/cassandra/cassandra.yaml
      docker exec -t -i  $node  sed -i  "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: GossipingPropertyFileSnitch/g" /etc/cassandra/cassandra.yaml
   done
}

start_all_service(){
   for node in $ALL_NODES; do 
      echo "start service on $node"
      docker exec -t -i   $node service cassandra start
   done 
}


create_cluster
config
start_all_service

echo "docker exec -t -i  node0  nodetool status"
