#!/bin/sh





#docker exec -ti   cassandra1  /opt/dse-4.8.2/bin/nodetool  status


#python  -V


export CASSANDRA_ADDRESS=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra1)



python -m unittest discover  -s  ./src

