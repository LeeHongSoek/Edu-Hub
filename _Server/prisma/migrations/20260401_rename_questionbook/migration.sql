-- Rename user_question_books -> questionbook and repair the FK from
-- user_question_book_items in a way that is safe to re-run.

SET @db_name := DATABASE();

SET @has_old_table := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = @db_name
    AND table_name = 'user_question_books'
);

SET @has_new_table := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = @db_name
    AND table_name = 'questionbook'
);

SET @has_old_fk := (
  SELECT COUNT(*)
  FROM information_schema.referential_constraints
  WHERE constraint_schema = @db_name
    AND table_name = 'user_question_book_items'
    AND constraint_name = 'fk_uqbi_book'
    AND referenced_table_name = 'user_question_books'
);

SET @drop_fk_sql := IF(
  @has_old_fk > 0,
  'ALTER TABLE `user_question_book_items` DROP FOREIGN KEY `fk_uqbi_book`',
  'SELECT 1'
);
PREPARE drop_fk_stmt FROM @drop_fk_sql;
EXECUTE drop_fk_stmt;
DEALLOCATE PREPARE drop_fk_stmt;

SET @rename_table_sql := IF(
  @has_old_table > 0 AND @has_new_table = 0,
  'RENAME TABLE `user_question_books` TO `questionbook`',
  'SELECT 1'
);
PREPARE rename_table_stmt FROM @rename_table_sql;
EXECUTE rename_table_stmt;
DEALLOCATE PREPARE rename_table_stmt;

SET @has_new_fk := (
  SELECT COUNT(*)
  FROM information_schema.referential_constraints
  WHERE constraint_schema = @db_name
    AND table_name = 'user_question_book_items'
    AND constraint_name = 'fk_uqbi_book'
    AND referenced_table_name = 'questionbook'
);

SET @add_fk_sql := IF(
  @has_new_fk = 0,
  'ALTER TABLE `user_question_book_items` ADD CONSTRAINT `fk_uqbi_book` FOREIGN KEY (`book_id`) REFERENCES `questionbook`(`book_id`) ON DELETE CASCADE',
  'SELECT 1'
);
PREPARE add_fk_stmt FROM @add_fk_sql;
EXECUTE add_fk_stmt;
DEALLOCATE PREPARE add_fk_stmt;
