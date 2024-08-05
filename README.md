# Image Text Retrieval

An image search application based on textual features input by users through the UI.

** Note: This project is still under development.

# Features:

Image Text Retrieval System:

 Utilizes CLIP (Contrastive Language-Image Pre-training) model for image-text matching. 
Implements a Flask backend deployed on Google Colab. 
Integrates with a Flutter frontend for user interaction. 
Implements a Flask backend deployed on Google Colab.
Search Functionality: 

Text-based image search using natural language queries
Supports multiple search types: Clip, Sketch, and All
Translates Vietnamese queries to English for broader search capabilities
Filtering Options: Users can use OCR, ASR, or Tag information to filter the JSON information previously extracted from images and stored in the Database.

Gender-based filtering (Female, Male, Both) with numerical inputs.
OCR (Optical Character Recognition) text filtering.
ASR (Automatic Speech Recognition) text filtering.
Backend Features: 

FAISS (Facebook AI Similarity Search) for efficient similarity search.
Pre-computed image embeddings for fast retrieval
Frontend Features: 

Responsive design using Flutter with cross-platform compatibility (iOS, Android, PC, Web)

# Future plans: With a larger dataset, data will be stored in MongoDB and support queries through ElasticSearch. Additional models and features will be incorporated to improve search accuracy. 

# Demo Images of the Application

![Demo Image 1](Demo/1.png)


