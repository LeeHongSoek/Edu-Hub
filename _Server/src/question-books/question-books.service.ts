import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class QuestionBooksService {
  constructor(private prisma: PrismaService) {}

  async create(userNo: bigint, data: any) {
    return this.prisma.userQuestionBook.create({
      data: {
        user_no: userNo,
        book_name: data.book_name,
        description: data.description,
      },
    });
  }

  async findByUser(userNo: bigint) {
    return this.prisma.userQuestionBook.findMany({
      where: { user_no: userNo },
      include: {
        items: {
          include: {
            question: true
          }
        }
      },
      orderBy: { created_at: 'desc' },
    });
  }

  async findById(bookId: bigint, userNo: bigint) {
    const book = await this.prisma.userQuestionBook.findUnique({
      where: { book_id: bookId },
      include: {
        items: {
          include: {
            question: true,
          },
        },
      },
    });

    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return book;
  }

  async update(bookId: bigint, userNo: bigint, data: any) {
    const book = await this.prisma.userQuestionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.userQuestionBook.update({
      where: { book_id: bookId },
      data: {
        book_name: data.book_name,
        description: data.description,
      },
    });
  }

  async remove(bookId: bigint, userNo: bigint) {
    const book = await this.prisma.userQuestionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.userQuestionBook.delete({
      where: { book_id: bookId },
    });
  }

  async addItem(bookId: bigint, userNo: bigint, questionId: bigint) {
    const book = await this.prisma.userQuestionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.userQuestionBookItem.create({
      data: {
        book_id: bookId,
        question_id: questionId,
      },
    });
  }

  async removeItem(bookId: bigint, userNo: bigint, questionId: bigint) {
    const book = await this.prisma.userQuestionBook.findUnique({
      where: { book_id: bookId },
    });
    if (!book) throw new NotFoundException('Question book not found');
    if (book.user_no !== userNo) throw new ForbiddenException('Not authorized');

    return this.prisma.userQuestionBookItem.delete({
      where: {
        book_id_question_id: {
          book_id: bookId,
          question_id: questionId,
        }
      },
    });
  }
}
