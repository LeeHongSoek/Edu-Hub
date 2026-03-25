/*
 Edu-Hub DB 샘플 데이터 (Edu-Hub-sample_data.sql)
 - 실제 로컬 데이터베이스 상태와 동기화됨 (2026-03-25)
*/

-- 1. 사용자 데이터 추가
INSERT INTO `users` (`user_no`, `user_id`, `user_pw`, `username`, `email`, `role_id`, `is_withdrawn`) VALUES
(1, 'a', '$2b$10$8DUUwzrxVmk1ilG2akDWy.9me9C9WP9n.Y..bhBQj4aT21tNhayJ6', '제이미 A', 'teacher1@edu-hub.com', 'T', 'N'),
(2, 'b', '$2b$10$8DUUwzrxVmk1ilG2akDWy.9me9C9WP9n.Y..bhBQj4aT21tNhayJ6', '김철수', 'student1@edu-hub.com', 'S', 'N'),
(3, 'c', '$2b$10$8DUUwzrxVmk1ilG2akDWy.9me9C9WP9n.Y..bhBQj4aT21tNhayJ6', '이영희', 'parent1@edu-hub.com', 'P', 'N'),
(4, 'd', '$2b$10$8DUUwzrxVmk1ilG2akDWy.9me9C9WP9n.Y..bhBQj4aT21tNhayJ6', '제이미', 'aaa@aa.aaa', 'S', 'N');

-- 2. 학급 관리 및 학생 매핑
INSERT INTO `classes` (`class_id`, `teacher_no`, `class_name`) VALUES
(1, 1, '파이썬 및 네트워크 기초반');

INSERT INTO `class_students` (`class_id`, `student_no`) VALUES
(1, 2);

-- 3. 사용자 관계 (필요 시 추가)
-- INSERT INTO `user_relations` (`user_no_1`, `user_no_2`, `relation_type_id`) VALUES (3, 2, 'PARENT_CHILD');

-- 4. 계층형 그룹 데이터
INSERT INTO `groups` (`group_id`, `creator_no`, `parent_group_id`, `depth`, `name`, `description`) VALUES
(1, 1, NULL, 1, '컴퓨터 공학', '컴공 자료'),
(2, 1, 1, 2, 'IT 자격증', 'IT 자격증'),
(3, 1, 2, 3, '정보처리기사 실기', '2026 기출'),
(4, 2, NULL, 1, '내 공부장', '개인 자율 복습'),
(5, 2, 4, 2, '오답 노트', '틀린 문제들만'),
(6, 2, 5, 3, '파이썬 기초', '파이썬 복습'),
(7, 3, NULL, 1, '아이 학습 관리', '부모 정리 문제'),
(8, 3, 7, 2, '영어 단어장', '영단어 모음'),
(9, 3, 8, 3, '중등 필수 영단어', '알아야 할 단어들'),
(10, 1, NULL, 1, '고등 과학', '과학 탐구'),
(11, 1, 10, 2, '물리', '물리 기초'),
(12, 1, NULL, 1, '고등 수학', '수학 기초'),
(13, 1, 12, 2, '미적분', '미분과 적분');

-- 5. 문제 데이터 (Markdown 및 LaTeX 지원)
INSERT INTO `questions` (`question_id`, `creator_no`, `group_id`, `question_type_id`, `title`, `question`, `content`, `answer`, `explanation`, `hint`, `difficulty`, `is_public`, `time_limit`) VALUES
(1, 1, 3, 'M', 'Test', 'Test', NULL, '', '', '', 1, 1, 0),
(2, 1, 3, 'M', '디자인 패턴 - 생성 (5지선다)', '다음 중 소프트웨어 객체 지향 디자인 패턴의 생성(Creational) 패턴이 아닌 것은?', NULL, '', 'Observer 패턴은 행위(Behavioral) 패턴에 속합니다.', '상태 변화를 관찰하는 패턴은 생성과 무관합니다.', 4, 1, 120),
(3, 3, 9, 'M', '영어 단어 - Abandon (4지선다)', '다음 중 영어 단어 \'Abandon\'의 뜻으로 가장 알맞은 것은?', NULL, '', '어원은 프랑스어 abandonner (넘겨주다)에서 유래했으며, give up과 유사한 의미를 가집니다.', 'give up과 비슷한 뜻', 1, 1, 30),
(4, 2, 6, 'S', '파이썬 - 리스트 기초 (주관식)', '파이썬에서 비어있는 리스트를 생성하는 코드를 두 가지 작성하시오.', NULL, '[] 또는 list()', '대괄호를 사용하거나 내장 함수 list()를 사용하여 빈 리스트를 만들 수 있습니다.', '대괄호 사용', 2, 1, 180),
(5, 1, 11, 'M', '물리 - 뉴턴 제2법칙 (긴 지문형)', '수식과 내용에 따르면, 질량 $m$이 2배로 증가할 때 가속도 $a$는 어떻게 변하는가?', '다음 지문을 읽고 물음에 답하시오.\n\n> "물체의 가속도는 작용한 힘에 비례하고 질량에 반비례한다."\n\n이를 뉴턴의 제2법칙이라 부르며, 수식으로는 다음과 같이 나타낼 수 있다.\n\n$$ F = m \\cdot a $$\n\n여기서 힘 $F$가 $\\underline{\\text{일정}}$하게 유지될 때, 다음 물음에 답하라.', '', '수식 $a = \\frac{F}{m}$ 에 대입하여 관계를 파악하세요.', '마크다운과 수식을 렌더링하는 테스트입니다.', 4, 1, 300),
(6, 1, 13, 'M', '고등 수학 - 정적분 (라텍스 수식형)', '다음 주어지는 미적분 문제의 정적분 수행 결과값으로 알맞은 것은?', '함수 $f(x) = x \\sin(x)$ 일 때, 정적분 $\\int_{0}^{\\frac{\\pi}{2}} f(x) dx$ 의 값을 구하시오.\n\n(참고: 필요하다면 부분적분법 $\\int u v\' dx = uv - \\int u\' v dx$ 을 활용하시오.)', '', '부분적분 $u=x, v\'=\\sin(x)$로 치환하면 $u\'=1, v=-\\cos(x)$이므로, $[-x\\cos(x)]_{0}^{\\frac{\\pi}{2}} + \\int_{0}^{\\frac{\\pi}{2}} \\cos(x)dx$ = $0 + [\\sin(x)]_{0}^{\\frac{\\pi}{2}}$ = $1$이 됩니다.', '부분적분법을 활용', 5, 1, 600),
(7, 2, NULL, 'M', '[영어] 수능 기출 독해', '다음 글의 요지로 가장 적절한 것은?', NULL, '3', '지문의 내용을 통해 Indigenous stewardship의 효과를 설명하고 있습니다.', NULL, 4, 1, 120);

-- 6. 객관식 보기 데이터
INSERT INTO `question_options` (`question_id`, `option_number`, `content`, `is_answer`) VALUES
(2, 1, 'Singleton', 0), (2, 2, 'Factory Method', 0), (2, 3, 'Abstract Factory', 0), (2, 4, 'Builder', 0), (2, 5, 'Observer', 1),
(3, 1, '성취하다', 0), (3, 2, '버리다, 포기하다', 1), (3, 3, '획득하다', 0), (3, 4, '유지하다', 0),
(5, 1, '변화 없음', 0), (5, 2, '절반(1/2)으로 감소한다', 1), (5, 3, '2배로 증가한다', 0), (5, 4, '제곱에 비례하여 증가한다', 0), (5, 5, '알 수 없다', 0),
(6, 1, '1', 1), (6, 2, '$\\frac{\\pi}{2}$', 0), (6, 3, '$\\pi$', 0), (6, 4, '0', 0), (6, 5, '$-1$', 0),
(7, 1, '자연을 보존하려면 인간의 접근을 전면 차단해야 한다.', 0), (7, 2, '원주민의 삶의 터전을 새로운 구역으로 이주시켜야 한다.', 0), (7, 3, '원주민의 관리가 생물 다양성 유지에 더 효과적일 수 있다.', 1), (7, 4, '자연 보존 구역의 경제적 가치는 계속 하락하고 있다.', 0), (7, 5, '최근 연구는 전통적 방식의 한계를 지적하고 있다.', 0);

-- 7. 지문 데이터
INSERT INTO `question_passages` (`question_id`, `content_md`) VALUES
(7, '### Reading Comprehension\n\n![Forest](https://images.unsplash.com/photo-1448375240586-882707db888b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80)\n\nMany people believe that the best way to preserve nature is to keep humans out of it in completely pristine reserves. However, **recent studies** show that indigenous stewardship is often more effective at maintaining biodiversity.');

-- 8. 미디어 리소스
INSERT INTO `media_attachments` (`question_id`, `media_type_id`, `media_url`, `sort_order`) VALUES
(1, 'I', 'https://s3.example.com/edu-hub/osi_7_layer.png', 1),
(1, 'Y', 'https://www.youtube.com/watch?v=example1', 2),
(2, 'I', 'https://s3.example.com/edu-hub/singleton_diagram.png', 1),
(4, 'Y', 'https://www.youtube.com/watch?v=example2', 1);

-- 9. 해시태그 및 매핑
INSERT INTO `tags` (`tag_id`, `tag_name`) VALUES
(1, '네트워크'), (2, '디자인패턴'), (3, '영단어'), (4, '파이썬'), (5, '기초'), (6, '고등수학'), (7, '미적분');

INSERT INTO `question_tags` (`question_id`, `tag_id`) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (3, 5), (4, 5), (6, 6), (6, 7);

-- 10. 고사 데이터
INSERT INTO `exams` (`exam_id`, `creator_no`, `class_id`, `exam_name`, `start_time`, `end_time`, `location`, `is_auto_score`) VALUES
(1, 1, 1, '1월 정보처리 기초 모의고사 (교사 생성)', '2026-01-20 14:00:00', '2026-01-20 15:00:00', '온라인 CBT', 1),
(2, 1, 1, '2월 정기 테스트 (교사 생성)', '2026-02-15 10:00:00', '2026-02-15 11:00:00', '제1 시험장', 1),
(3, 1, NULL, '전국 단위 공개 시험 (교사 생성)', '2026-03-01 13:00:00', '2026-03-01 13:30:00', '온라인', 1),
(4, 2, NULL, '내 약점 파악 모의고사 (학생 자율)', '2026-03-22 18:00:00', '2026-03-22 19:00:00', '내 책상', 1),
(5, 3, NULL, '우리아이 주말 확인 점검 (학부모 생성)', '2026-03-25 10:00:00', '2026-03-25 11:00:00', '자택 거실', 1);

-- 11. 고사별 문제 매핑
INSERT INTO `exam_questions` (`exam_id`, `question_id`, `question_order`, `score`) VALUES
(1, 1, 1, 50), (1, 2, 2, 50), (2, 1, 1, 50), (2, 2, 2, 50), (3, 1, 1, 100), (4, 4, 1, 100), (5, 3, 1, 100);

-- 12. 고사 결과 리포트
INSERT INTO `exam_results` (`exam_id`, `student_no`, `total_score`, `student_rank`, `total_examinees`, `grade`, `ai_comment`, `teacher_comment`) VALUES
(1, 2, 50, 15, 30, '미', '[AI 분석] 네트워크 계층은 훌륭하나 디자인 패턴 복습 요망.', '철수 학생, 디자인 패턴을 다시 봅시다.'),
(2, 4, 2, 100, 1, 1, '수', '[AI 분석] 파이썬 자율 모의고사를 모두 맞췄습니다.', NULL);

-- 13. 학습 기록 (Study Logs)
INSERT INTO `study_logs` (`user_no`, `question_id`, `user_memo`, `is_correct`, `try_count`) VALUES
(1, 1, '전송/네트워크 헷갈림.', 0, 2),
(1, 2, '행위 패턴 조심', 1, 1),
(1, 3, NULL, 1, 3),
(1, 6, '부분적분법 다시 봐야함.', 0, 1);

-- 14. 옴브즈먼 리포트
INSERT INTO `ombudsman_reports` (`report_id`, `user_no`, `category`, `title`, `content`, `status`) VALUES
(1, 1, 'OPINION', '사이트가 너무 예뻐요!', '디자인이 정말 깔끔하고 마음에 듭니다. 특히 다크모드가 인상적이네요.', 'PROCESSED'),
(2, 1, 'IMPROVEMENT', '퀴즈 풀이 시 효과음 추가 제안', '문제를 맞혔을 때나 틀렸을 때 간단한 효과음이 나오면 더 재미있을 것 같습니다.', 'PENDING'),
(3, 1, 'COMPLAINT', '모바일에서 버튼이 조금 작아요', '아이폰 SE 같은 작은 화면에서는 몇몇 버튼을 누르기가 조금 힘듭니다.', 'PENDING');