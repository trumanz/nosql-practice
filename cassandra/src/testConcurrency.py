#!/usr/bin/env python
import os
import time
import unittest
from cassandra.cluster import Cluster
import cassandra

class TestConcurrency(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
          cls._cluster  = Cluster([os.environ['CASSANDRA_ADDRESS']])
          cls._session = cls._cluster.connect()
          cls._session.execute("DROP KEYSPACE IF EXISTS testSpace")
          cls._session.execute("DROP KEYSPACE IF EXISTS testSpace")
          cls._session.execute("CREATE KEYSPACE testSpace WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 2}")
          cls._session.execute("USE testSpace")
    @classmethod
    def tearDownClass(cls):
          #close all sessions and connection assocaiated with this Cluster
          cls._cluster.shutdown();
 

    def test_set(self):
          session = TestConcurrency._session
          cql = "CREATE TABLE kv (key text PRIMARY KEY, value text)"
          session.execute(cql)
          for i in range(1,1*1024):
              value = 'a'*1024
              print i
              cql = "INSERT INTO kv (key, value) VALUES('key" + str(i) + "', '"+ value + "')"
              #print cql
              session.execute(cql)
         
