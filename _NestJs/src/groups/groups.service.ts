import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.group.findMany({
      include: {
        child_groups: {
          include: {
            child_groups: true,
          },
        },
      },
      where: {
        parent_group_id: null,
      },
    });
  }

  async getHierarchy() {
    // This simple findMany handles 3 levels. For deeper levels, recursive logic or a specialized query would be better.
    // However, given the requirement, 3 levels usually suffice for standard organization.
    return this.prisma.group.findMany({
      where: {
        parent_group_id: null,
      },
      include: {
        child_groups: {
          include: {
            child_groups: true,
          },
        },
      },
    });
  }
}
