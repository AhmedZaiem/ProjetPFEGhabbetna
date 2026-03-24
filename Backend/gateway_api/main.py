from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.auth import router as auth_router
from routes.incidentUpload import router as incident_router
from routes.forest import router as forest_router
from routes.parcelle import router as parcelle_router
from routes.service import router as service_router

app = FastAPI(title="Gateway API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/auth")
app.include_router(incident_router, prefix="/incidents")
app.include_router(forest_router, prefix="/forest")
app.include_router(parcelle_router, prefix="/parcelles")
app.include_router(service_router, prefix="/services")
