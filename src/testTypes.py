#!/usr/bin/env python
import os
import time
import unittest
from cassandra.cluster import Cluster


class TestCassandraType(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
          cls._cluster  = Cluster([os.environ['CASSANDRA_ADDRESS']])
          cls._session = cls._cluster.connect()
          cls._session.execute("DROP KEYSPACE IF EXISTS testSpace")
          cls._session.execute("DROP KEYSPACE IF EXISTS testSpace")
          cls._session.execute("CREATE KEYSPACE testSpace WITH REPLICATION = {'class' : 'SimpleStrategy', 'replication_factor' : 1}")
          cls._session.execute("USE testSpace")
    @classmethod
    def tearDownClass(cls):
          #close all sessions and connection assocaiated with this Cluster
          cls._cluster.shutdown();
 
    def test_bolb(self):
          session = TestCassandraType._session
          session.execute("CREATE TABLE bios ( user_name varchar PRIMARY KEY,  bio blob)")
          session.execute("INSERT INTO bios ( user_name, bio ) VALUES ('fred', bigintAsBlob(3))");
          rows = session.execute("SELECT * FROM bios WHERE user_name = 'fred' ").current_rows;
          self.assertEqual(1, len(rows))
          self.assertEqual('fred', rows[0].user_name)
          self.assertEqual(8, len(rows[0].bio))
          self.assertEqual('\x03', rows[0].bio[7])

    def test_set(self):
          session = TestCassandraType._session
          cql = "CREATE TABLE id ("
          cql = cql +  "id  text  PRIMARY KEY,"
          cql = cql +  "tag  set<text>"
          cql = cql + ")"
          session.execute(cql)
                  
         
