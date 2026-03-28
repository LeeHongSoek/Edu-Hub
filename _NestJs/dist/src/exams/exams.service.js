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
exports.ExamsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let ExamsService = class ExamsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll(userNo) {
        return this.prisma.exam.findMany({
            where: userNo ? { creator_no: userNo } : {},
            include: {
                creator: { select: { username: true } },
                class: true,
                _count: { select: { questions: true } }
            },
            orderBy: { created_at: 'desc' },
        });
    }
    async findById(examId, userNo) {
        const exam = await this.prisma.exam.findUnique({
            where: { exam_id: examId },
            include: {
                creator: { select: { username: true } },
                class: true,
                questions: {
                    include: {
                        question: true,
                    },
                    orderBy: {
                        question_order: 'asc',
                    },
                },
            },
        });
        if (!exam)
            throw new common_1.NotFoundException('Exam not found');
        if (userNo !== undefined && exam.creator_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized');
        return exam;
    }
};
exports.ExamsService = ExamsService;
exports.ExamsService = ExamsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ExamsService);
//# sourceMappingURL=exams.service.js.map