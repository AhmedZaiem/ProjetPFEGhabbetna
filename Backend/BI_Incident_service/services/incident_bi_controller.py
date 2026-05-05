from sqlalchemy.orm import Session
from sqlalchemy import func
from db.database import SessionLocal
from models.incident import Incident
import httpx

ADMIN_SERVICE_URL = "http://localhost:8002"


class IncidentBIController:

    # Incidents over time
    @staticmethod
    def incidents_over_time():
        db: Session = SessionLocal()

        data = db.query(
            func.date(Incident.created_at),
            func.count(Incident.id)
        ).group_by(func.date(Incident.created_at)).all()

        db.close()

        return [
            {"date": str(d[0]), "count": d[1]}
            for d in data
        ]


    # Incidents by status
    @staticmethod
    def incidents_by_status():
        db: Session = SessionLocal()

        data = db.query(
            Incident.status,
            func.count(Incident.id)
        ).group_by(Incident.status).all()

        db.close()

        return [
            {"status": str(d[0]), "count": d[1]}
            for d in data
        ]


    # 📊 Incidents by region
    @staticmethod
    def incidents_by_region():
        db: Session = SessionLocal()

        data = db.query(
            Incident.region,
            func.count(Incident.id)
        ).group_by(Incident.region).all()

        db.close()

        return [
            {"region": d[0], "count": d[1]}
            for d in data
        ]


    # TOP 3 FORESTS
    @staticmethod
    def top_forests_by_incidents():
        db: Session = SessionLocal()

        data = db.query(
            Incident.forest_id,
            func.count(Incident.id).label("count")
        ).group_by(
            Incident.forest_id
        ).order_by(
            func.count(Incident.id).desc()
        ).limit(3).all()

        db.close()

        result = []

        for d in data:
            forest_id = d[0]
            count = d[1]

            try:
                response = httpx.get(f"{ADMIN_SERVICE_URL}/forest/{forest_id}")

                if response.status_code == 200:
                    forest = response.json()
                    name = forest.get("name", "Unknown")
                else:
                    name = "Unknown"

            except Exception:
                name = "Unknown"

            result.append({
                "forest_id": forest_id,
                "forest_name": name,
                "count": count
            })

        return result


    # TOP 3 AGENTS
    @staticmethod
    def top_agents_by_incidents():
        db: Session = SessionLocal()

        data = db.query(
            Incident.user_id,
            func.count(Incident.id).label("count")
        ).group_by(
            Incident.user_id
        ).order_by(
            func.count(Incident.id).desc()
        ).limit(3).all()

        db.close()

        return [
            {
                "user_id": d[0],
                "count": d[1]
            }
            for d in data if d[0] is not None
        ]