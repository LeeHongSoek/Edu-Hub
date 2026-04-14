-- Rename user_question_book_items -> questionbook_question.
-- This migration is safe to re-run.

SET @db_name := DATABASE();

SET @has_old_table := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = @db_name
    AND table_name = 'user_question_book_items'
);

SET @has_new_table := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = @db_name
    AND table_name = 'questionbook_question'
);

SET @rename_table_sql := IF(
  @has_old_table > 0 AND @has_new_table = 0,
  'RENAME TABLE `user_question_book_items` TO `questionbook_question`',
  'SELECT 1'
);
PREPARE rename_table_stmt FROM @rename_table_sql;
EXECUTE rename_table_stmt;
DEALLOCATE PREPARE rename_table_stmt;
