import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../common/prisma/prisma.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

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
        userId: user.user_id,
        username: user.username,
        role: user.role_id
      }
    };
  }
}
