## High-level Architecture

Mobile App (Flutter)
 ├── Camera / Video Capture
 ├── Frame Sampling (1–2 fps)
 ├── Upload Frames
 └── Outfit Generator UI

Backend (FastAPI)
 ├── Object Detection (YOLO)
 ├── Attribute Classification
 ├── Deduplication Logic
 ├── Outfit Scoring Engine
 └── API

Database
 ├── Clothing Items
 ├── Attributes
 ├── Image References
 └── Outfit History

## Routes:
/ → Home
/capture
/wardrobe
/outfits
/item/:id


## Data Flow (End-to-End)
User records video
↓
CaptureController
↓
UploadService
↓
Backend ML
↓
WardrobeRepository
↓
WardrobeController
↓
UI updates

*No widget directly talks to APIs. Ever.*
