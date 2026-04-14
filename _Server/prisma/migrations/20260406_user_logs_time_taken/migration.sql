ALTER TABLE users_logs
  ADD COLUMN time_taken INT NULL DEFAULT 0 COMMENT '문제 풀이 소요 시간(초)' AFTER score100;

UPDATE users_logs
SET time_taken = 0
WHERE time_taken IS NULL;

ALTER TABLE users_logs
  DROP COLUMN last_played_at;
