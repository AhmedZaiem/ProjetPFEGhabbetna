from fastapi import FastAPI
from routes.auth import router as auth_router
from fastapi.middleware.cors import CORSMiddleware
from db.database import Base, engine
from dotenv import load_dotenv

app = FastAPI(title="Professional FastAPI Auth")

load_dotenv()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)


app.include_router(auth_router)