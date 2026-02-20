from __future__ import annotations

import os
from abc import ABC, abstractmethod

import boto3

from app.config.settings import settings


class StorageService(ABC):
    @abstractmethod
    def upload_image(self, image_bytes: bytes, key: str) -> str:
        """Upload image bytes and return the stored URL/path."""

    @abstractmethod
    def delete_image(self, key: str) -> None:
        """Delete an image by key."""


class LocalStorageService(StorageService):
    def __init__(self, base_path: str = settings.storage_path):
        self._base_path = base_path

    def upload_image(self, image_bytes: bytes, key: str) -> str:
        file_path = os.path.join(self._base_path, key)
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, "wb") as f:
            f.write(image_bytes)
        return file_path

    def delete_image(self, key: str) -> None:
        file_path = os.path.join(self._base_path, key)
        if os.path.exists(file_path):
            os.remove(file_path)


class S3StorageService(StorageService):
    def __init__(
        self,
        bucket: str = settings.s3_bucket_name,
        region: str = settings.aws_region,
    ):
        self._bucket = bucket
        self._s3 = boto3.client("s3", region_name=region)

    def upload_image(self, image_bytes: bytes, key: str) -> str:
        self._s3.put_object(
            Bucket=self._bucket,
            Key=key,
            Body=image_bytes,
            ContentType="image/jpeg",
        )
        return f"s3://{self._bucket}/{key}"

    def delete_image(self, key: str) -> None:
        self._s3.delete_object(Bucket=self._bucket, Key=key)


def get_storage_service() -> StorageService:
    if settings.storage_backend == "s3":
        return S3StorageService()
    return LocalStorageService()
