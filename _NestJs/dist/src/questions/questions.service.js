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
exports.QuestionsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let QuestionsService = class QuestionsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(creator_no, group_id) {
        const where = {};
        if (creator_no !== undefined)
            where.creator_no = creator_no;
        if (group_id !== undefined)
            where.group_id = group_id;
        return this.prisma.question.findMany({
            where,
            include: {
                type: true,
                passage: true,
                options: {
                    orderBy: {
                        option_number: 'asc',
                    },
                },
                group: {
                    include: {
                        parent_group: {
                            include: {
                                parent_group: true,
                            },
                        },
                    },
                },
                tags: {
                    include: {
                        tag: true,
                    },
                },
            },
        });
    }
    async create(data) {
        const { options, ...questionData } = data;
        return this.prisma.$transaction(async (tx) => {
            const question = await tx.question.create({
                data: {
                    ...questionData,
                    passage: questionData.passage ? {
                        create: {
                            content_md: questionData.passage
                        }
                    } : undefined,
                    options: options ? {
                        create: options.map((opt) => ({
                            option_number: opt.option_number,
                            content: opt.content,
                            is_answer: opt.is_answer,
                        })),
                    } : undefined,
                },
                include: { options: true, passage: true },
            });
            return question;
        });
    }
    async update(id, data) {
        const { options, passage, ...questionData } = data;
        const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);
        return this.prisma.$transaction(async (tx) => {
            if (options) {
                await tx.questionOption.deleteMany({
                    where: { question_id: questionId },
                });
            }
            if (passage !== undefined) {
                if (passage) {
                    await tx.questionPassage.upsert({
                        where: { question_id: questionId },
                        update: { content_md: passage },
                        create: { question_id: questionId, content_md: passage }
                    });
                }
                else {
                    await tx.questionPassage.deleteMany({
                        where: { question_id: questionId }
                    });
                }
            }
            return tx.question.update({
                where: { question_id: questionId },
                data: {
                    ...questionData,
                    options: options ? {
                        create: options.map((opt) => ({
                            option_number: opt.option_number,
                            content: opt.content,
                            is_answer: opt.is_answer,
                        })),
                    } : undefined,
                },
                include: { options: true, passage: true },
            });
        });
    }
    async remove(id) {
        const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);
        return this.prisma.question.delete({
            where: { question_id: questionId },
        });
    }
    async getReviews(questionId) {
        const qid = typeof questionId === 'string' ? BigInt(questionId) : BigInt(questionId);
        return this.prisma.questionReview.findMany({
            where: { question_id: qid },
            include: {
                user: { select: { username: true } },
            },
            orderBy: { review_id: 'desc' },
        });
    }
    async addReview(questionId, data) {
        const qid = typeof questionId === 'string' ? BigInt(questionId) : BigInt(questionId);
        return this.prisma.$transaction(async (tx) => {
            const review = await tx.questionReview.create({
                data: {
                    question_id: qid,
                    user_no: data.user_no || 2,
                    content: data.content,
                    rating: data.rating,
                },
            });
            const aggregations = await tx.questionReview.aggregate({
                where: { question_id: qid },
                _avg: { rating: true },
            });
            const avgRating = Math.round(aggregations._avg.rating || 0);
            await tx.question.update({
                where: { question_id: qid },
                data: { rating: avgRating },
            });
            return review;
        });
    }
};
exports.QuestionsService = QuestionsService;
exports.QuestionsService = QuestionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], QuestionsService);
//# sourceMappingURL=questions.service.js.map