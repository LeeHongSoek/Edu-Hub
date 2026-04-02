/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for osx10.20 (arm64)
--
-- Host: localhost    Database: Edu-Hub
-- ------------------------------------------------------
-- Server version	11.7.2-MariaDB

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

--
-- Table structure for table `class_students`
--

DROP TABLE IF EXISTS `class_students`;
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

--
-- Dumping data for table `class_students`
--

LOCK TABLES `class_students` WRITE;
/*!40000 ALTER TABLE `class_students` DISABLE KEYS */;
INSERT INTO `class_students` VALUES
(1,2),
(4,2),
(8,2),
(11,2),
(15,2),
(19,2),
(5,4),
(8,4),
(12,4),
(15,4),
(20,4),
(6,5),
(12,5),
(16,5),
(21,5),
(2,10),
(5,10),
(9,10),
(12,10),
(17,10),
(19,10),
(2,11),
(6,11),
(10,11),
(13,11),
(15,11),
(20,11),
(3,12),
(7,12),
(11,12),
(16,12),
(19,12),
(2,15),
(7,15),
(10,15),
(14,15),
(17,15),
(20,15),
(3,18),
(8,18),
(11,18),
(14,18),
(18,18),
(21,18),
(3,20),
(5,20),
(9,20),
(13,20),
(16,20),
(18,20),
(4,22),
(6,22),
(9,22),
(13,22),
(17,22),
(21,22),
(4,23),
(7,23),
(10,23),
(14,23),
(18,23);
/*!40000 ALTER TABLE `class_students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='학급 관리 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES
(1,1,'파이썬 및 네트워크 기초반','2026-03-27 21:48:28'),
(2,6,'알고리즘 훈련 1반','2026-03-28 09:00:00'),
(3,7,'알고리즘 훈련 2반','2026-03-28 10:00:00'),
(4,13,'정보처리기사 실기 집중반','2026-03-28 11:00:00'),
(5,16,'프론트엔드 프로젝트반','2026-03-28 13:00:00'),
(6,19,'백엔드 API 설계반','2026-03-28 14:00:00'),
(7,24,'자료구조 마스터반','2026-03-28 15:00:00'),
(8,1,'네트워크 기초 A반','2026-03-29 09:00:00'),
(9,6,'네트워크 기초 B반','2026-03-29 10:30:00'),
(10,7,'데이터 분석 입문반','2026-03-29 13:00:00'),
(11,13,'SQL 실습반','2026-03-29 14:30:00'),
(12,16,'JavaScript 문법 완성반','2026-03-29 16:00:00'),
(13,19,'Python 문제풀이반','2026-03-30 09:00:00'),
(14,24,'영어 단어 암기반','2026-03-30 10:00:00'),
(15,1,'코딩 테스트 초급반','2026-03-30 11:30:00'),
(16,6,'코딩 테스트 중급반','2026-03-30 13:30:00'),
(17,7,'웹 서비스 기획반','2026-03-30 15:00:00'),
(18,13,'AI 활용 학습반','2026-03-31 09:00:00'),
(19,16,'정보보안 기초반','2026-03-31 10:30:00'),
(20,19,'운영체제 실습반','2026-03-31 13:00:00'),
(21,24,'컴퓨터 구조 핵심반','2026-03-31 15:00:00');
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enm_media_types`
--

DROP TABLE IF EXISTS `enm_media_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_media_types` (
  `type_id` char(1) NOT NULL COMMENT '미디어 타입 코드 (I, Y)',
  `type_name` varchar(20) NOT NULL COMMENT '미디어 영문명 (image, youtube)',
  `description` varchar(50) NOT NULL COMMENT '지원 미디어 포맷 (이미지, 유튜브 동영상)',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='미디어 타입 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enm_media_types`
--

LOCK TABLES `enm_media_types` WRITE;
/*!40000 ALTER TABLE `enm_media_types` DISABLE KEYS */;
INSERT INTO `enm_media_types` VALUES
('I','image','이미지'),
('Y','youtube','유튜브 동영상');
/*!40000 ALTER TABLE `enm_media_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enm_question_types`
--

DROP TABLE IF EXISTS `enm_question_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_question_types` (
  `type_id` char(1) NOT NULL COMMENT '문제 유형 코드 (M, S)',
  `type_name` varchar(20) NOT NULL COMMENT '유형 영문명 (MULTIPLE_CHOICE, SUBJECTIVE)',
  `description` varchar(50) NOT NULL COMMENT '유형 설명 (객관식, 주관식)',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='문제 유형 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enm_question_types`
--

LOCK TABLES `enm_question_types` WRITE;
/*!40000 ALTER TABLE `enm_question_types` DISABLE KEYS */;
INSERT INTO `enm_question_types` VALUES
('M','객관식','객관식'),
('S','주관식','주관식');
/*!40000 ALTER TABLE `enm_question_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enm_relation_types`
--

DROP TABLE IF EXISTS `enm_relation_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_relation_types` (
  `relation_type_id` varchar(20) NOT NULL COMMENT '관계 유형 코드 (FRIEND, TEACHER_PUPIL, etc.)',
  `description` varchar(50) NOT NULL COMMENT '관계 설명',
  PRIMARY KEY (`relation_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 간 관계 유형 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enm_relation_types`
--

LOCK TABLES `enm_relation_types` WRITE;
/*!40000 ALTER TABLE `enm_relation_types` DISABLE KEYS */;
INSERT INTO `enm_relation_types` VALUES
('CHILD_PARENT','부자 (학생-부모)'),
('FRIEND','친구 (학생-학생)'),
('PARENT_CHILD','부자 (부모-학생)'),
('PUPIL_TEACHER','사제 (학생-선생)'),
('TEACHER_PUPIL','사제 (선생-학생)');
/*!40000 ALTER TABLE `enm_relation_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enm_roles`
--

DROP TABLE IF EXISTS `enm_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `enm_roles` (
  `role_id` char(1) NOT NULL COMMENT '권한 코드 (T, S, P)',
  `role_name` varchar(20) NOT NULL COMMENT '권한 영문명 (TEACHER, STUDENT, PARENT)',
  `description` varchar(50) NOT NULL COMMENT '권한 설명 (교사, 학생, 학부모)',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 권한 기초 데이터';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enm_roles`
--

LOCK TABLES `enm_roles` WRITE;
/*!40000 ALTER TABLE `enm_roles` DISABLE KEYS */;
INSERT INTO `enm_roles` VALUES
('P','PARENT','학부모'),
('S','STUDENT','학생'),
('T','TEACHER','교사');
/*!40000 ALTER TABLE `enm_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_questions`
--

DROP TABLE IF EXISTS `exam_questions`;
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

--
-- Dumping data for table `exam_questions`
--

LOCK TABLES `exam_questions` WRITE;
/*!40000 ALTER TABLE `exam_questions` DISABLE KEYS */;
INSERT INTO `exam_questions` VALUES
(1,1,1,50),
(1,2,2,50),
(1,3,1,10),
(1,13,2,10),
(1,23,3,10),
(1,33,4,10),
(1,43,5,10),
(1,53,6,10),
(1,63,7,10),
(1,73,8,10),
(1,83,9,10),
(1,93,10,10),
(2,1,1,50),
(2,2,2,50),
(2,6,1,10),
(2,16,2,10),
(2,26,3,10),
(2,36,4,10),
(2,46,5,10),
(2,56,6,10),
(2,66,7,10),
(2,76,8,10),
(2,86,9,10),
(2,96,10,10),
(3,1,1,100),
(3,9,1,10),
(3,19,2,10),
(3,29,3,10),
(3,39,4,10),
(3,49,5,10),
(3,59,6,10),
(3,69,7,10),
(3,79,8,10),
(3,89,9,10),
(3,99,10,10),
(4,2,1,10),
(4,4,1,100),
(4,12,2,10),
(4,22,3,10),
(4,32,4,10),
(4,42,5,10),
(4,52,6,10),
(4,58,2,50),
(4,61,3,50),
(4,62,7,10),
(4,72,8,10),
(4,78,4,50),
(4,82,9,10),
(4,92,10,10),
(5,3,1,100),
(5,5,1,10),
(5,15,2,10),
(5,25,3,10),
(5,35,4,10),
(5,45,5,10),
(5,55,6,10),
(5,65,7,10),
(5,75,8,10),
(5,85,9,10),
(5,95,10,10),
(5,98,2,50),
(24,2,1,10),
(24,12,2,10),
(24,22,3,10),
(24,32,4,10),
(24,42,5,10),
(24,52,6,10),
(24,62,7,10),
(24,72,8,10),
(24,82,9,10),
(24,92,10,10),
(25,5,1,10),
(25,15,2,10),
(25,25,3,10),
(25,35,4,10),
(25,45,5,10),
(25,55,6,10),
(25,65,7,10),
(25,75,8,10),
(25,85,9,10),
(25,95,10,10),
(26,8,1,10),
(26,18,2,10),
(26,28,3,10),
(26,38,4,10),
(26,48,5,10),
(26,58,6,10),
(26,68,7,10),
(26,78,8,10),
(26,88,9,10),
(26,98,10,10),
(27,1,1,10),
(27,11,2,10),
(27,21,3,10),
(27,31,4,10),
(27,41,5,10),
(27,51,6,10),
(27,61,7,10),
(27,71,8,10),
(27,81,9,10),
(27,91,10,10),
(28,4,1,10),
(28,14,2,10),
(28,24,3,10),
(28,34,4,10),
(28,44,5,10),
(28,54,6,10),
(28,64,7,10),
(28,74,8,10),
(28,84,9,10),
(28,94,10,10),
(29,7,1,10),
(29,17,2,10),
(29,27,3,10),
(29,37,4,10),
(29,47,5,10),
(29,57,6,10),
(29,67,7,10),
(29,77,8,10),
(29,87,9,10),
(29,97,10,10),
(30,10,1,10),
(30,20,2,10),
(30,30,3,10),
(30,40,4,10),
(30,50,5,10),
(30,60,6,10),
(30,70,7,10),
(30,80,8,10),
(30,90,9,10),
(30,100,10,10),
(31,3,1,10),
(31,13,2,10),
(31,23,3,10),
(31,33,4,10),
(31,43,5,10),
(31,53,6,10),
(31,63,7,10),
(31,73,8,10),
(31,83,9,10),
(31,93,10,10),
(32,6,1,10),
(32,16,2,10),
(32,26,3,10),
(32,36,4,10),
(32,46,5,10),
(32,56,6,10),
(32,66,7,10),
(32,76,8,10),
(32,86,9,10),
(32,96,10,10),
(33,9,1,10),
(33,19,2,10),
(33,29,3,10),
(33,39,4,10),
(33,49,5,10),
(33,59,6,10),
(33,69,7,10),
(33,79,8,10),
(33,89,9,10),
(33,99,10,10),
(34,2,1,10),
(34,12,2,10),
(34,22,3,10),
(34,32,4,10),
(34,42,5,10),
(34,52,6,10),
(34,62,7,10),
(34,72,8,10),
(34,82,9,10),
(34,92,10,10),
(35,5,1,10),
(35,15,2,10),
(35,25,3,10),
(35,35,4,10),
(35,45,5,10),
(35,55,6,10),
(35,65,7,10),
(35,75,8,10),
(35,85,9,10),
(35,95,10,10),
(36,8,1,10),
(36,18,2,10),
(36,28,3,10),
(36,38,4,10),
(36,48,5,10),
(36,58,6,10),
(36,68,7,10),
(36,78,8,10),
(36,88,9,10),
(36,98,10,10),
(38,4,1,10),
(38,14,2,10),
(38,24,3,10),
(38,34,4,10),
(38,44,5,10),
(38,54,6,10),
(38,64,7,10),
(38,74,8,10),
(38,84,9,10),
(38,94,10,10),
(39,7,1,10),
(39,17,2,10),
(39,27,3,10),
(39,37,4,10),
(39,47,5,10),
(39,57,6,10),
(39,67,7,10),
(39,77,8,10),
(39,87,9,10),
(39,97,10,10),
(40,10,1,10),
(40,20,2,10),
(40,30,3,10),
(40,40,4,10),
(40,50,5,10),
(40,60,6,10),
(40,70,7,10),
(40,80,8,10),
(40,90,9,10),
(40,100,10,10),
(41,3,1,10),
(41,13,2,10),
(41,23,3,10),
(41,33,4,10),
(41,43,5,10),
(41,53,6,10),
(41,63,7,10),
(41,73,8,10),
(41,83,9,10),
(41,93,10,10),
(42,6,1,10),
(42,16,2,10),
(42,26,3,10),
(42,36,4,10),
(42,46,5,10),
(42,56,6,10),
(42,66,7,10),
(42,76,8,10),
(42,86,9,10),
(42,96,10,10),
(43,9,1,10),
(43,19,2,10),
(43,29,3,10),
(43,39,4,10),
(43,49,5,10),
(43,59,6,10),
(43,69,7,10),
(43,79,8,10),
(43,89,9,10),
(43,99,10,10),
(44,2,1,10),
(44,12,2,10),
(44,22,3,10),
(44,32,4,10),
(44,42,5,10),
(44,52,6,10),
(44,62,7,10),
(44,72,8,10),
(44,82,9,10),
(44,92,10,10),
(45,5,1,10),
(45,15,2,10),
(45,25,3,10),
(45,35,4,10),
(45,45,5,10),
(45,55,6,10),
(45,65,7,10),
(45,75,8,10),
(45,85,9,10),
(45,95,10,10),
(46,8,1,10),
(46,18,2,10),
(46,28,3,10),
(46,38,4,10),
(46,48,5,10),
(46,58,6,10),
(46,68,7,10),
(46,78,8,10),
(46,88,9,10),
(46,98,10,10),
(48,4,1,10),
(48,14,2,10),
(48,24,3,10),
(48,34,4,10),
(48,44,5,10),
(48,54,6,10),
(48,64,7,10),
(48,74,8,10),
(48,84,9,10),
(48,94,10,10),
(49,7,1,10),
(49,17,2,10),
(49,27,3,10),
(49,37,4,10),
(49,47,5,10),
(49,57,6,10),
(49,67,7,10),
(49,77,8,10),
(49,87,9,10),
(49,97,10,10),
(50,10,1,10),
(50,20,2,10),
(50,30,3,10),
(50,40,4,10),
(50,50,5,10),
(50,60,6,10),
(50,70,7,10),
(50,80,8,10),
(50,90,9,10),
(50,100,10,10),
(51,3,1,10),
(51,13,2,10),
(51,23,3,10),
(51,33,4,10),
(51,43,5,10),
(51,53,6,10),
(51,63,7,10),
(51,73,8,10),
(51,83,9,10),
(51,93,10,10),
(52,6,1,10),
(52,16,2,10),
(52,26,3,10),
(52,36,4,10),
(52,46,5,10),
(52,56,6,10),
(52,66,7,10),
(52,76,8,10),
(52,86,9,10),
(52,96,10,10),
(53,9,1,10),
(53,19,2,10),
(53,29,3,10),
(53,39,4,10),
(53,49,5,10),
(53,59,6,10),
(53,69,7,10),
(53,79,8,10),
(53,89,9,10),
(53,99,10,10),
(54,2,1,10),
(54,12,2,10),
(54,22,3,10),
(54,32,4,10),
(54,42,5,10),
(54,52,6,10),
(54,62,7,10),
(54,72,8,10),
(54,82,9,10),
(54,92,10,10),
(55,5,1,10),
(55,15,2,10),
(55,25,3,10),
(55,35,4,10),
(55,45,5,10),
(55,55,6,10),
(55,65,7,10),
(55,75,8,10),
(55,85,9,10),
(55,95,10,10),
(56,8,1,10),
(56,18,2,10),
(56,28,3,10),
(56,38,4,10),
(56,48,5,10),
(56,58,6,10),
(56,68,7,10),
(56,78,8,10),
(56,88,9,10),
(56,98,10,10),
(58,4,1,10),
(58,14,2,10),
(58,24,3,10),
(58,34,4,10),
(58,44,5,10),
(58,54,6,10),
(58,64,7,10),
(58,74,8,10),
(58,84,9,10),
(58,94,10,10),
(59,7,1,10),
(59,17,2,10),
(59,27,3,10),
(59,37,4,10),
(59,47,5,10),
(59,57,6,10),
(59,67,7,10),
(59,77,8,10),
(59,87,9,10),
(59,97,10,10),
(60,10,1,10),
(60,20,2,10),
(60,30,3,10),
(60,40,4,10),
(60,50,5,10),
(60,60,6,10),
(60,70,7,10),
(60,80,8,10),
(60,90,9,10),
(60,100,10,10);
/*!40000 ALTER TABLE `exam_questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_results`
--

DROP TABLE IF EXISTS `exam_results`;
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

--
-- Dumping data for table `exam_results`
--

LOCK TABLES `exam_results` WRITE;
/*!40000 ALTER TABLE `exam_results` DISABLE KEYS */;
INSERT INTO `exam_results` VALUES
(1,1,2,50,15,30,'미','[AI 분석] 네트워크 계층은 훌륭하나 디자인 패턴 복습 요망.','철수 학생, 디자인 패턴을 다시 봅시다.','2026-03-27 21:48:29'),
(2,2,4,100,1,1,'수','[AI 분석] 파이썬 자율 모의고사를 모두 맞췄습니다.',NULL,'2026-03-27 21:48:29'),
(3,4,2,150,1,1,'수','[AI 분석] 오답 노트 기반 복습 효과가 좋아져 자료구조와 통계 문제 정답률이 크게 올랐습니다.','철수 학생, 문제 풀이 속도보다 개념 정리가 훨씬 안정적으로 좋아졌어요.','2026-03-27 21:48:29'),
(4,5,2,50,1,1,'우','[AI 분석] 웹 기초 개념은 좋지만 용어 정의를 더 정확히 구분하면 좋겠습니다.','부모님과 함께 HTML/CSS 역할 차이를 다시 읽어 보세요.','2026-03-27 21:48:29');
/*!40000 ALTER TABLE `exam_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exams`
--

DROP TABLE IF EXISTS `exams`;
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

--
-- Dumping data for table `exams`
--

LOCK TABLES `exams` WRITE;
/*!40000 ALTER TABLE `exams` DISABLE KEYS */;
INSERT INTO `exams` VALUES
(1,1,1,'1월 정보처리 기초 모의고사 (교사 생성)','2026-01-20 14:00:00','2026-01-20 15:00:00','온라인 CBT',1,NULL,'2026-03-27 21:48:29'),
(2,2,2,'2월 정기 테스트 (교사 생성)','2026-02-15 10:00:00','2026-02-15 11:00:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(3,3,3,'전국 단위 공개 시험 (교사 생성)','2026-03-01 13:00:00','2026-03-01 13:30:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(4,4,4,'내 약점 파악 모의고사 (학생 자율)','2026-03-22 18:00:00','2026-03-22 19:00:00','내 책상',1,NULL,'2026-03-27 21:48:29'),
(5,5,5,'우리아이 주말 확인 점검 (학부모 생성)','2026-03-25 10:00:00','2026-03-25 11:00:00','자택 거실',1,NULL,'2026-03-27 21:48:29'),
(24,6,6,'4월 정기 점검 모의고사 (교사 생성)','2026-04-05 09:00:00','2026-04-05 10:30:00','제2 시험장',1,NULL,'2026-03-27 21:48:29'),
(25,7,7,'중간 실전 모의고사','2026-04-12 13:00:00','2026-04-12 14:30:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(26,8,8,'내 진도 점검 자율 시험','2026-04-18 19:00:00','2026-04-18 20:00:00','집',1,NULL,'2026-03-27 21:48:29'),
(27,1,9,'깊이 있는 알고리즘 챌린지','2026-04-20 20:00:00','2026-04-20 22:00:00','스터디룸',1,NULL,'2026-03-27 21:48:29'),
(28,2,10,'학부모와 함께 하는 복습 타임','2026-04-22 18:00:00','2026-04-22 19:30:00','자택',1,NULL,'2026-03-27 21:48:29'),
(29,3,11,'실전문제 풀이 마라톤','2026-04-27 14:00:00','2026-04-27 16:00:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(30,4,12,'AI 추천 오답 집중','2026-04-30 10:00:00','2026-04-30 11:00:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(31,5,13,'패턴/자료구조 경시대회','2026-05-03 14:00:00','2026-05-03 15:30:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(32,6,14,'리더십 문제풀이 챌린지','2026-05-05 20:00:00','2026-05-05 21:00:00','스터디룸',1,NULL,'2026-03-27 21:48:29'),
(33,7,15,'고사 대비 복습 세션','2026-05-08 10:00:00','2026-05-08 11:30:00','제3 시험장',1,NULL,'2026-03-27 21:48:29'),
(34,8,16,'비대면 알고리즘 묶음 모의고사','2026-05-10 13:00:00','2026-05-10 14:30:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(35,1,17,'정리와 정답 흐름 점검','2026-05-12 18:00:00','2026-05-12 19:15:00','청정 독서실',1,NULL,'2026-03-27 21:48:29'),
(36,2,18,'부모님과 함께하는 수학 연습','2026-05-14 16:00:00','2026-05-14 17:30:00','자택',1,NULL,'2026-03-27 21:48:29'),
(38,3,19,'수식과 그래프 실전','2026-05-18 20:00:00','2026-05-18 21:00:00','스터디룸',1,NULL,'2026-03-27 21:48:29'),
(39,4,20,'English+Algorithm 콤보','2026-05-20 11:00:00','2026-05-20 12:00:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(40,5,21,'HTML/CSS 데일리 퀴즈','2026-05-22 17:00:00','2026-05-22 17:40:00','제3 시험장',1,NULL,'2026-03-27 21:48:29'),
(41,6,1,'파이널 프로젝트 리허설','2026-05-24 19:30:00','2026-05-24 21:00:00','스튜디오',1,NULL,'2026-03-27 21:48:29'),
(42,7,2,'AI 추천 오답 분석회','2026-05-26 14:30:00','2026-05-26 16:00:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(43,8,3,'학부모 모의고사 회고','2026-05-28 10:00:00','2026-05-28 11:30:00','자택',1,NULL,'2026-03-27 21:48:29'),
(44,1,4,'모의고사 실전리뷰','2026-05-30 15:00:00','2026-05-30 16:30:00','제2 시험장',1,NULL,'2026-03-27 21:48:29'),
(45,2,5,'교사 추천 빠른 풀이','2026-06-01 09:00:00','2026-06-01 10:00:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(46,3,6,'개념 정리 서술형','2026-06-03 18:00:00','2026-06-03 19:30:00','스터디룸',1,NULL,'2026-03-27 21:48:29'),
(48,4,7,'보강 + 학부모 설명회','2026-06-07 18:30:00','2026-06-07 20:00:00','자택',1,NULL,'2026-03-27 21:48:29'),
(49,5,8,'마지막 정리 합동 세션','2026-06-09 18:00:00','2026-06-09 19:30:00','제3 시험장',1,NULL,'2026-03-27 21:48:29'),
(50,6,9,'5월 마무리 종합','2026-06-11 10:00:00','2026-06-11 11:30:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(51,7,10,'집중 대비 새벽 스터디','2026-06-13 05:30:00','2026-06-13 07:00:00','자택',1,NULL,'2026-03-27 21:48:29'),
(52,8,11,'기말 직전 모의고사','2026-06-15 13:00:00','2026-06-15 15:00:00','제3 시험장',1,NULL,'2026-03-27 21:48:29'),
(53,1,12,'특강+테스트 복합','2026-06-17 18:00:00','2026-06-17 19:30:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(54,2,13,'부모님과 함께하는 설명회','2026-06-19 10:00:00','2026-06-19 11:30:00','자택',1,NULL,'2026-03-27 21:48:29'),
(55,3,14,'문제해결 실전 모의','2026-06-21 14:00:00','2026-06-21 15:30:00','제1 시험장',1,NULL,'2026-03-27 21:48:29'),
(56,4,15,'개념 마무리 자율 테스트','2026-06-23 19:00:00','2026-06-23 20:00:00','스터디룸',1,NULL,'2026-03-27 21:48:29'),
(58,5,16,'문제집 순환 리뷰','2026-06-27 11:00:00','2026-06-27 12:30:00','온라인',1,NULL,'2026-03-27 21:48:29'),
(59,6,17,'가정 학습 점검','2026-06-29 16:00:00','2026-06-29 17:30:00','자택',1,NULL,'2026-03-27 21:48:29'),
(60,7,18,'기말 마무리 리허설','2026-07-01 09:00:00','2026-07-01 10:30:00','제3 시험장',1,NULL,'2026-03-27 21:48:29');
/*!40000 ALTER TABLE `exams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
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

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
INSERT INTO `groups` VALUES
(1,1,NULL,1,'컴퓨터 공학.','컴공 자료','2026-03-27 21:48:28'),
(2,1,1,2,'IT 자격증','IT 자격증','2026-03-27 21:48:28'),
(3,1,2,3,'정보처리기사 실기','2026 기출','2026-03-27 21:48:28'),
(4,2,NULL,1,'내 공부장','개인 자율 복습','2026-03-27 21:48:28'),
(5,2,4,2,'오답 노트','틀린 문제들만','2026-03-27 21:48:28'),
(6,2,5,3,'파이썬 기초','파이썬 복습','2026-03-27 21:48:28'),
(7,3,NULL,1,'아이 학습 관리','부모 정리 문제','2026-03-27 21:48:28'),
(8,3,7,2,'영어 단어장','영단어 모음','2026-03-27 21:48:28'),
(9,3,8,3,'중등 필수 영단어','알아야 할 단어들','2026-03-27 21:48:28'),
(10,1,NULL,1,'고등 과학','과학 탐구','2026-03-27 21:48:28'),
(11,1,10,2,'물리','물리 기초','2026-03-27 21:48:28'),
(12,1,NULL,1,'고등 수학','수학 기초','2026-03-27 21:48:28'),
(13,1,12,2,'미적분','미분과 적분','2026-03-27 21:48:28'),
(14,2,NULL,1,'알고리즘 훈련실','코딩 테스트 대비 문제 분류','2026-03-27 21:48:29'),
(15,2,14,2,'자료구조','스택, 큐, 트리, 그래프 중심','2026-03-27 21:48:29'),
(16,2,14,2,'정렬과 탐색','기본 정렬, 이진 탐색, 투 포인터','2026-03-27 21:48:29'),
(17,2,NULL,1,'데이터 분석 기초','통계와 데이터 해석','2026-03-27 21:48:29'),
(18,2,17,2,'통계 기본기','평균, 분산, 확률, 분포','2026-03-27 21:48:29'),
(19,2,NULL,1,'프론트엔드 실습장','HTML/CSS/JavaScript 학습용','2026-03-27 21:48:29'),
(20,2,19,2,'HTML & CSS','레이아웃과 스타일링','2026-03-27 21:48:29'),
(21,2,19,2,'JavaScript 기초','비동기와 DOM 제어','2026-03-27 21:48:29'),
(22,2,15,3,'스택과 큐','선형 자료구조 집중','2026-03-27 21:48:29'),
(23,2,18,3,'확률 분포','이산/연속 분포 입문','2026-03-27 21:48:29'),
(24,1,NULL,1,'수학','수학 전반 분류','2026-03-31 21:36:25'),
(25,2,NULL,1,'영어','영어 전반 분류','2026-03-31 21:36:25'),
(26,3,NULL,1,'과학','과학 전반 분류','2026-03-31 21:36:25'),
(27,4,NULL,1,'사회','사회 전반 분류','2026-03-31 21:36:25'),
(28,5,NULL,1,'코딩','코딩 전반 분류','2026-03-31 21:36:25'),
(29,6,NULL,1,'데이터','데이터 전반 분류','2026-03-31 21:36:25'),
(30,7,NULL,1,'국어','국어 전반 분류','2026-03-31 21:36:25'),
(31,8,NULL,1,'역사','역사 전반 분류','2026-03-31 21:36:25'),
(32,9,NULL,1,'경제','경제 전반 분류','2026-03-31 21:36:25'),
(33,10,NULL,1,'예체능','예체능 전반 분류','2026-03-31 21:36:25'),
(34,11,24,2,'대수','수학 > 대수 세부 주제','2026-03-31 21:36:25'),
(35,12,24,2,'기하','수학 > 기하 세부 주제','2026-03-31 21:36:25'),
(36,13,25,2,'문법','영어 > 문법 세부 주제','2026-03-31 21:36:25'),
(37,14,25,2,'독해','영어 > 독해 세부 주제','2026-03-31 21:36:25'),
(38,15,26,2,'물리','과학 > 물리 세부 주제','2026-03-31 21:36:25'),
(39,16,26,2,'화학','과학 > 화학 세부 주제','2026-03-31 21:36:25'),
(40,17,27,2,'지리','사회 > 지리 세부 주제','2026-03-31 21:36:25'),
(41,18,27,2,'윤리','사회 > 윤리 세부 주제','2026-03-31 21:36:25'),
(42,19,28,2,'알고리즘','코딩 > 알고리즘 세부 주제','2026-03-31 21:36:25'),
(43,20,28,2,'웹개발','코딩 > 웹개발 세부 주제','2026-03-31 21:36:25'),
(44,21,29,2,'통계','데이터 > 통계 세부 주제','2026-03-31 21:36:25'),
(45,22,29,2,'머신러닝','데이터 > 머신러닝 세부 주제','2026-03-31 21:36:25'),
(46,23,30,2,'문학','국어 > 문학 세부 주제','2026-03-31 21:36:25'),
(47,24,30,2,'비문학','국어 > 비문학 세부 주제','2026-03-31 21:36:25'),
(48,25,31,2,'한국사','역사 > 한국사 세부 주제','2026-03-31 21:36:25'),
(49,1,31,2,'세계사','역사 > 세계사 세부 주제','2026-03-31 21:36:25'),
(50,2,32,2,'미시경제','경제 > 미시경제 세부 주제','2026-03-31 21:36:25'),
(51,3,32,2,'거시경제','경제 > 거시경제 세부 주제','2026-03-31 21:36:25'),
(52,4,33,2,'미술','예체능 > 미술 세부 주제','2026-03-31 21:36:25'),
(53,5,33,2,'음악','예체능 > 음악 세부 주제','2026-03-31 21:36:25');
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `media_attachments`
--

DROP TABLE IF EXISTS `media_attachments`;
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

--
-- Dumping data for table `media_attachments`
--

LOCK TABLES `media_attachments` WRITE;
/*!40000 ALTER TABLE `media_attachments` DISABLE KEYS */;
INSERT INTO `media_attachments` VALUES
(1,1,'I','https://s3.example.com/edu-hub/osi_7_layer.png',1),
(2,1,'Y','https://www.youtube.com/watch?v=example1',2),
(3,2,'I','https://s3.example.com/edu-hub/singleton_diagram.png',1),
(4,4,'Y','https://www.youtube.com/watch?v=example2',1),
(5,61,'I','https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=800&q=80',1),
(6,78,'I','https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=80',1),
(7,98,'Y','https://www.youtube.com/watch?v=PkZNo7MFNFg',1);
/*!40000 ALTER TABLE `media_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ombudsman_reports`
--

DROP TABLE IF EXISTS `ombudsman_reports`;
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

--
-- Dumping data for table `ombudsman_reports`
--

LOCK TABLES `ombudsman_reports` WRITE;
/*!40000 ALTER TABLE `ombudsman_reports` DISABLE KEYS */;
INSERT INTO `ombudsman_reports` VALUES
(1,1,'OPINION','사이트가 너무 예뻐요!','디자인이 정말 깔끔하고 마음에 듭니다. 특히 다크모드가 인상적이네요.','PROCESSED','2026-03-27 09:12:00','2026-03-27 10:05:00'),
(2,1,'IMPROVEMENT','퀴즈 풀이 시 효과음 추가 제안','문제를 맞혔을 때나 틀렸을 때 간단한 효과음이 나오면 더 재미있을 것 같습니다.','PENDING','2026-03-27 10:24:00','2026-03-27 10:24:00'),
(3,1,'COMPLAINT','모바일에서 버튼이 조금 작아요','아이폰 SE 같은 작은 화면에서는 몇몇 버튼을 누르기가 조금 힘듭니다.','PENDING','2026-03-27 11:05:00','2026-03-27 11:05:00'),
(4,2,'OPINION','복습 흐름이 한눈에 보여서 좋아요','문제집과 오답 흐름이 자연스럽게 이어져서 오늘 무엇을 해야 할지 바로 보입니다.','PROCESSED','2026-03-27 11:42:00','2026-03-27 12:10:00'),
(5,2,'IMPROVEMENT','오답노트에 중요도 표시가 있으면 좋겠어요','틀린 문제 중에서도 다시 꼭 봐야 하는 문제를 별표처럼 표시하고 싶습니다.','PENDING','2026-03-27 12:30:00','2026-03-27 12:30:00'),
(6,2,'COMPLAINT','문제집이 많아지면 찾기가 어려워요','문제집 수가 늘어나니 스크롤이 길어져서 원하는 항목을 다시 찾는 데 시간이 걸립니다.','PENDING','2026-03-27 13:18:00','2026-03-27 13:18:00'),
(7,3,'OPINION','부모 입장에서 학습 현황이 잘 보여요','아이 진도와 최근 활동이 정리돼 있어서 대화할 때 참고하기 편합니다.','PROCESSED','2026-03-27 13:44:00','2026-03-27 14:06:00'),
(8,3,'IMPROVEMENT','주간 요약을 PDF로 저장하고 싶어요','가정에서 보관하려고 주간 학습 요약을 PDF로 내려받는 기능이 있었으면 합니다.','PENDING','2026-03-27 14:27:00','2026-03-27 14:27:00'),
(9,3,'COMPLAINT','알림 문구가 조금 딱딱해 보여요','학부모 화면의 일부 안내 문구가 너무 관리자용 느낌이라 조금 부드러우면 좋겠습니다.','PENDING','2026-03-27 15:03:00','2026-03-27 15:03:00'),
(10,4,'OPINION','문제 풀이 화면 집중감이 좋아요','주변 요소가 과하지 않아서 문제 푸는 데 몰입하기 좋았습니다.','PROCESSED','2026-03-27 15:30:00','2026-03-27 16:10:00'),
(11,4,'IMPROVEMENT','문항 사이 이동 애니메이션이 있으면 좋겠어요','다음 문제로 넘어갈 때 화면이 조금 더 부드럽게 넘어가면 학습 흐름이 좋아질 것 같습니다.','PENDING','2026-03-27 16:18:00','2026-03-27 16:18:00'),
(12,4,'COMPLAINT','일부 버튼 색 대비가 약해요','어두운 배경에서 회색 계열 버튼은 상태 차이가 잘 안 보일 때가 있습니다.','PENDING','2026-03-27 17:02:00','2026-03-27 17:02:00'),
(13,1,'OPINION','선생님 대시보드가 정돈돼 보여요','학생 관리와 문제 관리가 같은 흐름 안에 있어서 작업 전환이 편합니다.','PROCESSED','2026-03-27 17:26:00','2026-03-27 17:55:00'),
(14,1,'IMPROVEMENT','옴브즈먼 목록에도 검색이 있으면 좋겠어요','예전에 남긴 의견을 찾으려면 스크롤을 많이 해야 해서 검색이 있으면 편할 것 같습니다.','PROCESSED','2026-03-27 18:07:00','2026-03-28 09:10:00'),
(15,1,'COMPLAINT','긴 제목은 한 줄에서 잘려 보여요','제목이 길 때 줄바꿈 규칙이 일정하지 않아 가끔 정보가 덜 보입니다.','PENDING','2026-03-27 18:40:00','2026-03-27 18:40:00'),
(16,2,'OPINION','영단어 문제집 구성이 실용적이에요','짧은 시간에 복습하기 좋은 분량으로 나뉘어 있어서 통학 중에도 보기 좋습니다.','PROCESSED','2026-03-27 19:05:00','2026-03-27 19:40:00'),
(17,2,'IMPROVEMENT','최근 푼 문제만 따로 모아보고 싶어요','오늘 푼 문제를 바로 다시 볼 수 있는 임시 묶음이 있으면 복습에 도움이 됩니다.','PENDING','2026-03-27 19:28:00','2026-03-27 19:28:00'),
(18,2,'COMPLAINT','작은 화면에서 카드 간격이 조금 넓어요','휴대폰에서는 카드 사이 여백이 커서 한 화면에 보이는 정보가 적게 느껴집니다.','PROCESSED','2026-03-27 20:02:00','2026-03-28 08:20:00'),
(19,3,'OPINION','과한 장식 없이 안정적인 화면이라 좋습니다','부모가 보기에도 복잡하지 않고 필요한 정보가 차분하게 정리되어 있습니다.','PROCESSED','2026-03-27 20:21:00','2026-03-27 20:58:00'),
(20,3,'IMPROVEMENT','출석이나 학습시간도 같이 보이면 좋겠어요','점수 외에 학습 시간 변화까지 함께 보이면 아이 상태를 이해하기 더 쉬울 것 같습니다.','PENDING','2026-03-27 20:47:00','2026-03-27 20:47:00'),
(21,3,'COMPLAINT','날짜 표기 형식이 화면마다 조금 달라요','어떤 곳은 점 표기이고 어떤 곳은 슬래시 표기라서 한 가지 규칙으로 맞춰지면 좋겠습니다.','PENDING','2026-03-27 21:10:00','2026-03-27 21:10:00'),
(22,4,'OPINION','다크 톤인데 답답하지 않아서 마음에 듭니다','배경이 어두워도 텍스트 대비가 안정적이라 오래 봐도 피로감이 적었습니다.','PROCESSED','2026-03-27 21:36:00','2026-03-27 22:01:00'),
(23,4,'IMPROVEMENT','버튼 hover 상태를 조금 더 분명히 해주세요','마우스를 올렸을 때 클릭 가능한 요소라는 느낌이 조금 더 강하면 좋겠습니다.','PENDING','2026-03-27 22:18:00','2026-03-27 22:18:00'),
(24,4,'COMPLAINT','모달 안쪽 스크롤이 한 번에 안 잡힐 때가 있어요','트랙패드로 천천히 내리면 배경과 모달 스크롤이 번갈아 반응하는 느낌이 있습니다.','PENDING','2026-03-27 22:54:00','2026-03-27 22:54:00'),
(25,1,'OPINION','새 제보하기 버튼 위치가 잘 보여요','목록을 보다가 바로 의견을 남기기 좋은 위치에 있어서 행동 유도가 자연스럽습니다.','PROCESSED','2026-03-28 08:15:00','2026-03-28 08:44:00'),
(26,1,'IMPROVEMENT','처리 상태별 색 구분이 있으면 좋겠습니다','PENDING과 PROCESSED를 배지 색으로 구분하면 목록을 훨씬 빨리 읽을 수 있을 것 같아요.','PENDING','2026-03-28 08:52:00','2026-03-28 08:52:00'),
(27,2,'COMPLAINT','입력창 placeholder가 조금 흐립니다','현재도 예쁘지만 밝기가 조금 더 올라가면 모바일에서 읽기 쉬울 것 같습니다.','PENDING','2026-03-28 09:06:00','2026-03-28 09:06:00'),
(28,2,'OPINION','아이콘이 직관적이라 배우기 쉬워요','처음 들어온 사람도 수정과 삭제 동작을 거의 바로 이해할 수 있었습니다.','PROCESSED','2026-03-28 09:22:00','2026-03-28 09:40:00'),
(29,3,'IMPROVEMENT','목록을 페이지로 나눠서 보면 더 편할 것 같아요','의견이 쌓이면 한 번에 다 보기보다 적당히 나뉘어 보이는 편이 더 읽기 편합니다.','PROCESSED','2026-03-28 09:35:00','2026-03-28 10:15:00'),
(30,4,'COMPLAINT','검색창 포커스 표시가 조금 더 선명했으면 해요','현재는 포커스 여부가 은은해서 키보드로 이동할 때 활성 상태를 놓칠 수 있습니다.','PENDING','2026-03-28 10:02:00','2026-03-28 10:02:00');
/*!40000 ALTER TABLE `ombudsman_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_options`
--

DROP TABLE IF EXISTS `question_options`;
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

--
-- Dumping data for table `question_options`
--

LOCK TABLES `question_options` WRITE;
/*!40000 ALTER TABLE `question_options` DISABLE KEYS */;
INSERT INTO `question_options` VALUES
(1,2,1,'Singleton',0),
(2,2,2,'Factory Method',0),
(3,2,3,'Abstract Factory',0),
(4,2,4,'Builder',0),
(5,2,5,'Observer',1),
(6,3,1,'성취하다',0),
(7,3,2,'버리다, 포기하다',1),
(8,3,3,'획득하다',0),
(9,3,4,'유지하다',0),
(10,5,1,'변화 없음',0),
(11,5,2,'절반(1/2)으로 감소한다',1),
(12,5,3,'2배로 증가한다',0),
(13,5,4,'제곱에 비례하여 증가한다',0),
(14,5,5,'알 수 없다',0),
(15,6,1,'1',1),
(16,6,2,'$\\frac{\\pi}{2}$',0),
(17,6,3,'$\\pi$',0),
(18,6,4,'0',0),
(19,6,5,'$-1$',0),
(20,7,1,'자연을 보존하려면 인간의 접근을 전면 차단해야 한다.',0),
(21,7,2,'원주민의 삶의 터전을 새로운 구역으로 이주시켜야 한다.',0),
(22,7,3,'원주민의 관리가 생물 다양성 유지에 더 효과적일 수 있다.',1),
(23,7,4,'자연 보존 구역의 경제적 가치는 계속 하락하고 있다.',0),
(24,7,5,'최근 연구는 전통적 방식의 한계를 지적하고 있다.',0),
(25,8,1,'문서의 구조와 의미를 더 명확히 전달한다.',1),
(26,8,2,'폰트 색상과 크기를 직접 지정한다.',0),
(27,8,3,'자바스크립트 이벤트를 자동 실행한다.',0),
(28,8,4,'이미지 용량을 압축하는 기능을 제공한다.',0),
(29,9,1,'요소 내부의 글자 간격을 뜻한다.',0),
(30,9,2,'요소의 바깥쪽 여백을 뜻한다.',1),
(31,9,3,'테두리의 두께를 뜻한다.',0),
(32,9,4,'배경 이미지의 반복 횟수를 뜻한다.',0),
(33,10,1,'slice',0),
(34,10,2,'map',0),
(35,10,3,'splice',1),
(36,10,4,'filter',0),
(37,11,1,'함수 정의를 강제로 생략해야만 사용할 수 있다.',0),
(38,11,2,'문자열 전용 문법이라 숫자에는 쓸 수 없다.',0),
(39,11,3,'리스트의 길이를 자동으로 고정시킨다.',0),
(40,11,4,'반복과 조건을 한 줄로 표현해 새 리스트를 만든다.',1),
(41,12,1,'커밋 기준점을 다시 옮겨 히스토리를 정리한다.',1),
(42,12,2,'원격 저장소와 자동으로 동기화만 수행한다.',0),
(43,12,3,'태그와 브랜치를 하나로 합친다.',0),
(44,12,4,'충돌이 나면 항상 커밋을 모두 삭제한다.',0),
(45,13,1,'모든 INSERT를 무조건 빠르게 만든다.',0),
(46,13,2,'데이터 조회 속도를 높이는 데 도움을 준다.',1),
(47,13,3,'외래키 제약을 자동으로 제거한다.',0),
(48,13,4,'테이블 컬럼 수를 늘려 준다.',0),
(49,14,1,'인증이 성공해 리소스가 생성됐다.',0),
(50,14,2,'서버 내부 오류가 발생했다.',0),
(51,14,3,'요청한 리소스를 찾을 수 없다.',1),
(52,14,4,'요청이 정상적으로 처리됐다.',0),
(53,15,1,'독립된 주소 공간을 반드시 가진다.',0),
(54,15,2,'하드웨어 장치 자체를 의미한다.',0),
(55,15,3,'파일 시스템만 다루는 개념이다.',0),
(56,15,4,'프로세스 내부에서 실행되는 흐름 단위이다.',1),
(57,16,1,'연결 설정 없이 빠르게 전송할 수 있다.',1),
(58,16,2,'항상 순서 보장을 최우선으로 한다.',0),
(59,16,3,'반드시 세 단계 핸드셰이크를 수행한다.',0),
(60,16,4,'패킷 손실이 절대 일어나지 않는다.',0),
(61,17,1,'나중에 들어온 데이터가 먼저 나간다.',0),
(62,17,2,'먼저 들어온 데이터가 먼저 나간다.',1),
(63,17,3,'항상 무작위 순서로 나간다.',0),
(64,17,4,'정렬된 값만 저장할 수 있다.',0),
(65,18,1,'입력이 늘어도 시간이 전혀 증가하지 않는다.',0),
(66,18,2,'항상 제곱에 비례해 증가한다.',0),
(67,18,3,'입력 크기에 비례해 처리량이 증가한다.',1),
(68,18,4,'입력이 커질수록 오히려 시간이 줄어든다.',0),
(69,19,1,'모든 테이블을 하나로 합친다.',0),
(70,19,2,'컬럼 수를 무조건 늘린다.',0),
(71,19,3,'조회 속도만 최우선으로 최적화한다.',0),
(72,19,4,'데이터 중복과 이상 현상을 줄인다.',1),
(73,20,1,'리소스를 URI로 표현하고 메서드로 행위를 구분한다.',1),
(74,20,2,'모든 요청을 POST 하나로만 처리한다.',0),
(75,20,3,'상태 코드 사용을 금지한다.',0),
(76,20,4,'클라이언트와 서버가 반드시 같은 화면을 공유한다.',0),
(77,21,1,'사용자 이름과 비밀번호를 확인한다.',0),
(78,21,2,'사용자가 어떤 권한을 가졌는지 확인한다.',1),
(79,21,3,'브라우저 캐시를 비운다.',0),
(80,21,4,'네트워크 속도를 측정한다.',0),
(81,22,1,'부모가 항상 강제로 고정해 주는 값이다.',0),
(82,22,2,'CSS 스타일 파일만 의미한다.',0),
(83,22,3,'컴포넌트 내부에서 관리되는 변경 가능한 값이다.',1),
(84,22,4,'서버에서만 변경되는 정적 값이다.',0),
(85,23,1,'모든 함수를 동기식으로 강제 변환한다.',0),
(86,23,2,'변수 선언 키워드를 대체한다.',0),
(87,23,3,'DOM 요소를 삭제하는 명령이다.',0),
(88,23,4,'Promise의 결과를 기다리는 표현이다.',1),
(89,24,1,'바로 앞 패턴이 1회 이상 반복된다.',1),
(90,24,2,'문자열의 시작을 의미한다.',0),
(91,24,3,'앞 패턴이 반드시 0회만 나온다.',0),
(92,24,4,'문자 하나를 무조건 제외한다.',0),
(93,25,1,'오직 영어 알파벳만 표현할 수 있다.',0),
(94,25,2,'가변 길이 인코딩이며 ASCII와 호환된다.',1),
(95,25,3,'항상 1바이트만 사용한다.',0),
(96,25,4,'이미지 전용 파일 형식이다.',0),
(97,26,1,'모든 객체를 전역 변수로 공유한다.',0),
(98,26,2,'상속을 금지하고 클래스 수를 줄인다.',0),
(99,26,3,'객체 생성 책임을 분리해 유연성을 높인다.',1),
(100,26,4,'UI 색상만 자동으로 바꾸는 패턴이다.',0),
(101,27,1,'부모 클래스의 메서드를 무조건 숨긴다.',0),
(102,27,2,'클래스 선언을 전혀 사용하지 않는다.',0),
(103,27,3,'함수형 프로그래밍만 지원한다.',0),
(104,27,4,'객체를 포함 관계로 조합하는 방식이다.',1),
(105,28,1,'작은 기능 단위를 독립적으로 검증한다.',1),
(106,28,2,'운영 서버에서만 실행할 수 있다.',0),
(107,28,3,'배포 후에만 작성할 수 있다.',0),
(108,28,4,'브라우저 화면만 확인하면 충분하다.',0),
(109,29,1,'서버, 클라이언트, 네트워크',0),
(110,29,2,'소유자, 그룹, 기타 사용자',1),
(111,29,3,'읽기, 쓰기, 삭제',0),
(112,29,4,'프로세스, 스레드, 세션',0),
(113,30,1,'모든 커밋 메시지를 삭제한다.',0),
(114,30,2,'원격 저장소 접근을 금지한다.',0),
(115,30,3,'작업을 분리하고 병합 흐름을 관리한다.',1),
(116,30,4,'코드 포맷만 자동으로 수정한다.',0),
(117,31,1,'오직 바이너리 데이터만 저장한다.',0),
(118,31,2,'브라우저에서 실행되는 자바스크립트 코드이다.',0),
(119,31,3,'이미지 파일을 압축하는 알고리즘이다.',0),
(120,31,4,'가볍고 사람이 읽기 쉬운 데이터 교환 포맷이다.',1),
(121,32,1,'주축 방향의 아이템 정렬을 담당한다.',1),
(122,32,2,'폰트 종류를 바꾸는 역할을 한다.',0),
(123,32,3,'이미지의 해상도를 자동 조정한다.',0),
(124,32,4,'서버 응답 코드를 바꾸는 역할을 한다.',0),
(125,33,1,'이벤트가 부모에서 자식으로만 전파된다.',0),
(126,33,2,'이벤트가 자식 요소에서 부모 요소로 전파된다.',1),
(127,33,3,'이벤트가 브라우저를 절대 통과하지 않는다.',0),
(128,33,4,'이벤트는 항상 서버로 먼저 전송된다.',0),
(129,34,1,'브라우저를 닫아도 영구히 유지된다.',0),
(130,34,2,'서버 데이터베이스와 완전히 동일하다.',0),
(131,34,3,'탭 세션이 끝나면 일반적으로 사라진다.',1),
(132,34,4,'이미지 캐시만 저장할 수 있다.',0),
(133,35,1,'테이블 전체를 항상 순차로 다 읽는다.',0),
(134,35,2,'정렬을 무조건 삭제한다.',0),
(135,35,3,'컬럼 타입을 자동으로 변경한다.',0),
(136,35,4,'인덱스를 이용해 목표 위치를 빠르게 찾는다.',1),
(137,36,1,'내부 구현을 숨기고 필요한 기능만 제공한다.',1),
(138,36,2,'모든 필드를 무조건 public으로 공개한다.',0),
(139,36,3,'함수 호출을 금지한다.',0),
(140,36,4,'클래스보다 HTML이 더 중요하다는 뜻이다.',0),
(141,37,1,'양쪽 테이블이 모두 비어야 결과가 나온다.',0),
(142,37,2,'왼쪽 테이블의 행을 모두 유지한다.',1),
(143,37,3,'조건에 맞지 않아도 오른쪽만 전부 남긴다.',0),
(144,37,4,'조인 조건을 작성할 수 없다.',0),
(145,38,1,'브라우저 화면을 자동으로 디자인한다.',0),
(146,38,2,'서버의 CPU 성능을 무제한으로 높인다.',0),
(147,38,3,'전송 구간의 암호화와 무결성 보호에 도움을 준다.',1),
(148,38,4,'모든 URL을 짧게 줄여 준다.',0),
(149,39,1,'중복을 자유롭게 허용하는 임의 컬럼이다.',0),
(150,39,2,'조인의 성능을 무조건 낮춘다.',0),
(151,39,3,'문자열 컬럼에서만 사용할 수 있다.',0),
(152,39,4,'행을 유일하게 식별하는 역할을 한다.',1),
(153,40,1,'입력이 멈춘 뒤 마지막 동작을 실행한다.',1),
(154,40,2,'정해진 간격마다 무조건 즉시 실행한다.',0),
(155,40,3,'이벤트를 모두 삭제한다.',0),
(156,40,4,'화면을 새로 고침만 수행한다.',0),
(157,41,1,'정렬 시간이 항상 O(1)이다.',0),
(158,41,2,'같은 키를 가진 원소의 상대적 순서를 유지한다.',1),
(159,41,3,'정렬 전후에 데이터 개수가 바뀐다.',0),
(160,41,4,'숫자형 데이터에서만 사용할 수 있다.',0),
(161,42,1,'모든 로직을 HTML 태그에 작성',0),
(162,42,2,'데이터베이스만으로 화면을 구성',0),
(163,42,3,'View와 ViewModel의 분리 및 바인딩',1),
(164,42,4,'브라우저 캐시 삭제를 자동화',0),
(165,43,1,'해시 함수가 항상 하나의 값만 출력한다.',0),
(166,43,2,'암호화 키가 자동으로 삭제된다.',0),
(167,43,3,'데이터베이스 컬럼이 모두 정렬된다.',0),
(168,43,4,'서로 다른 입력이 같은 해시 값을 갖는 상황이다.',1),
(169,44,1,'대량 데이터를 나눠서 전달한다.',1),
(170,44,2,'서버 로그를 자동으로 삭제한다.',0),
(171,44,3,'브라우저 글꼴을 변경한다.',0),
(172,44,4,'이미지의 배경색을 생성한다.',0),
(173,45,1,'항상 화면의 정중앙에만 고정된다.',0),
(174,45,2,'가장 가까운 위치 지정 조상을 기준으로 배치될 수 있다.',1),
(175,45,3,'텍스트 색상만 바꾸는 속성이다.',0),
(176,45,4,'테이블 셀 안에서만 사용할 수 있다.',0),
(177,46,1,'인덱스 접근이 항상 O(1)이다.',0),
(178,46,2,'메모리를 전혀 사용하지 않는다.',0),
(179,46,3,'중간 삽입과 삭제에 유리할 수 있다.',1),
(180,46,4,'정렬만 가능한 구조이다.',0),
(181,47,1,'이미지가 너무 많아서 무조건 발생한다.',0),
(182,47,2,'네트워크 속도가 느리면 자동으로 발생한다.',0),
(183,47,3,'문자열 길이가 짧을수록 반드시 발생한다.',0),
(184,47,4,'재귀 호출이 과도해져 스택 공간이 부족해진다.',1),
(185,48,1,'왼쪽 자식은 현재 노드보다 작고 오른쪽 자식은 크다.',1),
(186,48,2,'모든 자식은 현재 노드와 같은 값을 가져야 한다.',0),
(187,48,3,'항상 깊이가 1이어야 한다.',0),
(188,48,4,'정렬과는 전혀 관련이 없다.',0),
(189,49,1,'반드시 기계어 파일만 실행한다.',0),
(190,49,2,'소스 코드를 해석하며 실행한다.',1),
(191,49,3,'실행 전에 메모리를 사용하지 않는다.',0),
(192,49,4,'이미지 파일만 변환할 수 있다.',0),
(193,50,1,'네트워크 요청이 항상 실패한다.',0),
(194,50,2,'정렬 알고리즘이 자동으로 빨라진다.',0),
(195,50,3,'더 이상 필요 없는 메모리가 해제되지 않고 남는다.',1),
(196,50,4,'파일 이름이 너무 길어질 때만 발생한다.',0),
(197,51,1,'서버에서만 절대적으로 고정된다.',0),
(198,51,2,'이미지 파일 전용 저장소이다.',0),
(199,51,3,'자바스크립트에서만 읽을 수 없다.',0),
(200,51,4,'브라우저에 저장되며 만료 속성을 가질 수 있다.',1),
(201,52,1,'악성 스크립트를 삽입해 브라우저에서 실행되게 한다.',1),
(202,52,2,'서버의 전원을 끄는 공격이다.',0),
(203,52,3,'데이터베이스 인덱스를 삭제한다.',0),
(204,52,4,'네트워크 패킷을 압축하는 기술이다.',0),
(205,53,1,'같은 이름의 변수를 모두 삭제한다.',0),
(206,53,2,'상속받은 메서드를 하위 클래스에서 다시 정의한다.',1),
(207,53,3,'함수 호출을 전부 금지한다.',0),
(208,53,4,'브라우저 캐시를 자동 비운다.',0),
(209,54,1,'모든 테이블을 하나로 합친다.',0),
(210,54,2,'무조건 조인 수를 늘린다.',0),
(211,54,3,'이행적 종속을 줄여 이상 현상을 완화한다.',1),
(212,54,4,'컬럼의 문자 길이를 제한하지 않는다.',0),
(213,55,1,'Availability(가용성)',0),
(214,55,2,'Alignment(정렬성)',0),
(215,55,3,'Aggregation(집계성)',0),
(216,55,4,'Atomicity(원자성)',1),
(217,56,1,'여러 지역의 캐시 서버로 콘텐츠 전달을 돕는다.',1),
(218,56,2,'항상 데이터베이스 스키마를 자동 변경한다.',0),
(219,56,3,'소스 코드를 기계어로 변환하는 역할만 한다.',0),
(220,56,4,'브라우저의 자바스크립트를 차단한다.',0),
(221,57,1,'한 경로를 끝까지 먼저 깊게 탐색한다.',0),
(222,57,2,'시작 정점에서 가까운 정점부터 넓게 탐색한다.',1),
(223,57,3,'항상 무작위 순서로 정점을 선택한다.',0),
(224,57,4,'가중치가 없는 그래프에서만 사용할 수 없다.',0),
(225,58,1,'가장 중요한 학습 목표를 먼저 정하고 일정을 조정한다.',1),
(226,59,1,'정답만 적어 두고 다음에는 감으로 다시 푼다.',0),
(227,60,1,'파이썬의 리스트는 항상 고정 길이만 허용한다.',0),
(228,61,1,'연결 리스트는 중간 삽입이 자주 일어날 때 유리할 수 있다.',1),
(229,62,1,'이진 탐색은 정렬되지 않은 데이터에서만 가장 잘 동작한다.',0),
(230,63,1,'평균은 데이터의 중심을 나타내는 대표값 중 하나이다.',1),
(231,64,1,'CSS는 주로 문서 구조를 정의하고 HTML은 색상을 담당한다.',0),
(232,65,1,'JavaScript의 비동기 작업은 콜백이나 Promise로 제어할 수 있다.',1),
(233,66,1,'큐는 후입선출 구조이다.',0),
(234,67,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(235,68,1,'가장 중요한 학습 목표를 먼저 정하고 일정을 조정한다.',1),
(236,69,1,'정답만 적어 두고 다음에는 감으로 다시 푼다.',0),
(237,70,1,'파이썬의 리스트는 항상 고정 길이만 허용한다.',0),
(238,58,2,'공부할 자료만 계속 모으고 시작은 미룬다.',0),
(239,59,2,'틀린 이유와 다시 풀 때의 기준을 함께 적어 둔다.',1),
(240,60,2,'파이썬 함수는 return 없이 값을 여러 개 강제로 반환해야 한다.',0),
(241,61,2,'배열은 삽입과 삭제가 항상 가장 빠르다.',0),
(242,62,2,'선택 정렬은 교환 횟수를 줄이려는 관점에서 볼 수 있다.',1),
(243,63,2,'분산은 항상 데이터의 최대값만 의미한다.',0),
(244,64,2,'HTML은 콘텐츠 구조를, CSS는 표현과 배치를 담당한다.',1),
(245,65,2,'이벤트 루프는 브라우저에서 한 번도 사용되지 않는다.',0),
(246,66,2,'스택은 먼저 들어온 데이터가 먼저 나간다.',0),
(247,67,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(248,68,2,'공부할 자료만 계속 모으고 시작은 미룬다.',0),
(249,69,2,'틀린 이유와 다시 풀 때의 기준을 함께 적어 둔다.',1),
(250,70,2,'파이썬 함수는 return 없이 값을 여러 개 강제로 반환해야 한다.',0),
(251,58,3,'좋아하는 과목만 반복하고 약점은 뒤로 미룬다.',0),
(252,59,3,'틀린 문제를 바로 지우고 새 문제로 넘어간다.',0),
(253,60,3,'들여쓰기는 파이썬에서 코드 블록을 구분하는 중요한 문법이다.',1),
(254,61,3,'트리는 항상 선형 구조이므로 부모-자식 관계가 없다.',0),
(255,62,3,'퀵 정렬은 어떤 입력에서도 항상 O(n)이다.',0),
(256,63,3,'중앙값은 정렬과 전혀 관련이 없다.',0),
(257,64,3,'HTML과 CSS는 역할 구분 없이 완전히 같은 작업만 한다.',0),
(258,65,3,'DOM 조작은 JavaScript로 전혀 불가능하다.',0),
(259,66,3,'스택은 최근 작업을 되돌리는 기능과 잘 어울린다.',1),
(260,67,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',0),
(261,68,3,'좋아하는 과목만 반복하고 약점은 뒤로 미룬다.',0),
(262,69,3,'틀린 문제를 바로 지우고 새 문제로 넘어간다.',0),
(263,70,3,'들여쓰기는 파이썬에서 코드 블록을 구분하는 중요한 문법이다.',1),
(264,58,4,'복습 없이 매번 새 문제만 늘린다.',0),
(265,59,4,'해설을 읽지 않고 답만 암기한다.',0),
(266,60,4,'파이썬의 문자열은 숫자형처럼 자동 덧셈만 가능하다.',0),
(267,61,4,'그래프는 정점과 간선을 표현할 수 없다.',0),
(268,62,4,'선형 탐색은 배열 길이와 무관하게 항상 한 번에 끝난다.',0),
(269,63,4,'표준편차가 작을수록 데이터가 더 흩어진다.',0),
(270,64,4,'CSS 없이 HTML은 어떤 구조도 만들 수 없다.',0),
(271,65,4,'setTimeout은 항상 현재 코드보다 먼저 실행된다.',0),
(272,66,4,'큐와 스택은 저장 순서를 전혀 구분하지 않는다.',0),
(273,67,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(274,68,4,'복습 없이 매번 새 문제만 늘린다.',0),
(275,69,4,'해설을 읽지 않고 답만 암기한다.',0),
(276,70,4,'파이썬의 문자열은 숫자형처럼 자동 덧셈만 가능하다.',0),
(277,71,1,'연결 리스트는 중간 삽입이 자주 일어날 때 유리할 수 있다.',1),
(278,72,1,'이진 탐색은 정렬되지 않은 데이터에서만 가장 잘 동작한다.',0),
(279,73,1,'평균은 데이터의 중심을 나타내는 대표값 중 하나이다.',1),
(280,74,1,'CSS는 주로 문서 구조를 정의하고 HTML은 색상을 담당한다.',0),
(281,75,1,'JavaScript의 비동기 작업은 콜백이나 Promise로 제어할 수 있다.',1),
(282,76,1,'큐는 후입선출 구조이다.',0),
(283,77,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(284,78,1,'가장 중요한 학습 목표를 먼저 정하고 일정을 조정한다.',1),
(285,79,1,'정답만 적어 두고 다음에는 감으로 다시 푼다.',0),
(286,80,1,'파이썬의 리스트는 항상 고정 길이만 허용한다.',0),
(287,81,1,'연결 리스트는 중간 삽입이 자주 일어날 때 유리할 수 있다.',1),
(288,82,1,'이진 탐색은 정렬되지 않은 데이터에서만 가장 잘 동작한다.',0),
(289,83,1,'평균은 데이터의 중심을 나타내는 대표값 중 하나이다.',1),
(290,71,2,'배열은 삽입과 삭제가 항상 가장 빠르다.',0),
(291,72,2,'선택 정렬은 교환 횟수를 줄이려는 관점에서 볼 수 있다.',1),
(292,73,2,'분산은 항상 데이터의 최대값만 의미한다.',0),
(293,74,2,'HTML은 콘텐츠 구조를, CSS는 표현과 배치를 담당한다.',1),
(294,75,2,'이벤트 루프는 브라우저에서 한 번도 사용되지 않는다.',0),
(295,76,2,'스택은 먼저 들어온 데이터가 먼저 나간다.',0),
(296,77,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(297,78,2,'공부할 자료만 계속 모으고 시작은 미룬다.',0),
(298,79,2,'틀린 이유와 다시 풀 때의 기준을 함께 적어 둔다.',1),
(299,80,2,'파이썬 함수는 return 없이 값을 여러 개 강제로 반환해야 한다.',0),
(300,81,2,'배열은 삽입과 삭제가 항상 가장 빠르다.',0),
(301,82,2,'선택 정렬은 교환 횟수를 줄이려는 관점에서 볼 수 있다.',1),
(302,83,2,'분산은 항상 데이터의 최대값만 의미한다.',0),
(303,71,3,'트리는 항상 선형 구조이므로 부모-자식 관계가 없다.',0),
(304,72,3,'퀵 정렬은 어떤 입력에서도 항상 O(n)이다.',0),
(305,73,3,'중앙값은 정렬과 전혀 관련이 없다.',0),
(306,74,3,'HTML과 CSS는 역할 구분 없이 완전히 같은 작업만 한다.',0),
(307,75,3,'DOM 조작은 JavaScript로 전혀 불가능하다.',0),
(308,76,3,'스택은 최근 작업을 되돌리는 기능과 잘 어울린다.',1),
(309,77,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',0),
(310,78,3,'좋아하는 과목만 반복하고 약점은 뒤로 미룬다.',0),
(311,79,3,'틀린 문제를 바로 지우고 새 문제로 넘어간다.',0),
(312,80,3,'들여쓰기는 파이썬에서 코드 블록을 구분하는 중요한 문법이다.',1),
(313,81,3,'트리는 항상 선형 구조이므로 부모-자식 관계가 없다.',0),
(314,82,3,'퀵 정렬은 어떤 입력에서도 항상 O(n)이다.',0),
(315,83,3,'중앙값은 정렬과 전혀 관련이 없다.',0),
(316,71,4,'그래프는 정점과 간선을 표현할 수 없다.',0),
(317,72,4,'선형 탐색은 배열 길이와 무관하게 항상 한 번에 끝난다.',0),
(318,73,4,'표준편차가 작을수록 데이터가 더 흩어진다.',0),
(319,74,4,'CSS 없이 HTML은 어떤 구조도 만들 수 없다.',0),
(320,75,4,'setTimeout은 항상 현재 코드보다 먼저 실행된다.',0),
(321,76,4,'큐와 스택은 저장 순서를 전혀 구분하지 않는다.',0),
(322,77,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(323,78,4,'복습 없이 매번 새 문제만 늘린다.',0),
(324,79,4,'해설을 읽지 않고 답만 암기한다.',0),
(325,80,4,'파이썬의 문자열은 숫자형처럼 자동 덧셈만 가능하다.',0),
(326,81,4,'그래프는 정점과 간선을 표현할 수 없다.',0),
(327,82,4,'선형 탐색은 배열 길이와 무관하게 항상 한 번에 끝난다.',0),
(328,83,4,'표준편차가 작을수록 데이터가 더 흩어진다.',0),
(329,84,1,'CSS는 주로 문서 구조를 정의하고 HTML은 색상을 담당한다.',0),
(330,85,1,'JavaScript의 비동기 작업은 콜백이나 Promise로 제어할 수 있다.',1),
(331,86,1,'큐는 후입선출 구조이다.',0),
(332,87,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(333,88,1,'가장 중요한 학습 목표를 먼저 정하고 일정을 조정한다.',1),
(334,89,1,'정답만 적어 두고 다음에는 감으로 다시 푼다.',0),
(335,90,1,'파이썬의 리스트는 항상 고정 길이만 허용한다.',0),
(336,91,1,'연결 리스트는 중간 삽입이 자주 일어날 때 유리할 수 있다.',1),
(337,92,1,'이진 탐색은 정렬되지 않은 데이터에서만 가장 잘 동작한다.',0),
(338,93,1,'평균은 데이터의 중심을 나타내는 대표값 중 하나이다.',1),
(339,94,1,'CSS는 주로 문서 구조를 정의하고 HTML은 색상을 담당한다.',0),
(340,95,1,'JavaScript의 비동기 작업은 콜백이나 Promise로 제어할 수 있다.',1),
(341,96,1,'큐는 후입선출 구조이다.',0),
(342,84,2,'HTML은 콘텐츠 구조를, CSS는 표현과 배치를 담당한다.',1),
(343,85,2,'이벤트 루프는 브라우저에서 한 번도 사용되지 않는다.',0),
(344,86,2,'스택은 먼저 들어온 데이터가 먼저 나간다.',0),
(345,87,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(346,88,2,'공부할 자료만 계속 모으고 시작은 미룬다.',0),
(347,89,2,'틀린 이유와 다시 풀 때의 기준을 함께 적어 둔다.',1),
(348,90,2,'파이썬 함수는 return 없이 값을 여러 개 강제로 반환해야 한다.',0),
(349,91,2,'배열은 삽입과 삭제가 항상 가장 빠르다.',0),
(350,92,2,'선택 정렬은 교환 횟수를 줄이려는 관점에서 볼 수 있다.',1),
(351,93,2,'분산은 항상 데이터의 최대값만 의미한다.',0),
(352,94,2,'HTML은 콘텐츠 구조를, CSS는 표현과 배치를 담당한다.',1),
(353,95,2,'이벤트 루프는 브라우저에서 한 번도 사용되지 않는다.',0),
(354,96,2,'스택은 먼저 들어온 데이터가 먼저 나간다.',0),
(355,84,3,'HTML과 CSS는 역할 구분 없이 완전히 같은 작업만 한다.',0),
(356,85,3,'DOM 조작은 JavaScript로 전혀 불가능하다.',0),
(357,86,3,'스택은 최근 작업을 되돌리는 기능과 잘 어울린다.',1),
(358,87,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',0),
(359,88,3,'좋아하는 과목만 반복하고 약점은 뒤로 미룬다.',0),
(360,89,3,'틀린 문제를 바로 지우고 새 문제로 넘어간다.',0),
(361,90,3,'들여쓰기는 파이썬에서 코드 블록을 구분하는 중요한 문법이다.',1),
(362,91,3,'트리는 항상 선형 구조이므로 부모-자식 관계가 없다.',0),
(363,92,3,'퀵 정렬은 어떤 입력에서도 항상 O(n)이다.',0),
(364,93,3,'중앙값은 정렬과 전혀 관련이 없다.',0),
(365,94,3,'HTML과 CSS는 역할 구분 없이 완전히 같은 작업만 한다.',0),
(366,95,3,'DOM 조작은 JavaScript로 전혀 불가능하다.',0),
(367,96,3,'스택은 최근 작업을 되돌리는 기능과 잘 어울린다.',1),
(368,84,4,'CSS 없이 HTML은 어떤 구조도 만들 수 없다.',0),
(369,85,4,'setTimeout은 항상 현재 코드보다 먼저 실행된다.',0),
(370,86,4,'큐와 스택은 저장 순서를 전혀 구분하지 않는다.',0),
(371,87,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(372,88,4,'복습 없이 매번 새 문제만 늘린다.',0),
(373,89,4,'해설을 읽지 않고 답만 암기한다.',0),
(374,90,4,'파이썬의 문자열은 숫자형처럼 자동 덧셈만 가능하다.',0),
(375,91,4,'그래프는 정점과 간선을 표현할 수 없다.',0),
(376,92,4,'선형 탐색은 배열 길이와 무관하게 항상 한 번에 끝난다.',0),
(377,93,4,'표준편차가 작을수록 데이터가 더 흩어진다.',0),
(378,94,4,'CSS 없이 HTML은 어떤 구조도 만들 수 없다.',0),
(379,95,4,'setTimeout은 항상 현재 코드보다 먼저 실행된다.',0),
(380,96,4,'큐와 스택은 저장 순서를 전혀 구분하지 않는다.',0),
(381,97,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(382,98,1,'가장 중요한 학습 목표를 먼저 정하고 일정을 조정한다.',1),
(383,99,1,'정답만 적어 두고 다음에는 감으로 다시 푼다.',0),
(384,100,1,'파이썬의 리스트는 항상 고정 길이만 허용한다.',0),
(385,101,1,'연결 리스트는 중간 삽입이 자주 일어날 때 유리할 수 있다.',1),
(386,102,1,'이진 탐색은 정렬되지 않은 데이터에서만 가장 잘 동작한다.',0),
(387,103,1,'평균은 데이터의 중심을 나타내는 대표값 중 하나이다.',1),
(388,104,1,'CSS는 주로 문서 구조를 정의하고 HTML은 색상을 담당한다.',0),
(389,105,1,'JavaScript의 비동기 작업은 콜백이나 Promise로 제어할 수 있다.',1),
(390,106,1,'큐는 후입선출 구조이다.',0),
(392,97,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(393,98,2,'공부할 자료만 계속 모으고 시작은 미룬다.',0),
(394,99,2,'틀린 이유와 다시 풀 때의 기준을 함께 적어 둔다.',1),
(395,100,2,'파이썬 함수는 return 없이 값을 여러 개 강제로 반환해야 한다.',0),
(396,101,2,'배열은 삽입과 삭제가 항상 가장 빠르다.',0),
(397,102,2,'선택 정렬은 교환 횟수를 줄이려는 관점에서 볼 수 있다.',1),
(398,103,2,'분산은 항상 데이터의 최대값만 의미한다.',0),
(399,104,2,'HTML은 콘텐츠 구조를, CSS는 표현과 배치를 담당한다.',1),
(400,105,2,'이벤트 루프는 브라우저에서 한 번도 사용되지 않는다.',0),
(401,106,2,'스택은 먼저 들어온 데이터가 먼저 나간다.',0),
(403,97,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',0),
(404,98,3,'좋아하는 과목만 반복하고 약점은 뒤로 미룬다.',0),
(405,99,3,'틀린 문제를 바로 지우고 새 문제로 넘어간다.',0),
(406,100,3,'들여쓰기는 파이썬에서 코드 블록을 구분하는 중요한 문법이다.',1),
(407,101,3,'트리는 항상 선형 구조이므로 부모-자식 관계가 없다.',0),
(408,102,3,'퀵 정렬은 어떤 입력에서도 항상 O(n)이다.',0),
(409,103,3,'중앙값은 정렬과 전혀 관련이 없다.',0),
(410,104,3,'HTML과 CSS는 역할 구분 없이 완전히 같은 작업만 한다.',0),
(411,105,3,'DOM 조작은 JavaScript로 전혀 불가능하다.',0),
(412,106,3,'스택은 최근 작업을 되돌리는 기능과 잘 어울린다.',1),
(414,97,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(415,98,4,'복습 없이 매번 새 문제만 늘린다.',0),
(416,99,4,'해설을 읽지 않고 답만 암기한다.',0),
(417,100,4,'파이썬의 문자열은 숫자형처럼 자동 덧셈만 가능하다.',0),
(418,101,4,'그래프는 정점과 간선을 표현할 수 없다.',0),
(419,102,4,'선형 탐색은 배열 길이와 무관하게 항상 한 번에 끝난다.',0),
(420,103,4,'표준편차가 작을수록 데이터가 더 흩어진다.',0),
(421,104,4,'CSS 없이 HTML은 어떤 구조도 만들 수 없다.',0),
(422,105,4,'setTimeout은 항상 현재 코드보다 먼저 실행된다.',0),
(423,106,4,'큐와 스택은 저장 순서를 전혀 구분하지 않는다.',0),
(488,107,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(489,107,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(490,107,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',1),
(491,107,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(492,1,1,'문서의 스타일을 직접 지정한다.',0),
(493,1,2,'자바스크립트 기능을 대체한다.',0),
(494,1,3,'문서의 구조와 의미를 더 잘 전달한다.',1),
(495,1,4,'이미지의 해상도를 자동으로 높인다.',0),
(496,1,5,'서버와의 통신을 대신 처리한다.',0),
(497,108,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(498,108,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(499,108,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',1),
(500,108,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(501,109,1,'확률 분포는 가능한 값과 그 값의 나타날 가능성을 함께 본다.',1),
(502,109,2,'확률 분포는 오직 정답이 하나일 때만 정의된다.',0),
(503,109,3,'확률 분포를 보면 값이 얼마나 자주 나오는지는 알 수 없다.',1),
(504,109,4,'기대값은 무조건 실제 관측값 중 하나와 같아야 한다.',0),
(505,111,1,'To compare different kinds of gardens',0),
(506,111,2,'To describe how a community garden changed a neighborhood',1),
(507,111,3,'To explain how to build raised beds',0),
(508,111,4,'To argue against urban farming',0),
(509,112,1,'Residents planted herbs',0),
(510,112,2,'People shared seeds and recipes',1),
(511,112,3,'The lot was empty',0),
(512,112,4,'Volunteers installed shade cloth',0),
(513,113,1,'The garden closed',0),
(514,113,2,'Volunteers added shade and collected rainwater',1),
(515,113,3,'The plants were removed',0),
(516,113,4,'Residents stopped visiting',0),
(517,114,1,'Critical',0),
(518,114,2,'Celebratory',1),
(519,114,3,'Indifferent',0),
(520,114,4,'Sarcastic',0),
(521,115,1,'It was already closely connected',0),
(522,115,2,'It had no available land',0),
(523,115,3,'Many neighbors did not know each other',1),
(524,115,4,'It was famous for farming',0),
(525,117,1,'Different types of memory tests',0),
(526,117,2,'People who napped and people who stayed awake',1),
(527,117,3,'Morning learning and evening learning',0),
(528,117,4,'Long naps and no naps only',0),
(529,118,1,'It reduces hunger',0),
(530,118,2,'The brain replays new information during light sleep',1),
(531,118,3,'It increases physical strength',0),
(532,118,4,'It lowers stress permanently',0),
(533,119,1,'They improved recall too much',0),
(534,119,2,'They had no effect and caused grogginess',1),
(535,119,3,'They caused participants to forget the words entirely',0),
(536,119,4,'They were not allowed',0),
(537,120,1,'Sleep never helps learning',0),
(538,120,2,'Long naps are better than short naps',0),
(539,120,3,'Brief naps can boost learning without major disruption',1),
(540,120,4,'Only students benefit from naps',0),
(541,121,1,'Problem and solution',0),
(542,121,2,'Cause and effect',0),
(543,121,3,'Description of a study and its results',1),
(544,121,4,'Chronological biography',0),
(545,123,1,'A bridge',0),
(546,123,2,'An aging power plant',1),
(547,123,3,'A fishing port',0),
(548,123,4,'A highway',0),
(549,124,1,'It canceled the project',0),
(550,124,2,'It approved a smaller offshore project',1),
(551,124,3,'It built the largest possible project',0),
(552,124,4,'It delayed the decision for years',0),
(553,125,1,'Residents became less supportive',0),
(554,125,2,'Electricity prices doubled',0),
(555,125,3,'Tourism increased because of interest in clean energy',1),
(556,125,4,'The turbines were removed',0),
(557,126,1,'Noise from trains',0),
(558,126,2,'Loss of ocean view',1),
(559,126,3,'Damage to farmland',0),
(560,126,4,'Lack of internet access',0),
(561,127,1,'Wind energy always faces opposition',0),
(562,127,2,'Compromise helped a clean energy project succeed',1),
(563,127,3,'Tourism is the town primary industry',0),
(564,127,4,'Power plants are safer than turbines',0),
(565,129,1,'The letters were already digital',0),
(566,129,2,'The paper was aging and hard to handle',1),
(567,129,3,'Researchers requested paper copies only',0),
(568,129,4,'The archive wanted to reduce staff',0),
(569,130,1,'Fewer researchers used the archive',0),
(570,130,2,'Students were more engaged with online access and annotation',1),
(571,130,3,'The letters lost their historical value',0),
(572,130,4,'The project required no funding',0),
(573,131,1,'Skeptical about digitization',0),
(574,131,2,'Neutral but acknowledging benefits and costs',1),
(575,131,3,'Angry about technology',0),
(576,131,4,'Dismissive of researchers',0),
(577,132,1,'Reducing',0),
(578,132,2,'Limiting',0),
(579,132,3,'Increasing',1),
(580,132,4,'Hiding',0),
(581,133,1,'Digitization preserves and broadens access to historical letters',1),
(582,133,2,'Online archives are always free',0),
(583,133,3,'Students dislike reading letters',0),
(584,133,4,'Archives should stop collecting letters',0);
/*!40000 ALTER TABLE `question_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_passages`
--

DROP TABLE IF EXISTS `question_passages`;
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

--
-- Dumping data for table `question_passages`
--

LOCK TABLES `question_passages` WRITE;
/*!40000 ALTER TABLE `question_passages` DISABLE KEYS */;
INSERT INTO `question_passages` VALUES
(1,7,'### Reading Comprehension\n\n![Forest](https://images.unsplash.com/photo-1448375240586-882707db888b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80)\n\nMany people believe that the best way to preserve nature is to keep humans out of it in completely pristine reserves. However, **recent studies** show that indigenous stewardship is often more effective at maintaining biodiversity.'),
(2,61,'### 자료구조 빠른 정리\n\n배열은 **인덱스 접근**에 강하고, 연결 리스트는 **중간 삽입/삭제**에 유리합니다. 각 구조는 데이터 접근 패턴에 따라 선택해야 합니다.'),
(3,78,'### 통계 개념 메모\n\n대표값은 데이터의 중심을 요약하고, 산포도는 데이터가 얼마나 퍼져 있는지를 설명합니다. 평균과 분산을 함께 읽는 습관이 중요합니다.'),
(4,98,'### 웹 개발 기초\n\nHTML은 문서의 구조를 만들고 CSS는 그 구조를 화면에서 어떻게 보이게 할지를 결정합니다. JavaScript는 사용자와 상호작용하는 동작을 담당합니다.');
/*!40000 ALTER TABLE `question_passages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_reviews`
--

DROP TABLE IF EXISTS `question_reviews`;
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

--
-- Dumping data for table `question_reviews`
--

LOCK TABLES `question_reviews` WRITE;
/*!40000 ALTER TABLE `question_reviews` DISABLE KEYS */;
INSERT INTO `question_reviews` VALUES
(1,2,2,'패턴 분류를 비교하면서 풀 수 있어서 좋았습니다.',4,'2026-03-27 21:48:29'),
(2,3,2,'단어 뜻과 보기 난이도가 적절했습니다.',5,'2026-03-27 21:48:29'),
(3,6,1,'부분적분 개념 확인용으로 수업 자료에 쓰기 좋습니다.',4,'2026-03-27 21:48:29'),
(4,58,2,'짧지만 핵심을 묻는 문제라 복습용으로 괜찮았습니다.',4,'2026-03-27 21:48:29'),
(5,61,2,'자료구조 개념을 헷갈릴 때 다시 보기 좋았습니다.',5,'2026-03-27 21:48:29'),
(6,42,2,'ㅎ ㅗㅜ',5,'2026-03-31 13:31:49'),
(7,42,2,'ㅠㅎ ㅜㅠ',4,'2026-03-31 13:31:55');
/*!40000 ALTER TABLE `question_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question_tags`
--

DROP TABLE IF EXISTS `question_tags`;
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

--
-- Dumping data for table `question_tags`
--

LOCK TABLES `question_tags` WRITE;
/*!40000 ALTER TABLE `question_tags` DISABLE KEYS */;
INSERT INTO `question_tags` VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(3,5),
(4,5),
(6,6),
(6,7),
(58,8),
(61,8),
(71,8),
(78,9),
(88,9),
(98,10),
(101,10);
/*!40000 ALTER TABLE `question_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questionbook`
--

DROP TABLE IF EXISTS `questionbook`;
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
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자별 개인 문제집(북마크)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questionbook`
--

LOCK TABLES `questionbook` WRITE;
/*!40000 ALTER TABLE `questionbook` DISABLE KEYS */;
INSERT INTO `questionbook` VALUES
(0,0,'오늘의 공개문제','매일 자동으로 갱신되는 추천 문제 세트입니다.','2026-04-02 02:41:40'),
(1,1,'김철수 3월 오답 정리','틀린 문제만 다시 모아 둔 개인 문제집','2026-03-27 21:48:29'),
(2,2,'김철수 자료구조 집중','자료구조와 알고리즘 관련 문제를 따로 묶은 컬렉션','2026-03-27 21:48:29'),
(3,3,'학부모 체크용 주말 점검','아이와 함께 볼 핵심 문제집','2026-03-27 21:48:29'),
(4,4,'김철수 단원별 정리: 알고리즘Ⅰ','기본 알고리즘 개념을 요약한 문제집','2026-03-27 21:48:29'),
(5,5,'김철수 단원별 정리: 알고리즘Ⅱ','응용 알고리즘과 손코딩 문제로 구성된 컬렉션','2026-03-27 21:48:29'),
(6,6,'김철수 통계 마스터십','평균, 분산, 확률까지 차근차근 복습하는 문제집','2026-03-27 21:48:29'),
(7,7,'김철수 프론트엔드 스프린트','HTML/CSS/JavaScript 핵심 실습 문제 집중','2026-03-27 21:48:29'),
(8,8,'김철수 Python Quick Win','회고 와 퀵 윈을 위한 파이썬 문제 셋','2026-03-27 21:48:29'),
(9,1,'김철수 자료구조 이론 정리','스택, 큐, 그래프를 중심으로 이론을 정리','2026-03-27 21:48:29'),
(10,2,'김철수 기말 대비 영어','독해·어휘·문법을 섞어 만든 복습 문제집','2026-03-27 21:48:29'),
(11,3,'김철수 약점 분석 리뷰','최근 틀린 문제만 모아둔 집중 리뷰북','2026-03-27 21:48:29'),
(12,4,'김철수 오답 노트 - 3월','틀린 문제를 한번 더 되짚는 서술형 오답 노트','2026-03-27 21:48:29'),
(13,5,'김철수 운영체제 실전','프로세스, 스케줄링, 메모리 중심 문제','2026-03-27 21:48:29'),
(14,6,'김철수 네트워크 진도별','OSI 7계층부터 TCP/IP까지 점검','2026-03-27 21:48:29'),
(15,7,'김철수 MySQL 실습','SQL 작성 흐름과 디버깅에 집중한 복습','2026-03-27 21:48:29'),
(16,8,'김철수 컴퓨터 구조 리뷰','기계어, 캐시, 연산 등 기초 개념 정리','2026-03-27 21:48:29'),
(17,1,'김철수 AI 수학 믹스','행렬·확률·통계 기반 문제들을 적절히 섞은 믹스','2026-03-27 21:48:29'),
(18,2,'김철수 논술형 대비','서술형 답안 구조를 연습하는 문항 모음','2026-03-27 21:48:29'),
(19,3,'김철수 자료구조 속성 복습','선형 자료구조 성능 비교 중심 문제 세트','2026-03-27 21:48:29'),
(20,4,'김철수 프로젝트 리뷰 꾸러미','실습 중 자주 쓰는 문제들을 묶은 번외 세트','2026-03-27 21:48:29'),
(21,5,'학부모 시선: 우리아이 핵심 체크1','기초 체력 점검용 부모용 문제집','2026-03-27 21:48:29'),
(22,6,'학부모 시선: 우리아이 핵심 체크2','취약 영역별 요약 문제로 구성된 부모 협업북','2026-03-27 21:48:29'),
(23,7,'제이미 선생님 추천 문제집','교사용으로 만든 추천 문제 묶음','2026-03-27 21:48:29'),
(24,8,'김철수 Java 실전 클러스터','기초 자바 문법부터 스프링까지 통합','2026-03-27 21:48:29'),
(25,1,'김철수 알고리즘 파이널','대회형 알고리즘 문제를 정리한 실전집','2026-03-27 21:48:29'),
(26,2,'김철수 스킬업 SQL','한 번에 흐름을 읽는 SQL 집중 훈련','2026-03-27 21:48:29'),
(27,3,'김철수 클라우드 네트워크','클라우드 네트워크 구성 중심 실습 문제','2026-03-27 21:48:29'),
(28,4,'김철수 자료 구조 집중코스','트리부터 힙까지 확장 문제를 묶은 세트','2026-03-27 21:48:29'),
(29,5,'김철수 프로그래밍 챌린지','자체 문제 50문제를 한 번에 푸는 연습','2026-03-27 21:48:29'),
(30,6,'김철수 경시대비 리뷰','시간 제한 기반 경시형 문제 모음','2026-03-27 21:48:29'),
(31,7,'김철수 TOEIC+코딩','영어 독해와 코딩 논리를 섞은 셋','2026-03-27 21:48:29'),
(32,8,'김철수 파이썬 디버깅','에러로그 해석과 디버깅을 묶은 문제집','2026-03-27 21:48:29'),
(33,1,'김철수 개발자 인터뷰 예제','자주 묻는 개념 문항을 정리','2026-03-27 21:48:29'),
(34,2,'김철수 네트워크 운영실','네트워크 구조와 운영 시나리오 문제집','2026-03-27 21:48:29'),
(35,3,'김철수 컴퓨터 시스템 그림책','도표 중심 하드웨어 설명 문제','2026-03-27 21:48:29'),
(36,4,'김철수 데이터 분석 실습','통계와 시각화 질문이 섞인 문제집','2026-03-27 21:48:29'),
(37,5,'김철수 컬러 코딩 일지','한 문항씩 색으로 인지하는 개념 정리','2026-03-27 21:48:29'),
(38,6,'김철수 통합 모의고사','실제 시험질문과 같은 형식으로 구성','2026-03-27 21:48:29'),
(39,7,'김철수 소프트웨어 정책 리뷰','운영 정책과 윤리 문제를 묶은 세트','2026-03-27 21:48:29'),
(40,8,'김철수 AI/ML 실전','머신러닝 원리 기반 문제집','2026-03-27 21:48:29'),
(41,1,'김철수 과학 리콜','물리/화학 통합 문제로 구성된 리뷰','2026-03-27 21:48:29'),
(42,2,'김철수 실무 배포 연습','CI/CD와 데브옵스 상황문제','2026-03-27 21:48:29'),
(43,3,'김철수 집중 리팩터링','코드 품질과 리팩터링 중심 질문','2026-03-27 21:48:29'),
(44,4,'김철수 JavaScript 심화','노드 · 브라우저 경계를 넘나드는 실습','2026-03-27 21:48:29'),
(45,5,'김철수 디자인 패턴 리서치','패턴별 핵심 개념을 뽑은 미션셋','2026-03-27 21:48:29'),
(46,6,'김철수 게임 개발 집중','시뮬레이션 캡슐화 · 이벤트 문제 세트','2026-03-27 21:48:29'),
(47,7,'김철수 OS+네트워크 리뷰','운영체제와 네트워크 실습을 잇는 문항','2026-03-27 21:48:29'),
(48,8,'김철수 데이터 시각화','차트·SQL 결과를 엮은 분석 문제','2026-03-27 21:48:29'),
(49,1,'김철수 AI 수학 연계','확률·선형대수를 응용하는 해법 질문','2026-03-27 21:48:29'),
(50,2,'김철수 실전 PT 리허설','서술/객관식 혼합형 실전 리허설','2026-03-27 21:48:29'),
(51,3,'김철수 국제 공모전 준비','프로그래밍·논술 혼합 셋','2026-03-27 21:48:29'),
(52,4,'김철수 스타트업 팀워크','협업 시나리오와 이슈 대응 문항','2026-03-27 21:48:29'),
(53,5,'김철수 에디터 픽셀','UI 설계 · 디버그 사례 중심','2026-03-27 21:48:29'),
(57,1,'오늘의 공개문제 풀이문제집','오늘의 공개문제 풀이문제집','2026-03-27 21:48:29'),
(58,1,'오늘의 공개문제','매일 자동으로 갱신되는 추천 문제 세트입니다.','2026-04-02 11:10:37');
/*!40000 ALTER TABLE `questionbook` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questionbook_question`
--

DROP TABLE IF EXISTS `questionbook_question`;
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

--
-- Dumping data for table `questionbook_question`
--

LOCK TABLES `questionbook_question` WRITE;
/*!40000 ALTER TABLE `questionbook_question` DISABLE KEYS */;
INSERT INTO `questionbook_question` VALUES
(1,2),
(4,2),
(3,3),
(1,4),
(4,4),
(4,5),
(1,6),
(5,6),
(3,7),
(5,7),
(5,8),
(6,9),
(6,10),
(6,11),
(7,12),
(7,13),
(7,14),
(8,15),
(8,16),
(8,17),
(9,18),
(9,20),
(9,21),
(10,22),
(10,23),
(10,24),
(11,25),
(11,26),
(11,27),
(12,28),
(12,29),
(12,30),
(13,31),
(0,32),
(13,32),
(0,33),
(13,33),
(14,34),
(14,35),
(14,36),
(15,37),
(15,38),
(15,39),
(16,40),
(16,41),
(16,42),
(0,43),
(17,43),
(0,44),
(17,44),
(24,44),
(0,45),
(17,45),
(24,45),
(18,46),
(25,46),
(18,47),
(25,47),
(0,48),
(18,48),
(26,48),
(19,49),
(26,49),
(19,50),
(27,50),
(0,51),
(27,51),
(28,52),
(28,53),
(0,54),
(29,54),
(29,55),
(30,56),
(0,57),
(30,57),
(1,58),
(19,58),
(31,58),
(31,59),
(0,60),
(32,60),
(44,60),
(0,61),
(2,61),
(20,61),
(32,61),
(44,61),
(2,62),
(33,62),
(44,62),
(0,63),
(1,63),
(20,63),
(33,63),
(45,63),
(34,64),
(45,64),
(34,65),
(45,65),
(35,66),
(46,66),
(35,67),
(46,67),
(36,68),
(46,68),
(36,69),
(47,69),
(37,70),
(47,70),
(2,71),
(20,71),
(37,71),
(47,71),
(48,72),
(48,73),
(48,74),
(49,75),
(49,76),
(49,77),
(0,78),
(3,78),
(21,78),
(38,78),
(50,78),
(38,79),
(50,79),
(39,80),
(50,80),
(2,81),
(21,81),
(39,81),
(51,81),
(0,82),
(40,82),
(51,82),
(40,83),
(51,83),
(41,84),
(52,84),
(41,85),
(52,85),
(42,86),
(52,86),
(42,87),
(53,87),
(0,88),
(3,88),
(21,88),
(43,88),
(53,88),
(43,89),
(53,89),
(0,90),
(2,91),
(22,91),
(0,93),
(0,94),
(22,98),
(22,99),
(0,100),
(23,100),
(23,101),
(23,102),
(0,106);
/*!40000 ALTER TABLE `questionbook_question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
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

--
-- Dumping data for table `questions`
--

LOCK TABLES `questions` WRITE;
/*!40000 ALTER TABLE `questions` DISABLE KEYS */;
INSERT INTO `questions` VALUES
(1,NULL,1,20,'M','HTML - 시맨틱 태그 (5지선다)','다음 중 HTML 시맨틱 태그의 역할로 가장 알맞은 것은?','문서 구조를 의미 있게 구분하는 태그의 목적을 묻는 문제입니다.','3','시맨틱 태그는 문서의 의미를 명확히 해 접근성과 유지보수성을 높입니다.','구조와 의미를 떠올려 보세요.',2,1,'N',60,1,'2026-03-27 21:48:28'),
(2,NULL,2,3,'M','디자인 패턴 - 생성 (5지선다)','다음 중 소프트웨어 객체 지향 디자인 패턴의 생성(Creational) 패턴이 아닌 것은?',NULL,'','Observer 패턴은 행위(Behavioral) 패턴에 속합니다.','상태 변화를 관찰하는 패턴은 생성과 무관합니다.',4,1,'N',120,0,'2026-03-27 21:48:28'),
(3,NULL,3,9,'M','영어 단어 - Abandon (4지선다)','다음 중 영어 단어 \'Abandon\'의 뜻으로 가장 알맞은 것은?',NULL,'','어원은 프랑스어 abandonner (넘겨주다)에서 유래했으며, give up과 유사한 의미를 가집니다.','give up과 비슷한 뜻',1,1,'N',30,0,'2026-03-27 21:48:28'),
(4,NULL,4,6,'S','파이썬 - 리스트 기초 (주관식)','파이썬에서 비어있는 리스트를 생성하는 코드를 두 가지 작성하시오.',NULL,'[] 또는 list()','대괄호를 사용하거나 내장 함수 list()를 사용하여 빈 리스트를 만들 수 있습니다.','대괄호 사용',2,1,'N',180,0,'2026-03-27 21:48:28'),
(5,NULL,5,11,'M','물리 - 뉴턴 제2법칙 (긴 지문형)','수식과 내용에 따르면, 질량 $m$이 2배로 증가할 때 가속도 $a$는 어떻게 변하는가?','다음 지문을 읽고 물음에 답하시오.\n\n> \"물체의 가속도는 작용한 힘에 비례하고 질량에 반비례한다.\"\n\n이를 뉴턴의 제2법칙이라 부르며, 수식으로는 다음과 같이 나타낼 수 있다.\n\n$$ F = m \\cdot a $$\n\n여기서 힘 $F$가 $\\underline{\\text{일정}}$하게 유지될 때, 다음 물음에 답하라.','','수식 $a = \\frac{F}{m}$ 에 대입하여 관계를 파악하세요.','마크다운과 수식을 렌더링하는 테스트입니다.',4,1,'N',300,0,'2026-03-27 21:48:28'),
(6,NULL,6,13,'M','고등 수학 - 정적분 (라텍스 수식형)','다음 주어지는 미적분 문제의 정적분 수행 결과값으로 알맞은 것은?','함수 $f(x) = x \\sin(x)$ 일 때, 정적분 $\\int_{0}^{\\frac{\\pi}{2}} f(x) dx$ 의 값을 구하시오.\n\n(참고: 필요하다면 부분적분법 $\\int u v\' dx = uv - \\int u\' v dx$ 을 활용하시오.)','','부분적분 $u=x, v\'=\\sin(x)$로 치환하면 $u\'=1, v=-\\cos(x)$이므로, $[-x\\cos(x)]_{0}^{\\frac{\\pi}{2}} + \\int_{0}^{\\frac{\\pi}{2}} \\cos(x)dx$ = $0 + [\\sin(x)]_{0}^{\\frac{\\pi}{2}}$ = $1$이 됩니다.','부분적분법을 활용',5,1,'N',600,0,'2026-03-27 21:48:28'),
(7,NULL,7,NULL,'M','[영어] 수능 기출 독해','다음 글의 요지로 가장 적절한 것은?',NULL,'3','지문의 내용을 통해 Indigenous stewardship의 효과를 설명하고 있습니다.',NULL,4,1,'N',120,0,'2026-03-27 21:48:28'),
(8,NULL,8,4,'M','HTML 시맨틱 태그','다음 중 HTML 시맨틱 태그의 역할로 가장 알맞은 것은?','문서의 구조와 의미를 분리해 표현하는 개념을 묻는 문제입니다.','1','시맨틱 태그는 문서 구조를 명확히 해 접근성과 유지보수성을 높입니다.','태그가 무엇을 뜻하는지 생각해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(9,NULL,1,5,'M','CSS 박스 모델','다음 중 CSS 박스 모델에서 margin이 의미하는 것은?','요소 주변의 여백 개념을 확인하는 기본 개념 문제입니다.','2','margin은 요소 바깥쪽 공간을 뜻하고, 요소 간 간격을 만드는 데 쓰입니다.','요소 밖의 공간인지, 안쪽의 공간인지 구분해 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(10,NULL,2,6,'M','JavaScript 배열 메서드','다음 중 원본 배열을 직접 변경하는 JavaScript 메서드는?','배열 메서드가 원본을 바꾸는지 여부를 묻는 문제입니다.','3','splice는 원본 배열을 수정하고, slice나 map은 새 배열을 반환합니다.','원본 배열을 바꾸는 메서드를 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(11,NULL,3,4,'M','Python 리스트 컴프리헨션','다음 중 Python 리스트 컴프리헨션의 특징으로 가장 알맞은 것은?','반복문과 조건식을 한 줄로 압축하는 문법을 확인합니다.','4','리스트 컴프리헨션은 새 리스트를 간결하게 생성할 수 있게 해 줍니다.','반복과 조건을 한 줄로 표현할 수 있는지 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(12,NULL,4,5,'M','Git merge와 rebase','다음 중 Git rebase에 대한 설명으로 가장 알맞은 것은?','브랜치 기록을 정리하는 방식을 확인하는 문제입니다.','1','rebase는 커밋을 다른 기준점 위로 옮겨 히스토리를 정리하는 데 자주 쓰입니다.','기준 커밋을 다시 쌓는다는 느낌으로 생각해 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(13,NULL,5,6,'M','SQL 인덱스','다음 중 SQL 인덱스의 일반적인 역할로 가장 알맞은 것은?','조회 성능과 저장 구조의 관계를 묻는 문제입니다.','2','인덱스는 검색 속도를 높이는 대신 저장 공간과 쓰기 비용이 늘 수 있습니다.','조회는 빨라지지만 모든 작업이 좋아지는 것은 아닙니다.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(14,NULL,6,4,'M','HTTP 상태 코드','다음 중 HTTP 404 상태 코드의 의미로 가장 알맞은 것은?','웹 요청 결과를 해석하는 기본 상태 코드 문제입니다.','3','404는 요청한 리소스를 서버에서 찾을 수 없을 때 사용됩니다.','존재하지 않는 페이지를 떠올려 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(15,NULL,7,5,'M','프로세스와 스레드','다음 중 스레드에 대한 설명으로 가장 알맞은 것은?','운영체제의 실행 단위 차이를 확인하는 문제입니다.','4','스레드는 프로세스 내부에서 실행되는 흐름 단위로, 자원을 공유하며 동작합니다.','프로세스 내부의 실행 흐름인지 생각해 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(16,NULL,8,6,'M','TCP와 UDP','다음 중 UDP의 특징으로 가장 알맞은 것은?','전송 계층 프로토콜의 성질을 비교하는 문제입니다.','1','UDP는 연결 설정이 없고 오버헤드가 적어 빠르지만 신뢰성 보장은 상대적으로 약합니다.','연결 절차가 간단한지 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(17,NULL,1,4,'M','스택과 큐','다음 중 큐(Queue)의 자료구조 특징으로 가장 알맞은 것은?','선입선출 개념을 확인하는 기본 자료구조 문제입니다.','2','큐는 먼저 들어온 데이터가 먼저 나가는 FIFO 구조입니다.','대기 줄을 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(18,NULL,2,5,'M','시간 복잡도','다음 중 빅오 표기법 O(n) 의 의미로 가장 알맞은 것은?','입력 크기에 따른 증가 양상을 묻는 문제입니다.','3','O(n)은 입력 크기에 비례해 처리 시간이 증가하는 형태를 말합니다.','입력이 두 배면 수행량도 대체로 두 배인지 생각해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(19,NULL,3,6,'M','정규화','다음 중 데이터베이스 정규화의 주된 목적은?','중복과 이상 현상을 줄이는 설계 개념을 묻습니다.','4','정규화는 데이터 중복을 줄이고 삽입/갱신/삭제 이상을 완화하는 데 목적이 있습니다.','중복을 줄이고 일관성을 높이는 방향을 떠올려 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(20,NULL,4,4,'M','REST API','다음 중 REST API 설계 원칙에 가장 가까운 것은?','리소스 중심 설계와 HTTP 메서드 사용을 확인합니다.','1','REST는 리소스를 URI로 표현하고 HTTP 메서드로 행위를 구분하는 방식입니다.','리소스를 중심으로 생각해 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(21,NULL,5,5,'M','인증과 인가','다음 중 인가(Authorization)에 대한 설명으로 가장 알맞은 것은?','로그인 이후 권한 판단의 의미를 구분하는 문제입니다.','2','인가는 사용자가 어떤 자원에 접근할 수 있는지 권한을 확인하는 과정입니다.','“무엇을 할 수 있는가”를 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(22,NULL,6,6,'M','React props와 state','다음 중 React state의 특징으로 가장 알맞은 것은?','컴포넌트 내부 상태와 외부 입력을 구분하는 문제입니다.','3','state는 컴포넌트 내부에서 관리되는 값이며, 변화에 따라 화면이 다시 렌더링될 수 있습니다.','컴포넌트 내부에서 바뀌는 값인지 생각해 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(23,NULL,7,4,'M','async와 await','다음 중 JavaScript의 await 키워드 설명으로 가장 알맞은 것은?','비동기 함수의 흐름 제어를 묻는 문제입니다.','4','await는 Promise가 처리될 때까지 현재 async 함수의 실행을 잠시 멈춘 것처럼 보이게 합니다.','Promise 결과를 기다린다고 생각해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(24,NULL,8,5,'M','정규식','다음 중 정규식에서 + 의 일반적인 의미로 가장 알맞은 것은?','반복 패턴 표현의 기본 문법을 확인합니다.','1','+는 바로 앞 패턴이 1회 이상 반복됨을 뜻합니다.','한 번 이상 반복인지 떠올려 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(25,NULL,1,6,'M','UTF-8 인코딩','다음 중 UTF-8의 특징으로 가장 알맞은 것은?','문자 인코딩 방식의 기본 성질을 묻는 문제입니다.','2','UTF-8은 가변 길이 인코딩이며 ASCII와 호환성을 가집니다.','문자마다 바이트 수가 달라질 수 있는지 생각해 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(26,NULL,2,4,'M','Factory Method 패턴','다음 중 Factory Method 패턴의 의도로 가장 알맞은 것은?','객체 생성 책임을 분리하는 디자인 패턴 문제입니다.','3','Factory Method는 객체 생성을 서브클래스나 별도 메서드에 위임해 유연성을 높입니다.','생성 코드를 한 곳에 고정하지 않는다고 생각해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(27,NULL,3,5,'M','상속과 합성','다음 중 합성(composition)에 대한 설명으로 가장 알맞은 것은?','객체 간 관계를 설계할 때의 선택을 묻는 문제입니다.','4','합성은 객체를 포함 관계로 조합하는 방식으로, 상속보다 유연할 수 있습니다.','“is-a”보다 “has-a” 관계를 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(28,NULL,4,6,'M','단위 테스트와 통합 테스트','다음 중 단위 테스트의 일반적인 특징으로 가장 알맞은 것은?','테스트 범위의 크기를 구분하는 문제입니다.','1','단위 테스트는 작은 기능 단위를 독립적으로 검증하는 테스트입니다.','작고 독립적인 범위를 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(29,NULL,5,4,'M','리눅스 권한','다음 중 Linux 파일 권한의 세 그룹으로 가장 알맞은 것은?','소유자와 그룹, 기타 사용자 권한 구분을 묻는 문제입니다.','2','권한은 보통 소유자(owner), 그룹(group), 기타(other)로 나눠 관리합니다.','3개 묶음으로 생각해 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(30,NULL,6,5,'M','브랜치 전략','다음 중 Git 브랜치 전략의 일반적인 목적은?','협업 시 코드 변경을 분리하고 관리하는 방식을 묻습니다.','3','브랜치 전략은 작업을 분리하고 충돌을 줄이며 협업 흐름을 관리하는 데 도움이 됩니다.','작업을 나눠 병합하기 쉽게 만든다고 생각해 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(31,NULL,7,6,'M','JSON과 XML','다음 중 JSON의 일반적인 특징으로 가장 알맞은 것은?','데이터 교환 포맷의 구조 차이를 확인하는 문제입니다.','4','JSON은 가볍고 사람이 읽기 쉬운 구조로 API 응답에 자주 쓰입니다.','중괄호와 대괄호를 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(32,NULL,8,4,'M','Flexbox 정렬','다음 중 Flexbox의 justify-content 속성이 주로 다루는 것은?','플렉스 컨테이너의 주축 정렬을 묻는 문제입니다.','1','justify-content는 주축 방향으로 아이템을 어떻게 배치할지 정합니다.','주축 방향 정렬인지 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(33,NULL,1,5,'M','DOM 이벤트 버블링','다음 중 DOM 이벤트 버블링에 대한 설명으로 가장 알맞은 것은?','이벤트가 상위 요소로 전파되는 흐름을 묻는 문제입니다.','2','버블링은 이벤트가 발생한 요소에서 상위 요소 방향으로 전파되는 현상입니다.','안쪽에서 바깥쪽으로 올라간다고 생각해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(34,NULL,2,6,'M','localStorage와 sessionStorage','다음 중 sessionStorage의 특징으로 가장 알맞은 것은?','브라우저 저장소의 지속 범위를 비교하는 문제입니다.','3','sessionStorage는 세션 단위로 유지되며 탭을 닫으면 일반적으로 사라집니다.','탭이나 세션이 끝날 때를 떠올려 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(35,NULL,3,4,'M','인덱스 스캔과 시크','다음 중 index seek의 일반적인 의미로 가장 알맞은 것은?','DB 조회 계획에서 인덱스를 활용하는 방식을 묻습니다.','4','seek는 인덱스를 이용해 필요한 위치를 빠르게 찾는 동작을 뜻합니다.','인덱스로 목표 위치를 바로 찾는다고 생각해 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(36,NULL,4,5,'M','캡슐화','다음 중 객체지향에서 캡슐화의 목적에 가장 가까운 것은?','정보 은닉과 인터페이스 분리를 확인하는 문제입니다.','1','캡슐화는 내부 구현을 숨기고 필요한 기능만 외부에 제공하는 개념입니다.','내부를 감추고 외부에는 사용법만 보여준다고 생각해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(37,NULL,5,6,'M','INNER JOIN과 LEFT JOIN','다음 중 LEFT JOIN의 일반적인 특징으로 가장 알맞은 것은?','조인 방식에 따라 결과 집합이 달라지는지 묻는 문제입니다.','2','LEFT JOIN은 왼쪽 테이블의 행을 모두 유지하고 오른쪽이 없으면 NULL을 채울 수 있습니다.','왼쪽 기준으로 결과가 남는지 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(38,NULL,6,4,'M','TLS와 HTTPS','다음 중 HTTPS가 제공하는 대표적인 이점으로 가장 알맞은 것은?','웹 통신 보안의 기본 목적을 묻는 문제입니다.','3','HTTPS는 TLS를 이용해 전송 구간의 암호화와 무결성 보호에 도움을 줍니다.','전송 중 도청과 변조를 줄이는 기능을 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(39,NULL,7,5,'M','기본 키와 유니크','다음 중 primary key의 일반적인 특징으로 가장 알맞은 것은?','식별자 제약의 의미를 구분하는 문제입니다.','4','기본 키는 레코드를 고유하게 식별하며 NULL을 허용하지 않는 경우가 일반적입니다.','행을 유일하게 구분하는 값인지 생각해 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(40,NULL,8,6,'M','Debounce와 Throttle','다음 중 debounce의 일반적인 동작으로 가장 알맞은 것은?','연속 이벤트 처리 타이밍을 제어하는 기법을 묻습니다.','1','debounce는 이벤트가 잠시 멈춘 뒤 마지막 동작만 실행하는 데 적합합니다.','멈춘 뒤 한 번 실행하는 느낌을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(41,NULL,1,4,'M','Stable Sort','다음 중 안정 정렬(stable sort)의 의미로 가장 알맞은 것은?','같은 키를 가진 원소의 상대적 순서를 보존하는지 묻는 문제입니다.','2','안정 정렬은 키 값이 같은 원소들의 기존 순서를 유지합니다.','같은 값의 순서가 유지되는지 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(42,NULL,2,5,'M','MVC와 MVVM','다음 중 MVVM 패턴의 핵심 요소로 가장 알맞은 것은?','UI와 데이터 바인딩 구조를 비교하는 문제입니다.','3','MVVM은 View와 ViewModel을 통해 화면 상태와 로직을 분리하는 패턴입니다.','화면과 상태를 연결하는 중간 계층을 떠올려 보세요.',5,1,'N',180,5,'2026-03-27 21:48:28'),
(43,NULL,3,6,'M','해시 충돌','다음 중 해시 충돌(collision)의 의미로 가장 알맞은 것은?','해시 함수의 한계를 이해하는 기본 개념 문제입니다.','4','서로 다른 입력이 같은 해시 값으로 매핑되는 상황을 충돌이라고 합니다.','서로 다른 값이 같은 해시를 만드는 상황입니다.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(44,NULL,4,4,'M','API 페이지네이션','다음 중 페이지네이션의 일반적인 목적은?','대량 데이터를 나누어 전달하는 목적을 묻습니다.','1','페이지네이션은 한 번에 많은 데이터를 보내지 않고 나눠서 전달해 응답 부담을 줄입니다.','목록을 여러 페이지로 나눠 보여준다고 생각해 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(45,NULL,5,5,'M','CSS position','다음 중 position: absolute 의 일반적인 특징으로 가장 알맞은 것은?','CSS 배치 방식의 기준 요소를 묻는 문제입니다.','2','absolute는 가장 가까운 위치 지정 조상 요소를 기준으로 배치될 수 있습니다.','기준이 되는 부모를 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(46,NULL,6,6,'M','배열과 연결 리스트','다음 중 연결 리스트의 일반적인 장점으로 가장 알맞은 것은?','자료 구조의 삽입/삭제 특성을 비교하는 문제입니다.','3','연결 리스트는 노드 연결을 조정해 중간 삽입/삭제에 유리할 수 있습니다.','중간에 끼워 넣는 작업을 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(47,NULL,7,4,'M','스택 오버플로와 힙 오버플로','다음 중 스택 오버플로의 일반적인 원인으로 가장 알맞은 것은?','재귀 호출과 스택 메모리 한계를 확인하는 문제입니다.','4','재귀가 너무 깊어지면 스택 공간이 부족해질 수 있습니다.','재귀 호출이 과도해질 때를 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(48,NULL,8,5,'M','이진 탐색 트리','다음 중 이진 탐색 트리(BST)의 기본 규칙으로 가장 알맞은 것은?','왼쪽과 오른쪽 서브트리의 값 관계를 묻는 문제입니다.','1','BST는 왼쪽 서브트리에는 작은 값, 오른쪽 서브트리에는 큰 값이 오도록 유지합니다.','왼쪽은 작고 오른쪽은 큰 규칙을 생각해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(49,NULL,1,6,'M','컴파일러와 인터프리터','다음 중 인터프리터 방식의 일반적인 설명으로 가장 알맞은 것은?','실행 방식 차이를 이해하는 기본 개념 문제입니다.','2','인터프리터는 소스 코드를 한 줄씩 해석하며 실행하는 방식으로 설명할 수 있습니다.','해석하면서 바로 실행하는 흐름을 떠올려 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(50,NULL,2,4,'M','메모리 누수와 OOM','다음 중 메모리 누수(memory leak)의 일반적인 설명으로 가장 알맞은 것은?','반복 실행 중 메모리 해제가 제대로 되지 않는 상황을 묻습니다.','3','메모리 누수는 더 이상 필요 없는 메모리를 해제하지 못해 누적되는 현상입니다.','사용하지 않는 메모리가 계속 남는 상황을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(51,NULL,3,5,'M','Cookies와 Session','다음 중 Cookie의 일반적인 특징으로 가장 알맞은 것은?','웹 상태 유지 방식의 차이를 묻는 문제입니다.','4','쿠키는 브라우저에 저장되며 만료 시간과 속성 설정을 가질 수 있습니다.','브라우저에 저장되는 작은 정보 조각을 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(52,NULL,4,6,'M','CSRF와 XSS','다음 중 XSS 공격의 일반적인 설명으로 가장 알맞은 것은?','웹 보안 공격 유형을 구분하는 문제입니다.','1','XSS는 악성 스크립트를 삽입해 다른 사용자의 브라우저에서 실행되게 하는 공격입니다.','스크립트가 브라우저에서 실행되는지 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(53,NULL,5,4,'M','오버로딩과 오버라이딩','다음 중 오버라이딩(overriding)의 설명으로 가장 알맞은 것은?','같은 이름의 메서드를 재정의하는 개념을 묻습니다.','2','오버라이딩은 상속받은 메서드를 하위 클래스에서 다시 정의하는 것입니다.','부모 메서드를 자식이 다시 작성하는지 생각해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:28'),
(54,NULL,6,5,'M','제3정규형(3NF)','다음 중 제3정규형(3NF)의 일반적인 목적은?','함수 종속성과 데이터 중복을 줄이는 설계 원칙을 묻습니다.','3','3NF는 이행적 종속을 제거해 데이터 중복과 이상 현상을 줄이는 데 도움이 됩니다.','기본 키가 아닌 컬럼 간 종속을 떠올려 보세요.',2,1,'N',90,0,'2026-03-27 21:48:28'),
(55,NULL,7,6,'M','ACID 속성','다음 중 데이터베이스 ACID의 A가 의미하는 것은?','트랜잭션의 기본 성질을 묻는 문제입니다.','4','A는 Atomicity로, 트랜잭션이 전부 성공하거나 전부 실패하는 원자성을 뜻합니다.','전부 아니면 전무의 개념을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:28'),
(56,NULL,8,4,'M','CDN','다음 중 CDN의 일반적인 역할로 가장 알맞은 것은?','콘텐츠 전송 최적화 개념을 확인하는 문제입니다.','1','CDN은 여러 지역의 캐시 서버를 통해 콘텐츠 전달 속도와 안정성을 높이는 데 도움을 줍니다.','가까운 서버에서 콘텐츠를 받는 구조를 떠올려 보세요.',4,1,'N',150,0,'2026-03-27 21:48:28'),
(57,NULL,1,5,'M','BFS와 DFS','다음 중 BFS의 일반적인 탐색 방식으로 가장 알맞은 것은?','그래프 탐색 순서를 구분하는 문제입니다.','2','BFS는 시작 정점에서 가까운 정점부터 넓게 탐색하는 방식입니다.','너비 우선 탐색이라는 이름을 떠올려 보세요.',5,1,'N',180,0,'2026-03-27 21:48:28'),
(58,NULL,2,4,'M','김철수 확장 문제 01 - 학습 전략','다음 중 자기주도 학습 계획을 세울 때 가장 먼저 확인해야 할 요소는 무엇인가?','학습 루틴을 점검하고 복습 주기를 설계하는 상황을 가정한 문제입니다.','1','우선순위를 잘못 잡으면 계획이 길어도 학습 효율이 떨어집니다.','공부 시간보다 먼저 우선순위를 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(59,NULL,3,5,'M','김철수 확장 문제 02 - 오답 정리','다음 중 오답 노트를 작성할 때 가장 효과적인 방법으로 알맞은 것은 무엇인가?','틀린 이유를 다시 적어 보는 방식으로 오답 노트의 밀도를 높이는 문제입니다.','2','정답만 적는 오답 노트는 금방 잊히므로 틀린 이유와 교정 포인트가 필요합니다.','틀린 이유를 다시 설명할 수 있는지를 기준으로 보세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(60,NULL,4,6,'M','김철수 확장 문제 03 - 파이썬 문법','다음 중 파이썬 문법에 대한 설명으로 가장 알맞은 것은 무엇인가?','조건문, 반복문, 자료형, 함수 사용 습관을 함께 묻는 파이썬 복습 문제입니다.','3','문법 자체보다 어떤 상황에서 쓰는지 떠올리면 빠르게 정답에 도달할 수 있습니다.','파이썬 기본 문법의 사용 맥락을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(61,NULL,5,15,'M','김철수 확장 문제 04 - 자료구조','다음 중 자료구조의 특징에 대한 설명으로 가장 알맞은 것은 무엇인가?','배열, 연결 리스트, 트리, 그래프 등 자료구조의 핵심 목적을 비교하는 문제입니다.','1','자료구조는 데이터를 저장하는 방식만이 아니라, 꺼내 쓰는 비용 차이까지 생각해야 합니다.','삽입과 삭제가 자주 일어나는 상황을 상상해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(62,NULL,6,16,'M','김철수 확장 문제 05 - 정렬과 탐색','다음 중 정렬 또는 탐색 알고리즘에 대한 설명으로 가장 알맞은 것은 무엇인가?','시간 복잡도와 적용 상황을 함께 생각해야 하는 알고리즘 복습 문제입니다.','2','알고리즘은 무조건 빠른 것이 아니라 문제 조건에 맞게 고르는 것이 핵심입니다.','정렬과 탐색은 입력 크기에 따라 선택이 달라집니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(63,NULL,7,18,'M','김철수 확장 문제 06 - 통계 기본기','다음 중 기초 통계 개념에 대한 설명으로 가장 알맞은 것은 무엇인가?','평균, 중앙값, 분산, 표준편차, 확률 해석의 기본기를 다루는 문제입니다.','1','통계 용어는 정의를 외우는 것보다 어떤 데이터를 설명하는지 연결해야 합니다.','대표값과 산포도의 차이를 구분해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(64,NULL,8,20,'M','김철수 확장 문제 07 - HTML/CSS','다음 중 HTML/CSS의 역할 구분에 대한 설명으로 가장 알맞은 것은 무엇인가?','문서 구조와 시각 표현을 구분해 이해하는지 확인하는 프론트엔드 기초 문제입니다.','2','HTML은 구조, CSS는 표현이라는 큰 축을 기억하면 흔들리지 않습니다.','구조와 디자인을 담당하는 언어를 구분하세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(65,NULL,1,21,'M','김철수 확장 문제 08 - JavaScript','다음 중 JavaScript 동작 방식에 대한 설명으로 가장 알맞은 것은 무엇인가?','이벤트 루프, 비동기 처리, DOM 제어 중 핵심 개념을 묻는 문제입니다.','1','JavaScript는 실행 순서와 콜백 처리 흐름을 떠올리면 정리가 쉽습니다.','비동기 작업이 바로 순차 실행되지 않는다는 점을 떠올리세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(66,NULL,2,22,'M','김철수 확장 문제 09 - 스택과 큐','다음 중 스택과 큐의 차이에 대한 설명으로 가장 알맞은 것은 무엇인가?','선입선출과 후입선출의 차이를 실제 예시와 연결해 판단하는 문제입니다.','3','스택은 최근 작업 복귀, 큐는 순차 처리라는 대표 예시를 연결해 보세요.','후입선출과 선입선출 용어를 먼저 떠올리세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(67,NULL,3,23,'M','김철수 확장 문제 10 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(68,NULL,4,4,'M','김철수 확장 문제 11 - 학습 전략','다음 중 자기주도 학습 계획을 세울 때 가장 먼저 확인해야 할 요소는 무엇인가?','학습 루틴을 점검하고 복습 주기를 설계하는 상황을 가정한 문제입니다.','1','우선순위를 잘못 잡으면 계획이 길어도 학습 효율이 떨어집니다.','공부 시간보다 먼저 우선순위를 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(69,NULL,5,5,'M','김철수 확장 문제 12 - 오답 정리','다음 중 오답 노트를 작성할 때 가장 효과적인 방법으로 알맞은 것은 무엇인가?','틀린 이유를 다시 적어 보는 방식으로 오답 노트의 밀도를 높이는 문제입니다.','2','정답만 적는 오답 노트는 금방 잊히므로 틀린 이유와 교정 포인트가 필요합니다.','틀린 이유를 다시 설명할 수 있는지를 기준으로 보세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(70,NULL,6,6,'M','김철수 확장 문제 13 - 파이썬 문법','다음 중 파이썬 문법에 대한 설명으로 가장 알맞은 것은 무엇인가?','조건문, 반복문, 자료형, 함수 사용 습관을 함께 묻는 파이썬 복습 문제입니다.','3','문법 자체보다 어떤 상황에서 쓰는지 떠올리면 빠르게 정답에 도달할 수 있습니다.','파이썬 기본 문법의 사용 맥락을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(71,NULL,7,15,'M','김철수 확장 문제 14 - 자료구조','다음 중 자료구조의 특징에 대한 설명으로 가장 알맞은 것은 무엇인가?','배열, 연결 리스트, 트리, 그래프 등 자료구조의 핵심 목적을 비교하는 문제입니다.','1','자료구조는 데이터를 저장하는 방식만이 아니라, 꺼내 쓰는 비용 차이까지 생각해야 합니다.','삽입과 삭제가 자주 일어나는 상황을 상상해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(72,NULL,8,16,'M','김철수 확장 문제 15 - 정렬과 탐색','다음 중 정렬 또는 탐색 알고리즘에 대한 설명으로 가장 알맞은 것은 무엇인가?','시간 복잡도와 적용 상황을 함께 생각해야 하는 알고리즘 복습 문제입니다.','2','알고리즘은 무조건 빠른 것이 아니라 문제 조건에 맞게 고르는 것이 핵심입니다.','정렬과 탐색은 입력 크기에 따라 선택이 달라집니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(73,NULL,1,18,'M','김철수 확장 문제 16 - 통계 기본기','다음 중 기초 통계 개념에 대한 설명으로 가장 알맞은 것은 무엇인가?','평균, 중앙값, 분산, 표준편차, 확률 해석의 기본기를 다루는 문제입니다.','1','통계 용어는 정의를 외우는 것보다 어떤 데이터를 설명하는지 연결해야 합니다.','대표값과 산포도의 차이를 구분해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(74,NULL,2,20,'M','김철수 확장 문제 17 - HTML/CSS','다음 중 HTML/CSS의 역할 구분에 대한 설명으로 가장 알맞은 것은 무엇인가?','문서 구조와 시각 표현을 구분해 이해하는지 확인하는 프론트엔드 기초 문제입니다.','2','HTML은 구조, CSS는 표현이라는 큰 축을 기억하면 흔들리지 않습니다.','구조와 디자인을 담당하는 언어를 구분하세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(75,NULL,3,21,'M','김철수 확장 문제 18 - JavaScript','다음 중 JavaScript 동작 방식에 대한 설명으로 가장 알맞은 것은 무엇인가?','이벤트 루프, 비동기 처리, DOM 제어 중 핵심 개념을 묻는 문제입니다.','1','JavaScript는 실행 순서와 콜백 처리 흐름을 떠올리면 정리가 쉽습니다.','비동기 작업이 바로 순차 실행되지 않는다는 점을 떠올리세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(76,NULL,4,22,'M','김철수 확장 문제 19 - 스택과 큐','다음 중 스택과 큐의 차이에 대한 설명으로 가장 알맞은 것은 무엇인가?','선입선출과 후입선출의 차이를 실제 예시와 연결해 판단하는 문제입니다.','3','스택은 최근 작업 복귀, 큐는 순차 처리라는 대표 예시를 연결해 보세요.','후입선출과 선입선출 용어를 먼저 떠올리세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(77,NULL,5,23,'M','김철수 확장 문제 20 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(78,NULL,6,4,'M','김철수 확장 문제 21 - 학습 전략','다음 중 자기주도 학습 계획을 세울 때 가장 먼저 확인해야 할 요소는 무엇인가?','학습 루틴을 점검하고 복습 주기를 설계하는 상황을 가정한 문제입니다.','1','우선순위를 잘못 잡으면 계획이 길어도 학습 효율이 떨어집니다.','공부 시간보다 먼저 우선순위를 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(79,NULL,7,5,'M','김철수 확장 문제 22 - 오답 정리','다음 중 오답 노트를 작성할 때 가장 효과적인 방법으로 알맞은 것은 무엇인가?','틀린 이유를 다시 적어 보는 방식으로 오답 노트의 밀도를 높이는 문제입니다.','2','정답만 적는 오답 노트는 금방 잊히므로 틀린 이유와 교정 포인트가 필요합니다.','틀린 이유를 다시 설명할 수 있는지를 기준으로 보세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(80,NULL,8,6,'M','김철수 확장 문제 23 - 파이썬 문법','다음 중 파이썬 문법에 대한 설명으로 가장 알맞은 것은 무엇인가?','조건문, 반복문, 자료형, 함수 사용 습관을 함께 묻는 파이썬 복습 문제입니다.','3','문법 자체보다 어떤 상황에서 쓰는지 떠올리면 빠르게 정답에 도달할 수 있습니다.','파이썬 기본 문법의 사용 맥락을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(81,NULL,1,15,'M','김철수 확장 문제 24 - 자료구조','다음 중 자료구조의 특징에 대한 설명으로 가장 알맞은 것은 무엇인가?','배열, 연결 리스트, 트리, 그래프 등 자료구조의 핵심 목적을 비교하는 문제입니다.','1','자료구조는 데이터를 저장하는 방식만이 아니라, 꺼내 쓰는 비용 차이까지 생각해야 합니다.','삽입과 삭제가 자주 일어나는 상황을 상상해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(82,NULL,2,16,'M','김철수 확장 문제 25 - 정렬과 탐색','다음 중 정렬 또는 탐색 알고리즘에 대한 설명으로 가장 알맞은 것은 무엇인가?','시간 복잡도와 적용 상황을 함께 생각해야 하는 알고리즘 복습 문제입니다.','2','알고리즘은 무조건 빠른 것이 아니라 문제 조건에 맞게 고르는 것이 핵심입니다.','정렬과 탐색은 입력 크기에 따라 선택이 달라집니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(83,NULL,3,18,'M','김철수 확장 문제 26 - 통계 기본기','다음 중 기초 통계 개념에 대한 설명으로 가장 알맞은 것은 무엇인가?','평균, 중앙값, 분산, 표준편차, 확률 해석의 기본기를 다루는 문제입니다.','1','통계 용어는 정의를 외우는 것보다 어떤 데이터를 설명하는지 연결해야 합니다.','대표값과 산포도의 차이를 구분해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(84,NULL,4,20,'M','김철수 확장 문제 27 - HTML/CSS','다음 중 HTML/CSS의 역할 구분에 대한 설명으로 가장 알맞은 것은 무엇인가?','문서 구조와 시각 표현을 구분해 이해하는지 확인하는 프론트엔드 기초 문제입니다.','2','HTML은 구조, CSS는 표현이라는 큰 축을 기억하면 흔들리지 않습니다.','구조와 디자인을 담당하는 언어를 구분하세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(85,NULL,5,21,'M','김철수 확장 문제 28 - JavaScript','다음 중 JavaScript 동작 방식에 대한 설명으로 가장 알맞은 것은 무엇인가?','이벤트 루프, 비동기 처리, DOM 제어 중 핵심 개념을 묻는 문제입니다.','1','JavaScript는 실행 순서와 콜백 처리 흐름을 떠올리면 정리가 쉽습니다.','비동기 작업이 바로 순차 실행되지 않는다는 점을 떠올리세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(86,NULL,6,22,'M','김철수 확장 문제 29 - 스택과 큐','다음 중 스택과 큐의 차이에 대한 설명으로 가장 알맞은 것은 무엇인가?','선입선출과 후입선출의 차이를 실제 예시와 연결해 판단하는 문제입니다.','3','스택은 최근 작업 복귀, 큐는 순차 처리라는 대표 예시를 연결해 보세요.','후입선출과 선입선출 용어를 먼저 떠올리세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(87,NULL,7,23,'M','김철수 확장 문제 30 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(88,NULL,8,4,'M','김철수 확장 문제 31 - 학습 전략','다음 중 자기주도 학습 계획을 세울 때 가장 먼저 확인해야 할 요소는 무엇인가?','학습 루틴을 점검하고 복습 주기를 설계하는 상황을 가정한 문제입니다.','1','우선순위를 잘못 잡으면 계획이 길어도 학습 효율이 떨어집니다.','공부 시간보다 먼저 우선순위를 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(89,NULL,1,5,'M','김철수 확장 문제 32 - 오답 정리','다음 중 오답 노트를 작성할 때 가장 효과적인 방법으로 알맞은 것은 무엇인가?','틀린 이유를 다시 적어 보는 방식으로 오답 노트의 밀도를 높이는 문제입니다.','2','정답만 적는 오답 노트는 금방 잊히므로 틀린 이유와 교정 포인트가 필요합니다.','틀린 이유를 다시 설명할 수 있는지를 기준으로 보세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(90,NULL,2,6,'M','김철수 확장 문제 33 - 파이썬 문법','다음 중 파이썬 문법에 대한 설명으로 가장 알맞은 것은 무엇인가?','조건문, 반복문, 자료형, 함수 사용 습관을 함께 묻는 파이썬 복습 문제입니다.','3','문법 자체보다 어떤 상황에서 쓰는지 떠올리면 빠르게 정답에 도달할 수 있습니다.','파이썬 기본 문법의 사용 맥락을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(91,NULL,3,15,'M','김철수 확장 문제 34 - 자료구조','다음 중 자료구조의 특징에 대한 설명으로 가장 알맞은 것은 무엇인가?','배열, 연결 리스트, 트리, 그래프 등 자료구조의 핵심 목적을 비교하는 문제입니다.','1','자료구조는 데이터를 저장하는 방식만이 아니라, 꺼내 쓰는 비용 차이까지 생각해야 합니다.','삽입과 삭제가 자주 일어나는 상황을 상상해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(92,NULL,4,16,'M','김철수 확장 문제 35 - 정렬과 탐색','다음 중 정렬 또는 탐색 알고리즘에 대한 설명으로 가장 알맞은 것은 무엇인가?','시간 복잡도와 적용 상황을 함께 생각해야 하는 알고리즘 복습 문제입니다.','2','알고리즘은 무조건 빠른 것이 아니라 문제 조건에 맞게 고르는 것이 핵심입니다.','정렬과 탐색은 입력 크기에 따라 선택이 달라집니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(93,NULL,5,18,'M','김철수 확장 문제 36 - 통계 기본기','다음 중 기초 통계 개념에 대한 설명으로 가장 알맞은 것은 무엇인가?','평균, 중앙값, 분산, 표준편차, 확률 해석의 기본기를 다루는 문제입니다.','1','통계 용어는 정의를 외우는 것보다 어떤 데이터를 설명하는지 연결해야 합니다.','대표값과 산포도의 차이를 구분해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(94,NULL,6,20,'M','김철수 확장 문제 37 - HTML/CSS','다음 중 HTML/CSS의 역할 구분에 대한 설명으로 가장 알맞은 것은 무엇인가?','문서 구조와 시각 표현을 구분해 이해하는지 확인하는 프론트엔드 기초 문제입니다.','2','HTML은 구조, CSS는 표현이라는 큰 축을 기억하면 흔들리지 않습니다.','구조와 디자인을 담당하는 언어를 구분하세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(95,NULL,7,21,'M','김철수 확장 문제 38 - JavaScript','다음 중 JavaScript 동작 방식에 대한 설명으로 가장 알맞은 것은 무엇인가?','이벤트 루프, 비동기 처리, DOM 제어 중 핵심 개념을 묻는 문제입니다.','1','JavaScript는 실행 순서와 콜백 처리 흐름을 떠올리면 정리가 쉽습니다.','비동기 작업이 바로 순차 실행되지 않는다는 점을 떠올리세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(96,NULL,8,22,'M','김철수 확장 문제 39 - 스택과 큐','다음 중 스택과 큐의 차이에 대한 설명으로 가장 알맞은 것은 무엇인가?','선입선출과 후입선출의 차이를 실제 예시와 연결해 판단하는 문제입니다.','3','스택은 최근 작업 복귀, 큐는 순차 처리라는 대표 예시를 연결해 보세요.','후입선출과 선입선출 용어를 먼저 떠올리세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(97,NULL,1,23,'M','김철수 확장 문제 40 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(98,NULL,2,4,'M','김철수 확장 문제 41 - 학습 전략','다음 중 자기주도 학습 계획을 세울 때 가장 먼저 확인해야 할 요소는 무엇인가?','학습 루틴을 점검하고 복습 주기를 설계하는 상황을 가정한 문제입니다.','1','우선순위를 잘못 잡으면 계획이 길어도 학습 효율이 떨어집니다.','공부 시간보다 먼저 우선순위를 떠올려 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(99,NULL,3,5,'M','김철수 확장 문제 42 - 오답 정리','다음 중 오답 노트를 작성할 때 가장 효과적인 방법으로 알맞은 것은 무엇인가?','틀린 이유를 다시 적어 보는 방식으로 오답 노트의 밀도를 높이는 문제입니다.','2','정답만 적는 오답 노트는 금방 잊히므로 틀린 이유와 교정 포인트가 필요합니다.','틀린 이유를 다시 설명할 수 있는지를 기준으로 보세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(100,NULL,4,6,'M','김철수 확장 문제 43 - 파이썬 문법','다음 중 파이썬 문법에 대한 설명으로 가장 알맞은 것은 무엇인가?','조건문, 반복문, 자료형, 함수 사용 습관을 함께 묻는 파이썬 복습 문제입니다.','3','문법 자체보다 어떤 상황에서 쓰는지 떠올리면 빠르게 정답에 도달할 수 있습니다.','파이썬 기본 문법의 사용 맥락을 떠올려 보세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(101,NULL,5,15,'M','김철수 확장 문제 44 - 자료구조','다음 중 자료구조의 특징에 대한 설명으로 가장 알맞은 것은 무엇인가?','배열, 연결 리스트, 트리, 그래프 등 자료구조의 핵심 목적을 비교하는 문제입니다.','1','자료구조는 데이터를 저장하는 방식만이 아니라, 꺼내 쓰는 비용 차이까지 생각해야 합니다.','삽입과 삭제가 자주 일어나는 상황을 상상해 보세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(102,NULL,6,16,'M','김철수 확장 문제 45 - 정렬과 탐색','다음 중 정렬 또는 탐색 알고리즘에 대한 설명으로 가장 알맞은 것은 무엇인가?','시간 복잡도와 적용 상황을 함께 생각해야 하는 알고리즘 복습 문제입니다.','2','알고리즘은 무조건 빠른 것이 아니라 문제 조건에 맞게 고르는 것이 핵심입니다.','정렬과 탐색은 입력 크기에 따라 선택이 달라집니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(103,NULL,7,18,'M','김철수 확장 문제 46 - 통계 기본기','다음 중 기초 통계 개념에 대한 설명으로 가장 알맞은 것은 무엇인가?','평균, 중앙값, 분산, 표준편차, 확률 해석의 기본기를 다루는 문제입니다.','1','통계 용어는 정의를 외우는 것보다 어떤 데이터를 설명하는지 연결해야 합니다.','대표값과 산포도의 차이를 구분해 보세요.',1,1,'N',60,0,'2026-03-27 21:48:29'),
(104,NULL,8,20,'M','김철수 확장 문제 47 - HTML/CSS','다음 중 HTML/CSS의 역할 구분에 대한 설명으로 가장 알맞은 것은 무엇인가?','문서 구조와 시각 표현을 구분해 이해하는지 확인하는 프론트엔드 기초 문제입니다.','2','HTML은 구조, CSS는 표현이라는 큰 축을 기억하면 흔들리지 않습니다.','구조와 디자인을 담당하는 언어를 구분하세요.',2,1,'N',90,0,'2026-03-27 21:48:29'),
(105,NULL,1,21,'M','김철수 확장 문제 48 - JavaScript','다음 중 JavaScript 동작 방식에 대한 설명으로 가장 알맞은 것은 무엇인가?','이벤트 루프, 비동기 처리, DOM 제어 중 핵심 개념을 묻는 문제입니다.','1','JavaScript는 실행 순서와 콜백 처리 흐름을 떠올리면 정리가 쉽습니다.','비동기 작업이 바로 순차 실행되지 않는다는 점을 떠올리세요.',3,1,'N',120,0,'2026-03-27 21:48:29'),
(106,NULL,2,22,'M','김철수 확장 문제 49 - 스택과 큐','다음 중 스택과 큐의 차이에 대한 설명으로 가장 알맞은 것은 무엇인가?','선입선출과 후입선출의 차이를 실제 예시와 연결해 판단하는 문제입니다.','3','스택은 최근 작업 복귀, 큐는 순차 처리라는 대표 예시를 연결해 보세요.','후입선출과 선입선출 용어를 먼저 떠올리세요.',4,1,'N',150,0,'2026-03-27 21:48:29'),
(107,NULL,3,18,'M','김철수 확장 문제 50 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-27 21:48:29'),
(108,NULL,2,18,'M','김철수 확장 문제 50 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-31 03:53:45'),
(109,NULL,1,18,'M','김철수 확장 문제 50 - 확률 분포','다음 중 확률 분포에 대한 설명으로 가장 알맞은 것은 무엇인가?','분포의 개념과 기대값/확률 해석을 직관적으로 이해했는지 확인하는 문제입니다.','1','확률 분포는 값 하나가 아니라 값들이 어떤 규칙으로 나타나는지 보는 개념입니다.','하나의 값이 아니라 전체 분포 모양을 보는 개념입니다.',5,1,'N',180,0,'2026-03-31 05:27:48'),
(110,NULL,1,NULL,'S','Reading Passage 1','Read the passage and answer questions 1-5.','Last spring, a small neighborhood turned an empty lot into a community garden. At first, only a few residents joined. They built raised beds, planted herbs, and set up a schedule for watering. By summer, more people visited, sharing seeds and recipes. The garden did more than grow vegetables. It became a place where neighbors who had never spoken before began to talk. When a heat wave arrived, volunteers installed shade cloth and collected rainwater to keep the plants alive. The project showed how shared spaces can strengthen a community.','N/A',NULL,NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(111,110,2,NULL,'M','Passage 1 - Q1','What is the main purpose of the passage?\nA. To compare different kinds of gardens\nB. To describe how a community garden changed a neighborhood\nC. To explain how to build raised beds\nD. To argue against urban farming',NULL,'B','The passage focuses on the social impact of the community garden.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(112,110,2,NULL,'M','Passage 1 - Q2','Which detail shows that the garden encouraged community interaction?\nA. Residents planted herbs\nB. People shared seeds and recipes\nC. The lot was empty\nD. Volunteers installed shade cloth',NULL,'B','Sharing seeds and recipes indicates interaction among neighbors.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(113,110,2,NULL,'M','Passage 1 - Q3','What happened when the heat wave arrived?\nA. The garden closed\nB. Volunteers added shade and collected rainwater\nC. The plants were removed\nD. Residents stopped visiting',NULL,'B','The passage states volunteers installed shade cloth and collected rainwater.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(114,110,2,NULL,'M','Passage 1 - Q4','Which word best describes the tone of the passage?\nA. Critical\nB. Celebratory\nC. Indifferent\nD. Sarcastic',NULL,'B','The passage praises the positive effects of the garden.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(115,110,2,NULL,'M','Passage 1 - Q5','What can be inferred about the neighborhood before the garden?\nA. It was already closely connected\nB. It had no available land\nC. Many neighbors did not know each other\nD. It was famous for farming',NULL,'C','The passage notes neighbors who had never spoken began to talk.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(116,NULL,1,NULL,'S','Reading Passage 2','Read the passage and answer questions 6-10.','A recent study explored how short naps affect memory. Participants learned a list of word pairs, then either stayed awake or took a 30-minute nap. Later, the napping group recalled more pairs. Researchers suggest that during light sleep the brain replays new information, helping to store it. However, the study also found that longer naps did not improve recall and sometimes left participants groggy. The findings imply that brief naps may be a practical way to boost learning without disrupting daily routines.','N/A',NULL,NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(117,116,2,NULL,'M','Passage 2 - Q6','What did the study compare?\nA. Different types of memory tests\nB. People who napped and people who stayed awake\nC. Morning learning and evening learning\nD. Long naps and no naps only',NULL,'B','The study compared a napping group with a staying-awake group.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(118,116,2,NULL,'M','Passage 2 - Q7','Why might a short nap help memory, according to the researchers?\nA. It reduces hunger\nB. The brain replays new information during light sleep\nC. It increases physical strength\nD. It lowers stress permanently',NULL,'B','The passage mentions replay of new information during light sleep.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(119,116,2,NULL,'M','Passage 2 - Q8','What was a downside of longer naps in the study?\nA. They improved recall too much\nB. They had no effect and caused grogginess\nC. They caused participants to forget the words entirely\nD. They were not allowed',NULL,'B','Longer naps did not improve recall and left participants groggy.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(120,116,2,NULL,'M','Passage 2 - Q9','Which statement best summarizes the conclusion?\nA. Sleep never helps learning\nB. Long naps are better than short naps\nC. Brief naps can boost learning without major disruption\nD. Only students benefit from naps',NULL,'C','The findings imply brief naps are practical and helpful.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(121,116,2,NULL,'M','Passage 2 - Q10','What is the primary organizational pattern of the passage?\nA. Problem and solution\nB. Cause and effect\nC. Description of a study and its results\nD. Chronological biography',NULL,'C','It describes the study setup and outcomes.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(122,NULL,1,4,'S','Reading Passage 3','Read the passage and answer questions 11-15.','A coastal town decided to replace its aging power plant with wind turbines. Some residents worried that the turbines would spoil the ocean view, while others hoped they would create jobs. After months of debate, the town council approved a smaller project: fewer turbines placed farther offshore. The plan reduced visual impact and still provided enough electricity for public buildings. One year later, surveys showed that most residents supported the project, and local businesses reported increased tourism from visitors interested in clean energy.','N/A','','',1,1,'N',0,1,'2026-04-01 08:43:36'),
(123,122,2,NULL,'M','Passage 3 - Q11','What was the town replacing?\nA. A bridge\nB. An aging power plant\nC. A fishing port\nD. A highway',NULL,'B','The passage says the town replaced its aging power plant.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(124,122,2,NULL,'M','Passage 3 - Q12','How did the town council respond to the debate?\nA. It canceled the project\nB. It approved a smaller offshore project\nC. It built the largest possible project\nD. It delayed the decision for years',NULL,'B','The council approved fewer turbines placed farther offshore.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(125,122,2,NULL,'M','Passage 3 - Q13','What was one result after one year?\nA. Residents became less supportive\nB. Electricity prices doubled\nC. Tourism increased because of interest in clean energy\nD. The turbines were removed',NULL,'C','Local businesses reported increased tourism from visitors.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(126,122,2,NULL,'M','Passage 3 - Q14','Which concern is mentioned in the passage?\nA. Noise from trains\nB. Loss of ocean view\nC. Damage to farmland\nD. Lack of internet access',NULL,'B','Residents worried the turbines would spoil the ocean view.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(127,122,2,NULL,'M','Passage 3 - Q15','What is the main idea of the passage?\nA. Wind energy always faces opposition\nB. Compromise helped a clean energy project succeed\nC. Tourism is the town primary industry\nD. Power plants are safer than turbines',NULL,'B','A smaller offshore plan balanced concerns and benefits.',NULL,3,1,'N',0,0,'2026-04-01 08:43:36'),
(128,NULL,2,NULL,'S','Reading Passage 4','Read the passage and answer questions 16-20.','An archive recently digitized thousands of historical letters. The project began because the paper was aging and difficult to handle. By scanning the letters and creating searchable transcripts, the archive made the collection available to researchers worldwide. The team also discovered that students were more engaged when they could read the letters online and annotate them. While the digitization required significant time and funding, the archive argued that expanding access was worth the effort.','N/A',NULL,NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(129,128,2,NULL,'M','Passage 4 - Q16','Why did the archive start the digitization project?\nA. The letters were already digital\nB. The paper was aging and hard to handle\nC. Researchers requested paper copies only\nD. The archive wanted to reduce staff',NULL,'B','The passage states the paper was aging and difficult to handle.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(130,128,2,NULL,'M','Passage 4 - Q17','What new benefit did the team notice?\nA. Fewer researchers used the archive\nB. Students were more engaged with online access and annotation\nC. The letters lost their historical value\nD. The project required no funding',NULL,'B','Students engaged more when they could read and annotate online.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(131,128,2,NULL,'M','Passage 4 - Q18','Which best describes the author perspective?\nA. Skeptical about digitization\nB. Neutral but acknowledging benefits and costs\nC. Angry about technology\nD. Dismissive of researchers',NULL,'B','The passage notes the effort and cost while supporting access.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(132,128,2,NULL,'M','Passage 4 - Q19','What does the word expanding most nearly mean in this context?\nA. Reducing\nB. Limiting\nC. Increasing\nD. Hiding',NULL,'C','Expanding access means increasing access.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36'),
(133,128,2,NULL,'M','Passage 4 - Q20','What is the main idea of the passage?\nA. Digitization preserves and broadens access to historical letters\nB. Online archives are always free\nC. Students dislike reading letters\nD. Archives should stop collecting letters',NULL,'A','The passage emphasizes preservation and wider access.',NULL,2,1,'N',0,0,'2026-04-01 08:43:36');
/*!40000 ALTER TABLE `questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `solve_results`
--

DROP TABLE IF EXISTS `solve_results`;
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
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자별 문제 풀이 결과';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solve_results`
--

LOCK TABLES `solve_results` WRITE;
/*!40000 ALTER TABLE `solve_results` DISABLE KEYS */;
INSERT INTO `solve_results` VALUES
(1,2,2,1,'4','5',0,88,'2026-03-27 21:48:29'),
(2,2,4,4,'[] 와 list()','[] 또는 list()',1,75,'2026-03-27 21:48:29'),
(3,2,6,NULL,'2','1',0,241,'2026-03-27 21:48:29'),
(4,2,58,NULL,'3','1',0,96,'2026-03-27 21:48:29'),
(5,2,59,NULL,'2','2',1,72,'2026-03-27 21:48:29'),
(6,2,61,NULL,'1','4',0,103,'2026-03-27 21:48:29'),
(7,2,78,NULL,'4','4',1,91,'2026-03-27 21:48:29'),
(8,4,2,2,'5','5',1,55,'2026-03-27 21:48:29'),
(9,2,47,NULL,'182','4',0,3,'2026-03-27 14:21:05'),
(10,2,107,NULL,'402','1',0,14,'2026-03-27 21:44:49'),
(11,2,107,NULL,'489','1',0,27,'2026-03-27 21:46:31'),
(12,2,107,NULL,'489','1',0,9,'2026-03-28 03:35:50'),
(13,2,50,NULL,'193','3',0,2,'2026-03-31 13:30:23'),
(14,2,50,NULL,'194','3',0,2,'2026-03-31 13:30:32'),
(15,2,42,NULL,'164','3',0,7,'2026-03-31 13:30:48'),
(16,2,130,NULL,'569','B',0,0,'2026-04-01 00:48:40'),
(17,2,129,NULL,'567','B',0,0,'2026-04-01 01:04:08'),
(18,2,129,NULL,'567','B',0,0,'2026-04-01 01:04:40'),
(19,2,130,NULL,'572','B',0,0,'2026-04-01 01:05:04'),
(20,2,132,NULL,'578','C',0,0,'2026-04-01 01:05:06'),
(21,2,131,NULL,'576','B',0,0,'2026-04-01 01:05:08'),
(22,2,129,NULL,'568','B',0,0,'2026-04-01 01:15:37'),
(23,2,129,NULL,'566','B',1,0,'2026-04-01 01:19:10'),
(24,2,130,NULL,'569','B',0,0,'2026-04-01 01:19:10'),
(25,2,131,NULL,'574','B',1,0,'2026-04-01 01:19:10'),
(26,2,132,NULL,'580','C',0,0,'2026-04-01 01:19:10'),
(27,2,133,NULL,'584','A',0,0,'2026-04-01 01:19:10'),
(28,1,21,NULL,'78','2',1,2,'2026-04-01 04:41:59'),
(29,1,20,NULL,'74,73','1',0,9,'2026-04-01 04:42:27'),
(30,1,123,NULL,'547','B',-1,0,'2026-04-01 04:43:11'),
(31,1,124,NULL,'550','B',1,0,'2026-04-01 04:43:11'),
(32,1,125,NULL,'554','C',-1,0,'2026-04-01 04:43:11'),
(33,1,126,NULL,'560','B',-1,0,'2026-04-01 04:43:11'),
(34,1,127,NULL,'561','B',-1,0,'2026-04-01 04:43:11'),
(35,2,98,NULL,'382,393,415,404','1',0,10,'2026-04-01 09:30:49'),
(36,1,1,NULL,'496','3',0,3,'2026-04-02 00:24:16'),
(37,1,21,NULL,'80','2',0,26,'2026-04-02 00:24:51');
/*!40000 ALTER TABLE `solve_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_logs`
--

DROP TABLE IF EXISTS `study_logs`;
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
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='개인별 문제 풀이 기록 및 오답 노트';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_logs`
--

LOCK TABLES `study_logs` WRITE;
/*!40000 ALTER TABLE `study_logs` DISABLE KEYS */;
INSERT INTO `study_logs` VALUES
(1,1,1,'전송/네트워크 헷갈림.',0,2,'2026-03-27 21:48:29',NULL),
(2,1,2,'행위 패턴 조심',1,1,'2026-03-27 21:48:29',NULL),
(3,1,3,NULL,1,3,'2026-03-27 21:48:29',NULL),
(4,1,6,'부분적분법 다시 봐야함.',0,1,'2026-03-27 21:48:29',NULL),
(5,2,47,'문제보기',0,0,'2026-03-27 14:21:02',NULL),
(6,2,47,'문제풀기',0,0,'2026-03-27 14:21:04',NULL),
(7,2,47,'정답확인:오답',0,0,'2026-03-27 14:21:05',NULL),
(8,2,107,'문제보기',0,0,'2026-03-27 21:44:28',NULL),
(9,2,107,'문제보기',0,0,'2026-03-27 21:44:34',NULL),
(10,2,107,'문제풀기',0,0,'2026-03-27 21:44:47',NULL),
(11,2,107,'정답확인:오답',0,0,'2026-03-27 21:44:49',NULL),
(12,2,106,'문제보기',0,0,'2026-03-27 21:44:52',NULL),
(13,2,107,'문제보기',0,0,'2026-03-27 21:46:03',NULL),
(14,2,107,'문제풀기',0,0,'2026-03-27 21:46:30',NULL),
(15,2,107,'정답확인:오답',0,0,'2026-03-27 21:46:31',NULL),
(16,2,107,'문제보기',0,0,'2026-03-28 02:10:10',NULL),
(17,2,107,'문제보기',0,0,'2026-03-28 03:35:40',NULL),
(18,2,107,'문제풀기',0,0,'2026-03-28 03:35:48',NULL),
(19,2,107,'정답확인:오답',0,0,'2026-03-28 03:35:50',NULL),
(20,2,104,'문제보기',0,0,'2026-03-31 03:40:12',NULL),
(21,2,104,'정답확인:시간초과',0,0,'2026-03-31 03:41:43',NULL),
(22,2,104,'문제보기',0,0,'2026-03-31 03:42:57',NULL),
(23,2,107,'문제보기',0,0,'2026-03-31 03:43:21',NULL),
(24,2,107,'문제보기',0,0,'2026-03-31 03:43:45',NULL),
(25,2,107,'문제보기',0,0,'2026-03-31 03:44:55',NULL),
(26,2,50,'문제보기',0,0,'2026-03-31 13:30:20',NULL),
(27,2,50,'문제풀기',0,0,'2026-03-31 13:30:22',NULL),
(28,2,50,'정답확인:오답',0,0,'2026-03-31 13:30:23',NULL),
(29,2,50,'문제보기',0,0,'2026-03-31 13:30:29',NULL),
(30,2,50,'문제풀기',0,0,'2026-03-31 13:30:31',NULL),
(31,2,50,'정답확인:오답',0,0,'2026-03-31 13:30:32',NULL),
(32,2,42,'문제보기',0,0,'2026-03-31 13:30:41',NULL),
(33,2,42,'문제풀기',0,0,'2026-03-31 13:30:43',NULL),
(34,2,42,'정답확인:오답',0,0,'2026-03-31 13:30:48',NULL),
(35,2,133,'문제보기',0,0,'2026-03-31 23:51:31',NULL),
(36,2,133,'문제보기',0,0,'2026-03-31 23:52:13',NULL),
(37,2,128,'문제보기',0,0,'2026-04-01 00:00:34',NULL),
(38,2,128,'문제보기',0,0,'2026-04-01 00:25:29',NULL),
(39,2,128,'문제보기',0,0,'2026-04-01 00:25:48',NULL),
(40,2,128,'문제보기',0,0,'2026-04-01 00:26:16',NULL),
(41,2,128,'문제보기',0,0,'2026-04-01 00:26:37',NULL),
(42,2,128,'문제보기',0,0,'2026-04-01 00:29:34',NULL),
(43,2,128,'문제보기',0,0,'2026-04-01 00:30:56',NULL),
(44,2,128,'문제보기',0,0,'2026-04-01 00:36:24',NULL),
(45,2,128,'문제보기',0,0,'2026-04-01 00:37:04',NULL),
(46,2,128,'문제보기',0,0,'2026-04-01 00:37:12',NULL),
(47,2,108,'문제보기',0,0,'2026-04-01 00:40:29',NULL),
(48,2,128,'문제보기',0,0,'2026-04-01 00:40:31',NULL),
(49,2,128,'문제보기',0,0,'2026-04-01 00:42:41',NULL),
(50,2,128,'문제보기',0,0,'2026-04-01 00:42:51',NULL),
(51,2,128,'문제보기',0,0,'2026-04-01 00:43:46',NULL),
(52,2,129,'문제보기',0,0,'2026-04-01 00:43:48',NULL),
(53,2,129,'문제보기',0,0,'2026-04-01 00:43:55',NULL),
(54,2,128,'문제보기',0,0,'2026-04-01 00:48:22',NULL),
(55,2,129,'문제보기',0,0,'2026-04-01 00:48:23',NULL),
(56,2,128,'문제보기',0,0,'2026-04-01 00:48:30',NULL),
(57,2,130,'문제보기',0,0,'2026-04-01 00:48:35',NULL),
(58,2,130,'문제풀기',0,0,'2026-04-01 00:48:37',NULL),
(59,2,130,'정답확인:오답',0,0,'2026-04-01 00:48:40',NULL),
(60,2,128,'문제보기',0,0,'2026-04-01 00:48:49',NULL),
(61,2,133,'문제보기',0,0,'2026-04-01 00:49:33',NULL),
(62,2,128,'문제보기',0,0,'2026-04-01 00:49:39',NULL),
(63,2,128,'문제보기',0,0,'2026-04-01 01:03:34',NULL),
(64,2,129,'문제풀기',0,0,'2026-04-01 01:04:06',NULL),
(65,2,129,'정답확인:오답',0,0,'2026-04-01 01:04:08',NULL),
(66,2,128,'문제보기',0,0,'2026-04-01 01:04:36',NULL),
(67,2,129,'문제풀기',0,0,'2026-04-01 01:04:39',NULL),
(68,2,129,'정답확인:오답',0,0,'2026-04-01 01:04:40',NULL),
(69,2,130,'문제풀기',0,0,'2026-04-01 01:04:59',NULL),
(70,2,130,'정답확인:오답',0,0,'2026-04-01 01:05:04',NULL),
(71,2,132,'문제풀기',0,0,'2026-04-01 01:05:05',NULL),
(72,2,132,'정답확인:오답',0,0,'2026-04-01 01:05:06',NULL),
(73,2,131,'문제풀기',0,0,'2026-04-01 01:05:07',NULL),
(74,2,131,'정답확인:오답',0,0,'2026-04-01 01:05:08',NULL),
(75,2,128,'문제보기',0,0,'2026-04-01 01:05:36',NULL),
(76,2,108,'문제보기',0,0,'2026-04-01 01:05:42',NULL),
(77,2,128,'문제보기',0,0,'2026-04-01 01:05:44',NULL),
(78,2,108,'문제보기',0,0,'2026-04-01 01:05:47',NULL),
(79,2,106,'문제보기',0,0,'2026-04-01 01:05:47',NULL),
(80,2,98,'문제보기',0,0,'2026-04-01 01:05:47',NULL),
(81,2,90,'문제보기',0,0,'2026-04-01 01:05:48',NULL),
(82,2,82,'문제보기',0,0,'2026-04-01 01:05:48',NULL),
(83,2,74,'문제보기',0,0,'2026-04-01 01:05:48',NULL),
(84,2,66,'문제보기',0,0,'2026-04-01 01:05:48',NULL),
(85,2,58,'문제보기',0,0,'2026-04-01 01:05:49',NULL),
(86,2,50,'문제보기',0,0,'2026-04-01 01:05:49',NULL),
(87,2,58,'문제보기',0,0,'2026-04-01 01:05:53',NULL),
(88,2,66,'문제보기',0,0,'2026-04-01 01:05:53',NULL),
(89,2,74,'문제보기',0,0,'2026-04-01 01:05:53',NULL),
(90,2,82,'문제보기',0,0,'2026-04-01 01:05:53',NULL),
(91,2,90,'문제보기',0,0,'2026-04-01 01:05:54',NULL),
(92,2,98,'문제보기',0,0,'2026-04-01 01:05:54',NULL),
(93,2,98,'정답확인:시간초과',0,0,'2026-04-01 01:06:55',NULL),
(94,2,106,'문제보기',0,0,'2026-04-01 01:07:36',NULL),
(95,2,98,'문제보기',0,0,'2026-04-01 01:07:37',NULL),
(96,2,98,'문제풀기',0,0,'2026-04-01 01:07:38',NULL),
(97,2,98,'정답확인:시간초과',0,0,'2026-04-01 01:08:38',NULL),
(98,2,98,'문제보기',0,0,'2026-04-01 01:10:11',NULL),
(99,2,98,'문제보기',0,0,'2026-04-01 01:10:11',NULL),
(100,2,98,'문제보기',0,0,'2026-04-01 01:10:11',NULL),
(101,2,98,'정답확인:시간초과',0,0,'2026-04-01 01:11:12',NULL),
(102,2,106,'문제보기',0,0,'2026-04-01 01:15:02',NULL),
(103,2,108,'문제보기',0,0,'2026-04-01 01:15:02',NULL),
(104,2,128,'문제보기',0,0,'2026-04-01 01:15:02',NULL),
(105,2,129,'문제풀기',0,0,'2026-04-01 01:15:36',NULL),
(106,2,129,'정답확인:오답',0,0,'2026-04-01 01:15:37',NULL),
(107,2,128,'문제보기',0,0,'2026-04-01 01:16:39',NULL),
(108,2,128,'문제보기',0,0,'2026-04-01 01:18:08',NULL),
(109,2,133,'문제풀기',0,0,'2026-04-01 01:19:03',NULL),
(110,2,132,'문제풀기',0,0,'2026-04-01 01:19:05',NULL),
(111,2,131,'문제풀기',0,0,'2026-04-01 01:19:06',NULL),
(112,2,130,'문제풀기',0,0,'2026-04-01 01:19:07',NULL),
(113,2,129,'문제풀기',0,0,'2026-04-01 01:19:08',NULL),
(114,2,129,'정답확인:정답',0,0,'2026-04-01 01:19:10',NULL),
(115,2,130,'정답확인:오답',0,0,'2026-04-01 01:19:10',NULL),
(116,2,131,'정답확인:정답',0,0,'2026-04-01 01:19:10',NULL),
(117,2,132,'정답확인:오답',0,0,'2026-04-01 01:19:10',NULL),
(118,2,133,'정답확인:오답',0,0,'2026-04-01 01:19:10',NULL),
(119,2,108,'문제보기',0,0,'2026-04-01 01:19:25',NULL),
(120,2,128,'문제보기',0,0,'2026-04-01 01:19:26',NULL),
(121,2,108,'문제보기',0,0,'2026-04-01 01:19:51',NULL),
(122,2,128,'문제보기',0,0,'2026-04-01 01:19:58',NULL),
(123,2,108,'문제보기',0,0,'2026-04-01 01:20:00',NULL),
(124,2,128,'문제보기',0,0,'2026-04-01 01:20:03',NULL),
(125,2,128,'문제보기',0,0,'2026-04-01 01:23:20',NULL),
(126,2,128,'문제보기',0,0,'2026-04-01 01:23:27',NULL),
(127,2,108,'문제보기',0,0,'2026-04-01 01:23:43',NULL),
(128,2,106,'문제보기',0,0,'2026-04-01 01:23:44',NULL),
(129,2,106,'문제풀기',0,0,'2026-04-01 01:23:47',NULL),
(130,2,98,'문제보기',0,0,'2026-04-01 01:23:50',NULL),
(131,2,90,'문제보기',0,0,'2026-04-01 01:23:51',NULL),
(132,2,82,'문제보기',0,0,'2026-04-01 01:23:51',NULL),
(133,2,74,'문제보기',0,0,'2026-04-01 01:23:51',NULL),
(134,2,66,'문제보기',0,0,'2026-04-01 01:23:51',NULL),
(135,2,58,'문제보기',0,0,'2026-04-01 01:23:51',NULL),
(136,2,50,'문제보기',0,0,'2026-04-01 01:23:52',NULL),
(137,2,58,'문제보기',0,0,'2026-04-01 01:23:53',NULL),
(138,2,66,'문제보기',0,0,'2026-04-01 01:23:53',NULL),
(139,2,74,'문제보기',0,0,'2026-04-01 01:23:53',NULL),
(140,2,82,'문제보기',0,0,'2026-04-01 01:23:53',NULL),
(141,2,90,'문제보기',0,0,'2026-04-01 01:23:54',NULL),
(142,2,98,'문제보기',0,0,'2026-04-01 01:23:54',NULL),
(143,2,106,'문제보기',0,0,'2026-04-01 01:23:54',NULL),
(144,2,108,'문제보기',0,0,'2026-04-01 01:23:54',NULL),
(145,2,128,'문제보기',0,0,'2026-04-01 01:23:54',NULL),
(146,2,108,'문제보기',0,0,'2026-04-01 01:23:57',NULL),
(147,2,106,'문제보기',0,0,'2026-04-01 01:23:57',NULL),
(148,2,98,'문제보기',0,0,'2026-04-01 01:23:58',NULL),
(149,2,90,'문제보기',0,0,'2026-04-01 01:23:58',NULL),
(150,2,98,'문제보기',0,0,'2026-04-01 01:23:59',NULL),
(151,2,106,'문제보기',0,0,'2026-04-01 01:24:00',NULL),
(152,2,108,'문제보기',0,0,'2026-04-01 01:24:00',NULL),
(153,2,108,'문제풀기',0,0,'2026-04-01 01:24:14',NULL),
(154,2,108,'문제보기',0,0,'2026-04-01 01:25:45',NULL),
(155,2,108,'정답확인:시간초과',0,0,'2026-04-01 01:28:46',NULL),
(156,2,128,'문제보기',0,0,'2026-04-01 01:29:04',NULL),
(157,2,128,'문제보기',0,0,'2026-04-01 01:29:18',NULL),
(158,2,128,'문제보기',0,0,'2026-04-01 01:29:37',NULL),
(159,2,108,'문제보기',0,0,'2026-04-01 01:29:42',NULL),
(160,2,90,'문제보기',0,0,'2026-04-01 01:29:43',NULL),
(161,2,74,'문제보기',0,0,'2026-04-01 01:29:44',NULL),
(162,2,74,'정답확인:시간초과',0,0,'2026-04-01 01:31:15',NULL),
(163,2,106,'문제보기',0,0,'2026-04-01 01:31:37',NULL),
(164,2,108,'문제보기',0,0,'2026-04-01 01:31:38',NULL),
(165,2,128,'문제보기',0,0,'2026-04-01 01:31:42',NULL),
(166,2,108,'문제보기',0,0,'2026-04-01 01:31:44',NULL),
(167,2,106,'문제보기',0,0,'2026-04-01 01:31:44',NULL),
(168,2,98,'문제보기',0,0,'2026-04-01 01:31:46',NULL),
(169,2,74,'문제보기',0,0,'2026-04-01 01:31:47',NULL),
(170,2,66,'문제보기',0,0,'2026-04-01 01:31:49',NULL),
(171,2,58,'문제보기',0,0,'2026-04-01 01:31:50',NULL),
(172,2,50,'문제보기',0,0,'2026-04-01 01:31:51',NULL),
(173,2,50,'정답확인:시간초과',0,0,'2026-04-01 01:33:52',NULL),
(174,2,106,'문제보기',0,0,'2026-04-01 01:34:03',NULL),
(175,2,82,'문제보기',0,0,'2026-04-01 01:36:00',NULL),
(176,2,74,'문제보기',0,0,'2026-04-01 01:36:00',NULL),
(177,2,66,'문제보기',0,0,'2026-04-01 01:36:01',NULL),
(178,2,58,'문제보기',0,0,'2026-04-01 01:36:02',NULL),
(179,2,74,'문제보기',0,0,'2026-04-01 01:36:03',NULL),
(180,1,21,'문제보기',0,0,'2026-04-01 04:41:57',NULL),
(181,1,21,'문제풀기',0,0,'2026-04-01 04:41:58',NULL),
(182,1,21,'정답확인:정답',0,0,'2026-04-01 04:41:59',NULL),
(183,1,20,'문제보기',0,0,'2026-04-01 04:42:04',NULL),
(184,1,18,'문제보기',0,0,'2026-04-01 04:42:05',NULL),
(185,1,20,'문제보기',0,0,'2026-04-01 04:42:08',NULL),
(186,1,20,'문제풀기',0,0,'2026-04-01 04:42:09',NULL),
(187,1,21,'문제보기',0,0,'2026-04-01 04:42:11',NULL),
(188,1,20,'문제보기',0,0,'2026-04-01 04:42:14',NULL),
(189,1,18,'문제보기',0,0,'2026-04-01 04:42:16',NULL),
(190,1,20,'문제보기',0,0,'2026-04-01 04:42:17',NULL),
(191,1,20,'문제풀기',0,0,'2026-04-01 04:42:19',NULL),
(192,1,20,'정답확인:오답',0,0,'2026-04-01 04:42:27',NULL),
(193,1,122,'문제보기',0,0,'2026-04-01 04:42:56',NULL),
(194,1,127,'문제풀기',0,0,'2026-04-01 04:43:01',NULL),
(195,1,126,'문제풀기',0,0,'2026-04-01 04:43:02',NULL),
(196,1,125,'문제풀기',0,0,'2026-04-01 04:43:04',NULL),
(197,1,124,'문제풀기',0,0,'2026-04-01 04:43:05',NULL),
(198,1,123,'문제풀기',0,0,'2026-04-01 04:43:09',NULL),
(199,1,123,'정답확인:시간초과',0,0,'2026-04-01 04:43:11',NULL),
(200,1,124,'정답확인:정답',0,0,'2026-04-01 04:43:11',NULL),
(201,1,125,'정답확인:시간초과',0,0,'2026-04-01 04:43:11',NULL),
(202,1,126,'정답확인:시간초과',0,0,'2026-04-01 04:43:11',NULL),
(203,1,127,'정답확인:시간초과',0,0,'2026-04-01 04:43:11',NULL),
(204,2,122,'문제보기',0,0,'2026-04-01 09:29:00',NULL),
(205,2,98,'문제보기',0,0,'2026-04-01 09:30:39',NULL),
(206,2,98,'문제풀기',0,0,'2026-04-01 09:30:46',NULL),
(207,2,98,'정답확인:오답',0,0,'2026-04-01 09:30:49',NULL),
(208,1,91,'문제보기',0,0,'2026-04-02 00:23:57',NULL),
(209,1,91,'문제보기',0,0,'2026-04-02 00:24:05',NULL),
(210,1,81,'문제보기',0,0,'2026-04-02 00:24:08',NULL),
(211,1,71,'문제보기',0,0,'2026-04-02 00:24:09',NULL),
(212,1,61,'문제보기',0,0,'2026-04-02 00:24:09',NULL),
(213,1,51,'문제보기',0,0,'2026-04-02 00:24:10',NULL),
(214,1,31,'문제보기',0,0,'2026-04-02 00:24:11',NULL),
(215,1,11,'문제보기',0,0,'2026-04-02 00:24:12',NULL),
(216,1,1,'문제보기',0,0,'2026-04-02 00:24:12',NULL),
(217,1,1,'문제풀기',0,0,'2026-04-02 00:24:15',NULL),
(218,1,1,'정답확인:오답',0,0,'2026-04-02 00:24:16',NULL),
(219,1,21,'문제보기',0,0,'2026-04-02 00:24:24',NULL),
(220,1,21,'문제풀기',0,0,'2026-04-02 00:24:26',NULL),
(221,1,21,'정답확인:오답',0,0,'2026-04-02 00:24:51',NULL),
(222,1,61,'문제보기',0,0,'2026-04-02 00:29:20',NULL),
(223,1,61,'문제풀기',0,0,'2026-04-02 00:29:21',NULL),
(224,2,128,'문제보기',0,0,'2026-04-02 00:43:38',NULL),
(225,2,108,'문제보기',0,0,'2026-04-02 00:45:53',NULL);
/*!40000 ALTER TABLE `study_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
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

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES
(1,'네트워크','2026-03-27 21:48:29'),
(2,'디자인패턴','2026-03-27 21:48:29'),
(3,'영단어','2026-03-27 21:48:29'),
(4,'파이썬','2026-03-27 21:48:29'),
(5,'기초','2026-03-27 21:48:29'),
(6,'고등수학','2026-03-27 21:48:29'),
(7,'미적분','2026-03-27 21:48:29'),
(8,'알고리즘','2026-03-27 21:48:29'),
(9,'통계','2026-03-27 21:48:29'),
(10,'웹개발','2026-03-27 21:48:29');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_comments`
--

DROP TABLE IF EXISTS `user_comments`;
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

--
-- Dumping data for table `user_comments`
--

LOCK TABLES `user_comments` WRITE;
/*!40000 ALTER TABLE `user_comments` DISABLE KEYS */;
INSERT INTO `user_comments` VALUES
(1,1,2,2,'Observer 패턴과 Singleton 패턴의 분류 차이를 다시 설명해 보세요.','2026-03-27 21:48:29'),
(2,1,2,6,'부분적분법 풀이 순서를 줄글로 정리해 두면 기억에 오래 남습니다.','2026-03-27 21:48:29'),
(3,3,2,3,'영단어는 뜻만 말고 예문까지 같이 외우면 훨씬 좋아요.','2026-03-27 21:48:29'),
(4,2,NULL,4,'빈 리스트 생성 문법은 실수 없이 바로 적을 수 있어야 함.','2026-03-27 21:48:29');
/*!40000 ALTER TABLE `user_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_messages`
--

DROP TABLE IF EXISTS `user_messages`;
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

--
-- Dumping data for table `user_messages`
--

LOCK TABLES `user_messages` WRITE;
/*!40000 ALTER TABLE `user_messages` DISABLE KEYS */;
INSERT INTO `user_messages` VALUES
(1,1,2,'이번 주는 알고리즘과 영어 독해를 함께 복습해 봅시다.','Y','2026-03-27 21:48:29'),
(2,3,2,'주말 전에 오답 노트 문제집 한 번만 더 확인해 줘.','N','2026-03-27 21:48:29'),
(3,2,1,'선생님, 자료구조 쪽 문제를 더 풀어보고 싶어요.','Y','2026-03-27 21:48:29'),
(4,2,13,'쪼마나...','N','2026-03-30 08:34:27');
/*!40000 ALTER TABLE `user_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_relations`
--

DROP TABLE IF EXISTS `user_relations`;
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
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 간 관계 매핑 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_relations`
--

LOCK TABLES `user_relations` WRITE;
/*!40000 ALTER TABLE `user_relations` DISABLE KEYS */;
INSERT INTO `user_relations` VALUES
(1,1,2,'TEACHER_PUPIL','2026-03-27 21:48:29'),
(2,2,1,'PUPIL_TEACHER','2026-03-27 21:48:29'),
(3,3,2,'PARENT_CHILD','2026-03-27 21:48:29'),
(4,2,3,'CHILD_PARENT','2026-03-27 21:48:29'),
(5,2,14,'CHILD_PARENT','2026-03-30 07:56:15'),
(6,14,2,'PARENT_CHILD','2026-03-30 07:56:15'),
(17,2,13,'PUPIL_TEACHER','2026-03-30 08:20:42'),
(18,13,2,'TEACHER_PUPIL','2026-03-30 08:20:42'),
(19,2,7,'PUPIL_TEACHER','2026-03-31 13:23:35'),
(20,7,2,'TEACHER_PUPIL','2026-03-31 13:23:35'),
(21,2,10,'FRIEND','2026-04-01 03:48:38'),
(22,10,2,'FRIEND','2026-04-01 03:48:38'),
(23,2,15,'FRIEND','2026-04-01 03:48:39'),
(24,15,2,'FRIEND','2026-04-01 03:48:39'),
(25,1,5,'TEACHER_PUPIL','2026-04-01 04:28:23'),
(26,5,1,'PUPIL_TEACHER','2026-04-01 04:28:23'),
(27,1,10,'TEACHER_PUPIL','2026-04-01 04:28:25'),
(28,10,1,'PUPIL_TEACHER','2026-04-01 04:28:25'),
(29,1,22,'TEACHER_PUPIL','2026-04-01 04:28:25'),
(30,22,1,'PUPIL_TEACHER','2026-04-01 04:28:25'),
(31,3,22,'PARENT_CHILD','2026-04-01 05:49:24'),
(32,22,3,'CHILD_PARENT','2026-04-01 05:49:24');
/*!40000 ALTER TABLE `user_relations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
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
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 정보 테이블';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(0,'0','none','무명','noname@edu-hub.com','S','N','2026-04-02 10:41:31'),
(1,'t','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','제이미','teacher1@edu-hub.com','T','N','2026-03-27 21:48:28'),
(2,'s','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','김철수','student1@edu-hub.com','S','N','2026-03-27 21:48:28'),
(3,'p','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','이영희','parent1@edu-hub.com','P','N','2026-03-27 21:48:28'),
(4,'ss','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','마이클','aaa@aa.aaa','S','N','2026-03-27 21:48:28'),
(5,'x','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','x','x@x.c','S','N','2026-03-27 13:48:19'),
(6,'t2','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','최하늘','teacher2@edu-hub.com','T','N','2026-03-30 09:00:00'),
(7,'t3','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','윤서준','teacher3@edu-hub.com','T','N','2026-03-30 09:00:00'),
(8,'p2','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','한미정','parent2@edu-hub.com','P','N','2026-03-30 09:00:00'),
(9,'p3','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','오지은','parent3@edu-hub.com','P','N','2026-03-30 09:00:00'),
(10,'s2','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','강민준','student2@edu-hub.com','S','N','2026-03-30 09:00:00'),
(11,'s3','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','서예린','student3@edu-hub.com','S','N','2026-03-30 09:00:00'),
(12,'s4','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','정우진','student4@edu-hub.com','S','N','2026-03-30 09:00:00'),
(13,'t4','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','김도윤','teacher4@edu-hub.com','T','N','2026-03-30 09:00:00'),
(14,'p4','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','배수현','parent4@edu-hub.com','P','N','2026-03-30 09:00:00'),
(15,'s5','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','이도현','student5@edu-hub.com','S','N','2026-03-30 09:00:00'),
(16,'t5','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','황유진','teacher5@edu-hub.com','T','N','2026-03-30 09:00:00'),
(17,'p5','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','문지후','parent5@edu-hub.com','P','N','2026-03-30 09:00:00'),
(18,'s6','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','임서윤','student6@edu-hub.com','S','N','2026-03-30 09:00:00'),
(19,'t6','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','장민서','teacher6@edu-hub.com','T','N','2026-03-30 09:00:00'),
(20,'s7','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','홍지호','student7@edu-hub.com','S','N','2026-03-30 09:00:00'),
(21,'p6','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','윤하린','parent6@edu-hub.com','P','N','2026-03-30 09:00:00'),
(22,'s8','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','고서진','student8@edu-hub.com','S','N','2026-03-30 09:00:00'),
(23,'s9','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','차유나','student9@edu-hub.com','S','N','2026-03-30 09:00:00'),
(24,'t7','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','송태영','teacher7@edu-hub.com','T','N','2026-03-30 09:00:00'),
(25,'p7','$2b$10$w0fA4tbVaov4l2Osw6lzyOiwvEUmv9dPVCwFzN4DdVVPHXE2Tdb0u','신가은','parent7@edu-hub.com','P','N','2026-03-30 09:00:00');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'Edu-Hub'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-04-02 13:53:04
--------------------