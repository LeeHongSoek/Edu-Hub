/*
 Edu-Hub DB 샘플 데이터 (Edu-Hub-sample-data.sql)
*/

-- 0. 기초 데이터 (ENUM 대체) 추가
INSERT INTO `enm_roles` (`role_id`, `role_name`, `description`) VALUES
('T', 'TEACHER', '교사'),
('S', 'STUDENT', '학생'),
('P', 'PARENT', '학부모');

INSERT INTO `enm_question_types` (`type_id`, `type_name`, `description`) VALUES
('M', 'MULTIPLE_CHOICE', '객관식'),
('S', 'SUBJECTIVE', '주관식');

INSERT INTO `enm_media_types` (`type_id`, `type_name`, `description`) VALUES
('I', 'image', '이미지'),
('Y', 'youtube', '유튜브 동영상');

-- 1. 사용자 데이터 추가
INSERT INTO `users` (`user_id`, `username`, `email`, `role_id`) VALUES
('hong123', '홍길동', 'teacher1@edu-hub.com', 'T'),
('kim123', '김철수', 'student1@edu-hub.com', 'S'),
('lee123', '이영희', 'parent1@edu-hub.com', 'P');

-- 2. 학급 관리, 학생 매핑, 학부모 매핑 데이터 추가
INSERT INTO `classes` (`teacher_no`, `class_name`) VALUES
(1, '파이썬 및 네트워크 기초반');
INSERT INTO `class_students` (`class_id`, `student_no`) VALUES
(1, 2); -- 홍길동 교사의 반에 김철수 학생 소속
INSERT INTO `parent_students` (`parent_no`, `student_no`) VALUES
(3, 2); -- 이영희 학부모의 자녀 김철수

-- 3. 계층형 그룹 데이터 추가 (최대 3층, 사용자 3명이 각자 독립적으로 그룹 관리)
-- 3-1. 사용자 1(교사)의 그룹
INSERT INTO `groups` (`group_id`, `creator_no`, `parent_group_id`, `depth`, `name`, `description`) VALUES
(1, 1, NULL, 1, '컴퓨터 공학', '컴공 자료'),
(2, 1, 1,    2, 'IT 자격증', 'IT 자격증'),
(3, 1, 2,    3, '정보처리기사 실기', '2026 기출');

-- 3-2. 사용자 2(학생)의 자율 학습용 그룹
INSERT INTO `groups` (`group_id`, `creator_no`, `parent_group_id`, `depth`, `name`, `description`) VALUES
(4, 2, NULL, 1, '내 공부장', '개인 자율 복습'),
(5, 2, 4,    2, '오답 노트', '틀린 문제들만'),
(6, 2, 5,    3, '파이썬 기초', '파이썬 복습');

-- 3-3. 사용자 3(학부모)의 자녀 학습 관리 그룹
INSERT INTO `groups` (`group_id`, `creator_no`, `parent_group_id`, `depth`, `name`, `description`) VALUES
(7, 3, NULL, 1, '아이 학습 관리', '부모 정리 문제'),
(8, 3, 7,    2, '영어 단어장', '영단어 모음'),
(9, 3, 8,    3, '중등 필수 영단어', '알아야 할 단어들');

-- 4. 문제 데이터 추가 (긴 지문과 서식 지원 테스트)
INSERT INTO `questions` (`question_id`, `creator_no`, `group_id`, `question_type_id`, `title`, `question`, `content`, `answer`, `explanation`, `hint`, `difficulty`, `is_public`, `is_deleted`) VALUES
(1, 1, 3, 'M', 'OSI 7계층 - 전송 계층 (4지선다)', 'OSI 7계층 중 종단 간(End-to-End) 신뢰성 있는 정보 전송을 담당하는 계층은?', NULL, '', '전송 계층(Transport Layer)은 TCP와 UDP 프로토콜이 대표적이며 오류 복구와 흐름 제어 등을 담당합니다.', 'TCP/UDP가 속한 계층', 3, TRUE, 'N'),
(2, 1, 3, 'M', '디자인 패턴 - 생성 (5지선다)', '다음 중 소프트웨어 객체 지향 디자인 패턴의 생성(Creational) 패턴이 아닌 것은?', NULL, '', 'Observer 패턴은 행위(Behavioral) 패턴에 속합니다.', '상태 변화를 관찰하는 패턴은 생성과 무관합니다.', 4, TRUE, 'N'),
(3, 3, 9, 'M', '영어 단어 - Abandon (4지선다)', '다음 중 영어 단어 ''Abandon''의 뜻으로 가장 알맞은 것은?', NULL, '', '어원은 프랑스어 abandonner (넘겨주다)에서 유래했으며, give up과 유사한 의미를 가집니다.', 'give up과 비슷한 뜻', 1, TRUE, 'N'),
(4, 2, 6, 'S', '파이썬 - 리스트 기초 (주관식)', '파이썬에서 비어있는 리스트를 생성하는 코드를 두 가지 작성하시오.', NULL, '[] 또는 list()', '대괄호를 사용하거나 내장 함수 list()를 사용하여 빈 리스트를 만들 수 있습니다.', '대괄호 사용', 2, TRUE, 'N'),
(5, 1, 1, 'M', '물리 - 뉴턴 제2법칙 (긴 지문형)', '수식과 내용에 따르면, 질량 $m$이 2배로 증가할 때 가속도 $a$는 어떻게 변하는가?', '다음 지문을 읽고 물음에 답하시오.\n\n> "물체의 가속도는 작용한 힘에 비례하고 질량에 반비례한다."\n\n이를 뉴턴의 제2법칙이라 부르며, 수식으로는 다음과 같이 나타낼 수 있다.\n\n$$ F = m \\cdot a $$\n\n여기서 힘 $F$가 $\\underline{\\text{일정}}$하게 유지될 때, 다음 물음에 답하라.', '', '수식 $a = \\frac{F}{m}$ 에 대입하여 관계를 파악하세요.', '마크다운과 수식을 렌더링하는 테스트입니다.', 4, TRUE, 'N'),
(6, 1, 1, 'M', '고등 수학 - 정적분 (라텍스 수식형)', '다음 주어지는 미적분 문제의 정적분 수행 결과값으로 알맞은 것은?', '함수 $f(x) = x \\sin(x)$ 일 때, 정적분 $\\int_{0}^{\\frac{\\pi}{2}} f(x) dx$ 의 값을 구하시오.\n\n(참고: 필요하다면 부분적분법 $\\int u v'' dx = uv - \\int u'' v dx$ 을 활용하시오.)', '', '부분적분 $u=x, v''=\\sin(x)$로 치환하면 $u''=1, v=-\\cos(x)$이므로, $[-x\\cos(x)]_{0}^{\\frac{\\pi}{2}} + \\int_{0}^{\\frac{\\pi}{2}} \\cos(x)dx$ = $0 + [\\sin(x)]_{0}^{\\frac{\\pi}{2}}$ = $1$이 됩니다.', '부분적분법을 활용', 5, TRUE, 'N');


-- 5. 객관식 보기 데이터 추가 (question_options)
INSERT INTO `question_options` (`question_id`, `option_number`, `content`, `is_answer`) VALUES
-- 1번 문제의 보기 (4지선다, 정답: 4)
(1, 1, '물리 계층', FALSE), (1, 2, '데이터 링크 계층', FALSE), (1, 3, '네트워크 계층', FALSE), (1, 4, '전송 계층', TRUE),
-- 2번 문제의 보기 (5지선다, 정답: 5)
(2, 1, 'Singleton', FALSE), (2, 2, 'Factory Method', FALSE), (2, 3, 'Abstract Factory', FALSE), (2, 4, 'Builder', FALSE), (2, 5, 'Observer', TRUE),
-- 3번 문제의 보기 (4지선다, 정답: 2)
(3, 1, '성취하다', FALSE), (3, 2, '버리다, 포기하다', TRUE), (3, 3, '획득하다', FALSE), (3, 4, '유지하다', FALSE),
-- 5번 문제의 보기 (5지선다, 정답: 2)
(5, 1, '변화 없음', FALSE), (5, 2, '절반(1/2)으로 감소한다', TRUE), (5, 3, '2배로 증가한다', FALSE), (5, 4, '제곱에 비례하여 증가한다', FALSE), (5, 5, '알 수 없다', FALSE),
-- 6번 문제의 보기 (5지선다, 정답: 1)
(6, 1, '1', TRUE), (6, 2, '$\\frac{\\pi}{2}$', FALSE), (6, 3, '$\\pi$', FALSE), (6, 4, '0', FALSE), (6, 5, '$-1$', FALSE);

-- 6. 미디어 리소스 데이터 추가
INSERT INTO `media_attachments` (`question_id`, `media_type_id`, `media_url`, `sort_order`) VALUES
(1, 'I', 'https://s3.example.com/edu-hub/osi_7_layer.png', 1),
(1, 'Y', 'https://www.youtube.com/watch?v=example1', 2),
(2, 'I', 'https://s3.example.com/edu-hub/singleton_diagram.png', 1),
(4, 'Y', 'https://www.youtube.com/watch?v=example2', 1);

-- 7. 해시태그 데이터 추가
INSERT INTO `tags` (`tag_id`, `tag_name`) VALUES
(1, '네트워크'), (2, '디자인패턴'), (3, '영단어'), (4, '파이썬'), (5, '기초'), (6, '고등수학'), (7, '미적분');

-- 8. 문제-태그 매핑
INSERT INTO `question_tags` (`question_id`, `tag_id`) VALUES
(1, 1),
(2, 2),
(3, 3), (3, 5),
(4, 4), (4, 5),
(6, 6), (6, 7);

-- 9. 고사(이벤트) 5개 추가 (교사 3종, 학생 자율 1종, 학부모 주도 1종)
INSERT INTO `exams` (`exam_id`, `creator_no`, `class_id`, `exam_name`, `start_time`, `end_time`, `location`, `is_auto_score`) VALUES
(1, 1, 1,    '1월 정보처리 기초 모의고사 (교사 생성)', '2026-01-20 14:00:00', '2026-01-20 15:00:00', '온라인 CBT', TRUE),
(2, 1, 1,    '2월 정기 테스트 (교사 생성)',         '2026-02-15 10:00:00', '2026-02-15 11:00:00', '제1 시험장', TRUE),
(3, 1, NULL, '전국 단위 공개 시험 (교사 생성)',    '2026-03-01 13:00:00', '2026-03-01 13:30:00', '온라인', TRUE),
(4, 2, NULL, '내 약점 파악 모의고사 (학생 자율)',      '2026-03-22 18:00:00', '2026-03-22 19:00:00', '내 책상', TRUE),
(5, 3, NULL, '우리아이 주말 확인 점검 (학부모 생성)',    '2026-03-25 10:00:00', '2026-03-25 11:00:00', '자택 거실', TRUE);

-- 10. 고사별 문제 매핑
INSERT INTO `exam_questions` (`exam_id`, `question_id`, `question_order`, `score`) VALUES
(1, 1, 1, 50), (1, 2, 2, 50), -- 1월 모의고사
(2, 1, 1, 50), (2, 2, 2, 50), -- 2월 정기 테스트
(3, 1, 1, 100),               -- 전국 공개 시험
(4, 4, 1, 100),               -- 학생 자율 (파이썬)
(5, 3, 1, 100);               -- 학부모 모의고사 (영어)

-- 11. 고사 결과 리포트 (학생 2번의 결과 예제)
INSERT INTO `exam_results` (`exam_id`, `student_no`, `total_score`, `student_rank`, `total_examinees`, `grade`, `ai_comment`, `teacher_comment`) VALUES
(1, 2, 50, 15, 30, '미', '[AI 분석] 네트워크 계층은 훌륭하나 디자인 패턴 복습 요망.', '철수 학생, 디자인 패턴을 다시 봅시다.'),
(4, 2, 100, 1, 1, '수', '[AI 분석] 파이썬 자율 모의고사를 모두 맞췄습니다.', NULL);

-- 12. 사용자별 주석 (문제에 대한 메모)
INSERT INTO `user_comments` (`author_no`, `target_user_no`, `question_id`, `content`) VALUES
(1, 2, 1, '김철수 학생, 이 문제는 꼭 복습하세요.'), -- 교사가 학생에게 전송
(2, NULL, 3, 'abandon 스펠링 주의.'); -- 학생 본인 확인용 메모

-- 13. 학습 기록 (누적 복습 정보)
INSERT INTO `study_logs` (`user_no`, `question_id`, `user_memo`, `is_correct`, `try_count`, `next_review_at`) VALUES
(2, 1, '전송/네트워크 헷갈림.', FALSE, 2, DATE_ADD(NOW(), INTERVAL 1 DAY)),
(2, 2, '행위 패턴 조심', TRUE, 1, DATE_ADD(NOW(), INTERVAL 3 DAY)),
(2, 3, NULL, TRUE, 3, DATE_ADD(NOW(), INTERVAL 7 DAY)),
(2, 6, '부분적분법 다시 봐야함.', FALSE, 1, DATE_ADD(NOW(), INTERVAL 2 DAY));

-- 14. 실 개별 문제 풀이 결과
INSERT INTO `solve_results` (`user_no`, `question_id`, `exam_id`, `submitted_answer`, `is_correct`, `time_taken`, `solved_at`) VALUES
(2, 1, 1, '4', TRUE, 45, '2026-01-20 14:05:00'),   -- 1월 시험 중 풀이 (정답)
(2, 2, 1, '3', FALSE, 120, '2026-01-20 14:10:00'), -- 1월 시험 중 풀이 (오답)
(2, 4, 4, 'list()', TRUE, 15, '2026-03-22 18:05:00'),-- 자율 시험 풀이 (정답)
(2, 3, NULL, '1', FALSE, 20, '2026-03-22 10:06:00'), -- 일반 자율 풀이
(2, 6, NULL, '2', FALSE, 300, '2026-03-22 16:00:00'); -- 수학 자율 풀이 (오답)
