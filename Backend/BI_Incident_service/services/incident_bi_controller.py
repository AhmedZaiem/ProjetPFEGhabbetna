from sqlalchemy.orm import Session
from sqlalchemy import func
from db.database import SessionLocal
from models.incident import Incident
from core.redis import redis_client
import httpx
from datetime import datetime
import json


class IncidentBIController:

    @staticmethod
    def consume_incidents():
        while True:
            events = redis_client.xreadgroup(
                groupname="bi_group",
                consumername="bi_consumer_1",
                streams={"incidents_stream": ">"},
                count=10,
                block=5000
            )

            if not events:
                continue

            db = SessionLocal()

            try:
                message_ids = []
                for stream_name, messages in events:
                    for message_id, data in messages:
                        event_type = data["event_type"]
                        payload = json.loads(data["data"])

                        if event_type == "incident_created":
                            IncidentBIController.handle_created(db, payload)
                        elif event_type == "incident_updated":
                            IncidentBIController.handle_updated(db, payload)
                        message_ids.append(message_id)
                        
                       
                db.commit() 
                for msg_id in message_ids:
                    redis_client.xack("incidents_stream", "bi_group", msg_id)
            except Exception as e:
                db.rollback()
                print(f"Error processing events: {e}")
            finally:
                db.close()

    @staticmethod
    def handle_created(db, payload):
        bi_incident = Incident(
            incident_id=payload["id"],
            user_id=payload["user_id"],
            user_email=payload["user_email"],
            forest_id=payload["forest_id"],
            forest_name=payload["forest_name"],
            status=payload["status"],
            type=payload["type"],
            region=payload["region"],
            created_at=datetime.fromisoformat(payload["created_at"])
        )

        db.add(bi_incident)
    
    @staticmethod
    def handle_updated(db, payload):
        incident = db.query(Incident).filter(Incident.incident_id == payload["id"]).first()
        if incident:
            incident.status = payload["status"]
            incident.comment = payload["comment"]

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
            Incident.forest_name,
            func.count(Incident.id).label("count")
        ).group_by(
            Incident.forest_id,
            Incident.forest_name
        ).order_by(
            func.count(Incident.id).desc()
        ).limit(3).all()

        db.close()

        result = [
            {
                "forest_id": forest_id,
                "forest_name": forest_name,
                "count": count
            }
            for forest_id, forest_name, count in data if forest_id is not None
        ]

        

        return result


    # TOP 3 AGENTS
    @staticmethod
    def top_agents_by_incidents():
        db: Session = SessionLocal()

        data = db.query(
            Incident.user_id,
            Incident.user_email,
            func.count(Incident.id).label("count")
        ).group_by(
            Incident.user_id,
            Incident.user_email
        ).order_by(
            func.count(Incident.id).desc()
        ).limit(3).all()

        db.close()

        return [
            {
                "user_id": d[0],
                "count": d[2],
                "user_email": d[1]
            }
            for d in data if d[0] is not None
        ]