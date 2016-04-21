#!/bin/sh





#docker exec -ti   cassandra1  /opt/dse-4.8.2/bin/nodetool  status


#python  -V


docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra0
docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra1
docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra2

export CASSANDRA_ADDRESS=$(docker inspect --format='{{ .NetworkSettings.IPAddress }}'  cassandra1)



python -m unittest discover -v  -s  ./src  -p test*.py

