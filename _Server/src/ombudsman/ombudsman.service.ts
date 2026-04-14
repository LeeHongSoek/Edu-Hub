import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class OmbudsmanService {
  constructor(private prisma: PrismaService) {}

  async create(userNo: bigint, data: any) {
    return this.prisma.ombudsmanReport.create({
      data: {
        user_no: userNo,
        category: data.category,
        title: data.title,
        content: data.content,
      },
    });
  }

  async findByUser(userNo: bigint) {
    return this.prisma.ombudsmanReport.findMany({
      where: { user_no: userNo },
      orderBy: { created_at: 'desc' },
    });
  }

  async update(reportId: bigint, userNo: bigint, data: any) {
    const report = await this.prisma.ombudsmanReport.findUnique({
      where: { report_id: reportId },
    });

    if (!report) throw new NotFoundException('Report not found');
    if (report.user_no !== userNo) throw new ForbiddenException('Not authorized to update this report');

    return this.prisma.ombudsmanReport.update({
      where: { report_id: reportId },
      data: {
        category: data.category,
        title: data.title,
        content: data.content,
      },
    });
  }

  async remove(reportId: bigint, userNo: bigint) {
    const report = await this.prisma.ombudsmanReport.findUnique({
      where: { report_id: reportId },
    });

    if (!report) throw new NotFoundException('Report not found');
    if (report.user_no !== userNo) throw new ForbiddenException('Not authorized to delete this report');

    return this.prisma.ombudsmanReport.delete({
      where: { report_id: reportId },
    });
  }
}
