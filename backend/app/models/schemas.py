from __future__ import annotations

from pydantic import BaseModel, Field


class BoundingBox(BaseModel):
    """Normalised bounding box; x/y are the centre of the box (YOLO xywhn convention)."""

    x: float = Field(..., ge=0.0, le=1.0)
    y: float = Field(..., ge=0.0, le=1.0)
    width: float = Field(..., ge=0.0, le=1.0)
    height: float = Field(..., ge=0.0, le=1.0)


class Detection(BaseModel):
    id: str
    label: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    bbox: BoundingBox


class DetectionResponse(BaseModel):
    detections: list[Detection]
