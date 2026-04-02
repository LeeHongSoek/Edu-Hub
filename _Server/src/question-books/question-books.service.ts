import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class QuestionBooksService {
  constructor(private prisma: PrismaService) { }

  async create(userNo: bigint, data: any) {
    return this.prisma.questionBook.create({
      data: {
        user_no: userNo,
        book_name: data.book_name,
        description: data.description,
      },
    });
  }

  async findAll() {
    const books = await this.prisma.questionBook.findMany({
      include: {
        user: { select: { user_no: true, username: true } },
        items: {
          include: {
            question: true
          }
        }
      },
      orderBy: { created_at: 'desc' },
    });

    return books.map(({ user, ...book }) => ({
      ...book,
      creator: user,
    }));
  }

  async findByUser(userNo: bigint) {
    const books = await this.prisma.questionBook.findMany({
      where: { user_no: userNo },
      include: {
        user: { select: { user_no: true, username: true } },
        items: {
          include: {
            question: true
          }
        }
      },
      orderBy: { created_at: 'desc' },
    });

    return books.map(({ user, ...book }) => ({
      ...book,
      creator: user,
    }));
  }

  async findById(bookId: bigint) {
    const book = await this.prisma.questionBook.findUnique({
      where: { book_id: bookId },
      include: {
        user: { select: { user_no: true, username: true } },
        items: {
          include: {
            question: {
              include: {
                type: true,
                creator: { select: { username: true } },
                group: {
                  include: {
                    parent_group: {
                      include: {
                        parent_group: true,
                      },
                    },
                  },
                },
                options: {
                  orderBy: { option_number: 'asc' },
                },
                passage: true,
                children: {
                  include: {
                    type: true,
                    group: {
                      include: {
                        parent_group: {
                          include: {
                            parent_group: true,
                          },
                        },
                      },
                    },
                    options: { orderBy: { option_number: 'asc' } },
                    passage: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!book) throw new NotFoundException('Question book not found');

    const { user, ...rest } = book;
    return {
      ...rest,
      creator: user,
    };
  }

  async update(bookId: bigint, userNo: bigint, data: any) {
    const book = await this.prisma.questionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.questionBook.update({
      where: { book_id: bookId },
      data: {
        book_name: data.book_name,
        description: data.description,
      },
    });
  }

  async remove(bookId: bigint, userNo: bigint) {
    const book = await this.prisma.questionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.questionBook.delete({
      where: { book_id: bookId },
    });
  }

  async addItem(bookId: bigint, userNo: bigint, questionId: bigint) {
    const book = await this.prisma.questionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.questionBookItem.create({
      data: {
        book_id: bookId,
        question_id: questionId,
      },
    });
  }

  async removeItem(bookId: bigint, userNo: bigint, questionId: bigint) {
    const book = await this.prisma.questionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.questionBookItem.delete({
      where: {
        book_id_question_id: {
          book_id: bookId,
          question_id: questionId,
        }
      },
    });
  }

  // 1 & 2. 매일 첫 접속 시 오늘의 공개문제(book_id: 0) 갱신
  async refreshDailyQuestions() {
    const dailyBookId = BigInt(0);
    let book = await this.prisma.questionBook.findUnique({
      where: { book_id: dailyBookId },
    });

    if (!book) {
      // 존재하지 않으면 생성 (failsafe)
      book = await this.prisma.questionBook.create({
        data: {
          book_id: dailyBookId,
          user_no: BigInt(0), // 시스템 관리자 계정 (보통 0번), 이번호 무로그인 키
          book_name: '오늘의 공개문제',
          description: '매일 자동으로 갱신되는 추천 문제 세트입니다.',
        },
      });
    }

    const today = new Date();
    const bookDate = new Date(book.created_at || 0);

    const isSameDay =
      today.getFullYear() === bookDate.getFullYear() &&
      today.getMonth() === bookDate.getMonth() &&
      today.getDate() === bookDate.getDate();

    // 오늘 날짜가 아니면 갱신 실행
    if (!isSameDay) {
      // 1. 기존 데이터 삭제
      await this.prisma.questionBookItem.deleteMany({
        where: { book_id: dailyBookId },
      });

      // 2. 랜덤하게 공개된 객관식 부모 문제 20개 추출
      const randomQuestions = await this.prisma.$queryRaw<any[]>`
        SELECT question_id FROM questions 
        WHERE is_public = 1 
          AND question_type_id = 'M' 
          AND p_question_id IS NULL 
          AND is_deleted = 'N'
        ORDER BY RAND() LIMIT 20
      `;

      if (randomQuestions.length > 0) {
        // ID 타입이 raw query에서 다를 수 있으므로 변환 (MySQL BigInt -> JS BigInt)
        await this.prisma.questionBookItem.createMany({
          data: randomQuestions.map((q) => ({
            book_id: dailyBookId,
            question_id: BigInt(q.question_id),
          })),
        });
      }

      // 3. 갱신 시각 업데이트 (오늘 날짜로)
      await this.prisma.questionBook.update({
        where: { book_id: dailyBookId },
        data: { created_at: today },
      });
    }

    // 최종 20문제가 담긴 문제집 상세 정보 반환
    return this.findById(dailyBookId);
  }
}
