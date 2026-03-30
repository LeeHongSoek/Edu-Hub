import { Injectable } from '@nestjs/common';

type DemoQuery = {
  id?: string;
  type?: string;
};

type DemoPostBody = {
  userId?: number;
  action?: string;
  timestamp?: string;
};

@Injectable()
export class DemoService {
  getStatus(query: DemoQuery) {
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

  createAction(payload: DemoPostBody) {
    return {
      status: 'created',
      message: 'Demo POST payload processed.',
      received: payload,
      processedAt: new Date().toISOString(),
    };
  }
}
