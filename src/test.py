#!/usr/bin/env python
from cassandra.cluster import Cluster



cluster = Cluster()
session = cluster.connect('demo')
