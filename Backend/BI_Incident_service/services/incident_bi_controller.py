from sqlalchemy.orm import Session
from sqlalchemy import func
from db.database import SessionLocal
from models.incident import Incident


class IncidentBIController:

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


