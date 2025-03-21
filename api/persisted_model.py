import pandas as pd
import joblib
import os
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer

# Define file paths
model_path = "random_forest_model.pkl"
preprocessor_path = "preprocessor.pkl"
file_path = "laptop_pricing_dataset.csv"

def train_and_save_model():
    # Load dataset
    df = pd.read_csv(file_path)
    df.drop(columns=["Unnamed: 0"], inplace=True)
    
    # Define features and target
    categorical_cols = ["Manufacturer", "Screen"]
    numerical_cols = ["Screen_Size_cm", "CPU_frequency", "RAM_GB", "Storage_GB_SSD", "Weight_kg"]
    target_column = "Price"
    
    X = df.drop(columns=[target_column])
    y = df[target_column]
    
    # Split dataset
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Data Preprocessing
    preprocessor = ColumnTransformer([
        ("num", Pipeline([
            ("imputer", SimpleImputer(strategy="mean")),
            ("scaler", StandardScaler())
        ]), numerical_cols),
        
        ("cat", OneHotEncoder(handle_unknown="ignore"), categorical_cols)
    ])
    
    X_train_transformed = preprocessor.fit_transform(X_train)
    
    # Initialize and train Random Forest model
    model = RandomForestRegressor(n_estimators=100, max_depth=None, min_samples_split=2, min_samples_leaf=1, random_state=42)
    model.fit(X_train_transformed, y_train)
    
    # Save model and preprocessor
    joblib.dump(model, model_path)
    joblib.dump(preprocessor, preprocessor_path)

def load_model():
    if not os.path.exists(model_path):
        train_and_save_model()
    return joblib.load(model_path)

def load_preprocessor():
    if not os.path.exists(preprocessor_path):
        train_and_save_model()
    return joblib.load(preprocessor_path)

# Train and save the model if it doesn't exist
if not os.path.exists(model_path) or not os.path.exists(preprocessor_path):
    train_and_save_model()