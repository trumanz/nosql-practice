package trumanz.cqlLearn;

import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.util.Collection;
import java.util.Date;
import java.util.LinkedList;
import java.util.UUID;

import org.apache.log4j.Logger;
import org.junit.AfterClass;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Session;

public class Client {

	private static Cluster cluster = null;
	private static Session session = null;
	private static Logger logger = Logger.getLogger(Client.class);

	private static final String keyspaceName = " trumanz_keyspace ";
	private static final String tableName = " trumanz_table ";
	private static final String compactConstraint = " ";// " WITH COMPACT
														// STORAGE";

	@BeforeClass
	public static void prepSession() {
		
		

		Collection<InetSocketAddress> addresses = new LinkedList<InetSocketAddress>();

		addresses.add(new InetSocketAddress("10.29.113.20", 10000));
		addresses.add(new InetSocketAddress("10.29.113.20", 10001));
		addresses.add(new InetSocketAddress("10.29.113.20", 10002));
		addresses.add(new InetSocketAddress("10.29.113.20", 10003));
		addresses.add(new InetSocketAddress("10.29.113.20", 10004));

		cluster = Cluster.builder().addContactPointsWithPorts(addresses).build();

		Metadata metadata = cluster.getMetadata();

		System.out.println("ClusterName: " + metadata.getClusterName());

		for (Host host : metadata.getAllHosts()) {

			System.out.printf("Datacenter %s, Host %s, Rack %s\n", host.getDatacenter(), host.getAddress(),
					host.getRack());

		}
		session = cluster.connect();
		dropKeySpaceAndTable();
		prepKeySpaceAndTable();
	}

	@AfterClass
	public static void closeSession() {
		System.out.printf("Close it");
		dropKeySpaceAndTable();
		session.close();
		cluster.close();
		cluster = null;
	}

	private static void prepKeySpaceAndTable() {
		logger.info("Start");
		// create keyspace and using it
		//
		session.execute("CREATE KEYSPACE " + keyspaceName
				+ " WITH replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1}");

		session.execute("USE " + keyspaceName);
		logger.info("KEYSPACE created");

		// create table
		session.execute("CREATE TABLE " + tableName + "  (key bigint PRIMARY KEY, value text) " + compactConstraint);
		logger.info("TABLE created");
	}
	private static void dropKeySpaceAndTable() {
		// delete the keyspace
		session.execute("DROP KEYSPACE IF EXISTS " + keyspaceName);
		logger.info("KEYSPACE droped");
	}
	

	@Test
	public void testCURDWithCQL() {

		int key = 1;
		final String origValue =  UUID.randomUUID().toString();
		
		// CQL
		//http://docs.datastax.com/en/landing_page/doc/landing_page/current.html 
		//http://docs.datastax.com/en/cql/3.1/cql/cql_reference/cql_data_types_c.html
		// Create one value with prepaerd statement
		PreparedStatement preparedStmt = session.prepare("UPDATE " + tableName + " SET value = ? WHERE key = ?");
		BoundStatement boundStmt = preparedStmt.bind();
		boundStmt.setLong("key", key);
		boundStmt.setString("value", origValue);
		session.execute(boundStmt);
		logger.info("OBJ created");
		
		
		//Retrieve
		ResultSet resultSet = session.execute("SELECT * FROM " + tableName + "WHERE key = 1");
		Row row = resultSet.one();
		Assert.assertNotNull(row);
		Assert.assertEquals(origValue, row.getString("value"));
	
		//UPDATE
		final String newValue =    UUID.randomUUID().toString();
		session.execute("UPDATE " + tableName + "SET value='" + newValue + "'  WHERE key=1");
		final String getValue = session.execute("SELECT * FROM " + tableName + "WHERE key = 1").one().getString("value");
		Assert.assertEquals(newValue, getValue);
		Assert.assertNotEquals(origValue, getValue);
		
		//DELETE
	 
		session.execute("DELETE  FROM " + tableName +  " WHERE key=1");

		Assert.assertNull(session.execute("SELECT * FROM " + tableName + "WHERE key = 1").one());


	}

}
