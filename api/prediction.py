import numpy as np
import pandas as pd
import joblib
import uvicorn
from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from persisted_model import load_model, load_preprocessor

# 1. FastAPI App Setup
app = FastAPI(
    title="Laptop Price Prediction API",
    description="API for predicting laptop prices based on specifications using a trained Random Forest model.",
    version="1.0.0",
    contact={
        "name": "Your Name",
        "email": "your.email@example.com",
    },
    license_info={
        "name": "MIT",
        "url": "https://opensource.org/licenses/MIT",
    }
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
    Manufacturer: str = Field(..., description="Brand of the laptop", example="Dell")
    Screen: str = Field(..., description="Type of screen used in the laptop", example="LED")
    Screen_Size_cm: float = Field(..., description="Size of the screen in centimeters", ge=10, le=50, example=39.6)
    CPU_frequency: float = Field(..., description="Processor speed in GHz", ge=1.0, le=5.0, example=2.5)
    RAM_GB: float = Field(..., description="Amount of RAM in GB", ge=2, le=128, example=16)
    Storage_GB_SSD: float = Field(..., description="Storage capacity in GB", ge=128, le=8192, example=512)
    Weight_kg: float = Field(..., description="Weight of the laptop in kilograms", ge=0.5, le=5.0, example=1.8)

    class Config:
        schema_extra = {
            "example": {
                "Manufacturer": "Apple",
                "Screen": "Retina",
                "Screen_Size_cm": 34.3,
                "CPU_frequency": 3.1,
                "RAM_GB": 16,
                "Storage_GB_SSD": 512,
                "Weight_kg": 1.5
            }
        }

# 3. Load the Trained Model & Preprocessor
model = load_model()
preprocessor = load_preprocessor()

# 4. Prediction Endpoint
@app.post("/predict", tags=["Prediction"], summary="Predict Laptop Price", responses={
    200: {"description": "Successful Prediction", "content": {"application/json": {"example": {"Predicted Price": 1200.50}}}},
    400: {"description": "Bad Request - Invalid Input"}
})
def predict_price(features: LaptopFeatures):
    """
    Predicts the price of a laptop based on its specifications.

    **Returns**:
    - A dictionary with the predicted price.
    """
    try:
        # Convert input to DataFrame
        input_data = pd.DataFrame([features.dict()])
        input_transformed = preprocessor.transform(input_data)
        
        # Make prediction
        prediction = model.predict(input_transformed)
        return {"Predicted Price": round(prediction[0], 2)}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# 5. Run the API
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
