/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `class_students` (
  `class_id` bigint(20) NOT NULL COMMENT '학급 ID',
  `student_no` bigint(20) NOT NULL COMMENT '학생 식별번호',
  PRIMARY KEY (`class_id`,`student_no`),
  KEY `fk_cs_student` (`student_no`),
  CONSTRAINT `fk_cs_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cs_student` FOREIGN KEY (`student_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='학급별 학생 매핑 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `classes` (
  `class_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '학급 고유 ID',
  `teacher_no` bigint(20) NOT NULL COMMENT '담당 교사 식별번호',
  `class_name` varchar(100) NOT NULL COMMENT '학급 이름 (예: 1학년 1반, 심화반)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '생성 일시',
  PRIMARY KEY (`class_id`),
  KEY `fk_class_teacher` (`teacher_no`),
  CONSTRAINT `fk_class_teacher` FOREIGN KEY (`teacher_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='학급 관리 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_media_types` (
  `type_id` char(1) NOT NULL COMMENT '미디어 타입 코드 (I, Y)',
  `type_name` varchar(20) NOT NULL COMMENT '미디어 영문명 (image, youtube)',
  `description` varchar(50) NOT NULL COMMENT '지원 미디어 포맷 (이미지, 유튜브 동영상)',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='미디어 타입 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_question_types` (
  `type_id` char(1) NOT NULL COMMENT '문제 유형 코드 (M, S)',
  `type_name` varchar(20) NOT NULL COMMENT '유형 영문명 (MULTIPLE_CHOICE, SUBJECTIVE)',
  `description` varchar(50) NOT NULL COMMENT '유형 설명 (객관식, 주관식)',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제 유형 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_relation_types` (
  `relation_type_id` varchar(20) NOT NULL COMMENT '관계 유형 코드 (FRIEND, TEACHER_PUPIL, etc.)',
  `description` varchar(50) NOT NULL COMMENT '관계 설명',
  PRIMARY KEY (`relation_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 간 관계 유형 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_roles` (
  `role_id` char(1) NOT NULL COMMENT '권한 코드 (T, S, P)',
  `role_name` varchar(20) NOT NULL COMMENT '권한 영문명 (TEACHER, STUDENT, PARENT)',
  `description` varchar(50) NOT NULL COMMENT '권한 설명 (교사, 학생, 학부모)',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 권한 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_questions` (
  `exam_id` bigint(20) NOT NULL COMMENT '고사 ID',
  `question_id` bigint(20) NOT NULL COMMENT '문제 ID',
  `question_order` int(11) NOT NULL COMMENT '고사 내 문항 순서 (1, 2, 3...)',
  `score` int(11) DEFAULT 10 COMMENT '문항 배점',
  PRIMARY KEY (`exam_id`,`question_id`),
  KEY `fk_eq_question` (`question_id`),
  CONSTRAINT `fk_eq_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_eq_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='고사별 포함된 문제들';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_results` (
  `result_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '결과 리포트 ID',
  `exam_id` bigint(20) NOT NULL COMMENT '고사 ID',
  `student_no` bigint(20) NOT NULL COMMENT '응시 학생 식별번호',
  `total_score` int(11) DEFAULT 0 COMMENT '총점',
  `student_rank` int(11) DEFAULT NULL COMMENT '응시자 내 등수',
  `total_examinees` int(11) DEFAULT NULL COMMENT '해당 고사 총 응시자 수',
  `grade` enum('수','우','미','양','가') DEFAULT NULL COMMENT '성취 평가 등급 (수/우/미/양/가)',
  `ai_comment` text DEFAULT NULL COMMENT 'AI 분석 코멘트 (학부모/학생용)',
  `teacher_comment` text DEFAULT NULL COMMENT '담당 교사의 코멘트',
  `submitted_at` datetime DEFAULT current_timestamp() COMMENT '제출 및 리포트 생성 일시',
  PRIMARY KEY (`result_id`),
  KEY `fk_er_exam` (`exam_id`),
  KEY `fk_er_student` (`student_no`),
  CONSTRAINT `fk_er_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_er_student` FOREIGN KEY (`student_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='고사(모의고사) 최종 결과 및 분석 리포트';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `exams` (
  `exam_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '고사 고유 ID',
  `creator_no` bigint(20) NOT NULL COMMENT '생성자(선생님/학생) 식별번호',
  `class_id` bigint(20) DEFAULT NULL COMMENT '관련 학급 (NULL이면 전체 대상)',
  `exam_name` varchar(255) NOT NULL COMMENT '고사 명칭 (예: 1월 모의고사)',
  `start_time` datetime NOT NULL COMMENT '시험 시작 시간',
  `end_time` datetime NOT NULL COMMENT '시험 종료 시간',
  `location` varchar(100) DEFAULT NULL COMMENT '시험 장소 (온라인/오프라인 장소 등)',
  `is_auto_score` tinyint(1) DEFAULT 1 COMMENT '자동 채점 여부',
  `description` text DEFAULT NULL COMMENT '문제집 설명',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '생성 일시',
  PRIMARY KEY (`exam_id`),
  KEY `fk_exam_creator` (`creator_no`),
  KEY `fk_exam_class` (`class_id`),
  CONSTRAINT `fk_exam_class` FOREIGN KEY (`class_id`) REFERENCES `classes` (`class_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_exam_creator` FOREIGN KEY (`creator_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='고사(모의고사 등) 관리 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `groups` (
  `group_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '그룹 고유 식별자 (PK)',
  `creator_no` bigint(20) NOT NULL COMMENT '생성자(선생님/학생/학부모) 식별번호',
  `parent_group_id` bigint(20) DEFAULT NULL COMMENT '상위 그룹 식별자 (최대 3뎁스 계층 지원)',
  `depth` tinyint(4) DEFAULT 1 COMMENT '계층 깊이 (1~3)',
  `name` varchar(100) NOT NULL COMMENT '그룹 명칭 (예: 정보처리기사, 영어단어)',
  `description` text DEFAULT NULL COMMENT '그룹에 대한 상세 설명',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '그룹 생성 일시',
  PRIMARY KEY (`group_id`),
  KEY `fk_group_creator` (`creator_no`),
  KEY `fk_group_parent` (`parent_group_id`),
  CONSTRAINT `fk_group_creator` FOREIGN KEY (`creator_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
  CONSTRAINT `fk_group_parent` FOREIGN KEY (`parent_group_id`) REFERENCES `groups` (`group_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제 분류 그룹 계층형 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `media_attachments` (
  `media_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '미디어 고유 ID',
  `question_id` bigint(20) NOT NULL COMMENT '연결된 문제 ID',
  `media_type_id` char(1) NOT NULL COMMENT '리소스 타입 코드 (enm_media_types 참조)',
  `media_url` text NOT NULL COMMENT 'S3 이미지 경로 또는 YouTube URL 주소',
  `sort_order` int(11) DEFAULT 0 COMMENT '한 문제 내 미디어 노출 순서',
  PRIMARY KEY (`media_id`),
  KEY `fk_media_q` (`question_id`),
  KEY `fk_media_type` (`media_type_id`),
  CONSTRAINT `fk_media_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_media_type` FOREIGN KEY (`media_type_id`) REFERENCES `enm_media_types` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제 부가 미디어(이미지/영상) 관리';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ombudsman_reports` (
  `report_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '민원 고유 ID',
  `user_no` bigint(20) NOT NULL COMMENT '작성자 식별번호',
  `category` enum('OPINION','IMPROVEMENT','COMPLAINT') NOT NULL DEFAULT 'OPINION' COMMENT '민원 분류',
  `title` varchar(255) NOT NULL COMMENT '민원 제목',
  `content` text NOT NULL COMMENT '민원 상세 내용',
  `status` enum('PENDING','PROCESSED') DEFAULT 'PENDING' COMMENT '처리 상태',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '작성 일시',
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '수정 일시',
  PRIMARY KEY (`report_id`),
  KEY `fk_ombudsman_user` (`user_no`),
  CONSTRAINT `fk_ombudsman_user` FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 요구사항 및 피드백 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_options` (
  `option_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '보기 고유 식별자 (PK)',
  `question_id` bigint(20) NOT NULL COMMENT '연결된 문제 ID',
  `option_number` tinyint(4) NOT NULL COMMENT '보기 번호 (1, 2, 3...)',
  `content` text NOT NULL COMMENT '보기 내용',
  `is_answer` tinyint(1) DEFAULT 0 COMMENT '정답 여부',
  PRIMARY KEY (`option_id`),
  KEY `fk_option_q` (`question_id`),
  CONSTRAINT `fk_option_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=585 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='객관식 문제 보기 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_passages` (
  `passage_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '지문 고유 식별자 (PK)',
  `question_id` bigint(20) NOT NULL COMMENT '연결된 문제 ID (1:1 권장)',
  `content_md` text NOT NULL COMMENT 'Markdown 및 이미지(삽화)가 포함된 긴 지문',
  PRIMARY KEY (`passage_id`),
  UNIQUE KEY `question_id` (`question_id`),
  CONSTRAINT `fk_passage_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='영어 독해 등 문제 상단의 긴 마크다운 지문';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_reviews` (
  `review_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '리뷰 고유 ID',
  `question_id` bigint(20) NOT NULL COMMENT '문제 ID',
  `user_no` bigint(20) NOT NULL COMMENT '작성자 식별번호',
  `content` text NOT NULL COMMENT '리뷰 내용',
  `rating` tinyint(4) NOT NULL COMMENT '평점 (1~5)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '작성 일시',
  PRIMARY KEY (`review_id`),
  KEY `fk_review_q` (`question_id`),
  KEY `fk_review_u` (`user_no`),
  CONSTRAINT `fk_review_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_u` FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제에 대한 평점 및 의견 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `question_tags` (
  `question_id` bigint(20) NOT NULL COMMENT '문제 ID',
  `tag_id` bigint(20) NOT NULL COMMENT '태그 ID',
  PRIMARY KEY (`question_id`,`tag_id`),
  KEY `fk_qt_t` (`tag_id`),
  CONSTRAINT `fk_qt_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_qt_t` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제와 해시태그 간의 매핑 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `questions` (
  `question_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '문제 고유 식별자 (PK)',
  `p_question_id` bigint(20) DEFAULT NULL COMMENT '부모 문제 고유 식별자',
  `creator_no` bigint(20) NOT NULL COMMENT '생성자(선생님/학생) 식별번호',
  `group_id` bigint(20) DEFAULT NULL COMMENT '소속 그룹 ID (외래키)',
  `question_type_id` char(1) NOT NULL DEFAULT 'M' COMMENT '문제 유형 코드 (enm_question_types 참조)',
  `title` varchar(255) NOT NULL COMMENT '문제 제목 또는 요약',
  `question` text NOT NULL COMMENT '실제 질문 내용 (기존 content)',
  `content` text DEFAULT NULL COMMENT '긴 지문 (수학 수식, 영어 독해 등), Markdown 및 LaTeX 지원',
  `answer` text NOT NULL COMMENT '주관식 정답 (객관식일 경우 무시)',
  `explanation` text DEFAULT NULL COMMENT '정답에 대한 상세 해설',
  `hint` text DEFAULT NULL COMMENT '문제 풀이 힌트',
  `difficulty` tinyint(4) DEFAULT 1 COMMENT '난이도 (1:최하 ~ 5:최상)',
  `is_public` tinyint(1) DEFAULT 1 COMMENT '웹 공유 활성화 여부 (0:비공개, 1:공개)',
  `is_deleted` enum('Y','N','T') DEFAULT 'N' COMMENT '삭제 여부 (Y: 삭제, N: 디폴트, T: 휴지통)',
  `time_limit` int(11) DEFAULT 0 COMMENT '제한 시간 설정 (초 단위, 0이면 무제한)',
  `rating` tinyint(4) DEFAULT 0 COMMENT '사용자 평점 (1~5 별점)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '문제 등록 일시',
  PRIMARY KEY (`question_id`),
  KEY `fk_question_creator` (`creator_no`),
  KEY `fk_question_group` (`group_id`),
  KEY `fk_question_type` (`question_type_id`),
  KEY `fk_question_p_question` (`p_question_id`),
  CONSTRAINT `fk_question_creator` FOREIGN KEY (`creator_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
  CONSTRAINT `fk_question_group` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_question_type` FOREIGN KEY (`question_type_id`) REFERENCES `enm_question_types` (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제 은행 메인 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `solve_results` (
  `result_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '결과 고유 ID',
  `user_no` bigint(20) NOT NULL COMMENT '응시자(사용자) 식별번호',
  `question_id` bigint(20) NOT NULL COMMENT '문제 ID',
  `exam_id` bigint(20) DEFAULT NULL COMMENT '소속 고사 ID (일반 풀이 시 NULL)',
  `submitted_answer` text DEFAULT NULL COMMENT '제출한 답안 (오답 포함)',
  `correct_answer` text NOT NULL COMMENT '모범 답안',
  `is_correct` tinyint(1) NOT NULL COMMENT '정답 여부 (1: 정답, 0: 오답, -1:시간초과)',
  `time_taken` int(11) NOT NULL DEFAULT 0 COMMENT '경과 시간 (초 단위)',
  `solved_at` datetime DEFAULT current_timestamp() COMMENT '문제를 푼 시간',
  PRIMARY KEY (`result_id`),
  KEY `fk_result_user` (`user_no`),
  KEY `fk_result_q` (`question_id`),
  KEY `fk_result_exam` (`exam_id`),
  CONSTRAINT `fk_result_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_result_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_result_user` FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자별 문제 풀이 결과';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_logs` (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '학습 로그 고유 ID',
  `user_no` bigint(20) NOT NULL COMMENT '학습자(사용자) 식별번호',
  `question_id` bigint(20) NOT NULL COMMENT '학습한 문제 ID',
  `user_memo` text DEFAULT NULL COMMENT '사용자가 해당 문제에 남긴 개인적인 메모',
  `is_correct` tinyint(1) DEFAULT 0 COMMENT '최근 풀이 정답 여부',
  `try_count` int(11) DEFAULT 0 COMMENT '누적 풀이 횟수',
  `last_played_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT '최종 풀이 시간',
  `next_review_at` datetime DEFAULT NULL COMMENT '망각곡선 기반 다음 복습 권장 일시',
  PRIMARY KEY (`log_id`),
  KEY `fk_log_user` (`user_no`),
  KEY `fk_log_q` (`question_id`),
  CONSTRAINT `fk_log_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_log_user` FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=180 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='개인별 문제 풀이 기록 및 오답 노트';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `tag_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '태그 고유 ID',
  `tag_name` varchar(50) NOT NULL COMMENT '태그 키워드 (중복 불가)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '태그 생성 일시',
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `tag_name` (`tag_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='해시태그 마스터 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_comments` (
  `comment_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '주석 고유 ID',
  `author_no` bigint(20) NOT NULL COMMENT '작성자(선생님/학생) 식별번호',
  `target_user_no` bigint(20) DEFAULT NULL COMMENT '전송 대상(학생 등) 식별번호 (NULL이면 본인용 메모)',
  `question_id` bigint(20) NOT NULL COMMENT '문제 ID',
  `content` text NOT NULL COMMENT '주석 내용',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '작성 일시',
  PRIMARY KEY (`comment_id`),
  KEY `fk_comment_author` (`author_no`),
  KEY `fk_comment_target` (`target_user_no`),
  KEY `fk_comment_q` (`question_id`),
  CONSTRAINT `fk_comment_author` FOREIGN KEY (`author_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_target` FOREIGN KEY (`target_user_no`) REFERENCES `users` (`user_no`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자별 문제 주석 (교사가 학생에게 전송 가능)';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_messages` (
  `message_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '메시지 고유 ID',
  `sender_no` bigint(20) NOT NULL COMMENT '발신자 식별번호',
  `receiver_no` bigint(20) NOT NULL COMMENT '수신자 식별번호',
  `content` text NOT NULL COMMENT '메시지 내용',
  `is_read` enum('Y','N') DEFAULT 'N' COMMENT '읽음 여부 (Y: 읽음, N: 안읽음)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '발신 일시',
  PRIMARY KEY (`message_id`),
  KEY `fk_msg_sender` (`sender_no`),
  KEY `fk_msg_receiver` (`receiver_no`),
  CONSTRAINT `fk_msg_receiver` FOREIGN KEY (`receiver_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
  CONSTRAINT `fk_msg_sender` FOREIGN KEY (`sender_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 간 다이렉트 메시지 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `questionbook_question` (
  `book_id` bigint(20) NOT NULL,
  `question_id` bigint(20) NOT NULL,
  PRIMARY KEY (`book_id`,`question_id`),
  KEY `fk_uqbi_q` (`question_id`),
  CONSTRAINT `fk_uqbi_book` FOREIGN KEY (`book_id`) REFERENCES `questionbook` (`book_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_uqbi_q` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제집에 포함된 문제 매핑';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `questionbook` (
  `book_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '문제집 ID',
  `user_no` bigint(20) NOT NULL COMMENT '소유자 식별번호',
  `book_name` varchar(255) NOT NULL COMMENT '문제집 제목',
  `description` text DEFAULT NULL COMMENT '문제집 설명',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '생성 일시',
  PRIMARY KEY (`book_id`),
  KEY `fk_uqb_user` (`user_no`),
  CONSTRAINT `fk_uqb_user` FOREIGN KEY (`user_no`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자별 개인 문제집(북마크)';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_relations` (
  `relation_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '관계 고유 ID',
  `user_no_1` bigint(20) NOT NULL COMMENT '사용자 1 (주체)',
  `user_no_2` bigint(20) NOT NULL COMMENT '사용자 2 (대상)',
  `relation_type_id` varchar(20) NOT NULL COMMENT '관계 유형 (enm_relation_types 참조)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '관계 생성 일시',
  PRIMARY KEY (`relation_id`),
  KEY `fk_rel_user1` (`user_no_1`),
  KEY `fk_rel_user2` (`user_no_2`),
  KEY `fk_rel_type` (`relation_type_id`),
  CONSTRAINT `fk_rel_type` FOREIGN KEY (`relation_type_id`) REFERENCES `enm_relation_types` (`relation_type_id`),
  CONSTRAINT `fk_rel_user1` FOREIGN KEY (`user_no_1`) REFERENCES `users` (`user_no`) ON DELETE CASCADE,
  CONSTRAINT `fk_rel_user2` FOREIGN KEY (`user_no_2`) REFERENCES `users` (`user_no`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 간 관계 매핑 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_no` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '사용자 고유 식별번호 (PK)',
  `user_id` varchar(10) NOT NULL COMMENT '일반 접속용 로그인 아이디',
  `user_pw` varchar(255) NOT NULL COMMENT '일반 접속용 로그인 암호',
  `username` varchar(50) NOT NULL COMMENT '사용자 이름',
  `email` varchar(255) NOT NULL COMMENT '이메일 주소',
  `role_id` char(1) NOT NULL COMMENT '사용자 권한 코드 (enm_roles 참조)',
  `is_withdrawn` enum('Y','N') DEFAULT 'N' COMMENT '탈퇴 여부 (Y: 탈퇴, N: 활동중)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT '가입 일시',
  PRIMARY KEY (`user_no`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_user_role` (`role_id`),
  CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `enm_roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 정보 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;
