from fastapi import Request


def get_lang(request: Request) -> str:
    lang = request.headers.get("x-app-language", "")
    if lang in ("zh", "en"):
        return lang
    header = request.headers.get("accept-language", "zh")
    return "en" if header.lower().startswith("en") else "zh"


def pick(zh: str, en: str | None, lang: str) -> str:
    if lang == "en" and en:
        return en
    return zh
