from core.redis import redis_client
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import threading
from services.incident_bi_controller import IncidentBIController
from db.database import Base, engine, SessionLocal
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

@app.on_event("startup")
def startup():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    try:
        redis_client.xgroup_create(
            "incidents_stream",
            "bi_group",
            id="0",
            mkstream=True
        )
    except:
        pass
    threading.Thread(
        target=IncidentBIController.consume_incidents,
        daemon=True
    ).start()

# BI routes
app.include_router(incident_bi_router)