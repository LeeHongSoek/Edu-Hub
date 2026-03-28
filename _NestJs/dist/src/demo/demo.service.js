"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DemoService = void 0;
const common_1 = require("@nestjs/common");
let DemoService = class DemoService {
    getStatus(query) {
        const samples = [
            { id: 1, title: '문제집 샘플 A', description: '기출 핵심 요약' },
            { id: 2, title: '문제집 샘플 B', description: '풀이 노트 포함' },
            { id: 3, title: '문제집 샘플 C', description: '노트와 정답 비법' },
        ];
        return {
            status: 'ok',
            message: 'Demo GET hit received.',
            query,
            serverTime: new Date().toISOString(),
            totalSamples: samples.length,
            samples,
        };
    }
    createAction(payload) {
        return {
            status: 'created',
            message: 'Demo POST payload processed.',
            received: payload,
            processedAt: new Date().toISOString(),
        };
    }
};
exports.DemoService = DemoService;
exports.DemoService = DemoService = __decorate([
    (0, common_1.Injectable)()
], DemoService);
//# sourceMappingURL=demo.service.js.map