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
    async findAll() {
        return this.prisma.question.findMany({
            include: {
                type: true,
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
                    options: options ? {
                        create: options.map((opt) => ({
                            option_number: opt.option_number,
                            content: opt.content,
                            is_answer: opt.is_answer,
                        })),
                    } : undefined,
                },
                include: { options: true },
            });
            return question;
        });
    }
    async update(id, data) {
        const { options, ...questionData } = data;
        const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);
        return this.prisma.$transaction(async (tx) => {
            if (options) {
                await tx.questionOption.deleteMany({
                    where: { question_id: questionId },
                });
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
                include: { options: true },
            });
        });
    }
    async remove(id) {
        const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);
        return this.prisma.question.delete({
            where: { question_id: questionId },
        });
    }
};
exports.QuestionsService = QuestionsService;
exports.QuestionsService = QuestionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], QuestionsService);
//# sourceMappingURL=questions.service.js.map