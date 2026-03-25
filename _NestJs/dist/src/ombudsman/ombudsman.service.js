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
exports.OmbudsmanService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../common/prisma/prisma.service");
let OmbudsmanService = class OmbudsmanService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(userNo, data) {
        return this.prisma.ombudsmanReport.create({
            data: {
                user_no: userNo,
                category: data.category,
                title: data.title,
                content: data.content,
            },
        });
    }
    async findByUser(userNo) {
        return this.prisma.ombudsmanReport.findMany({
            where: { user_no: userNo },
            orderBy: { created_at: 'desc' },
        });
    }
    async update(reportId, userNo, data) {
        const report = await this.prisma.ombudsmanReport.findUnique({
            where: { report_id: reportId },
        });
        if (!report)
            throw new common_1.NotFoundException('Report not found');
        if (report.user_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized to update this report');
        return this.prisma.ombudsmanReport.update({
            where: { report_id: reportId },
            data: {
                category: data.category,
                title: data.title,
                content: data.content,
            },
        });
    }
    async remove(reportId, userNo) {
        const report = await this.prisma.ombudsmanReport.findUnique({
            where: { report_id: reportId },
        });
        if (!report)
            throw new common_1.NotFoundException('Report not found');
        if (report.user_no !== userNo)
            throw new common_1.ForbiddenException('Not authorized to delete this report');
        return this.prisma.ombudsmanReport.delete({
            where: { report_id: reportId },
        });
    }
};
exports.OmbudsmanService = OmbudsmanService;
exports.OmbudsmanService = OmbudsmanService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], OmbudsmanService);
//# sourceMappingURL=ombudsman.service.js.map