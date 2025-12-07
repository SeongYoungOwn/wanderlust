import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class DatabaseConnectionTest {
    public static void main(String[] args) {
        String url = "jdbc:mariadb://localhost:3306/tt_db";
        String username = "root";
        String password = "";

        System.out.println("Testing database connection...");

        try {
            // Load driver
            Class.forName("org.mariadb.jdbc.Driver");
            System.out.println("✓ Driver loaded successfully");

            // Connect to database
            Connection conn = DriverManager.getConnection(url, username, password);
            System.out.println("✓ Connected to database successfully");

            // Test query
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT 1");
            if (rs.next()) {
                System.out.println("✓ Test query executed successfully");
            }

            // Test member table
            rs = stmt.executeQuery("SELECT COUNT(*) FROM member");
            if (rs.next()) {
                System.out.println("✓ Member table accessible, count: " + rs.getInt(1));
            }

            rs.close();
            stmt.close();
            conn.close();

            System.out.println("\n✅ All database tests passed!");

        } catch (Exception e) {
            System.err.println("❌ Database connection error:");
            e.printStackTrace();
        }
    }
}