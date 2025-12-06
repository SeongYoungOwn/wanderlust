package com.tour.project.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * Test configuration for Spring context
 * Replaces XML-based test configuration with Java config
 */
@Configuration
@ComponentScan(basePackages = {
    "com.tour.project.service",
    "com.tour.project.dao",
    "com.tour.project.config"
})
public class TestConfig {
    // Spring Boot auto-configuration will handle DataSource, MyBatis, etc.
}
