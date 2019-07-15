package trumanz.neo4jlearn;

import java.util.Map;
import java.util.Map.Entry;

import org.junit.Test;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Result;
import org.neo4j.graphdb.Transaction;
import org.neo4j.graphdb.factory.GraphDatabaseFactory;
import org.neo4j.graphdb.factory.GraphDatabaseSettings;
////http://maxdemarzi.com/2015/09/04/flight-search-with-the-neo4j-traversal-api/

public class BasicTest {
	@SuppressWarnings("deprecation")
	@Test
	public void test(){
		
		GraphDatabaseService graphDb = new GraphDatabaseFactory().newEmbeddedDatabaseBuilder("neo4j.db.file")
				.setConfig(GraphDatabaseSettings.pagecache_memory, "512M").newGraphDatabase();

		Transaction tx = graphDb.beginTx();
	
		
		Node node = null;
		
		node = graphDb.createNode();
		node.setProperty("id", "1");
		node.setProperty("time", 1);
		
		node = graphDb.createNode();
		node.setProperty("id", "2");
		node.setProperty("time", 2);

		
		node = graphDb.createNode();
		node.setProperty("id", "3");
		node.setProperty("time", 3);
		
		
		Result result = graphDb.execute("match (n {id: '1'}) return n, n.id");
		
		Map<String,Object> row = result.next();
		for ( Entry<String,Object> column : row.entrySet() )
        {
            System.out.println(column.getKey() + ": " + column.getValue() + "; ");
        }

		
		tx.terminate();
		
		graphDb.shutdown();
	}


}
