from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from db.db import Base, engine
from dotenv import load_dotenv
from routes.security_routes import router as security_router
from models.security_event import SecurityEvent

app = FastAPI(title="AI Security Service")

load_dotenv()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(security_router)

Base.metadata.create_all(bind=engine)

