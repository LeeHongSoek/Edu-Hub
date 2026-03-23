import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  // 최상위 그룹(depth 1)을 기준으로 하위 그룹들을 포함하여 조회
  async findAll() {
    return this.prisma.group.findMany({
      where: {
        parent_group_id: null,
      },
      include: {
        child_groups: {
          include: {
            child_groups: true, // 3단계까지 포함
          },
        },
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

  // 그룹 생성
  async create(data: any) {
    return this.prisma.group.create({
      data: {
        ...data,
        depth: data.depth || 1,
      },
    });
  }

  // 그룹 수정
  async update(id: string | number, data: any) {
    const groupId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.group.update({
      where: { group_id: groupId },
      data,
    });
  }

  // 그룹 삭제
  async remove(id: string | number) {
    const groupId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.group.delete({
      where: { group_id: groupId },
    });
  }
}
