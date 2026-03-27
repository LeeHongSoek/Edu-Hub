import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../common/prisma/prisma.service';
export declare class AuthService {
    private prisma;
    private jwtService;
    constructor(prisma: PrismaService, jwtService: JwtService);
    validateUser(userId: string, pass: string): Promise<any>;
    login(user: any): Promise<{
        access_token: string;
        user: {
            user_no: any;
            userId: any;
            username: any;
            email: any;
            role: any;
        };
    }>;
    register(userData: any): Promise<{
        role_id: string;
        created_at: Date | null;
        user_no: bigint;
        user_id: string;
        username: string;
        email: string;
        is_withdrawn: import("@prisma/client").$Enums.IsWithdrawn | null;
    }>;
    isIdAvailable(userId: string): Promise<boolean>;
    updateProfile(userNo: bigint, updateData: {
        username?: string;
        password?: string;
    }): Promise<{
        user: {
            user_no: string;
            userId: string;
            username: string;
            role: string;
            email: string;
        };
    } | null>;
}
