from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
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

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]


settings = Settings()
