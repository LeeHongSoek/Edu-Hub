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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.QuestionBooksController = void 0;
const common_1 = require("@nestjs/common");
const question_books_service_1 = require("./question-books.service");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let QuestionBooksController = class QuestionBooksController {
    questionBooksService;
    constructor(questionBooksService) {
        this.questionBooksService = questionBooksService;
    }
    async create(req, body) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.create(userNo, body);
    }
    async findMyBooks(req) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.findByUser(userNo);
    }
    async findOne(req, id) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.findById(BigInt(id), userNo);
    }
    async update(req, id, body) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.update(BigInt(id), userNo, body);
    }
    async remove(req, id) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.remove(BigInt(id), userNo);
    }
    async addItem(req, id, questionId) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.addItem(BigInt(id), userNo, BigInt(questionId));
    }
    async removeItem(req, id, qId) {
        const userNo = BigInt(req.user.user_no);
        return this.questionBooksService.removeItem(BigInt(id), userNo, BigInt(qId));
    }
};
exports.QuestionBooksController = QuestionBooksController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "create", null);
__decorate([
    (0, common_1.Get)('my'),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "findMyBooks", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)(':id/items'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)('question_id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "addItem", null);
__decorate([
    (0, common_1.Delete)(':id/items/:qId'),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Param)('qId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], QuestionBooksController.prototype, "removeItem", null);
exports.QuestionBooksController = QuestionBooksController = __decorate([
    (0, common_1.Controller)('question-books'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [question_books_service_1.QuestionBooksService])
], QuestionBooksController);
//# sourceMappingURL=question-books.controller.js.map