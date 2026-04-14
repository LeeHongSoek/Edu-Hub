import google.generativeai as genai
import sys
import os

genai.configure(api_key=os.environ.get('GEMINI_API_KEY', 'AIzaSyC7IeXFQqOTglxGG9CbSr8OnLRwBldJnSo'))

models_to_test = [
    'gemini-1.5-flash', 
    'gemini-1.5-flash-8b', 
    'gemini-1.0-pro', 
    'gemini-2.0-flash', 
    'models/gemini-1.5-flash'
]

for model_name in models_to_test:
    try:
        model = genai.GenerativeModel(model_name)
        res = model.generate_content("안녕")
        print(f"SUCCESS: {model_name} -> {res.text[:20]}")
    except Exception as e:
        err_msg = str(e)
        if "Quota" in err_msg or "429" in err_msg:
            print(f"RATE_LIMIT: {model_name}")
        elif "404" in err_msg:
             print(f"NOT_FOUND: {model_name}")
        else:
            print(f"ERROR: {model_name} -> {err_msg[:50]}")

