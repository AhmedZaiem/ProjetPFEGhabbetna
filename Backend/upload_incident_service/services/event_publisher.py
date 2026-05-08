from core.redis import redis_client
import json

def publish_incident(event_type: str, incident_data: dict):
    redis_client.xadd(
        "incidents_stream",
        {
            "event_type": event_type,
            "data": json.dumps(incident_data,ensure_ascii=False)
        }
    )