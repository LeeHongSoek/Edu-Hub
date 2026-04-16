from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
# 변경된 라이브러리 임포트
from google import genai 
from openai import OpenAI
from anthropic import Anthropic  # 상단으로 이동

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("서버 준비 완료! (Universal API 모드 - 프론트엔드 키 사용)")

class Query(BaseModel):
    prompt: str
    model: str
    provider: str
    api_key: str

@app.post("/py/ask")
async def ask(query: Query):
    api_key = query.api_key.strip()
    if not api_key:
        return {"answer": "화면 우측 상단에서 API 키를 입력해 주세요."}
        
    try:
        # 1. Google Gemini (신규 SDK 적용)
        if query.provider == "google":
            client = genai.Client(api_key=api_key)
            # 신규 SDK는 모델명과 내용을 인자로 명확히 전달합니다.
            response = client.models.generate_content(
                model=query.model,
                contents=query.prompt
            )
            return {"answer": response.text}
            
        # 2. Anthropic
        elif query.provider == "anthropic":
            client = Anthropic(api_key=api_key)
            response = client.messages.create(
                model=query.model,
                max_tokens=1000,
                messages=[{"role": "user", "content": query.prompt}]
            )
            return {"answer": response.content[0].text}
            
        # 3. OpenAI 및 호환 API들
        else:
            base_urls = {
                "openai": None,
                "xai": "https://api.x.ai/v1",
                "groq": "https://api.groq.com/openai/v1",
                "deepseek": "https://api.deepseek.com",
                "together": "https://api.together.xyz/v1",
                "upstage": "https://api.upstage.ai/v1/solar"
            }
            
            if query.provider not in base_urls:
                return {"answer": "지원하지 않는 제공자(Provider)입니다."}
                
            client_args = {"api_key": api_key}
            if base_urls[query.provider]:
                client_args["base_url"] = base_urls[query.provider]
                
            client = OpenAI(**client_args)
            
            response = client.chat.completions.create(
                model=query.model,
                messages=[{"role": "user", "content": query.prompt}],
                temperature=0.7,
                max_tokens=1000
            )
            return {"answer": response.choices[0].message.content}
            
    except Exception as e:
        # 에러 메시지를 좀 더 명확하게 찍어주면 디버깅이 편합니다.
        print(f"Error details: {e}")
        return {"answer": f"API 호출 중 오류가 발생했습니다: {str(e)}"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3500)