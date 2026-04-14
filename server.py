from fastapi import FastAPI 
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
from openai import OpenAI

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
    if not query.api_key.strip():
        return {"answer": "화면 우측 상단에서 API 키를 입력해 주세요."}
        
    try:
        if query.provider == "google":
            import google.generativeai as genai
            genai.configure(api_key=query.api_key.strip())
            model = genai.GenerativeModel(query.model)
            response = model.generate_content(query.prompt)
            return {"answer": response.text}
            
        elif query.provider == "anthropic":
            from anthropic import Anthropic
            client = Anthropic(api_key=query.api_key.strip())
            response = client.messages.create(
                model=query.model,
                max_tokens=1000,
                messages=[{"role": "user", "content": query.prompt}]
            )
            return {"answer": response.content[0].text}
            
        else:
            # 나머지 최신 AI 기업들은 대부분 OpenAI 규격을 똑같이 지원합니다!
            from openai import OpenAI
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
                
            client_args = {"api_key": query.api_key.strip()}
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
        return {"answer": f"API 호출 중 오류가 발생했습니다: {str(e)}"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3500)
