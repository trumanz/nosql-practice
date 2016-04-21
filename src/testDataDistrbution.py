#!/usr/bin/env python
import os
import time
import unittest
from cassandra.cluster import Cluster
import cassandra

#http://docs.datastax.com/en/cassandra/2.0/cassandra/dml/dml_config_consistency_c.html


class TestConcurrency(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
          cls._cluster  = Cluster([os.environ['CASSANDRA_ADDRESS']])
          cls._session = cls._cluster.connect()
          cls._session.default_consistency_level = cassandra.ConsistencyLevel.QUORUM
          cls._session.execute("DROP KEYSPACE IF EXISTS testSpace")
          cls._session.execute("DROP KEYSPACE IF EXISTS testSpace")
          cls._session.execute("CREATE KEYSPACE testSpace WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 3}")
          cls._session.execute("USE testSpace")
    @classmethod
    def tearDownClass(cls):
          #close all sessions and connection assocaiated with this Cluster
          cls._cluster.shutdown();

    @classmethod
    def  get_replicas(cls, token):
        return  cls._cluster.metadata.get_replicas("testspace", str(token));

    def test_one(self):
          session = TestConcurrency._session
          cql = "CREATE TABLE kv (key text PRIMARY KEY, value text)"
          session.execute(cql)
          for i in range(0,1):
              value = 'a'*1024
              key='key' + str(i)
              cql = "INSERT INTO kv (key, value) VALUES('" + key + "', '"+ value + "')"
              print cql
              session.execute(cql)
              resultSet = session.execute("select token(key),key from kv  where key = '" + key + "'");
              for row in  resultSet.current_rows:
                  print  TestConcurrency.get_replicas(row[0])
