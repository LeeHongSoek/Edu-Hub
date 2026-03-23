/*
 Edu-Hub DB 설계 (Edu-Hub.sql)
*/

-- 0-1. 공통 기초 데이터 (ENUM 대체용): 사용자 권한
CREATE TABLE `enm_roles` (
    `role_id`       CHAR(1)       PRIMARY KEY COMMENT '권한 코드 (T, S, P)',
    `role_name`     VARCHAR(20)   NOT NULL    COMMENT '권한 영문명 (TEACHER, STUDENT, PARENT)',
    `description`   VARCHAR(50)   NOT NULL    COMMENT '권한 설명 (교사, 학생, 학부모)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 권한 기초 데이터';

-- 0-2. 공통 기초 데이터 (ENUM 대체용): 문제 유형
CREATE TABLE `enm_question_types` (
    `type_id`       CHAR(1)       PRIMARY KEY COMMENT '문제 유형 코드 (M, S)',
    `type_name`     VARCHAR(20)   NOT NULL    COMMENT '유형 영문명 (MULTIPLE_CHOICE, SUBJECTIVE)',
    `description`   VARCHAR(50)   NOT NULL    COMMENT '유형 설명 (객관식, 주관식)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='문제 유형 기초 데이터';

-- 0-3. 공통 기초 데이터 (ENUM 대체용): 미디어 타입
CREATE TABLE `enm_media_types` (
    `type_id`       CHAR(1)       PRIMARY KEY COMMENT '미디어 타입 코드 (I, Y)',
    `type_name`     VARCHAR(20)   NOT NULL    COMMENT '미디어 영문명 (image, youtube)',
    `description`   VARCHAR(50)   NOT NULL    COMMENT '지원 미디어 포맷 (이미지, 유튜브 동영상)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='미디어 타입 기초 데이터';

-- 1. 사용자 관리
CREATE TABLE `users` (
    `user_no`       BIGINT        PRIMARY KEY AUTO_INCREMENT COMMENT '사용자 고유 식별번호 (PK)',
    `user_id`       VARCHAR(10)   UNIQUE NOT NULL            COMMENT '일반 접속용 로그인 아이디',
    `username`      VARCHAR(50)   NOT NULL                   COMMENT '사용자 이름',
    `email`         VARCHAR(255)  UNIQUE NOT NULL            COMMENT '이메일 주소',
    `role_id`       CHAR(1)       NOT NULL                   COMMENT '사용자 권한 코드 (enm_roles 참조)',
    `is_withdrawn`  ENUM('Y', 'N') DEFAULT 'N'               COMMENT '탈퇴 여부 (Y: 탈퇴, N: 활동중)',
    `created_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP  COMMENT '가입 일시',

    CONSTRAINT `fk_user_role`
        FOREIGN KEY (`role_id`) REFERENCES `enm_roles` (`role_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 정보 테이블';

-- 2. 학급 관리 (교사용)
CREATE TABLE `classes` (
    `class_id`      BIGINT        PRIMARY KEY AUTO_INCREMENT COMMENT '학급 고유 ID',
    `teacher_no`    BIGINT        NOT NULL                   COMMENT '담당 교사 식별번호',
    `class_name`    VARCHAR(100)  NOT NULL                   COMMENT '학급 이름 (예: 1학년 1반, 심화반)',
    `created_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP  COMMENT '생성 일시',

    CONSTRAINT `fk_class_teacher`
        FOREIGN KEY (`teacher_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='학급 관리 테이블';

-- 3. 학급 소속 학생 매핑
CREATE TABLE `class_students` (
    `class_id`      BIGINT        NOT NULL                   COMMENT '학급 ID',
    `student_no`    BIGINT        NOT NULL                   COMMENT '학생 식별번호',

    PRIMARY KEY (`class_id`, `student_no`),

    CONSTRAINT `fk_cs_class`
        FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cs_student`
        FOREIGN KEY (`student_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='학급별 학생 매핑 테이블';

-- 4. 학부모-학생 매핑 (다자녀 지원)
CREATE TABLE `parent_students` (
    `parent_no`     BIGINT        NOT NULL                   COMMENT '학부모 식별번호',
    `student_no`    BIGINT        NOT NULL                   COMMENT '자녀(학생) 식별번호',

    PRIMARY KEY (`parent_no`, `student_no`),

    CONSTRAINT `fk_ps_parent`
        FOREIGN KEY (`parent_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_ps_student`
        FOREIGN KEY (`student_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='학부모와 자녀 매핑 테이블';

-- 5. 그룹 관리: 문제의 카테고리(과목, 프로젝트 등)를 분류
CREATE TABLE `groups` (
    `group_id`        BIGINT        PRIMARY KEY AUTO_INCREMENT  COMMENT '그룹 고유 식별자 (PK)',
    `creator_no`      BIGINT        NOT NULL                    COMMENT '생성자(선생님/학생/학부모) 식별번호',
    `parent_group_id` BIGINT        NULL                        COMMENT '상위 그룹 식별자 (최대 3뎁스 계층 지원)',
    `depth`           TINYINT       DEFAULT 1                   COMMENT '계층 깊이 (1~3)',
    `name`            VARCHAR(100)  NOT NULL                    COMMENT '그룹 명칭 (예: 정보처리기사, 영어단어)',
    `description`     TEXT                                      COMMENT '그룹에 대한 상세 설명',
    `created_at`      DATETIME      DEFAULT CURRENT_TIMESTAMP   COMMENT '그룹 생성 일시',

    CONSTRAINT `fk_group_creator`
        FOREIGN KEY (`creator_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_group_parent`
        FOREIGN KEY (`parent_group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='문제 분류 그룹 계층형 테이블';

-- 6. 문제 본체: 핵심 학습 데이터 저장
CREATE TABLE `questions` (
    `question_id`   BIGINT        PRIMARY KEY AUTO_INCREMENT  COMMENT '문제 고유 식별자 (PK)',
    `creator_no`    BIGINT        NOT NULL                    COMMENT '생성자(선생님/학생) 식별번호',
    `group_id`      BIGINT        NULL                        COMMENT '소속 그룹 ID (외래키)',
    `question_type_id` CHAR(1)    NOT NULL DEFAULT 'M'        COMMENT '문제 유형 코드 (enm_question_types 참조)',
    `title`         VARCHAR(255)  NOT NULL                    COMMENT '문제 제목 또는 요약',
    `question`      TEXT          NOT NULL                    COMMENT '실제 질문 내용 (기존 content)',
    `content`       TEXT          NULL                        COMMENT '긴 지문 (수학 수식, 영어 독해 등), Markdown 및 LaTeX 지원',
    `answer`        TEXT          NOT NULL                    COMMENT '주관식 정답 (객관식일 경우 무시)',
    `explanation`   TEXT                                      COMMENT '정답에 대한 상세 해설',
    `hint`          TEXT                                      COMMENT '문제 풀이 힌트',
    `difficulty`    TINYINT       DEFAULT 1                   COMMENT '난이도 (1:최하 ~ 5:최상)',
    `is_public`     BOOLEAN       DEFAULT FALSE               COMMENT '웹 공유 활성화 여부 (0:비공개, 1:공개)',
    `is_deleted`    ENUM('Y', 'N', 'T') DEFAULT 'N'           COMMENT '삭제 여부 (Y: 삭제, N: 디폴트, T: 휴지통)',
    `time_limit`    INT           DEFAULT 0                   COMMENT '제한 시간 설정 (초 단위, 0이면 무제한)',
    `created_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP   COMMENT '문제 등록 일시',

    CONSTRAINT `fk_question_creator`
        FOREIGN KEY (`creator_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_question_group`
        FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL,
    CONSTRAINT `fk_question_type`
        FOREIGN KEY (`question_type_id`) REFERENCES `enm_question_types` (`type_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='문제 은행 메인 테이블';

-- 7. 객관식 보기: 문제의 선택지 분리
CREATE TABLE `question_options` (
    `option_id`     BIGINT        PRIMARY KEY AUTO_INCREMENT  COMMENT '보기 고유 식별자 (PK)',
    `question_id`   BIGINT        NOT NULL                    COMMENT '연결된 문제 ID',
    `option_number` TINYINT       NOT NULL                    COMMENT '보기 번호 (1, 2, 3...)',
    `content`       TEXT          NOT NULL                    COMMENT '보기 내용',
    `is_answer`     BOOLEAN       DEFAULT FALSE               COMMENT '정답 여부',

    CONSTRAINT `fk_option_q`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='객관식 문제 보기 데이터';

-- 8. 미디어 리소스: 이미지 경로 및 유튜브 링크 관리
CREATE TABLE `media_attachments` (
    `media_id`      BIGINT      PRIMARY KEY AUTO_INCREMENT   COMMENT '미디어 고유 ID',
    `question_id`   BIGINT      NOT NULL                     COMMENT '연결된 문제 ID',
    `media_type_id` CHAR(1)     NOT NULL                     COMMENT '리소스 타입 코드 (enm_media_types 참조)',
    `media_url`     TEXT        NOT NULL                     COMMENT 'S3 이미지 경로 또는 YouTube URL 주소',
    `sort_order`    INT         DEFAULT 0                    COMMENT '한 문제 내 미디어 노출 순서',

    CONSTRAINT `fk_media_q`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_media_type`
        FOREIGN KEY (`media_type_id`) REFERENCES `enm_media_types` (`type_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='문제 부가 미디어(이미지/영상) 관리';

-- 9. 해시태그: 유연한 필터링을 위한 태그 사전
CREATE TABLE `tags` (
    `tag_id`     BIGINT       PRIMARY KEY AUTO_INCREMENT   COMMENT '태그 고유 ID',
    `tag_name`   VARCHAR(50)  UNIQUE NOT NULL              COMMENT '태그 키워드 (중복 불가)',
    `created_at` DATETIME     DEFAULT CURRENT_TIMESTAMP    COMMENT '태그 생성 일시'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='해시태그 마스터 테이블';

-- 10. 문제-태그 매핑: 다대다 관계 연결
CREATE TABLE `question_tags` (
    `question_id` BIGINT  NOT NULL  COMMENT '문제 ID',
    `tag_id`      BIGINT  NOT NULL  COMMENT '태그 ID',

    PRIMARY KEY (`question_id`, `tag_id`),

    CONSTRAINT `fk_qt_q`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_qt_t`
        FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='문제와 해시태그 간의 매핑 테이블';

-- 11. 고사 (이벤트) 관리
CREATE TABLE `exams` (
    `exam_id`       BIGINT        PRIMARY KEY AUTO_INCREMENT COMMENT '고사 고유 ID',
    `creator_no`    BIGINT        NOT NULL                   COMMENT '생성자(선생님/학생) 식별번호',
    `class_id`      BIGINT        NULL                       COMMENT '관련 학급 (NULL이면 전체 대상)',
    `exam_name`     VARCHAR(255)  NOT NULL                   COMMENT '고사 명칭 (예: 1월 모의고사)',
    `start_time`    DATETIME      NOT NULL                   COMMENT '시험 시작 시간',
    `end_time`      DATETIME      NOT NULL                   COMMENT '시험 종료 시간',
    `location`      VARCHAR(100)                             COMMENT '시험 장소 (온라인/오프라인 장소 등)',
    `is_auto_score` BOOLEAN       DEFAULT TRUE               COMMENT '자동 채점 여부',
    `created_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP  COMMENT '생성 일시',

    CONSTRAINT `fk_exam_creator`
        FOREIGN KEY (`creator_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_exam_class`
        FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='고사(모의고사 등) 관리 테이블';

-- 12. 고사별 문제 매핑
CREATE TABLE `exam_questions` (
    `exam_id`       BIGINT        NOT NULL                   COMMENT '고사 ID',
    `question_id`   BIGINT        NOT NULL                   COMMENT '문제 ID',
    `question_order` INT          NOT NULL                   COMMENT '고사 내 문항 순서 (1, 2, 3...)',
    `score`         INT           DEFAULT 10                 COMMENT '문항 배점',

    PRIMARY KEY (`exam_id`, `question_id`),

    CONSTRAINT `fk_eq_exam`
        FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_eq_question`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='고사별 포함된 문제들';

-- 13. 고사 결과 리포트 (학생별)
CREATE TABLE `exam_results` (
    `result_id`       BIGINT        PRIMARY KEY AUTO_INCREMENT COMMENT '결과 리포트 ID',
    `exam_id`         BIGINT        NOT NULL                   COMMENT '고사 ID',
    `student_no`      BIGINT        NOT NULL                   COMMENT '응시 학생 식별번호',
    `total_score`     INT           DEFAULT 0                  COMMENT '총점',
    `student_rank`    INT                                      COMMENT '응시자 내 등수',
    `total_examinees` INT                                      COMMENT '해당 고사 총 응시자 수',
    `grade`           ENUM('수', '우', '미', '양', '가')       COMMENT '성취 평가 등급 (수/우/미/양/가)',
    `ai_comment`      TEXT                                     COMMENT 'AI 분석 코멘트 (학부모/학생용)',
    `teacher_comment` TEXT                                     COMMENT '담당 교사의 코멘트',
    `submitted_at`    DATETIME      DEFAULT CURRENT_TIMESTAMP  COMMENT '제출 및 리포트 생성 일시',

    CONSTRAINT `fk_er_exam`
        FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_er_student`
        FOREIGN KEY (`student_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='고사(모의고사) 최종 결과 및 분석 리포트';

-- 14. 사용자별 주석 (문제에 대한 주석/메모)
CREATE TABLE `user_comments` (
    `comment_id`     BIGINT        PRIMARY KEY AUTO_INCREMENT COMMENT '주석 고유 ID',
    `author_no`      BIGINT        NOT NULL                   COMMENT '작성자(선생님/학생) 식별번호',
    `target_user_no` BIGINT        NULL                       COMMENT '전송 대상(학생 등) 식별번호 (NULL이면 본인용 메모)',
    `question_id`    BIGINT        NOT NULL                   COMMENT '문제 ID',
    `content`        TEXT          NOT NULL                   COMMENT '주석 내용',
    `created_at`     DATETIME      DEFAULT CURRENT_TIMESTAMP  COMMENT '작성 일시',

    CONSTRAINT `fk_comment_author`
        FOREIGN KEY (`author_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_comment_target`
        FOREIGN KEY (`target_user_no`) REFERENCES `users` (`user_no`) ON DELETE SET NULL,
    CONSTRAINT `fk_comment_q`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자별 문제 주석 (교사가 학생에게 전송 가능)';

-- 15. 학습 기록 및 복습 관리: 개인별 학습 최적화 데이터
CREATE TABLE `study_logs` (
    `log_id`         BIGINT    PRIMARY KEY AUTO_INCREMENT                            COMMENT '학습 로그 고유 ID',
    `user_no`        BIGINT    NOT NULL                                              COMMENT '학습자(사용자) 식별번호',
    `question_id`    BIGINT    NOT NULL                                              COMMENT '학습한 문제 ID',
    `user_memo`      TEXT                                                            COMMENT '사용자가 해당 문제에 남긴 개인적인 메모',
    `is_correct`     BOOLEAN   DEFAULT FALSE                                         COMMENT '최근 풀이 정답 여부',
    `try_count`      INT       DEFAULT 0                                             COMMENT '누적 풀이 횟수',
    `last_played_at` DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '최종 풀이 시간',
    `next_review_at` DATETIME                                                        COMMENT '망각곡선 기반 다음 복습 권장 일시',

    CONSTRAINT `fk_log_user`
        FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_log_q`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='개인별 문제 풀이 기록 및 오답 노트';

-- 16. 문제 풀이 결과 (고사에 속할 수도 있음)
CREATE TABLE `solve_results` (
    `result_id`        BIGINT     PRIMARY KEY AUTO_INCREMENT COMMENT '결과 고유 ID',
    `user_no`          BIGINT     NOT NULL                   COMMENT '응시자(사용자) 식별번호',
    `question_id`      BIGINT     NOT NULL                   COMMENT '문제 ID',
    `exam_id`          BIGINT     NULL                       COMMENT '소속 고사 ID (일반 풀이 시 NULL)',
    `submitted_answer` TEXT                                  COMMENT '제출한 답안 (오답 포함)',
    `is_correct`       BOOLEAN    NOT NULL                   COMMENT '정답 여부 (TRUE: 정답, FALSE: 오답)',
    `time_taken`       INT        NOT NULL DEFAULT 0         COMMENT '경과 시간 (초 단위)',
    `solved_at`        DATETIME   DEFAULT CURRENT_TIMESTAMP  COMMENT '문제를 푼 시간',

    CONSTRAINT `fk_result_user`
        FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
    CONSTRAINT `fk_result_q`
        FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
    CONSTRAINT `fk_result_exam`
        FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자별 문제 풀이 결과';