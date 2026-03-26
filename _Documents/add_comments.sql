-- 테이블 주석 추가
ALTER TABLE `user_messages` COMMENT='사용자 간 다이렉트 메시지 테이블';
ALTER TABLE `user_relations` COMMENT='사용자 간 관계 매핑 테이블';
ALTER TABLE `ombudsman_reports` COMMENT='사용자 요구사항 및 피드백 테이블';
ALTER TABLE `user_question_books` COMMENT='사용자별 개인 문제집(북마크)';
ALTER TABLE `user_question_book_items` COMMENT='문제집에 포함된 문제 매핑';

-- 컬럼 주석 추가: user_messages
ALTER TABLE `user_messages` MODIFY COLUMN `message_id` BIGINT COMMENT '메시지 고유 ID';
ALTER TABLE `user_messages` MODIFY COLUMN `sender_no` BIGINT COMMENT '발신자 식별번호';
ALTER TABLE `user_messages` MODIFY COLUMN `receiver_no` BIGINT COMMENT '수신자 식별번호';
ALTER TABLE `user_messages` MODIFY COLUMN `content` TEXT COMMENT '메시지 내용';
ALTER TABLE `user_messages` MODIFY COLUMN `is_read` ENUM('Y', 'N') COMMENT '읽음 여부 (Y: 읽음, N: 안읽음)';
ALTER TABLE `user_messages` MODIFY COLUMN `created_at` DATETIME COMMENT '발신 일시';

-- 컬럼 주석 추가: user_relations
ALTER TABLE `user_relations` MODIFY COLUMN `relation_id` BIGINT COMMENT '관계 고유 ID';
ALTER TABLE `user_relations` MODIFY COLUMN `user_no_1` BIGINT COMMENT '사용자 1 (주체)';
ALTER TABLE `user_relations` MODIFY COLUMN `user_no_2` BIGINT COMMENT '사용자 2 (대상)';
ALTER TABLE `user_relations` MODIFY COLUMN `relation_type_id` VARCHAR(20) COMMENT '관계 유형 (enm_relation_types 참조)';
ALTER TABLE `user_relations` MODIFY COLUMN `created_at` DATETIME COMMENT '관계 생성 일시';

-- 컬럼 주석 추가: ombudsman_reports
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `report_id` BIGINT COMMENT '민원 고유 ID';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `user_no` BIGINT COMMENT '작성자 식별번호';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `category` ENUM('OPINION', 'IMPROVEMENT', 'COMPLAINT') COMMENT '민원 분류';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `title` VARCHAR(255) COMMENT '민원 제목';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `content` TEXT COMMENT '민원 상세 내용';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `status` ENUM('PENDING', 'PROCESSED') COMMENT '처리 상태';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `created_at` DATETIME COMMENT '작성 일시';
ALTER TABLE `ombudsman_reports` MODIFY COLUMN `updated_at` DATETIME COMMENT '수정 일시';

-- 컬럼 주석 추가: user_question_books
ALTER TABLE `user_question_books` MODIFY COLUMN `book_id` BIGINT COMMENT '문제집 ID';
ALTER TABLE `user_question_books` MODIFY COLUMN `user_no` BIGINT COMMENT '소유자 식별번호';
ALTER TABLE `user_question_books` MODIFY COLUMN `book_name` VARCHAR(255) COMMENT '문제집 제목';
ALTER TABLE `user_question_books` MODIFY COLUMN `description` TEXT COMMENT '문제집 설명';
ALTER TABLE `user_question_books` MODIFY COLUMN `created_at` DATETIME COMMENT '생성 일시';

-- 컬럼 주석 추가: user_question_book_items
ALTER TABLE `user_question_book_items` MODIFY COLUMN `book_id` BIGINT COMMENT '문제집 ID';
ALTER TABLE `user_question_book_items` MODIFY COLUMN `question_id` BIGINT COMMENT '문제 ID';

-- 컬럼 주석 추가: questions.is_public
ALTER TABLE `questions` MODIFY COLUMN `is_public` BOOLEAN COMMENT '웹 공유 활성화 여부 (0:비공개, 1:공개)';
