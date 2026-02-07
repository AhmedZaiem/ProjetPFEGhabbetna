"""
from core.redis import redis_client
from models.user import User

stream_name = "user.stream"

def publish_user_event(event: str,user: User):
    redis_client.xadd(
        stream_name, {
        "event": event,
        "user_id": str(user.id),
        "email": user.email}
    )
"""