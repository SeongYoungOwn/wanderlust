package com.tour.project.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MapController {
    
    @GetMapping("/map/sido")
    public String showSidoMap() {
        return "map/sido-map-optimized";
    }
    
    @GetMapping("/map/sido-map")
    public String showSidoMapAI() {
        return "map/sido-map";
    }
    
    @GetMapping("/map/test")
    public String showMapTest() {
        return "map/sido-map-test";
    }
    
    @GetMapping("/map/test-simple")
    public String showSimpleMapTest() {
        return "map/test-simple";
    }
}