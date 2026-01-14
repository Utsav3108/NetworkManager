Simple FastAPI Weather Server

Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Run

```bash
cd NetworkManager/fastapi_server
uvicorn main:app --reload --port 8000
```

Examples

```bash
# list all cities
curl http://127.0.0.1:8000/cities

# get a specific city (case-insensitive)
curl http://127.0.0.1:8000/cities/Tokyo
```
