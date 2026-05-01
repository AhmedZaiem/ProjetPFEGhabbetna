from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from routes.incident_bi_router import router as incident_bi_router

load_dotenv()

app = FastAPI(title="BI Incident Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# BI routes
app.include_router(incident_bi_router)