from __future__ import annotations

import io

from PIL import Image

from app.models.schemas import BoundingBox


def crop_detection(
    image_bytes: bytes,
    bbox: BoundingBox,
    padding: float = 0.15,
) -> bytes:
    """Crop a detection region from an image with extra padding.

    Args:
        image_bytes: Raw JPEG bytes of the full frame.
        bbox: Normalised bounding box (centre x/y, width, height in 0-1 range).
        padding: Fraction of the bbox dimensions to add on each side.

    Returns:
        JPEG bytes of the cropped region.
    """
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img_w, img_h = img.size

    # Convert normalised centre-based bbox to pixel coordinates
    cx = bbox.x * img_w
    cy = bbox.y * img_h
    bw = bbox.width * img_w
    bh = bbox.height * img_h

    # Add padding
    pad_x = bw * padding
    pad_y = bh * padding

    left = max(0, cx - bw / 2 - pad_x)
    top = max(0, cy - bh / 2 - pad_y)
    right = min(img_w, cx + bw / 2 + pad_x)
    bottom = min(img_h, cy + bh / 2 + pad_y)

    cropped = img.crop((int(left), int(top), int(right), int(bottom)))

    buf = io.BytesIO()
    cropped.save(buf, format="JPEG", quality=90)
    return buf.getvalue()
