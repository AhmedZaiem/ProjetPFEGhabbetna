from fastapi import FastAPI
from routes.auth import router as auth_router
from routes.user_routes import router as user_router
from routes.forest_routes import router as forest_router
from routes.parcelle_routes import router as parcelle_router
from routes.service_routes import router as service_router
from fastapi.middleware.cors import CORSMiddleware
from db.database import Base, engine
from dotenv import load_dotenv
from services.init_admin import init_admin

app = FastAPI(title="Professional FastAPI Auth")

load_dotenv()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup():
    init_admin()

Base.metadata.create_all(bind=engine)

app.include_router(auth_router)
app.include_router(user_router)
app.include_router(forest_router)
app.include_router(parcelle_router)
app.include_router(service_router)