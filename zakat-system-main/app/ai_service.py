import os

from dotenv import load_dotenv
from groq import Groq

load_dotenv()

api_key = os.getenv("GROQ_API_KEY")

if not api_key:
    raise ValueError("مفتاح GROQ_API_KEY غير موجود داخل ملف .env")

client = Groq(api_key=api_key)


def ask_ai(question: str) -> str:
    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {
                "role": "system",
                "content": (
                    "أنت مساعد ذكي متخصص في الزكاة داخل منصة سعودية. "
                    "أجب باللغة العربية فقط وبأسلوب واضح ومختصر. "
                    "إذا كان السؤال يحتاج فتوى شرعية خاصة أو حكمًا غير مؤكد، "
                    "اذكر أن المرجع النهائي هو هيئة الزكاة والضريبة والجمارك "
                    "أو جهة شرعية مختصة. "
                    "لا تخترع أسعار الذهب أو الفضة."
                ),
            },
            {
                "role": "user",
                "content": question,
            },
        ],
        temperature=0.2,
        max_completion_tokens=500,
    )

    answer = response.choices[0].message.content

    if not answer:
        return "تعذر الحصول على إجابة من المساعد الذكي."

    return answer