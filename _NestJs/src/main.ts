import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

// BigInt 타입을 JSON으로 직렬화할 때 문자열로 변환하는 설정
(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CORS 활성화
  app.enableCors();
  
  // 환경변수에서 포트를 가져오거나 기본값 4000 사용
  const port = process.env.PORT ?? 4000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
