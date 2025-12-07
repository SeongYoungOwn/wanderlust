-- 여행 계획 522번의 동행장 확인
SELECT
    plan_id,
    plan_writer,
    plan_title,
    plan_regdate
FROM travel_plan
WHERE plan_id = 522;

-- 여행 계획 522번의 참여자 확인
SELECT
    participant_id,
    travel_plan_id,
    user_id,
    status,
    joined_date
FROM travel_participants
WHERE travel_plan_id = 522;

-- UNION 쿼리 테스트 (동행장 포함한 전체 참여자)
(
    SELECT
        0 as participantId,
        t.plan_id as travelId,
        t.plan_writer as userId,
        t.plan_regdate as joinedDate,
        'HOST' as status,
        m.user_name as userName,
        m.nickname as nickname
    FROM travel_plan t
    LEFT JOIN member m ON t.plan_writer = m.user_id
    WHERE t.plan_id = 522
)
UNION ALL
(
    SELECT
        tp.participant_id as participantId,
        tp.travel_plan_id as travelId,
        tp.user_id as userId,
        tp.joined_date as joinedDate,
        tp.status as status,
        m.user_name as userName,
        m.nickname as nickname
    FROM travel_participants tp
    LEFT JOIN member m ON tp.user_id = m.user_id
    WHERE tp.travel_plan_id = 522
        AND tp.status = 'ACTIVE'
        AND tp.user_id NOT IN (
            SELECT plan_writer FROM travel_plan WHERE plan_id = 522
        )
)
ORDER BY status DESC, joinedDate ASC;