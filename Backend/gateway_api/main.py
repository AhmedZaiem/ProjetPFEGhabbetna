from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from routes.auth import router as auth_router
from routes.incidentUpload import router as incident_router
from routes.forest import router as forest_router
from routes.parcelle import router as parcelle_router
from routes.service import router as service_router
from core.middleware import auth_middleware

app = FastAPI(title="Gateway API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

#app.middleware("http")(auth_middleware)

UPLOAD_FOLDER="C:\\Users\\ASUS\\Desktop\\ProjetPFEGhabbetna\\Backend\\upload_incident_service\\uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

app.mount("/uploads", StaticFiles(directory=UPLOAD_FOLDER), name="uploads")

app.include_router(auth_router, prefix="/auth")
app.include_router(incident_router, prefix="/incidents")
app.include_router(forest_router, prefix="/forest")
app.include_router(parcelle_router, prefix="/parcelles")
app.include_router(service_router, prefix="/service")
