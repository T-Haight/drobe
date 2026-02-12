from __future__ import annotations

import asyncio
import logging
import uuid

from fastapi import APIRouter, File, HTTPException, UploadFile

from app.ml.yolo import YOLODetectionResult, run_inference
from app.models.schemas import BoundingBox, Detection, DetectionResponse

logger = logging.getLogger(__name__)

router = APIRouter()

# Typical mobile camera frames are 200–600 KB as JPEG; 10 MB is a safe ceiling.
_MAX_IMAGE_BYTES = 10 * 1024 * 1024


@router.post("/frame", response_model=DetectionResponse, include_in_schema=False)
async def detect_frame(image: UploadFile = File(...)) -> DetectionResponse:
    """Accept a JPEG frame and return YOLOv8 object detections.

    Errors:
        400 — empty upload, oversized upload, or corrupt image
        500 — unexpected inference failure
        503 — ultralytics ML package not installed
    """
    raw_bytes: bytes = await image.read()

    if len(raw_bytes) == 0:
        raise HTTPException(status_code=400, detail="Empty image upload")
    if len(raw_bytes) > _MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=400,
            detail=f"Image too large ({len(raw_bytes)} bytes; max {_MAX_IMAGE_BYTES})",
        )

    loop = asyncio.get_running_loop()
    try:
        raw: list[YOLODetectionResult] = await loop.run_in_executor(
            None,  # default ThreadPoolExecutor — does not block the event loop
            run_inference,
            raw_bytes,
        )
    except RuntimeError as exc:
        # ultralytics not installed
        logger.error("Model unavailable: %s", exc)
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except ValueError as exc:
        # PIL could not decode the uploaded bytes
        logger.warning("Bad image from client: %s", exc)
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        logger.exception("Inference error: %s", exc)
        raise HTTPException(status_code=500, detail="Inference failed") from exc

    return DetectionResponse(
        detections=[
            Detection(
                id=str(uuid.uuid4()),
                label=d.label,
                confidence=round(d.confidence, 4),
                bbox=BoundingBox(x=d.x, y=d.y, width=d.width, height=d.height),
            )
            for d in raw
        ]
    )
