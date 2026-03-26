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
exports.DashboardService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let DashboardService = class DashboardService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getStats(userNo, roleId) {
        let stats = {};
        if (roleId === 'S') {
            stats = await this.getStudentStats(userNo);
        }
        else if (roleId === 'T') {
            stats = await this.getTeacherStats(userNo);
        }
        else if (roleId === 'P') {
            stats = await this.getParentStats(userNo);
        }
        console.log('[여기:dashboard.service.ts] returning stats:', stats);
        return stats;
    }
    async getStudentStats(userNo) {
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
        const accuracy = recentSolvedCount > 0 ? Math.round((correctOnes / recentSolvedCount) * 100) : 0;
        const dailyStats = [];
        for (let i = 6; i >= 0; i--) {
            const d = new Date(now);
            d.setDate(d.getDate() - i);
            const dateStr = d.toISOString().split('T')[0];
            const count = solveResults.filter((r) => r.solved_at?.toISOString().split('T')[0] === dateStr).length;
            dailyStats.push({ date: dateStr, count });
        }
        return {
            totalViewed: await this.prisma.studyLog.count({
                where: {
                    user_no: userNo,
                    user_memo: '문제보기',
                },
            }),
            totalSolved: await this.prisma.studyLog.count({
                where: {
                    user_no: userNo,
                    user_memo: '문제풀기',
                },
            }),
            accuracy,
            dailyStats,
            studyLogs: await this.prisma.studyLog.count({
                where: {
                    user_no: userNo,
                    is_correct: false,
                },
            }),
        };
    }
    async getTeacherStats(userNo) {
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
    async getParentStats(userNo) {
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
    async getRelations(userNo) {
        return this.prisma.userRelation.findMany({
            where: { user_no_1: userNo },
            include: {
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
        });
    }
    async getMessages(userNo) {
        return this.prisma.userMessage.findMany({
            where: {
                OR: [{ sender_no: userNo }, { receiver_no: userNo }],
            },
            include: {
                sender: { select: { username: true } },
                receiver: { select: { username: true } },
            },
            orderBy: { created_at: 'desc' },
        });
    }
};
exports.DashboardService = DashboardService;
exports.DashboardService = DashboardService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], DashboardService);
//# sourceMappingURL=dashboard.service.js.map