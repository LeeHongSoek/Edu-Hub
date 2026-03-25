/*
 Edu-Hub DB 초기화 스크립트 (Edu-Hub-clear.sql)
*/

-- 1. 외래키 검사 일시 중지
SET FOREIGN_KEY_CHECKS = 0;

-- 2. 역순으로 테이블 모두 삭제 (IF EXISTS로 없는 테이블 무시)
DROP TABLE IF EXISTS `enm_media_types`;
DROP TABLE IF EXISTS `enm_question_types`;
DROP TABLE IF EXISTS `enm_roles`;

DROP TABLE IF EXISTS `solve_results`;
DROP TABLE IF EXISTS `study_logs`;
DROP TABLE IF EXISTS `user_comments`;
DROP TABLE IF EXISTS `enm_relation_types`;
DROP TABLE IF EXISTS `exam_results`;
DROP TABLE IF EXISTS `exam_questions`;
DROP TABLE IF EXISTS `exams`;
DROP TABLE IF EXISTS `question_tags`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `media_attachments`;
DROP TABLE IF EXISTS `question_options`;
DROP TABLE IF EXISTS `questions`;
DROP TABLE IF EXISTS `question_reviews`;
DROP TABLE IF EXISTS `groups`;
DROP TABLE IF EXISTS `parent_students`;
DROP TABLE IF EXISTS `class_students`;
DROP TABLE IF EXISTS `classes`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `question_passages`;

-- 3. 외래키 검사 원상 복구
SET FOREIGN_KEY_CHECKS = 1;
