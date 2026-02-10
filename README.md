# Virtual wardrobe and outfit generator

## Features/Highlights
- Add your clothes (shirts, shorts, pants, hoodies, etc.) with real-time inference on live video, detecting clothing objects on the screen. 
- Click on each clothing item as they are recognized to add them to your virtual closet/wardrobe. 
- An image of each clothing article is saved along with AI-generated attributes about the clothing item, and can later be modified by user. 
- The attributes (category, material, colors, fit, pattern, words, graphics, etc.) will then be used by a ML model to identify good outfits to wear. 
- Outfits can be generated for special occasions, on certain days, and weather-conscious decision making.
- Users can "like" outfits for human feedback reinforcement learning to help the model make future predictions.
- Click a button on an outfit indicating that you want to wear it and make any modifications you like.
- A history of the outfits worn are saved and can be viewed in a calendar panel along with usage statistics. 
- Outfits that were worn won't be suggested until a certain number of days (configured in user settings) have gone by.
- Notifications can be scheduled to send out outfit suggestions at a certain time, day of week, and occasion (ex. before bed, weeknights, for work).
- Opt into notifications for outfit suggestions on Holidays.
- Generated outfits can be displayed to the user using an AI image generation tool/model.
- The warbrode can be sorted by the user to their likings (category, color, etc.) making it easy to find and add particular clothes to an outfit.
- More to come!

## High-level Architecture

Mobile App (Flutter)
 ├── Camera / Video Capture
 ├── Frame Sampling (1–2 fps)
 ├── Upload Frames
 ├── Outfit Generator UI
 └── Calendar

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
 ├── Settings
 └── Outfit History

## Routes:
/ → Home
/capture
/wardrobe
/outfits
/item/:id


## Data Flow (End-to-End)
User opens camera
↓
CaptureController
↓
Backend ML
↓
UploadService
↓
WardrobeRepository
↓
WardrobeController
↓
UI updates

*No widget directly talks to APIs. Ever.*
