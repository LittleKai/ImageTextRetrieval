# Image Text Retrieval
![Demo Image 1](Demo/1.png)

An image search application based on textual features input by users through the UI.

Users can zlter the JSON information stored in the database, which was previously automatically extracted from images through Object Detection, OCR, ASR, and CLIP.

The information includes audio information, text, people, objects, location, and imagedescriptions.

** Note: This project is still under development.

# Features:

Image Text Retrieval System:

- Utilizes CLIP (Contrastive Language-Image Pre-training) model for image-text matching. 
- Implements a Flask backend deployed on Google Colab. 
- Integrates with a Flutter frontend for user interaction. 
- Implements a Flask backend deployed on Google Colab.

Search Functionality: 

- Text-based image search using natural language queries
- Supports multiple search types: Clip, Sketch, and All
- Translates Vietnamese queries to English for broader search capabilities
- Filtering Options: Users can use OCR, ASR, or Tag information to filter the JSON information previously extracted from images and stored in the Database.

Filtering Options:
- Gender-based filtering (Female, Male, Both) with numerical inputs.
- OCR (Optical Character Recognition) text filtering.
- ASR (Automatic Speech Recognition) text filtering.
- TAG text filtering.
- 
Backend Features: 

- FAISS (Facebook AI Similarity Search) for efficient similarity search.
- Pre-computed image embeddings for fast retrieval

Frontend Features: 
- Responsive design using Flutter with cross-platform compatibility (iOS, Android, PC, Web)

# Future plans: 
With a larger dataset, data will be stored in MongoDB and support queries through ElasticSearch. Additional models and features will be incorporated to improve search accuracy. 



