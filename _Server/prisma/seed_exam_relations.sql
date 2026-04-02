-- 고사집과 문제를 골고루 연결하기 위한 데이터 보정 SQL
-- 각 고사집마다 약 5~10개의 문제가 랜덤하게(순차적 분산) 연결되도록 구성

INSERT IGNORE INTO exam_questions (exam_id, question_id, question_order, score)
SELECT e.exam_id, q.question_id, 
       ROW_NUMBER() OVER(PARTITION BY e.exam_id ORDER BY q.question_id) as question_order, 
       10 as score
FROM exams e, questions q
WHERE q.question_id BETWEEN 1 AND 100
  AND e.exam_id BETWEEN 1 AND 100
  AND (e.exam_id * 7 + q.question_id) % 10 = 0; -- 약 10%의 확률로 매핑 (고사집당 평균 10문제)
