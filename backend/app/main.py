from fastapi import FastAPI

from app.api import detect, wardrobe
from app.middleware.cors import add_cors_middleware
from app.middleware.error_handler import add_error_handlers

app = FastAPI(title="Drobe API", version="0.1.0")

add_cors_middleware(app)
add_error_handlers(app)

app.include_router(detect.router, prefix="/detect", tags=["detection"])
app.include_router(wardrobe.router, prefix="/wardrobe", tags=["wardrobe"])


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
