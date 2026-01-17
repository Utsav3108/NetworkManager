from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import json
import asyncio

DATA_FILE = Path(__file__).parent / "data.json"

app = FastAPI(title="Simple Weather API")

security = HTTPBearer()

# Example hardcoded token for demonstration
AUTH_TOKEN = "mysecrettoken123"
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != AUTH_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid or missing token")
    return credentials.credentials

# Authenticated endpoint example
@app.get("/secure-cities")
def get_secure_data(token: str = Depends(verify_token)):
    """Return secure data, requires Bearer token authentication."""
    return load_data()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def add_delay_middleware(request, call_next):
    """Delay every incoming request by 5 seconds (useful for testing)."""
    print("Received request, adding delay...")
    #await asyncio.sleep(5)
    response = await call_next(request)
    return response


def load_data():
    with DATA_FILE.open("r", encoding="utf-8") as f:
        return json.load(f)


@app.get("/cities")
def list_cities():
    """Return all city weather records."""
    return load_data()


@app.get("/cities/{city_name}")
def get_city(city_name: str):
    """Return weather record for a single city (case-insensitive)."""
    data = load_data()
    for rec in data:
        if rec.get("city", "").lower() == city_name.lower():
            return rec
    raise HTTPException(status_code=404, detail="City not found")
