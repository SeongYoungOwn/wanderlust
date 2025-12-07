package com.tour.project.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

@Component
public class DatabaseInitializer implements CommandLineRunner {

    @Autowired(required = false)
    private JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) throws Exception {
        try {
            System.out.println("=== 데이터베이스 초기화 시작 ===");
            
            // Create missing tables
            createFavoriteTableIfNotExists();
            
            // Check if plan_tags column exists and add it if it doesn't
            addTagsColumnIfNotExists();
            
            // Create manner evaluation system tables
            createMannerEvaluationTables();
            
            // Create dislike system tables and columns
            createDislikeSystem();
            
            // Add account_status column for admin management
            addAccountStatusColumn();
            
            // Add user_role column for admin management
            addUserRoleColumn();
            
            // Add missing board columns for admin functionality
            addBoardViewsColumn();
            addBoardLikesColumn();
            
            // Create board_likes table if it doesn't exist
            createBoardLikesTable();
            
            // Create playlist tables
            createPlaylistTables();
            
            System.out.println("=== 데이터베이스 초기화 완료 ===");
            
        } catch (Exception e) {
            System.err.println("데이터베이스 초기화 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            // 초기화 실패해도 애플리케이션은 계속 시작되도록 함
        }
    }
    
    private void addTagsColumnIfNotExists() {
        try {
            // Check if plan_tags column already exists
            String checkColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'travel_plan' AND COLUMN_NAME = 'plan_tags'";
            
            Integer columnExists = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);
            
            if (columnExists == null || columnExists == 0) {
                System.out.println("Adding plan_tags column to travel_plan table...");
                
                // Add plan_tags column
                String addColumnSql = "ALTER TABLE travel_plan ADD COLUMN plan_tags TEXT";
                jdbcTemplate.execute(addColumnSql);
                
                // Update existing records with sample tags
                jdbcTemplate.execute("UPDATE travel_plan SET plan_tags = '힐링여행,국내여행' WHERE plan_destination LIKE '%제주%'");
                jdbcTemplate.execute("UPDATE travel_plan SET plan_tags = '감성여행,캠핑,국내여행' WHERE plan_destination LIKE '%강원도%'");
                jdbcTemplate.execute("UPDATE travel_plan SET plan_tags = '식도락여행,맛집추천,국내여행' WHERE plan_destination LIKE '%부산%'");
                jdbcTemplate.execute("UPDATE travel_plan SET plan_tags = '해외여행,일본여행' WHERE plan_destination LIKE '%일본%'");
                jdbcTemplate.execute("UPDATE travel_plan SET plan_tags = '해외여행,유럽여행' WHERE plan_destination LIKE '%유럽%'");
                
                // Create index for better performance
                jdbcTemplate.execute("CREATE INDEX idx_travel_plan_tags ON travel_plan (plan_tags)");
                
                System.out.println("Successfully added plan_tags column and sample data");
            } else {
                System.out.println("plan_tags column already exists, skipping creation");
            }
            
            // Check if plan_view_count column already exists
            String checkViewCountColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'travel_plan' AND COLUMN_NAME = 'plan_view_count'";
            
            Integer viewCountColumnExists = jdbcTemplate.queryForObject(checkViewCountColumnSql, Integer.class);
            
            if (viewCountColumnExists == null || viewCountColumnExists == 0) {
                System.out.println("Adding plan_view_count column to travel_plan table...");
                
                // Add plan_view_count column
                String addViewCountColumnSql = "ALTER TABLE travel_plan ADD COLUMN plan_view_count INT DEFAULT 0";
                jdbcTemplate.execute(addViewCountColumnSql);
                
                // Create index for better performance
                jdbcTemplate.execute("CREATE INDEX idx_travel_plan_view_count ON travel_plan (plan_view_count)");
                
                System.out.println("Successfully added plan_view_count column");
            } else {
                System.out.println("plan_view_count column already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error adding columns: " + e.getMessage());
            // Don't throw exception, just log it
        }
    }
    
    private void createFavoriteTableIfNotExists() {
        try {
            // Check if favorite table exists
            String checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'favorite'";
            
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);
            
            if (tableExists == null || tableExists == 0) {
                System.out.println("Creating favorite table...");
                
                // Create favorite table
                String createTableSql = "CREATE TABLE favorite (" +
                        "favorite_id INT PRIMARY KEY AUTO_INCREMENT, " +
                        "user_id VARCHAR(50) NOT NULL, " +
                        "target_type VARCHAR(50) NOT NULL, " +
                        "target_id INT NOT NULL, " +
                        "created_date DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "UNIQUE KEY uk_favorite (user_id, target_type, target_id), " +
                        "INDEX idx_favorite_target (target_type, target_id), " +
                        "INDEX idx_favorite_user (user_id)" +
                        ")";
                jdbcTemplate.execute(createTableSql);
                
                System.out.println("Successfully created favorite table");
            } else {
                System.out.println("favorite table already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error creating favorite table: " + e.getMessage());
            // Don't throw exception, just log it
        }
    }
    
    private void executeSqlFile(String sqlFilePath) {
        try {
            ClassPathResource resource = new ClassPathResource(sqlFilePath);
            
            if (resource.exists()) {
                StringBuilder sql = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        // 주석 제거
                        line = line.trim();
                        if (!line.startsWith("--") && !line.isEmpty()) {
                            sql.append(line).append(" ");
                        }
                    }
                }
                
                String sqlContent = sql.toString().trim();
                if (!sqlContent.isEmpty()) {
                    System.out.println("SQL 실행 중: " + sqlFilePath);
                    jdbcTemplate.execute(sqlContent);
                    System.out.println("SQL 실행 완료: " + sqlFilePath);
                }
            } else {
                System.out.println("SQL 파일을 찾을 수 없습니다: " + sqlFilePath);
            }
        } catch (Exception e) {
            System.err.println("SQL 파일 실행 중 오류 (" + sqlFilePath + "): " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void createMannerEvaluationTables() {
        try {
            // 1. Add status columns to travel_plan table
            addTravelPlanStatusColumns();
            
            // 2. Create manner_evaluation table
            createMannerEvaluationTable();
            
            // 3. Create user_manner_stats table
            createUserMannerStatsTable();
            
            // 4. Update chat_messages table
            updateChatMessageTable();
            
        } catch (Exception e) {
            System.err.println("Error creating manner evaluation tables: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void addTravelPlanStatusColumns() {
        try {
            // Check if plan_status column exists
            String checkStatusColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'travel_plan' AND COLUMN_NAME = 'plan_status'";
            
            Integer statusColumnExists = jdbcTemplate.queryForObject(checkStatusColumnSql, Integer.class);
            
            if (statusColumnExists == null || statusColumnExists == 0) {
                System.out.println("Adding plan_status column to travel_plan table...");
                jdbcTemplate.execute("ALTER TABLE travel_plan ADD COLUMN plan_status VARCHAR(20) DEFAULT 'ACTIVE'");
                jdbcTemplate.execute("CREATE INDEX idx_travel_plan_status ON travel_plan (plan_status)");
            } else {
                System.out.println("plan_status column already exists, skipping creation");
            }
            
            // Check if completed_date column exists
            String checkCompletedColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'travel_plan' AND COLUMN_NAME = 'completed_date'";
            
            Integer completedColumnExists = jdbcTemplate.queryForObject(checkCompletedColumnSql, Integer.class);
            
            if (completedColumnExists == null || completedColumnExists == 0) {
                System.out.println("Adding completed_date column to travel_plan table...");
                jdbcTemplate.execute("ALTER TABLE travel_plan ADD COLUMN completed_date DATETIME NULL");
            } else {
                System.out.println("completed_date column already exists, skipping creation");
            }
            
        } catch (Exception e) {
            System.err.println("Error adding travel_plan status columns: " + e.getMessage());
        }
    }
    
    private void createMannerEvaluationTable() {
        try {
            // Check if manner_evaluation table exists
            String checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'manner_evaluation'";
            
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);
            
            if (tableExists == null || tableExists == 0) {
                System.out.println("Creating manner_evaluation table...");
                
                String createTableSql = "CREATE TABLE manner_evaluation (" +
                        "evaluation_id INT PRIMARY KEY AUTO_INCREMENT, " +
                        "travel_plan_id INT NOT NULL, " +
                        "evaluator_id VARCHAR(50) NOT NULL, " +
                        "evaluated_id VARCHAR(50) NOT NULL, " +
                        "manner_score INT DEFAULT 365, " +
                        "is_like BOOLEAN NULL, " +
                        "evaluation_comment TEXT, " +
                        "created_date DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "updated_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, " +
                        "UNIQUE KEY unique_evaluation (travel_plan_id, evaluator_id, evaluated_id), " +
                        "INDEX idx_manner_evaluation_travel_plan (travel_plan_id), " +
                        "INDEX idx_manner_evaluation_evaluator (evaluator_id), " +
                        "INDEX idx_manner_evaluation_evaluated (evaluated_id)" +
                        ")";
                
                jdbcTemplate.execute(createTableSql);
                System.out.println("Successfully created manner_evaluation table");
            } else {
                System.out.println("manner_evaluation table already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error creating manner_evaluation table: " + e.getMessage());
        }
    }
    
    private void createUserMannerStatsTable() {
        try {
            // Check if user_manner_stats table exists
            String checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'user_manner_stats'";
            
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);
            
            if (tableExists == null || tableExists == 0) {
                System.out.println("Creating user_manner_stats table...");
                
                String createTableSql = "CREATE TABLE user_manner_stats (" +
                        "user_id VARCHAR(50) PRIMARY KEY, " +
                        "total_evaluations INT DEFAULT 0, " +
                        "average_manner_score DECIMAL(4,1) DEFAULT 36.5, " +
                        "total_likes INT DEFAULT 0, " +
                        "total_dislikes INT DEFAULT 0, " +
                        "completed_travels INT DEFAULT 0, " +
                        "last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                        ")";
                
                jdbcTemplate.execute(createTableSql);
                System.out.println("Successfully created user_manner_stats table");
            } else {
                System.out.println("user_manner_stats table already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error creating user_manner_stats table: " + e.getMessage());
        }
    }
    
    private void updateChatMessageTable() {
        try {
            // Check if chat_messages table exists
            String checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'chat_messages' OR TABLE_NAME = 'CHAT_MESSAGES'";
            
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);
            
            if (tableExists == null || tableExists == 0) {
                System.out.println("Creating chat_messages table...");
                
                String createTableSql = "CREATE TABLE IF NOT EXISTS chat_messages (" +
                        "message_id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                        "travel_plan_id INT NOT NULL, " +
                        "sender_id VARCHAR(50) NOT NULL, " +
                        "sender_name VARCHAR(100) NOT NULL, " +
                        "message_content TEXT NOT NULL, " +
                        "message_type VARCHAR(20) DEFAULT 'CHAT', " +
                        "sent_time DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "file_name VARCHAR(255) NULL, " +
                        "file_path VARCHAR(500) NULL, " +
                        "file_size VARCHAR(50) NULL, " +
                        "INDEX idx_chat_travel_plan (travel_plan_id), " +
                        "INDEX idx_chat_sender (sender_id), " +
                        "INDEX idx_chat_sent_time (sent_time)" +
                        ")";
                
                jdbcTemplate.execute(createTableSql);
                System.out.println("Successfully created chat_messages table");
            } else {
                System.out.println("chat_messages table already exists, checking for new columns...");
                
                // Check and add file_name column
                String checkFileNameColumn = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                        "WHERE TABLE_NAME IN ('chat_messages', 'CHAT_MESSAGES') AND COLUMN_NAME = 'file_name'";
                
                Integer fileNameExists = jdbcTemplate.queryForObject(checkFileNameColumn, Integer.class);
                
                if (fileNameExists == null || fileNameExists == 0) {
                    System.out.println("Adding file-related columns to chat_messages table...");
                    jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_name VARCHAR(255) NULL");
                    jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_path VARCHAR(500) NULL");
                    jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_size VARCHAR(50) NULL");
                    jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN original_filename VARCHAR(255) NULL");
                    jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_type VARCHAR(100) NULL");
                    jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_size_bytes BIGINT NULL");
                    System.out.println("Successfully added file-related columns");
                } else {
                    System.out.println("chat_messages file columns already exist, checking for additional columns...");
                    
                    // Check and add additional file columns if they don't exist
                    try {
                        String checkOriginalFilename = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                                "WHERE TABLE_NAME IN ('chat_messages', 'CHAT_MESSAGES') AND COLUMN_NAME = 'original_filename'";
                        Integer originalFilenameExists = jdbcTemplate.queryForObject(checkOriginalFilename, Integer.class);
                        
                        if (originalFilenameExists == null || originalFilenameExists == 0) {
                            System.out.println("Adding additional file columns...");
                            jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN original_filename VARCHAR(255) NULL");
                            jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_type VARCHAR(100) NULL");
                            jdbcTemplate.execute("ALTER TABLE chat_messages ADD COLUMN file_size_bytes BIGINT NULL");
                            System.out.println("Successfully added additional file columns");
                        } else {
                            System.out.println("All file columns already exist");
                        }
                    } catch (Exception ex) {
                        System.err.println("Error checking additional file columns: " + ex.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error updating chat_messages table: " + e.getMessage());
        }
    }
    
    private void createDislikeSystem() {
        try {
            // 1. Add board_dislikes column to board table
            addBoardDislikesColumn();
            
            // 2. Create board_dislikes table
            createBoardDislikesTable();
            
        } catch (Exception e) {
            System.err.println("Error creating dislike system: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void addBoardDislikesColumn() {
        try {
            // Check if board_dislikes column exists
            String checkColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'board' AND COLUMN_NAME = 'board_dislikes'";
            
            Integer columnExists = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);
            
            if (columnExists == null || columnExists == 0) {
                System.out.println("Adding board_dislikes column to board table...");
                
                // Add board_dislikes column
                String addColumnSql = "ALTER TABLE board ADD COLUMN board_dislikes INT DEFAULT 0";
                jdbcTemplate.execute(addColumnSql);
                
                // Create index for better performance
                jdbcTemplate.execute("CREATE INDEX idx_board_dislikes ON board (board_dislikes)");
                
                System.out.println("Successfully added board_dislikes column");
            } else {
                System.out.println("board_dislikes column already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error adding board_dislikes column: " + e.getMessage());
        }
    }
    
    private void createBoardDislikesTable() {
        try {
            // Check if board_dislikes table exists
            String checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'board_dislikes'";
            
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);
            
            if (tableExists == null || tableExists == 0) {
                System.out.println("Creating board_dislikes table...");
                
                // Create board_dislikes table
                String createTableSql = "CREATE TABLE board_dislikes (" +
                        "dislike_id INT PRIMARY KEY AUTO_INCREMENT, " +
                        "board_id INT NOT NULL, " +
                        "user_id VARCHAR(50) NOT NULL, " +
                        "created_date DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "UNIQUE KEY uk_board_dislike (board_id, user_id), " +
                        "INDEX idx_board_dislikes_board (board_id), " +
                        "INDEX idx_board_dislikes_user (user_id), " +
                        "FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE" +
                        ")";
                jdbcTemplate.execute(createTableSql);
                
                System.out.println("Successfully created board_dislikes table");
            } else {
                System.out.println("board_dislikes table already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error creating board_dislikes table: " + e.getMessage());
        }
    }
    
    private void addAccountStatusColumn() {
        try {
            // Check if account_status column exists
            String checkColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'member' AND COLUMN_NAME = 'account_status'";
            
            Integer columnExists = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);
            
            if (columnExists == null || columnExists == 0) {
                System.out.println("Adding account_status column to member table...");
                
                // Add account_status column with default value 'ACTIVE'
                String addColumnSql = "ALTER TABLE member ADD COLUMN account_status VARCHAR(20) DEFAULT 'ACTIVE'";
                jdbcTemplate.execute(addColumnSql);
                
                // Create index for better performance
                jdbcTemplate.execute("CREATE INDEX idx_member_account_status ON member (account_status)");
                
                // Update existing records to have ACTIVE status
                jdbcTemplate.execute("UPDATE member SET account_status = 'ACTIVE' WHERE account_status IS NULL");
                
                System.out.println("Successfully added account_status column");
            } else {
                System.out.println("account_status column already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error adding account_status column: " + e.getMessage());
        }
    }
    
    private void addUserRoleColumn() {
        try {
            // Check if user_role column exists
            String checkColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'member' AND COLUMN_NAME = 'user_role'";
            
            Integer columnExists = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);
            
            if (columnExists == null || columnExists == 0) {
                System.out.println("Adding user_role column to member table...");
                
                // Add user_role column with default value 'USER'
                String addColumnSql = "ALTER TABLE member ADD COLUMN user_role VARCHAR(20) DEFAULT 'USER'";
                jdbcTemplate.execute(addColumnSql);
                
                // Update admin user to have ADMIN role if exists
                String updateAdminSql = "UPDATE member SET user_role = 'ADMIN' WHERE user_id = 'admin'";
                int updatedRows = jdbcTemplate.update(updateAdminSql);
                
                if (updatedRows > 0) {
                    System.out.println("Updated admin user role to ADMIN");
                } else {
                    System.out.println("Admin user not found, skipping role update");
                }
                
            } else {
                System.out.println("user_role column already exists, skipping creation");
            }
            
        } catch (Exception e) {
            System.err.println("Error adding user_role column: " + e.getMessage());
        }
    }
    
    private void addBoardViewsColumn() {
        try {
            // Check if board_views column exists
            String checkColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'board' AND COLUMN_NAME = 'board_views'";
            
            Integer columnExists = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);
            
            if (columnExists == null || columnExists == 0) {
                System.out.println("Adding board_views column to board table...");
                
                // Add board_views column with default value 0
                String addColumnSql = "ALTER TABLE board ADD COLUMN board_views INT DEFAULT 0";
                jdbcTemplate.execute(addColumnSql);
                
                // Create index for better performance
                jdbcTemplate.execute("CREATE INDEX idx_board_views ON board (board_views)");
                
                System.out.println("Successfully added board_views column");
            } else {
                System.out.println("board_views column already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error adding board_views column: " + e.getMessage());
        }
    }
    
    private void addBoardLikesColumn() {
        try {
            // Check if board_likes column exists
            String checkColumnSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_NAME = 'board' AND COLUMN_NAME = 'board_likes'";
            
            Integer columnExists = jdbcTemplate.queryForObject(checkColumnSql, Integer.class);
            
            if (columnExists == null || columnExists == 0) {
                System.out.println("Adding board_likes column to board table...");
                
                // Add board_likes column with default value 0
                String addColumnSql = "ALTER TABLE board ADD COLUMN board_likes INT DEFAULT 0";
                jdbcTemplate.execute(addColumnSql);
                
                // Create index for better performance
                jdbcTemplate.execute("CREATE INDEX idx_board_likes ON board (board_likes)");
                
                System.out.println("Successfully added board_likes column");
            } else {
                System.out.println("board_likes column already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error adding board_likes column: " + e.getMessage());
        }
    }
    
    private void createBoardLikesTable() {
        try {
            // Check if board_likes table exists
            String checkTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'board_likes'";
            
            Integer tableExists = jdbcTemplate.queryForObject(checkTableSql, Integer.class);
            
            if (tableExists == null || tableExists == 0) {
                System.out.println("Creating board_likes table...");
                
                // Create board_likes table
                String createTableSql = "CREATE TABLE board_likes (" +
                        "like_id INT PRIMARY KEY AUTO_INCREMENT, " +
                        "board_id INT NOT NULL, " +
                        "user_id VARCHAR(50) NOT NULL, " +
                        "created_date DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "UNIQUE KEY uk_board_like (board_id, user_id), " +
                        "INDEX idx_board_likes_board (board_id), " +
                        "INDEX idx_board_likes_user (user_id), " +
                        "FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE" +
                        ")";
                jdbcTemplate.execute(createTableSql);
                
                System.out.println("Successfully created board_likes table");
            } else {
                System.out.println("board_likes table already exists, skipping creation");
            }
        } catch (Exception e) {
            System.err.println("Error creating board_likes table: " + e.getMessage());
        }
    }
    
    private void createPlaylistTables() {
        try {
            // Check if user_playlist table exists
            String checkPlaylistTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'user_playlist'";
            
            Integer playlistTableExists = jdbcTemplate.queryForObject(checkPlaylistTableSql, Integer.class);
            
            if (playlistTableExists == null || playlistTableExists == 0) {
                System.out.println("Creating user_playlist table...");
                
                String createPlaylistTableSql = "CREATE TABLE user_playlist (" +
                        "playlist_id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                        "user_id VARCHAR(50) NOT NULL, " +
                        "music_origin VARCHAR(20) NOT NULL, " +
                        "destination_type VARCHAR(50) NOT NULL, " +
                        "music_genre VARCHAR(50) NOT NULL, " +
                        "time_of_day VARCHAR(20), " +
                        "travel_style VARCHAR(20), " +
                        "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "INDEX idx_user_playlist_user_id (user_id), " +
                        "INDEX idx_user_playlist_created_at (created_at), " +
                        "FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE" +
                        ")";
                jdbcTemplate.execute(createPlaylistTableSql);
                
                System.out.println("Successfully created user_playlist table");
            } else {
                System.out.println("user_playlist table already exists, skipping creation");
            }
            
            // Check if playlist_songs table exists
            String checkSongsTableSql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES " +
                    "WHERE TABLE_NAME = 'playlist_songs'";
            
            Integer songsTableExists = jdbcTemplate.queryForObject(checkSongsTableSql, Integer.class);
            
            if (songsTableExists == null || songsTableExists == 0) {
                System.out.println("Creating playlist_songs table...");
                
                String createSongsTableSql = "CREATE TABLE playlist_songs (" +
                        "song_id BIGINT AUTO_INCREMENT PRIMARY KEY, " +
                        "playlist_id BIGINT NOT NULL, " +
                        "song_title VARCHAR(200) NOT NULL, " +
                        "artist VARCHAR(200) NOT NULL, " +
                        "genre VARCHAR(50) NOT NULL, " +
                        "reason TEXT, " +
                        "song_order INT DEFAULT 1, " +
                        "created_at DATETIME DEFAULT CURRENT_TIMESTAMP, " +
                        "INDEX idx_playlist_songs_playlist_id (playlist_id), " +
                        "FOREIGN KEY (playlist_id) REFERENCES user_playlist(playlist_id) ON DELETE CASCADE" +
                        ")";
                jdbcTemplate.execute(createSongsTableSql);
                
                System.out.println("Successfully created playlist_songs table");
            } else {
                System.out.println("playlist_songs table already exists, skipping creation");
            }
            
        } catch (Exception e) {
            System.err.println("Error creating playlist tables: " + e.getMessage());
            e.printStackTrace();
        }
    }
}