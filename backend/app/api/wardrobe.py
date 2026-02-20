from __future__ import annotations

import json
import uuid

from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.db.models import ClothingItem
from app.models.schemas import BoundingBox, WardrobeItemResponse
from app.services.image_crop import crop_detection
from app.services.storage import get_storage_service

router = APIRouter()


@router.post("/items", response_model=WardrobeItemResponse, include_in_schema=False)
async def create_wardrobe_item(
    image: UploadFile = File(...),
    bbox: str = Form(...),
    label: str = Form(...),
    db: Session = Depends(get_db),
) -> WardrobeItemResponse:
    item_id = uuid.uuid4()

    image_bytes = await image.read()

    bbox_data = json.loads(bbox)
    bounding_box = BoundingBox(**bbox_data)

    cropped_bytes = crop_detection(image_bytes, bounding_box)

    storage = get_storage_service()
    storage_key = f"wardrobe/{item_id}.jpg"
    image_url = storage.upload_image(cropped_bytes, storage_key)

    db_item = ClothingItem(
        id=item_id,
        label=label,
        image_path=image_url,
        bbox=bbox_data,
    )
    db.add(db_item)
    db.commit()

    return WardrobeItemResponse(
        id=str(item_id),
        label=label,
        image_url=image_url,
    )
