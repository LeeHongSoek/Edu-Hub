import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) { }

  private toDbLocalDate(date = new Date()) {
    return new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  }

  private async writeUserLog(
    userNo: bigint,
    logtype: string,
    objId: bigint,
    userContent: string,
    score = 0,
    totalScore = 0,
    score100 = 0,
  ) {
    try {
      await (this.prisma as any).userLog.create({
        data: {
          user_no: userNo,
          logtype,
          obj_id: objId,
          user_content: userContent,
          score,
          total_score: totalScore,
          score100,
          last_played_at: this.toDbLocalDate(),
        },
      });
    } catch (error) {
      console.warn('[dashboard] user log write failed:', error);
    }
  }

  async getStats(userNo: bigint, roleId: string) {
    let stats = {}; // 리턴할 값을 담을 변수

    if (roleId === 'S') {
      stats = await this.getStudentStats(userNo);
    } else if (roleId === 'T') {
      stats = await this.getTeacherStats(userNo);
    } else if (roleId === 'P') {
      stats = await this.getParentStats(userNo);
    }

    // 리턴하기 직전에 콘솔 출력
    console.log('[백엔드:dashboard.service.ts] returning stats:', stats);

    return stats;
  }

  async getClassList(userNo: bigint, roleId: string) {
    const normalizedRoleId = String(roleId || '').toUpperCase();

    // 학생은 수강중인 반, 선생님은 운영 중인 반 기준으로 같은 모양의 목록을 내려줍니다.
    if (normalizedRoleId === 'S') {
      const memberships = await this.prisma.classStudent.findMany({
        where: { student_no: userNo },
        select: {
          class_id: true,
          class: {
            select: {
              class_id: true,
              class_name: true,
              created_at: true,
              teacher: {
                select: {
                  user_no: true,
                  username: true,
                },
              },
              students: {
                select: {
                  student_no: true,
                },
              },
              class_exam_links: {
                where: {
                  exam: {
                    is_deleted: 'N',
                  },
                },
                select: {
                  exam_id: true,
                },
              },
            },
          },
        },
      });

      return memberships
        .sort((a, b) => {
          const left = a.class.created_at?.getTime() ?? 0;
          const right = b.class.created_at?.getTime() ?? 0;
          return right - left;
        })
        .map((membership) => ({
          classId: membership.class.class_id.toString(),
          className: membership.class.class_name,
          teacherNo: membership.class.teacher.user_no.toString(),
          teacherName: membership.class.teacher.username,
          studentCount: membership.class.students.length,
          examCount: membership.class.class_exam_links.length,
          createdAt: membership.class.created_at,
        }));
    }

    if (normalizedRoleId === 'T') {
      const classes = await this.prisma.class.findMany({
        where: { teacher_no: userNo },
        select: {
          class_id: true,
          class_name: true,
          teacher_no: true,
          created_at: true,
          _count: {
            select: {
              students: true,
            },
          },
          class_exam_links: {
            where: {
              exam: {
                creator_no: userNo,
                is_deleted: 'N',
              },
            },
            select: {
              exam_id: true,
            },
          },
        },
        orderBy: { created_at: 'desc' },
      });

      return classes.map((classroom) => ({
        classId: classroom.class_id.toString(),
        className: classroom.class_name,
        teacherNo: classroom.teacher_no.toString(),
        teacherName: null,
        studentCount: classroom._count.students,
        examCount: classroom.class_exam_links.length,
        createdAt: classroom.created_at,
      }));
    }

    return [];
  }

  async getClassMemberManagerData(userNo: bigint, classId: string | number | bigint) {
    const classIdBigInt = BigInt(classId);
    const classroom = await this.prisma.class.findFirst({
      where: {
        class_id: classIdBigInt,
        teacher_no: userNo,
      },
      select: {
        class_id: true,
        class_name: true,
        teacher_no: true,
        students: {
          include: {
            student: {
              select: {
                user_no: true,
                username: true,
                user_id: true,
              },
            },
          },
          orderBy: {
            student: {
              username: 'asc',
            },
          },
        },
      },
    });

    if (!classroom) {
      throw new NotFoundException('관리할 수 있는 클래스를 찾지 못했습니다.');
    }

    const relationTypeIds = ['TEACHER_PUPIL', 'PUPIL_TEACHER'];
    const connectedRelations = await this.prisma.userRelation.findMany({
      where: {
        approval: 'Y',
        relation_type_id: { in: relationTypeIds },
        OR: [{ user_no_1: userNo }, { user_no_2: userNo }],
      },
      include: {
        user1: {
          select: {
            user_no: true,
            username: true,
            user_id: true,
            role_id: true,
          },
        },
        user2: {
          select: {
            user_no: true,
            username: true,
            user_id: true,
            role_id: true,
          },
        },
      },
      orderBy: { created_at: 'desc' },
    });

    const assignedStudents = classroom.students.map((membership) => ({
      userNo: membership.student.user_no.toString(),
      username: membership.student.username,
      userId: membership.student.user_id,
    }));

    const assignedSet = new Set(assignedStudents.map((student) => student.userNo));
    const availableMap = new Map<string, { userNo: string; username: string; userId: string }>();

    for (const relation of connectedRelations) {
      const counterpart =
        relation.user_no_1.toString() === userNo.toString()
          ? relation.user2
          : relation.user1;

      if (!counterpart || counterpart.role_id !== 'S') continue;
      const key = counterpart.user_no.toString();
      if (assignedSet.has(key) || availableMap.has(key)) continue;

      availableMap.set(key, {
        userNo: key,
        username: counterpart.username,
        userId: counterpart.user_id,
      });
    }

    const sortUsers = (list: Array<{ userNo: string; username: string; userId: string }>) =>
      [...list].sort((a, b) => {
        const byName = a.username.localeCompare(b.username, 'ko');
        if (byName !== 0) return byName;
        return a.userId.localeCompare(b.userId, 'ko');
      });

    return {
      classId: classroom.class_id.toString(),
      className: classroom.class_name,
      assignedStudents: sortUsers(assignedStudents),
      availableStudents: sortUsers(Array.from(availableMap.values())),
    };
  }

  async updateClassMembers(
    userNo: bigint,
    classId: string | number | bigint,
    studentNos: Array<string | number>,
  ) {
    const classIdBigInt = BigInt(classId);
    const classroom = await this.prisma.class.findFirst({
      where: {
        class_id: classIdBigInt,
        teacher_no: userNo,
      },
      select: {
        class_id: true,
        class_name: true,
      },
    });

    if (!classroom) {
      throw new NotFoundException('관리할 수 있는 클래스를 찾지 못했습니다.');
    }

    const normalizedIds = Array.from(
      new Set(
        (Array.isArray(studentNos) ? studentNos : [])
          .map((studentNo) => String(studentNo))
          .filter(Boolean),
      ),
    );

    if (normalizedIds.length > 0) {
      const allowedStudents = await this.getClassMemberManagerData(userNo, classIdBigInt);
      const allowedSet = new Set(
        [...allowedStudents.assignedStudents, ...allowedStudents.availableStudents].map(
          (student) => student.userNo,
        ),
      );

      for (const studentNo of normalizedIds) {
        if (!allowedSet.has(studentNo)) {
          throw new BadRequestException('담당 학생만 클래스에 배정할 수 있습니다.');
        }
      }
    }

    await this.prisma.$transaction([
      this.prisma.classStudent.deleteMany({
        where: {
          class_id: classIdBigInt,
        },
      }),
      ...(normalizedIds.length > 0
        ? [
            this.prisma.classStudent.createMany({
              data: normalizedIds.map((studentNo) => ({
                class_id: classIdBigInt,
                student_no: BigInt(studentNo),
              })),
            }),
          ]
        : []),
    ]);

    await this.writeUserLog(
      userNo,
      'C',
      classIdBigInt,
      `클래스 #${classIdBigInt.toString()} [${classroom.class_name}] 구성원 수정 (${normalizedIds.length}명 배정)`,
      normalizedIds.length,
      normalizedIds.length,
      100,
    );

    return this.getClassMemberManagerData(userNo, classIdBigInt);
  }

  async getClassExamManagerData(userNo: bigint, classId: string | number | bigint) {
    const classIdBigInt = BigInt(classId);
    const classroom = await this.prisma.class.findFirst({
      where: {
        class_id: classIdBigInt,
        teacher_no: userNo,
      },
      select: {
        class_id: true,
        class_name: true,
      },
    });

    if (!classroom) {
      throw new NotFoundException('관리할 수 있는 클래스를 찾지 못했습니다.');
    }

    const exams = await this.prisma.exam.findMany({
      where: {
        creator_no: userNo,
        is_deleted: 'N',
      },
      select: {
        exam_id: true,
        exam_name: true,
        class_exam_links: {
          select: {
            class_id: true,
            class: {
              select: {
                class_name: true,
              },
            },
          },
        },
        _count: {
          select: {
            questions: true,
          },
        },
        created_at: true,
      },
      orderBy: [
        { created_at: 'desc' },
        { exam_id: 'desc' },
      ],
    });

    const assignedExams = exams
      .filter((exam) =>
        exam.class_exam_links.some(
          (link) => link.class_id.toString() === classIdBigInt.toString(),
        ),
      )
      .map((exam) => ({
        examId: exam.exam_id.toString(),
        examName: exam.exam_name,
        questionCount: exam._count.questions,
        linkedClassName: classroom.class_name,
      }));

    const availableExams = exams
      .filter(
        (exam) =>
          !exam.class_exam_links.some(
            (link) => link.class_id.toString() === classIdBigInt.toString(),
          ),
      )
      .map((exam) => ({
        examId: exam.exam_id.toString(),
        examName: exam.exam_name,
        questionCount: exam._count.questions,
        linkedClassName:
          exam.class_exam_links.length > 0
            ? exam.class_exam_links.map((link) => link.class.class_name).join(", ")
            : null,
      }));

    return {
      classId: classroom.class_id.toString(),
      className: classroom.class_name,
      assignedExams,
      availableExams,
    };
  }

  async updateClassExams(
    userNo: bigint,
    classId: string | number | bigint,
    examIds: Array<string | number>,
  ) {
    const classIdBigInt = BigInt(classId);
    const classroom = await this.prisma.class.findFirst({
      where: {
        class_id: classIdBigInt,
        teacher_no: userNo,
      },
      select: {
        class_id: true,
        class_name: true,
      },
    });

    if (!classroom) {
      throw new NotFoundException('관리할 수 있는 클래스를 찾지 못했습니다.');
    }

    const normalizedExamIds = Array.from(
      new Set(
        (Array.isArray(examIds) ? examIds : [])
          .map((examId) => String(examId))
          .filter(Boolean),
      ),
    );

    if (normalizedExamIds.length > 0) {
      const ownedExamCount = await this.prisma.exam.count({
        where: {
          exam_id: { in: normalizedExamIds.map((examId) => BigInt(examId)) },
          creator_no: userNo,
          is_deleted: 'N',
        },
      });

      if (ownedExamCount !== normalizedExamIds.length) {
        throw new BadRequestException('본인이 만든 고사만 클래스에 연결할 수 있습니다.');
      }
    }

    await this.prisma.$transaction([
      this.prisma.classExam.deleteMany({
        where: {
          class_id: classIdBigInt,
        },
      }),
      ...(normalizedExamIds.length > 0
        ? [
            this.prisma.classExam.createMany({
              data: normalizedExamIds.map((examId) => ({
                class_id: classIdBigInt,
                exam_id: BigInt(examId),
              })),
              skipDuplicates: true,
            }),
          ]
        : []),
    ]);

    await this.writeUserLog(
      userNo,
      'C',
      classIdBigInt,
      `클래스 #${classIdBigInt.toString()} [${classroom.class_name}] 고사 연결 수정 (${normalizedExamIds.length}개 연결)`,
      normalizedExamIds.length,
      normalizedExamIds.length,
      100,
    );

    return this.getClassExamManagerData(userNo, classIdBigInt);
  }

  private async getStudentStats(userNo: bigint) {
    // 학생 통계: 최근 7일간 푼 문제 수, 정답률 등
    const now = new Date();
    const ago7d = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const solveResults = await this.prisma.solveResult.findMany({
      where: {
        user_no: userNo,
        solved_at: { gte: ago7d },
      },
    });

    const recentSolvedCount = solveResults.length;
    // `solve_results.is_correct`는 DB에서 1/0/-1(Int)로 들어올 수 있고,
    // (일부 빌드/클라이언트에서는) boolean(true/false)로 섞일 가능성도 있어 숫자로 정규화합니다.
    const correctOnes = solveResults.filter((r) => Number(r.is_correct) === 1).length;
    const accuracy = recentSolvedCount > 0 ? Math.round((correctOnes / recentSolvedCount) * 100) : 0; // 정답률 : 정답 / 푼 문제

    // 일별 푼 문제 수 (최근 7일)
    const dailyStats: { date: string; count: number }[] = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      const count = solveResults.filter((r) => r.solved_at?.toISOString().split('T')[0] === dateStr).length;
      dailyStats.push({ date: dateStr, count });
    }

    return {
      totalViewed: await (this.prisma as any).userLog.count({
        where: {
          user_no: userNo,
          logtype: 'Q',
          user_content: { contains: '보기' },
        },
      }),
      totalSolved: await (this.prisma as any).userLog.count({
        where: {
          user_no: userNo,
          logtype: 'Q',
          user_content: { contains: '풀기' },
        },
      }),
      accuracy,
      dailyStats,
      studyLogs: await (this.prisma as any).userLog.count({
        where: {
          user_no: userNo,
          score: 0,
        },
      }),
    };
  }

  private async getTeacherStats(userNo: bigint) {
    // 선생님 통계: 담당 학급 수, 학생 수, 본인이 만든 문제 수
    const [classes, studentCount, myQuestions] = await Promise.all([
      this.prisma.class.findMany({ where: { teacher_no: userNo } }),
      this.prisma.classStudent.count({
        where: { class: { teacher_no: userNo } },
      }),
      this.prisma.question.count({ where: { creator_no: userNo } }),
    ]);

    return {
      classCount: classes.length,
      studentCount,
      myQuestions,
    };
  }

  private async getParentStats(userNo: bigint) {
    // 학부모 통계: 연결된 자녀 리스트 및 자녀의 최근 학습 요약
    const childrenRelations = await this.prisma.userRelation.findMany({
      where: {
        user_no_1: userNo,
        relation_type_id: 'PARENT_CHILD',
      },
      include: {
        user2: {
          select: {
            user_no: true,
            username: true,
            solve_results: {
              take: 5,
              orderBy: { solved_at: 'desc' },
            },
          },
        },
      },
    });

    return childrenRelations.map((rel) => ({
      studentNo: rel.user2.user_no.toString(),
      studentName: rel.user2.username,
      recentSolveCount: rel.user2.solve_results.length,
    }));
  }

  async getRelations(
    userNo: bigint,
    userRoleId: string,
    query = '',
    target = '',
    page = 1,
    limit = 8,
  ) {
    const safePage = Math.max(1, Number.isFinite(page) ? Math.floor(page) : 1);
    const safeLimit = Math.min(Math.max(Number.isFinite(limit) ? Math.floor(limit) : 8, 1), 24);
    const keyword = String(query || '').trim();
    const targetFilter = this.resolveRelationTargetFilter(userRoleId, target);

    const where: any = {
      approval: 'Y',
      OR: [{ user_no_1: userNo }, { user_no_2: userNo }],
    };

    if (targetFilter) {
      if (targetFilter.relationTypeId) {
        where.relation_type_id = targetFilter.relationTypeId;
      }
    }

    if (keyword) {
      const keywordFilter = [
        {
          user1: {
            is: {
              OR: [
                { username: { contains: keyword } },
                { user_id: { contains: keyword } },
              ],
            },
          },
        },
        {
          user2: {
            is: {
              OR: [
                { username: { contains: keyword } },
                { user_id: { contains: keyword } },
              ],
            },
          },
        },
        {
          relation_type: {
            is: {
              description: {
                contains: keyword,
              },
            },
          },
        },
      ];

      if (where.OR) {
        where.OR = [...where.OR, ...keywordFilter];
      } else {
        where.OR = keywordFilter;
      }
    }

    // 모든 방향을 불러온 뒤 counterpart 기준으로 중복 제거하여 페이지네이션
    const rawItems = await this.prisma.userRelation.findMany({
      where,
      include: {
        user1: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
        user2: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
        relation_type: true,
      },
      orderBy: { created_at: 'desc' },
    });

    const deduped: any[] = [];
    const seen = new Set<string>();
    for (const rel of rawItems) {
      // 현재 사용자 관점에서 상대방 사용자 결정
      const other =
        rel.user_no_1.toString() === userNo.toString() ? rel.user2 : rel.user1;
      if (!other?.user_no) continue;
      const otherKey = other.user_no.toString();
      if (seen.has(otherKey)) continue;
      seen.add(otherKey);
      deduped.push(rel);
    }

    const total = deduped.length;
    const start = (safePage - 1) * safeLimit;
    const items = deduped.slice(start, start + safeLimit);

    return {
      items: items.map((relation) => ({
        ...relation,
        relation_id: `${relation.user_no_1.toString()}_${relation.user_no_2.toString()}`,
        user_no_1: relation.user_no_1.toString(),
        user_no_2: relation.user_no_2.toString(),
      })),
      page: safePage,
      limit: safeLimit,
      total,
      totalPages: Math.max(1, Math.ceil(total / safeLimit)),
    };
  }

  private resolveRelationTargetFilter(userRoleId: string, targetKey?: string) {
    const normalizedRoleId = String(userRoleId || '').toUpperCase();
    const normalizedTargetKey = String(targetKey || '').toLowerCase();

    if (!normalizedTargetKey) {
      return null;
    }

    if (normalizedRoleId === 'S') {
      if (normalizedTargetKey === 'friends') {
        return { relationTypeId: 'FRIEND' };
      }
      if (normalizedTargetKey === 'parents') {
        return { relationTypeId: 'CHILD_PARENT' };
      }
      if (normalizedTargetKey === 'teachers') {
        return { relationTypeId: 'PUPIL_TEACHER' };
      }
    }

    if (normalizedRoleId === 'P' && normalizedTargetKey === 'students') {
      return { relationTypeId: 'PARENT_CHILD' };
    }

    if (normalizedRoleId === 'T' && normalizedTargetKey === 'students') {
      return { relationTypeId: 'TEACHER_PUPIL' };
    }

    return null;
  }

  async getRelationCandidates(userNo: bigint, targetRoleId: string, query: string, page: number, limit: number) {
    const safePage = Math.max(1, Number.isFinite(page) ? Math.floor(page) : 1);
    const safeLimit = Math.min(Math.max(Number.isFinite(limit) ? Math.floor(limit) : 6, 1), 30);
    const keyword = String(query || '').trim();

    const connectedRelations = await this.prisma.userRelation.findMany({
      where: {
        OR: [{ user_no_1: userNo }, { user_no_2: userNo }],
      },
      select: {
        user_no_1: true,
        user_no_2: true,
        approval: true,
      },
    });

    const connectedUserMap = new Map<string, { isConnected: boolean; approval: string | null }>();
    for (const relation of connectedRelations) {
      if (relation.user_no_1.toString() !== userNo.toString()) {
        connectedUserMap.set(relation.user_no_1.toString(), {
          isConnected: relation.approval === 'Y',
          approval: relation.approval === null ? 'null' : relation.approval,
        });
      }
      if (relation.user_no_2.toString() !== userNo.toString()) {
        connectedUserMap.set(relation.user_no_2.toString(), {
          isConnected: relation.approval === 'Y',
          approval: relation.approval === null ? 'null' : relation.approval,
        });
      }
    }

    const where: any = {
      role_id: targetRoleId,
      user_no: { not: userNo },
      is_withdrawn: 'N',
    };

    if (keyword) {
      where.OR = [
        {
          username: {
            contains: keyword,
          },
        },
        {
          user_id: {
            contains: keyword,
          },
        },
      ];
    }

    const [total, items] = await Promise.all([
      this.prisma.user.count({ where }),
      this.prisma.user.findMany({
        where,
        select: {
          user_no: true,
          user_id: true,
          username: true,
          role_id: true,
          created_at: true,
        },
        orderBy: [
          { username: 'asc' },
          { created_at: 'desc' },
        ],
        skip: (safePage - 1) * safeLimit,
        take: safeLimit,
      }),
    ]);

    return {
      items: items.map((user) => {
        const connInfo = connectedUserMap.get(user.user_no.toString());
        return {
          ...user,
          user_no: user.user_no.toString(),
          isConnected: connInfo?.isConnected || false,
          approval: connInfo?.approval === 'null' ? null : connInfo?.approval,
        };
      }),
      page: safePage,
      limit: safeLimit,
      total,
      totalPages: Math.max(1, Math.ceil(total / safeLimit)),
    };
  }

  async createRelation(userNo: bigint, targetUserNo: string | number | bigint | undefined, targetRoleId?: string) {
    if (targetUserNo === undefined || targetUserNo === null || targetUserNo === '') {
      throw new BadRequestException('대상 사용자가 선택되지 않았습니다.');
    }

    const targetUserNoBigInt = BigInt(targetUserNo);

    if (targetUserNoBigInt === userNo) {
      throw new BadRequestException('자기 자신과는 연결할 수 없습니다.');
    }

    const [me, target] = await Promise.all([
      this.prisma.user.findUnique({
        where: { user_no: userNo },
        select: { user_no: true, role_id: true, username: true },
      }),
      this.prisma.user.findUnique({
        where: { user_no: targetUserNoBigInt },
        select: { user_no: true, role_id: true, username: true },
      }),
    ]);

    if (!me || !target) {
      throw new NotFoundException('사용자 정보를 찾을 수 없습니다.');
    }

    const normalizedTargetRole = String(targetRoleId || target.role_id || '').toUpperCase();
    const relationPair = this.resolveRelationPair(me.role_id, normalizedTargetRole);

    if (!relationPair) {
      throw new BadRequestException('현재 역할 조합에서는 연결을 만들 수 없습니다.');
    }

    const existingRelation = await this.prisma.userRelation.findFirst({
      where: {
        OR: [
          { user_no_1: userNo, user_no_2: targetUserNoBigInt },
          { user_no_1: targetUserNoBigInt, user_no_2: userNo },
        ],
      },
    });

    if (existingRelation) {
      throw new ConflictException('이미 연결된 사용자입니다.');
    }

    const now = new Date();

    await this.prisma.userRelation.create({
      data: {
        user_no_1: userNo,
        user_no_2: targetUserNoBigInt,
        relation_type_id: relationPair.forward,
        approval: null,
        created_at: now,
      },
    });

    await this.writeUserLog(
      userNo,
      'R',
      targetUserNoBigInt,
      `관계 요청 발신: 사용자 #${targetUserNoBigInt.toString()} [${target.username}] 대상으로 ${relationPair.forward}`,
    );

    return {
      ok: true,
      message: `${target.username} 님에게 연결을 요청했습니다.`,
    };
  }

  async deleteRelation(userNo: bigint, targetUserNo: string | number | bigint | undefined) {
    if (targetUserNo === undefined || targetUserNo === null || targetUserNo === '') {
      throw new BadRequestException('대상 사용자가 선택되지 않았습니다.');
    }

    const targetUserNoBigInt = BigInt(targetUserNo);

    if (targetUserNoBigInt === userNo) {
      throw new BadRequestException('자기 자신과의 관계는 해제할 수 없습니다.');
    }

    const [forward, reverse] = await Promise.all([
      this.prisma.userRelation.findFirst({
        where: { user_no_1: userNo, user_no_2: targetUserNoBigInt },
        select: { user_no_1: true, user_no_2: true },
      }),
      this.prisma.userRelation.findFirst({
        where: { user_no_1: targetUserNoBigInt, user_no_2: userNo },
        select: { user_no_1: true, user_no_2: true },
      }),
    ]);

    if (!forward && !reverse) {
      throw new NotFoundException('해제할 연결을 찾을 수 없습니다.');
    }

    await this.prisma.$transaction([
      ...(forward ? [this.prisma.userRelation.delete({
        where: {
          user_no_1_user_no_2: {
            user_no_1: forward.user_no_1,
            user_no_2: forward.user_no_2,
          },
        },
      })] : []),
      ...(reverse ? [this.prisma.userRelation.delete({
        where: {
          user_no_1_user_no_2: {
            user_no_1: reverse.user_no_1,
            user_no_2: reverse.user_no_2,
          },
        },
      })] : []),
    ]);

    await this.writeUserLog(
      userNo,
      'R',
      targetUserNoBigInt,
      `관계 해제: 대상 사용자 #${targetUserNoBigInt.toString()}`,
    );

    return {
      ok: true,
      message: '연결을 해제했습니다.',
    };
  }

  private resolveRelationPair(sourceRoleId: string, targetRoleId: string) {
    const map: Record<string, Record<string, { forward: string; reverse: string }>> = {
      S: {
        S: { forward: 'FRIEND', reverse: 'FRIEND' },
        P: { forward: 'CHILD_PARENT', reverse: 'PARENT_CHILD' },
        T: { forward: 'PUPIL_TEACHER', reverse: 'TEACHER_PUPIL' },
      },
      P: {
        S: { forward: 'PARENT_CHILD', reverse: 'CHILD_PARENT' },
      },
      T: {
        S: { forward: 'TEACHER_PUPIL', reverse: 'PUPIL_TEACHER' },
      },
    };

    return map[sourceRoleId]?.[targetRoleId] ?? null;
  }

  async getPendingRelations(userNo: bigint) {
    const pending = await this.prisma.userRelation.findMany({
      where: {
        user_no_2: userNo,
        approval: null,
      },
      include: {
        user1: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
        relation_type: true,
      },
      orderBy: { created_at: 'desc' },
    });

    return pending.map((rel) => ({
      user_no: rel.user_no_1.toString(),
      username: rel.user1.username,
      user_id: rel.user1.user_id,
      role_id: rel.user1.role_id,
      relation_type_id: rel.relation_type_id,
      description: rel.relation_type?.description || '',
      created_at: rel.created_at,
    }));
  }

  async updateRelationApproval(userNo: bigint, targetUserNo: string | number | bigint, action: 'accept' | 'reject') {
    const targetUserNoBigInt = BigInt(targetUserNo);

    const pendingRelation = await this.prisma.userRelation.findFirst({
      where: {
        user_no_1: targetUserNoBigInt,
        user_no_2: userNo,
        approval: null,
      },
    });

    if (!pendingRelation) {
      throw new NotFoundException('요청을 찾을 수 없거나 이미 처리되었습니다.');
    }

    if (action === 'reject') {
      await this.prisma.userRelation.update({
        where: {
          user_no_1_user_no_2: {
            user_no_1: targetUserNoBigInt,
            user_no_2: userNo,
          },
        },
        data: { approval: 'N' },
      });
      await this.writeUserLog(
        userNo,
        'R',
        targetUserNoBigInt,
        `관계 요청 거절: 요청자 사용자 #${targetUserNoBigInt.toString()}`,
      );
      return { ok: true, message: '요청을 거절했습니다.' };
    }

    const [me, target] = await Promise.all([
      this.prisma.user.findUnique({ where: { user_no: userNo }, select: { role_id: true, username: true } }),
      this.prisma.user.findUnique({ where: { user_no: targetUserNoBigInt }, select: { role_id: true, username: true } }),
    ]);

    if (!me || !target) throw new NotFoundException('사용자 정보를 찾을 수 없습니다.');

    const relationPair = this.resolveRelationPair(me.role_id, target.role_id);

    await this.prisma.$transaction([
      this.prisma.userRelation.update({
        where: {
          user_no_1_user_no_2: {
            user_no_1: targetUserNoBigInt,
            user_no_2: userNo,
          },
        },
        data: { approval: 'Y' },
      }),
      this.prisma.userRelation.upsert({
        where: {
          user_no_1_user_no_2: {
            user_no_1: userNo,
            user_no_2: targetUserNoBigInt,
          },
        },
        update: { approval: 'Y' },
        create: {
          user_no_1: userNo,
          user_no_2: targetUserNoBigInt,
          relation_type_id: relationPair ? relationPair.forward : pendingRelation.relation_type_id,
          approval: 'Y',
          created_at: new Date(),
        },
      }),
    ]);

    await this.writeUserLog(
      userNo,
      'R',
      targetUserNoBigInt,
      `관계 요청 수락: 사용자 #${targetUserNoBigInt.toString()} [${target.username}]`,
    );

    return { ok: true, message: `${target.username} 님의 요청을 수락했습니다.` };
  }

  async getMessages(
    userNo: bigint,
    view = 'received',
    query = '',
    page = 1,
    limit = 8,
    peerUserNo?: string | number | bigint | null,
  ) {
    const safePage = Math.max(1, Number.isFinite(page) ? Math.floor(page) : 1);
    const safeLimit = Math.min(Math.max(Number.isFinite(limit) ? Math.floor(limit) : 8, 1), 24);
    const keyword = String(query || '').trim();
    const normalizedView = String(view || 'received').toLowerCase();
    const peerUserNoBigInt = peerUserNo === undefined || peerUserNo === null || peerUserNo === ''
      ? null
      : BigInt(peerUserNo);

    const where: any = {
      ...(normalizedView === 'sent'
        ? { sender_no: userNo }
        : { receiver_no: userNo }),
    };

    if (peerUserNoBigInt !== null) {
      if (normalizedView === 'sent') {
        where.receiver_no = peerUserNoBigInt;
      } else {
        where.sender_no = peerUserNoBigInt;
      }
    }

    if (keyword) {
      where.AND = [
        {
          OR: [
            {
              content: {
                contains: keyword,
              },
            },
            {
              sender: {
                OR: [
                  {
                    username: {
                      contains: keyword,
                    },
                  },
                  {
                    user_id: {
                      contains: keyword,
                    },
                  },
                ],
              },
            },
            {
              receiver: {
                OR: [
                  {
                    username: {
                      contains: keyword,
                    },
                  },
                  {
                    user_id: {
                      contains: keyword,
                    },
                  },
                ],
              },
            },
          ],
        },
      ];
    }

    const [total, items] = await Promise.all([
      this.prisma.userMessage.count({ where }),
      this.prisma.userMessage.findMany({
        where,
        include: {
          sender: {
            select: {
              user_no: true,
              user_id: true,
              username: true,
              role_id: true,
            },
          },
          receiver: {
            select: {
              user_no: true,
              user_id: true,
              username: true,
              role_id: true,
            },
          },
        },
        orderBy: { created_at: 'desc' },
        skip: (safePage - 1) * safeLimit,
        take: safeLimit,
      }),
    ]);

    return {
      items: items.map((message) => {
        const isSent = message.sender_no.toString() === userNo.toString();
        const counterpart = isSent ? message.receiver : message.sender;

        return {
          message_id: message.message_id.toString(),
          sender_no: message.sender_no.toString(),
          receiver_no: message.receiver_no.toString(),
          content: message.content,
          is_read: message.is_read,
          created_at: message.created_at,
          direction: isSent ? 'sent' : 'received',
          sender: message.sender,
          receiver: message.receiver,
          counterpart,
        };
      }),
      page: safePage,
      limit: safeLimit,
      total,
      totalPages: Math.max(1, Math.ceil(total / safeLimit)),
    };
  }

  async getMessageRecipients(userNo: bigint, query = '', page = 1, limit = 6) {
    const safePage = Math.max(1, Number.isFinite(page) ? Math.floor(page) : 1);
    const safeLimit = Math.min(Math.max(Number.isFinite(limit) ? Math.floor(limit) : 6, 1), 24);
    const keyword = String(query || '').trim();

    const relations = await this.prisma.userRelation.findMany({
      where: {
        user_no_1: userNo,
      },
      include: {
        user2: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
      },
      orderBy: { created_at: 'desc' },
    });

    const recipients = new Map<string, {
      user_no: string;
      user_id: string;
      username: string;
      role_id: string;
      relation_type_id: string;
      created_at: Date | null;
    }>();

    for (const relation of relations) {
      const user = relation.user2;
      const key = user.user_no.toString();
      if (!recipients.has(key)) {
        recipients.set(key, {
          user_no: key,
          user_id: user.user_id,
          username: user.username,
          role_id: user.role_id,
          relation_type_id: relation.relation_type_id,
          created_at: relation.created_at ?? null,
        });
      }
    }

    const filtered = Array.from(recipients.values()).filter((recipient) => {
      if (!keyword) return true;
      return (
        recipient.username.includes(keyword) ||
        recipient.user_id.includes(keyword)
      );
    });

    const total = filtered.length;
    const paged = filtered.slice((safePage - 1) * safeLimit, (safePage - 1) * safeLimit + safeLimit);

    return {
      items: paged,
      page: safePage,
      limit: safeLimit,
      total,
      totalPages: Math.max(1, Math.ceil(total / safeLimit)),
    };
  }

  async sendMessage(userNo: bigint, receiverUserNo: string | number | bigint | undefined, content?: string) {
    if (receiverUserNo === undefined || receiverUserNo === null || receiverUserNo === '') {
      throw new BadRequestException('받는 사람을 선택해 주세요.');
    }

    const text = String(content || '').trim();
    if (!text) {
      throw new BadRequestException('메시지 내용을 입력해 주세요.');
    }

    const receiverNoBigInt = BigInt(receiverUserNo);
    if (receiverNoBigInt === userNo) {
      throw new BadRequestException('자기 자신에게는 메시지를 보낼 수 없습니다.');
    }

    const [sender, receiver, relation] = await Promise.all([
      this.prisma.user.findUnique({
        where: { user_no: userNo },
        select: { user_no: true, user_id: true, username: true },
      }),
      this.prisma.user.findUnique({
        where: { user_no: receiverNoBigInt },
        select: { user_no: true, user_id: true, username: true },
      }),
      this.prisma.userRelation.findFirst({
        where: {
          user_no_1: userNo,
          user_no_2: receiverNoBigInt,
        },
        select: { user_no_1: true },
      }),
    ]);

    if (!sender || !receiver) {
      throw new NotFoundException('메시지 상대를 찾을 수 없습니다.');
    }

    if (!relation) {
      throw new BadRequestException('연결된 사용자에게만 메시지를 보낼 수 있습니다.');
    }

    const message = await this.prisma.userMessage.create({
      data: {
        sender_no: userNo,
        receiver_no: receiverNoBigInt,
        content: text,
        is_read: 'N',
      },
      include: {
        sender: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
        receiver: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
      },
    });

    await this.writeUserLog(
      userNo,
      'R',
      receiverNoBigInt,
      `메시지 발송: 사용자 #${receiverNoBigInt.toString()} [${receiver.username}]에게 ${text.length}자 전송`,
      text.length,
      text.length,
      100,
    );

    return {
      ok: true,
      message: '메시지를 전송했습니다.',
      data: {
        message_id: message.message_id.toString(),
        sender_no: message.sender_no.toString(),
        receiver_no: message.receiver_no.toString(),
        content: message.content,
        is_read: message.is_read,
        created_at: message.created_at,
        direction: 'sent',
        sender: message.sender,
        receiver: message.receiver,
        counterpart: message.receiver,
      },
    };
  }
}
