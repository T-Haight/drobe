"""YOLOv8 inference wrapper — singleton model, thread-pool-safe blocking call.

Design notes:
- Model is loaded once per process via functools.lru_cache(maxsize=1).
- Inference is blocking (PyTorch); callers must use run_in_executor from async code.
- Device selection: explicit env var > CUDA > MPS (Apple Silicon) > CPU.
- ultralytics is imported lazily so the module loads cleanly even when the
  package is absent; a RuntimeError is raised on first use (→ 503 response).
"""
from __future__ import annotations

import functools
import logging
from io import BytesIO

from PIL import Image

from app.config.settings import settings

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------


def _resolve_device(requested: str) -> str:
    """Return the device string to pass to YOLO.

    'auto' → try CUDA, then MPS, then CPU.
    Anything else is passed through verbatim (e.g. 'cpu', 'cuda:1').
    """
    if requested != "auto":
        return requested

    try:
        import torch

        if torch.cuda.is_available():
            logger.info("YOLOv8: using CUDA")
            return "cuda"
        if torch.backends.mps.is_available():
            logger.info("YOLOv8: using MPS (Apple Silicon)")
            return "mps"
    except ImportError:
        pass  # torch not installed; fall through to cpu

    logger.info("YOLOv8: using CPU")
    return "cpu"


@functools.lru_cache(maxsize=1)
def _load_model():
    """Load and return the YOLO model.  Called at most once per process.

    Raises RuntimeError if ultralytics is not installed.
    """
    try:
        from ultralytics import YOLO  # noqa: PLC0415
    except ImportError as exc:
        raise RuntimeError(
            "ultralytics is not installed. Run: pip install ultralytics==8.3.0"
        ) from exc

    device = _resolve_device(settings.model_device)
    logger.info(
        "Loading YOLO model '%s' on device '%s'",
        settings.model_path,
        device,
    )
    model = YOLO(settings.model_path)
    model.to(device)
    logger.info("YOLO model loaded successfully")
    return model


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------


class YOLODetectionResult:
    """Lightweight data container returned by run_inference.

    Kept separate from Pydantic schemas to decouple the ML layer from the
    web layer.
    """

    __slots__ = ("label", "confidence", "x", "y", "width", "height")

    def __init__(
        self,
        label: str,
        confidence: float,
        x: float,
        y: float,
        width: float,
        height: float,
    ) -> None:
        self.label = label
        self.confidence = confidence
        self.x = x
        self.y = y
        self.width = width
        self.height = height


def run_inference(image_bytes: bytes) -> list[YOLODetectionResult]:
    """Run synchronous YOLOv8 inference on raw image bytes.

    This function is intentionally blocking and must be called via
    asyncio.get_running_loop().run_in_executor() from async code.

    Args:
        image_bytes: Raw bytes of a JPEG (or any Pillow-readable) image.

    Returns:
        List of YOLODetectionResult.  Empty list if no detections.

    Raises:
        RuntimeError: ultralytics is not installed.
        ValueError: image_bytes cannot be decoded as an image.
    """
    # Decode image — raise ValueError for corrupt or wrong-format uploads
    try:
        image = Image.open(BytesIO(image_bytes)).convert("RGB")
    except Exception as exc:
        raise ValueError(f"Cannot decode image: {exc}") from exc

    model = _load_model()

    results = model.predict(
        source=image,
        conf=settings.confidence_threshold,
        iou=settings.iou_threshold,
        verbose=False,
    )

    detections: list[YOLODetectionResult] = []

    # results is a list with one entry per input image; we always send one image.
    if not results or results[0].boxes is None:
        return detections

    result = results[0]
    names: dict[int, str] = result.names  # {class_idx: "label", ...}

    for box in result.boxes:
        # box.xywhn → tensor [[x_centre, y_centre, w, h]] all normalised to [0,1]
        xywhn = box.xywhn[0].tolist()
        detections.append(
            YOLODetectionResult(
                label=names.get(int(box.cls[0]), str(int(box.cls[0]))),
                confidence=float(box.conf[0]),
                x=xywhn[0],
                y=xywhn[1],
                width=xywhn[2],
                height=xywhn[3],
            )
        )

    return detections
