from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

_BACKEND_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(_BACKEND_DIR / ".env"),
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    database_url: str = "postgresql://drobe:drobe@localhost:5432/drobe"
    cors_origins: str = "http://localhost:8080,http://localhost:3000"
    storage_path: str = "./storage"

    # ML settings
    model_path: str = "deepfashion2_yolov8s-seg.pt"  # DeepFashion2: 13 clothing categories
    model_device: str = "auto"           # "auto" | "cpu" | "cuda" | "mps"
    confidence_threshold: float = 0.25
    iou_threshold: float = 0.45
    
    # Storage settings ("local" for dev, "s3" for production)
    storage_backend: str = "local"
    s3_bucket_name: str = ""
    aws_region: str = "us-east-1"

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]


settings = Settings()
