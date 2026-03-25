import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../common/prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) { }

  async validateUser(userId: string, pass: string): Promise<any> {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
    });

    if (user && await bcrypt.compare(pass, user.user_pw)) {
      const { user_pw, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = {
      username: user.username,
      sub: user.user_no.toString(),
      role: user.role_id
    };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        user_no: user.user_no.toString(),
        userId: user.user_id,
        username: user.username,
        email: user.email,
        role: user.role_id
      }
    };
  }

  async register(userData: any) {
    const { userId, password, username, email, roleId } = userData;

    // 중복 확인
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [{ user_id: userId }, { email: email }],
      },
    });

    if (existingUser) {
      throw new UnauthorizedException('이미 존재하는 아이디 또는 이메일입니다.');
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await this.prisma.user.create({
      data: {
        user_id: userId,
        user_pw: hashedPassword,
        username,
        email,
        role_id: roleId || 'S', // 기본값 학생
      },
    });

    const { user_pw, ...result } = newUser;
    return result;
  }

  async isIdAvailable(userId: string): Promise<boolean> {
    const user = await this.prisma.user.findUnique({
      where: { user_id: userId },
    });
    return !user;
  }

  async updateProfile(userNo: bigint, updateData: { username?: string; password?: string }) {
    const data: any = {};
    if (updateData.username) {
      data.username = updateData.username;
    }
    if (updateData.password) {
      data.user_pw = await bcrypt.hash(updateData.password, 10);
    }

    if (Object.keys(data).length === 0) {
      return null;
    }

    const updatedUser = await this.prisma.user.update({
      where: { user_no: userNo },
      data,
    });

    return {
      user: {
        user_no: updatedUser.user_no.toString(),
        userId: updatedUser.user_id,
        username: updatedUser.username,
        role: updatedUser.role_id,
        email: updatedUser.email
      }
    };
  }
}
