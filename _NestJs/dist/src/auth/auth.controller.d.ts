import { AuthService } from './auth.service';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    login(loginDto: any): Promise<{
        access_token: string;
        user: {
            user_no: any;
            userId: any;
            username: any;
            email: any;
            role: any;
        };
    }>;
    register(registerDto: any): Promise<{
        role_id: string;
        created_at: Date | null;
        user_no: bigint;
        user_id: string;
        username: string;
        email: string;
        is_withdrawn: import("@prisma/client").$Enums.IsWithdrawn | null;
    }>;
    checkId(id: string): Promise<{
        isAvailable: boolean;
    }>;
    getProfile(req: any): any;
    updateProfile(req: any, body: {
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
