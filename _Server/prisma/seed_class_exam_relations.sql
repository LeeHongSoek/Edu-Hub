-- user_no = 1 선생님의 샘플 클래스-고사 다대다 연결 데이터
-- classes: 1(파이썬 및 네트워크 기초반), 8(네트워크 기초 A반), 15(코딩 테스트 초급반)
-- exams: 1, 27, 35, 44, 53

INSERT IGNORE INTO brg_class_exam (class_id, exam_id) VALUES
  (1, 1),
  (1, 35),
  (8, 27),
  (8, 53),
  (15, 27),
  (15, 44);
