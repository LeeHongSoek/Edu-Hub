import { Controller, Post, Body, Get, Put, UseGuards, Request, UnauthorizedException, Param } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() loginDto: any) {
    const user = await this.authService.validateUser(loginDto.userId, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('ID 또는 비밀번호가 올바르지 않습니다.');
    }
    return this.authService.login(user);
  }

  @Post('register')
  async register(@Body() registerDto: any) {
    return this.authService.register(registerDto);
  }

  @Get('check-id/:id')
  async checkId(@Param('id') id: string) {
    const isAvailable = await this.authService.isIdAvailable(id);
    return { isAvailable };
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    return req.user;
  }

  @UseGuards(JwtAuthGuard)
  @Put('profile')
  async updateProfile(@Request() req, @Body() body: { username?: string; password?: string }) {
    const userNo = BigInt(req.user.user_no);
    return this.authService.updateProfile(userNo, body);
  }
}
