from fastapi import APIRouter, UploadFile, File

router = APIRouter()


@router.post("/frame", include_in_schema=False)
async def detect_frame(image: UploadFile = File(...)):
    # Stub: returns a single hardcoded detection centred in the frame.
    # Replace with real YOLO inference once the ML pipeline is ready.
    return {
        "detections": [
            {
                "id": "stub-1",
                "label": "T-Shirt",
                "confidence": 0.95,
                "bbox": {
                    "x": 0.5,
                    "y": 0.5,
                    "width": 0.3,
                    "height": 0.4,
                },
            }
        ]
    }
