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
exports.SolveResultsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let SolveResultsService = class SolveResultsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(userNo, questionId, correctAnswer, submittedAnswer, isCorrect, timeTaken) {
        return this.prisma.solveResult.create({
            data: {
                user_no: userNo,
                question_id: questionId,
                correct_answer: correctAnswer,
                submitted_answer: submittedAnswer,
                is_correct: isCorrect,
                time_taken: timeTaken,
                solved_at: new Date(),
            },
        });
    }
    async findByUser(userNo) {
        return this.prisma.solveResult.findMany({
            where: {
                user_no: userNo,
            },
            include: {
                question: true,
            },
            orderBy: {
                solved_at: 'desc',
            },
        });
    }
    async findByQuestion(questionId) {
        return this.prisma.solveResult.findMany({
            where: {
                question_id: questionId,
            },
            include: {
                user: true,
            },
            orderBy: {
                solved_at: 'desc',
            },
        });
    }
    async findOne(resultId) {
        return this.prisma.solveResult.findUnique({
            where: {
                result_id: resultId,
            },
            include: {
                question: true,
                user: true,
            },
        });
    }
    async getStatsByUser(userNo) {
        const results = await this.prisma.solveResult.findMany({
            where: {
                user_no: userNo,
            },
        });
        const totalCount = results.length;
        const correctCount = results.filter((r) => r.is_correct === 1).length;
        const wrongCount = results.filter((r) => r.is_correct === 0).length;
        const timeoutCount = results.filter((r) => r.is_correct === -1).length;
        const accuracyRate = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
        const totalTime = results.reduce((sum, r) => sum + r.time_taken, 0);
        return {
            totalCount,
            correctCount,
            wrongCount,
            timeoutCount,
            accuracyRate: Math.round(accuracyRate * 100) / 100,
            totalTime,
            averageTime: totalCount > 0 ? Math.round(totalTime / totalCount) : 0,
        };
    }
};
exports.SolveResultsService = SolveResultsService;
exports.SolveResultsService = SolveResultsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SolveResultsService);
//# sourceMappingURL=solve-results.service.js.map