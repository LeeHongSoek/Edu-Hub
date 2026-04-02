ALTER TABLE `exams`
  ADD COLUMN IF NOT EXISTS `is_deleted` ENUM('Y','N','T') NOT NULL DEFAULT 'N' COMMENT '삭제 여부 (Y: 삭제, N: 디폴트, T: 휴지통)';

ALTER TABLE `questionbook`
  ADD COLUMN IF NOT EXISTS `is_deleted` ENUM('Y','N','T') NOT NULL DEFAULT 'N' COMMENT '삭제 여부 (Y: 삭제, N: 디폴트, T: 휴지통)';
