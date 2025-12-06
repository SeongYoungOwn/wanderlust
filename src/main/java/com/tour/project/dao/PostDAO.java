package com.tour.project.dao;

import com.tour.project.dto.PostDTO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;
import java.util.List;

@Mapper
@Repository
public interface PostDAO {
    
    int insertPost(PostDTO post);
    
    PostDTO getPost(int postId);
    
    int updatePost(PostDTO post);
    
    int deletePost(int postId);
    
    List<PostDTO> getAllPosts();
    
    List<PostDTO> getPostsByWriter(String postWriter);
    
    int getPostCountByWriter(String postWriter);
    
    int updateViewCount(int postId);
}