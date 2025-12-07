package com.tour.project.dao;

import com.tour.project.dto.SystemSettingDTO;
import org.apache.ibatis.annotations.*;

import java.util.List;

/**
 * 시스템 설정 DAO
 * - Claude API 키 등 시스템 설정 CRUD
 */
@Mapper
public interface SystemSettingDAO {

    /**
     * 설정 키로 설정 조회
     */
    @Select("SELECT setting_id as settingId, setting_key as settingKey, setting_value as settingValue, " +
            "setting_description as settingDescription, is_encrypted as isEncrypted, is_active as isActive, " +
            "created_at as createdAt, updated_at as updatedAt, updated_by as updatedBy " +
            "FROM system_settings WHERE setting_key = #{settingKey}")
    SystemSettingDTO getSettingByKey(@Param("settingKey") String settingKey);

    /**
     * 모든 설정 조회
     */
    @Select("SELECT setting_id as settingId, setting_key as settingKey, setting_value as settingValue, " +
            "setting_description as settingDescription, is_encrypted as isEncrypted, is_active as isActive, " +
            "created_at as createdAt, updated_at as updatedAt, updated_by as updatedBy " +
            "FROM system_settings ORDER BY setting_key")
    List<SystemSettingDTO> getAllSettings();

    /**
     * 설정 저장 (INSERT)
     */
    @Insert("INSERT INTO system_settings (setting_key, setting_value, setting_description, is_encrypted, is_active, updated_by) " +
            "VALUES (#{settingKey}, #{settingValue}, #{settingDescription}, #{isEncrypted}, #{isActive}, #{updatedBy})")
    @Options(useGeneratedKeys = true, keyProperty = "settingId")
    int insertSetting(SystemSettingDTO setting);

    /**
     * 설정 업데이트 (값, 활성화 상태, 수정자)
     */
    @Update("UPDATE system_settings SET setting_value = #{settingValue}, is_active = #{isActive}, " +
            "updated_by = #{updatedBy}, updated_at = CURRENT_TIMESTAMP WHERE setting_key = #{settingKey}")
    int updateSetting(SystemSettingDTO setting);

    /**
     * 설정 값만 업데이트
     */
    @Update("UPDATE system_settings SET setting_value = #{settingValue}, is_active = #{isActive}, " +
            "updated_by = #{updatedBy}, updated_at = CURRENT_TIMESTAMP WHERE setting_key = #{settingKey}")
    int updateSettingValue(@Param("settingKey") String settingKey,
                           @Param("settingValue") String settingValue,
                           @Param("isActive") Boolean isActive,
                           @Param("updatedBy") String updatedBy);

    /**
     * 설정 삭제 (값을 null로, 비활성화)
     */
    @Update("UPDATE system_settings SET setting_value = NULL, is_active = FALSE, " +
            "updated_by = #{updatedBy}, updated_at = CURRENT_TIMESTAMP WHERE setting_key = #{settingKey}")
    int deactivateSetting(@Param("settingKey") String settingKey, @Param("updatedBy") String updatedBy);

    /**
     * 설정 존재 여부 확인
     */
    @Select("SELECT COUNT(*) > 0 FROM system_settings WHERE setting_key = #{settingKey}")
    boolean existsByKey(@Param("settingKey") String settingKey);

    /**
     * 활성화된 설정인지 확인
     */
    @Select("SELECT COALESCE(is_active, FALSE) FROM system_settings WHERE setting_key = #{settingKey}")
    Boolean isSettingActive(@Param("settingKey") String settingKey);
}
