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
exports.DemoController = void 0;
const common_1 = require("@nestjs/common");
const demo_service_1 = require("./demo.service");
let DemoController = class DemoController {
    demoService;
    constructor(demoService) {
        this.demoService = demoService;
    }
    getDemo(id, type) {
        return this.demoService.getStatus({ id, type });
    }
    postDemo(userId, action, timestamp) {
        return this.demoService.createAction({ userId, action, timestamp });
    }
};
exports.DemoController = DemoController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('id')),
    __param(1, (0, common_1.Query)('type')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], DemoController.prototype, "getDemo", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)('userId')),
    __param(1, (0, common_1.Body)('action')),
    __param(2, (0, common_1.Body)('timestamp')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, String, String]),
    __metadata("design:returntype", void 0)
], DemoController.prototype, "postDemo", null);
exports.DemoController = DemoController = __decorate([
    (0, common_1.Controller)('api/demo'),
    __metadata("design:paramtypes", [demo_service_1.DemoService])
], DemoController);
//# sourceMappingURL=demo.controller.js.map