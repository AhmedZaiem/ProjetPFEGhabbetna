from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from routes.auth import router as auth_router
from routes.incidentUpload import router as incident_router
from routes.forest import router as forest_router
from routes.parcelle import router as parcelle_router
from routes.service import router as service_router
from routes.BI_Incident import router as BI_Incident_router
from routes.ai_security import router as ai_router
from core.middleware import auth_middleware
import httpx
from fastapi.responses import StreamingResponse

app = FastAPI(title="Gateway API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# app.middleware("http")(auth_middleware)

# ✅ FIX: use project local folder instead of ASUS path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, "uploads")

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.get("/uploads/{path:path}")
async def proxy_uploads(path: str):
    # URL of your upload_incident microservice
    microservice_url = f"http://localhost:8003/uploads/{path}"

    async with httpx.AsyncClient() as client:
        response = await client.get(microservice_url)
        if response.status_code != 200:
            return {"error": "File not found"}, response.status_code

        # Stream the file back to the client
        return StreamingResponse(
            response.aiter_bytes(),
            media_type=response.headers.get("content-type")
        )

app.include_router(auth_router, prefix="/auth")
app.include_router(incident_router, prefix="/incidents")
app.include_router(forest_router, prefix="/forest")
app.include_router(parcelle_router, prefix="/parcelles")
app.include_router(service_router, prefix="/service")
app.include_router(BI_Incident_router, prefix="/bi_incidents")
app.include_router(ai_router, prefix="/security")