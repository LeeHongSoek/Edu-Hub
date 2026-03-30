"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const path_1 = require("path");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const prisma_module_1 = require("./common/prisma/prisma.module");
const questions_module_1 = require("./questions/questions.module");
const groups_module_1 = require("./groups/groups.module");
const auth_module_1 = require("./auth/auth.module");
const stats_module_1 = require("./stats/stats.module");
const dashboard_module_1 = require("./dashboard/dashboard.module");
const ombudsman_module_1 = require("./ombudsman/ombudsman.module");
const study_logs_module_1 = require("./study-logs/study-logs.module");
const question_books_module_1 = require("./question-books/question-books.module");
const exams_module_1 = require("./exams/exams.module");
const solve_results_module_1 = require("./solve-results/solve-results.module");
const demo_module_1 = require("./demo/demo.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: [
                    process.env.ENV_FILE || (0, path_1.resolve)(process.cwd(), '..', 'config', 'runtime', 'primary.env'),
                    (0, path_1.resolve)(process.cwd(), '.env'),
                ],
            }),
            prisma_module_1.PrismaModule,
            questions_module_1.QuestionsModule,
            groups_module_1.GroupsModule,
            auth_module_1.AuthModule,
            stats_module_1.StatsModule,
            dashboard_module_1.DashboardModule,
            ombudsman_module_1.OmbudsmanModule,
            study_logs_module_1.StudyLogsModule,
            question_books_module_1.QuestionBooksModule,
            exams_module_1.ExamsModule,
            solve_results_module_1.SolveResultsModule,
            demo_module_1.DemoModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [app_service_1.AppService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map