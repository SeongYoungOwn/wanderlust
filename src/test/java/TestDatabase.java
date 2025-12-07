import java.sql.*;

public class TestDatabase {
    public static void main(String[] args) {
        String URL = "jdbc:mysql://localhost:3306/tourdb?useSSL=false&useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul";
        String USERNAME = "root";
        String PASSWORD = "1234";

        Connection conn = null;

        try {
            // MySQL 드라이버 로드
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 데이터베이스 연결
            conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("데이터베이스 연결 성공!");

            // 테이블 확인
            DatabaseMetaData meta = conn.getMetaData();
            ResultSet tables = meta.getTables(null, null, "guide%", null);

            System.out.println("\n=== Guide 관련 테이블 목록 ===");
            boolean hasTable = false;
            while (tables.next()) {
                String tableName = tables.getString("TABLE_NAME");
                System.out.println("- " + tableName);
                hasTable = true;
            }

            if (!hasTable) {
                System.out.println("Guide 테이블이 없습니다!");
                System.out.println("\n테이블을 생성하려면 다음 SQL을 실행하세요:");
                System.out.println("mysql -u root -p1234 tourdb < database\\guide_tables_fixed.sql");
            }

            // member 테이블 확인
            tables = meta.getTables(null, null, "member", null);
            if (tables.next()) {
                System.out.println("\nmember 테이블 존재 확인!");

                // member 테이블 구조 확인
                PreparedStatement pstmt = conn.prepareStatement("SELECT COUNT(*) FROM member");
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    System.out.println("member 테이블 레코드 수: " + rs.getInt(1));
                }
                rs.close();
                pstmt.close();
            } else {
                System.out.println("\nmember 테이블이 없습니다!");
            }

        } catch (ClassNotFoundException e) {
            System.err.println("MySQL 드라이버를 찾을 수 없습니다: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("데이터베이스 연결 오류: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    System.out.println("\n데이터베이스 연결 종료");
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}