package com.tour.project.dao;

import com.tour.project.dto.playlist.PlaylistSaveRequestDTO;
import com.tour.project.dto.playlist.SavedPlaylistDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 플레이리스트 데이터 접근 객체
 */
@Mapper
public interface PlaylistDAO {
    
    /**
     * 플레이리스트 기본 정보 저장
     * @param userId 사용자 ID
     * @param saveRequest 저장 요청 데이터 (저장 후 playlistId가 설정됨)
     */
    void insertPlaylist(@Param("userId") String userId, 
                       @Param("request") PlaylistSaveRequestDTO saveRequest);
    
    /**
     * 플레이리스트 음악 저장
     * @param playlistId 플레이리스트 ID
     * @param song 저장할 음악 정보
     * @param order 곡 순서
     * @return 저장된 행 수
     */
    int insertPlaylistSong(@Param("playlistId") Long playlistId, 
                          @Param("song") PlaylistSaveRequestDTO.SelectedSong song,
                          @Param("order") int order);
    
    /**
     * 사용자의 플레이리스트 개수 조회
     * @param userId 사용자 ID
     * @return 플레이리스트 개수
     */
    int getPlaylistCountByUser(@Param("userId") String userId);
    
    /**
     * 사용자의 저장된 플레이리스트 목록 조회
     * @param userId 사용자 ID
     * @return 플레이리스트 목록
     */
    List<SavedPlaylistDTO> getUserPlaylists(@Param("userId") String userId);
    
    /**
     * 플레이리스트의 음악 목록 조회
     * @param playlistId 플레이리스트 ID
     * @return 음악 목록
     */
    List<SavedPlaylistDTO.SavedSongDTO> getPlaylistSongs(@Param("playlistId") Long playlistId);
    
    /**
     * 임시 사용자 플레이리스트를 실제 사용자로 이관
     * @param tempUserId 임시 사용자 ID
     * @param realUserId 실제 사용자 ID
     * @return 이관된 플레이리스트 수
     */
    int transferTempPlaylistsToUser(@Param("tempUserId") String tempUserId, 
                                   @Param("realUserId") String realUserId);
    
    /**
     * 임시 사용자의 플레이리스트 목록 조회
     * @return 임시 사용자 플레이리스트 목록
     */
    List<SavedPlaylistDTO> getTempUserPlaylists();
}