INSERT INTO users_logs
  (user_no, logtype_id, obj_id, user_content, score, total_score, score100, last_played_at)
VALUES
  (2, 'L', 0, '로그인 세션 시작: 대시보드 진입', 1, 1, 100, DATE_SUB(NOW(), INTERVAL 12 MINUTE)),
  (2, 'Q', 1, '문제보기', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 11 MINUTE)),
  (2, 'Q', 1, '문제풀기', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 10 MINUTE)),
  (2, 'Q', 1, '정답확인:정답', 1, 1, 100, DATE_SUB(NOW(), INTERVAL 9 MINUTE)),
  (2, 'B', 1, '문제집 문제등록 화면 이동', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 8 MINUTE)),
  (2, 'B', 2, '문제집 선택 추가: 김철수 자료구조 집중', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 7 MINUTE)),
  (2, 'E', 1, '고사 문제등록 화면 이동', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 6 MINUTE)),
  (2, 'E', 2, '고사 검색 실행: "정기 테스트"', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 5 MINUTE)),
  (2, 'C', 1, '클래스 구성원 수정: 파이썬 및 네트워크 기초반 (3명 배정)', 3, 3, 100, DATE_SUB(NOW(), INTERVAL 4 MINUTE)),
  (2, 'C', 1, '클래스 고사 연결 수정: 파이썬 및 네트워크 기초반 (2개 연결)', 2, 2, 100, DATE_SUB(NOW(), INTERVAL 3 MINUTE)),
  (2, 'R', 1, '관계 요청 발신: 제이미 (PUPIL_TEACHER)', 0, 0, 0, DATE_SUB(NOW(), INTERVAL 2 MINUTE)),
  (2, 'R', 1, '메시지 발송: 제이미 (24자)', 24, 24, 100, DATE_SUB(NOW(), INTERVAL 1 MINUTE));
