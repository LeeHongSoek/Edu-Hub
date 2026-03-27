"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.QuestionBooksService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let QuestionBooksService = class QuestionBooksService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(userNo, data) {
        return this.prisma.userQuestionBook.create({
            data: {
                user_no: userNo,
                book_name: data.book_name,
                description: data.description,
            },
        });
    }
    async findByUser(userNo) {
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
    async update(bookId, userNo, data) {
        const book = await this.prisma.userQuestionBook.findUnique({
            where: { book_id: bookId },
        });
        if (!book)
            throw new common_1.NotFoundException('Question book not found');
        if (book.user_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized');
        return this.prisma.userQuestionBook.update({
            where: { book_id: bookId },
            data: {
                book_name: data.book_name,
                description: data.description,
            },
        });
    }
    async remove(bookId, userNo) {
        const book = await this.prisma.userQuestionBook.findUnique({
            where: { book_id: bookId },
        });
        if (!book)
            throw new common_1.NotFoundException('Question book not found');
        if (book.user_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized');
        return this.prisma.userQuestionBook.delete({
            where: { book_id: bookId },
        });
    }
    async addItem(bookId, userNo, questionId) {
        const book = await this.prisma.userQuestionBook.findUnique({
            where: { book_id: bookId },
        });
        if (!book)
            throw new common_1.NotFoundException('Question book not found');
        if (book.user_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized');
        return this.prisma.userQuestionBookItem.create({
            data: {
                book_id: bookId,
                question_id: questionId,
            },
        });
    }
    async removeItem(bookId, userNo, questionId) {
        const book = await this.prisma.userQuestionBook.findUnique({
            where: { book_id: bookId },
        });
        if (!book)
            throw new common_1.NotFoundException('Question book not found');
        if (book.user_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized');
        return this.prisma.userQuestionBookItem.delete({
            where: {
                book_id_question_id: {
                    book_id: bookId,
                    question_id: questionId,
                }
            },
        });
    }
};
exports.QuestionBooksService = QuestionBooksService;
exports.QuestionBooksService = QuestionBooksService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], QuestionBooksService);
//# sourceMappingURL=question-books.service.js.map