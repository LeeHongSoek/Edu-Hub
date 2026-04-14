from duckduckgo_search import DDGS

try:
    results = DDGS().chat("안녕? 넌 누구야?", model='gpt-4o-mini')
    print("SUCCESS:", results)
except Exception as e:
    print("ERROR:", e)
