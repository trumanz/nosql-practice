#!/bin/sh
sudo apt-get update  \
&& sudo apt-get install -y python-dev \
&& sudo pip install cassandra-driver
