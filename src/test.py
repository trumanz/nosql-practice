#!/usr/bin/env python
import os
from cassandra.cluster import Cluster


CADDR = os.environ['CASSANDRA_ADDRESS']
cluster = Cluster([CADDR])
session = cluster.connect()

session.execute("CREATE KEYSPACE IF NOT EXISTS Excelsior  WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 }")
#print session.execute("DESCRIBE KEYSPACES")
