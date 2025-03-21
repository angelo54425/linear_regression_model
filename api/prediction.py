import numpy as np
import pandas as pd
import joblib
import uvicorn
from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from persisted_model import load_model, load_preprocessor

# 1. FastAPI App Setup
 # Initialize FastAPI app with metadata
app = FastAPI(
    title="Laptop Price Prediction API",
    description="API for predicting laptop prices based on specifications using a trained Random Forest model."
)

 # Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# 2. Define the Input Data Structure using Pydantic
class LaptopFeatures(BaseModel):
    """
    Input data for predicting laptop prices.
    
    """
    Manufacturer: str = Field(..., description="Brand of the laptop")
    Screen: str = Field(..., description="Type of screen used in the laptop")
    Screen_Size_cm: float = Field(..., description="Size of the screen in centimeters", ge=10, le=50)
    CPU_frequency: float = Field(..., description="Processor speed in GHz", ge=1.0, le=5.0)
    RAM_GB: float = Field(..., description="Amount of RAM in GB", ge=2, le=128)
    Storage_GB_SSD: float = Field(..., description="Storage capacity in GB", ge=128, le=8192)
    Weight_kg: float = Field(..., description="Weight of the laptop in kilograms", ge=0.5, le=5.0)

# 3. Load the Trained Model & Preprocessor
model = load_model()
preprocessor = load_preprocessor()

# 4. Prediction Endpoint
@app.post("/predict")
def predict_price(features: LaptopFeatures):
    try:
        # Convert input to DataFrame
        input_data = pd.DataFrame([features.dict()])
        input_transformed = preprocessor.transform(input_data)
        
        # Make prediction
        prediction = model.predict(input_transformed)
        return {"Predicted Price": prediction[0]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# 5. Run the API
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)